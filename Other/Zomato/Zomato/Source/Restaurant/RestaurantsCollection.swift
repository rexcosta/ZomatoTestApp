//
// The MIT License (MIT)
//
// Copyright (c) 2021 David Costa Gonçalves
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import Foundation
import ZomatoFoundation

public final class RestaurantsCollection {
    
    private let restaurantManager: RestaurantManagerProtocol
    
    private let loadingState = Property<LoadingState>(.uninitialized)
    public var readOnlyLoadingState: ReadOnlyProperty<LoadingState> {
        return loadingState.readOnly
    }
    
    private let dataState = Property<DataState>(.uninitialized)
    public var readOnlyDataState: ReadOnlyProperty<DataState> {
        return dataState.readOnly
    }
    
    private var elements = [RestaurantModelProtocol]()
    private var filteredElements = [RestaurantModelProtocol]()
    private var currentPage: PageModel<RestaurantModelProtocol>?
    
    public private(set) var userLocation: CoordinateModel?
    
    private let sort = Property<Sort>(Sort.dontSort)
    public var readOnlySort: ReadOnlyProperty<Sort> {
        return sort.readOnly
    }
    
    private let filter = Property<RestaurantFilterModel?>(nil)
    public var readOnlyFilter: ReadOnlyProperty<RestaurantFilterModel?> {
        return filter.readOnly
    }
    
    public init(restaurantManager: RestaurantManagerProtocol) {
        self.restaurantManager = restaurantManager
    }
    
    public func set(filter: RestaurantFilterModel?) {
        set(sort: sort.value, filter: filter)
    }
    
    public func set(sort: Sort, filter: RestaurantFilterModel?) {
        guard let userLocation = userLocation else {
            Log.info("RestaurantsCollection", "Will not do anything because we dont have a location yet")
            return
        }
        
        // Because we changed sort, we need to request new data
        if self.sort.value != sort {
            Log.info("RestaurantsCollection", "Will apply sort \(sort)")
            self.sort.value = sort
            self.filter.value = filter
            refreshCollection(position: userLocation)
            return
        }
        
        switch (filter, self.filter.value) {
        case (.none, .none):
            // Nothing changed
            Log.info("RestaurantsCollection", "Filter didnt change both nil")
            
        case (.none, .some):
            // We have changes need to apply filter
            Log.info("RestaurantsCollection", "Need to remove filter")
            self.filter.value = nil
            applyFilter()
            
        case (.some(let newFilter), .none):
            // We have changes need to apply filter
            Log.info("RestaurantsCollection", "Need to add new filter")
            self.filter.value = newFilter
            applyFilter()
            
        case (.some(let newFilter), .some(let oldFilter)):
            if newFilter != oldFilter {
                // We have changes need to apply new filter
                Log.info("RestaurantsCollection", "Need to replace with new filter")
                self.filter.value = newFilter
                applyFilter()
            }
        }
    }
    
    public func refreshCollection() {
        if let userLocation = userLocation {
            refreshCollection(position: userLocation)
        }
    }
    
    public func refreshCollection(
        position: CoordinateModel
    ) {
        userLocation = position
        
        switch loadingState.value {
        case .uninitialized, .errorRefreshing, .errorLoadingNextPage, .empty, .withData:
            loadFirstPage(
                position: position,
                sort: sort.value
            )
            
        case .refreshing, .loadingNextPage, .filtering:
            Log.warning("RestaurantsCollection", "Refresh is unavailable for \(loadingState.value.debugDescription)")
        }
    }
    
    public func preloadElement(at index: Int) {
        switch loadingState.value {
        case
            .uninitialized,
            .errorRefreshing,
            .refreshing,
            .loadingNextPage,
            .errorLoadingNextPage,
            .empty,
            .filtering:
            break
            
        case .withData:
            guard let currentPage = currentPage else {
                assertionFailure("[RestaurantsCollection] Invalid state while preloading data")
                return
            }
            
            // Only preload if we have a next page
            guard currentPage.hasNextPage else {
                return
            }
            
            guard let userLocation = userLocation else {
                assertionFailure("[RestaurantsCollection] Must have location while preloading")
                return
            }
            
            // Only preload if the request element belogs in the end of our collection
            // Example:
            //
            // index == 16 && filteredElements.count == 20
            //     we start loading next page automatically
            //
            // index == 14 && filteredElements.count == 20
            //    we don't do anything user might not want to go the end of the collection
            guard index > (filteredElements.count - 5) else {
                return
            }
            
            loadNextPage(
                currentPage: currentPage,
                position: userLocation,
                sort: sort.value
            )
        }
    }
    
    public func loadNextPage() {
        switch loadingState.value {
        case
            .uninitialized,
            .errorRefreshing,
            .refreshing,
            .loadingNextPage,
            .errorLoadingNextPage,
            .empty,
            .filtering:
            Log.warning("RestaurantsCollection", "Load next is unavailable for \(loadingState.value.debugDescription)")
            
        case .withData:
            guard let currentPage = currentPage else {
                assertionFailure("[RestaurantsCollection] Invalid state while loading next page")
                return
            }
            guard let userLocation = userLocation else {
                assertionFailure("[RestaurantsCollection] Must have location while loading next page")
                return
            }
            loadNextPage(
                currentPage: currentPage,
                position: userLocation,
                sort: sort.value
            )
        }
    }
    
    public func retryNextPage() {
        switch loadingState.value {
        case .uninitialized,
             .errorRefreshing,
             .refreshing,
             .loadingNextPage,
             .withData,
             .empty,
             .filtering:
            Log.warning("RestaurantsCollection", "Retry is unavailable for \(loadingState.value.debugDescription)")
            
        case .errorLoadingNextPage:
            guard let currentPage = currentPage else {
                assertionFailure("[RestaurantsCollection] Invalid state while retry next page")
                return
            }
            guard let userLocation = userLocation else {
                assertionFailure("[RestaurantsCollection] Must have location while retry load next page")
                return
            }
            loadNextPage(
                currentPage: currentPage,
                position: userLocation,
                sort: sort.value
            )
        }
    }
    
}

// MARK: Private
extension RestaurantsCollection {
    
    private func loadFirstPage(
        position: CoordinateModel,
        sort: Sort
    ) {
        currentPage = nil
        elements.removeAll()
        filteredElements.removeAll()
        dataState.value = .dataCleared
        
        load(
            offset: 0,
            position: position,
            sort: sort
        )
    }
    
    private func loadNextPage(
        currentPage: PageModel<RestaurantModelProtocol>,
        position: CoordinateModel,
        sort: Sort
    ) {
        guard currentPage.hasNextPage else {
            Log.verbose("RestaurantsCollection", "No more pages available for \(loadingState.value.debugDescription)")
            return
        }
        
        load(
            offset: currentPage.nextOffset,
            position: position,
            sort: sort
        )
    }
    
    private func load(offset: Int, position: CoordinateModel, sort: Sort) {
        let isFirstPage = offset == 0
        if isFirstPage {
            loadingState.value = .refreshing
        } else {
            loadingState.value = .loadingNextPage
        }
        
        let updateElements = { [weak self] (_ newElements: [RestaurantModelProtocol]) in
            guard let self = self else { return }
            
            let previousCount = self.filteredElements.count
            self.filteredElements.append(contentsOf: newElements)
            
            if self.filteredElements.isEmpty {
                self.loadingState.value = .empty
                self.dataState.value = .dataCleared
                
            } else {
                self.loadingState.value = .withData
                
                let currentCount = self.filteredElements.count
                self.dataState.value = .newDataAvailable(
                    range: previousCount..<currentCount
                )
            }
        }
        
        _ = restaurantManager.searchRestaurants(
            offset: offset,
            position: position,
            sort: sort
        ) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .failure(let error):
                    if isFirstPage {
                        self.loadingState.value = .errorRefreshing(error: error)
                    } else {
                        self.loadingState.value = .errorLoadingNextPage
                    }
                    
                case .success(let page):
                    self.currentPage = page
                    
                    self.elements.append(contentsOf: page.elements)
                    
                    guard let filter = self.filter.value else {
                        updateElements(page.elements)
                        return
                    }
                    
                    self.filterInBackground(
                        filter: filter,
                        elements: page.elements,
                        completion: updateElements
                    )
                }
            }
        }
    }
    
    private func applyFilter() {
        let updateElements = { [weak self] (_ newElements: [RestaurantModelProtocol]) in
            guard let self = self else { return }
            self.filteredElements = newElements
            if self.filteredElements.isEmpty {
                self.loadingState.value = .empty
                self.dataState.value = .dataCleared
                
            } else {
                self.loadingState.value = .withData
                self.dataState.value = .dataFiltered
            }
        }
        
        guard let filter = filter.value else {
            // No filter to apply
            updateElements(elements)
            return
        }
        
        self.loadingState.value = .filtering
        filterInBackground(
            filter: filter,
            elements: elements,
            completion: updateElements
        )
    }
    
    private func filterInBackground(
        filter: RestaurantFilterModel,
        elements: [RestaurantModelProtocol],
        completion: @escaping (_ newElements: [RestaurantModelProtocol]) -> Void
    ) {
        // Go background to filter
        DispatchQueue.global(qos: .userInteractive).async {
            let filtered = elements.filter { filter.shouldFilter(restaurant: $0) }
            
            // Go back to main to update collection status and elements
            DispatchQueue.main.async {
                completion(filtered)
            }
        }
    }
    
}

// MARK: Data Query
extension RestaurantsCollection {
    
    public func numberOfElements() -> Int {
        switch loadingState.value {
        case .uninitialized,
             .errorRefreshing,
             .refreshing,
             .errorLoadingNextPage,
             .empty,
             .filtering:
            return 0
            
        case .withData, .loadingNextPage:
            return filteredElements.count
        }
    }
    
    public func element(at index: Int) -> RestaurantModelProtocol? {
        switch loadingState.value {
        case .uninitialized,
             .errorRefreshing,
             .refreshing,
             .errorLoadingNextPage,
             .empty,
             .filtering:
            return nil
            
        case .withData, .loadingNextPage:
            guard index < filteredElements.count else {
                return nil
            }
            return filteredElements[index]
        }
    }
    
}

extension RestaurantsCollection {
    
    // MARK: - LoadingState
    public enum LoadingState: Equatable {
        case uninitialized
        case refreshing
        case errorRefreshing(error: ZomatoError)
        case loadingNextPage
        case errorLoadingNextPage
        case filtering
        case empty
        case withData
        
        var debugDescription: String {
            switch self {
            case .uninitialized:
                return "uninitialized"
            case .refreshing:
                return "refreshing"
            case .errorRefreshing:
                return "errorRefreshing"
            case .loadingNextPage:
                return "loadingNextPage"
            case .errorLoadingNextPage:
                return "errorLoadingNextPage"
            case .filtering:
                return "filtering"
            case .empty:
                return "empty"
            case .withData:
                return "normal"
            }
        }
        
    }
    
    // MARK: - Data State
    public enum DataState: Equatable {
        case uninitialized
        case newDataAvailable(range: Range<Int>)
        case dataFiltered
        case dataCleared
    }
    
}
