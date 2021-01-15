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
import Zomato

final class RestaurantsListViewModel {
    
    private enum State {
        case acquiringLocation
        case refreshing
        case errorRefreshing
        case loadingNextPage
        case errorLoadingNextPage
        case filtering
        case empty
        case withData
    }
    
    enum DataChange: Equatable {
        case reload
        case insert(indexs: [IndexPath])
    }
    
    private let collectionDataChange = Property<DataChange>(.reload)
    var readOnlyCollectionDataChange: ReadOnlyProperty<DataChange> {
        return collectionDataChange.readOnly
    }
    
    let fullScreenState = FullScreenStateViewModel()
    let fullScreenStateVisible = Property<Bool>(false, skipRepeated: true)
    
    let bottomScreenState = BottomStateViewModel()
    let bottomScreenStateVisible = Property<Bool>(false, skipRepeated: true)
    
    let restaurantManager: RestaurantManagerProtocol
    let restaurantsCollection: RestaurantsCollection
    
    let locationManager: LocationManager
    
    let appCoordinator: AppCoordinator
    
    init(
        restaurantManager: RestaurantManagerProtocol,
        restaurantsCollection: RestaurantsCollection,
        locationManager: LocationManager,
        appCoordinator: AppCoordinator
    ) {
        self.restaurantManager = restaurantManager
        self.restaurantsCollection = restaurantsCollection
        self.locationManager = locationManager
        self.appCoordinator = appCoordinator
        
        set(state: .acquiringLocation)
        
        bind(to: locationManager)
        bind(to: restaurantsCollection)
    }
    
    func numberOfRestaurants() -> Int {
        return restaurantsCollection.numberOfElements()
    }
    
    func restaurant(at index: Int) -> RestaurantModelProtocol? {
        return restaurantsCollection.element(at: index)
    }
    
    func preloadElement(at index: Int) {
        restaurantsCollection.preloadElement(at: index)
    }
    
}

// MARK: Bind
extension RestaurantsListViewModel {
    
    private func bind(to restaurantsCollection: RestaurantsCollection) {
        restaurantsCollection
            .readOnlyLoadingState
            .observeOnMainContext(
                fire: true,
                whileTargetAlive: self
            ) { (me, collectionLoadingState) in
                me.receivedNew(collectionLoadingState: collectionLoadingState)
            }
        
        restaurantsCollection
            .readOnlyDataState
            .observeOnMainContext(
                fire: true,
                whileTargetAlive: self
            ) { (me, collectionDataState) in
                me.receivedNew(collectionDataState: collectionDataState)
            }
    }
    
    private func bind(to locationManager: LocationManager) {
        locationManager.readOnlyUserLocation.observeOnMainContext(
            fire: true,
            whileTargetAlive: self
        ) { (me, location) in
            guard let location = location else {
                me.set(state: .acquiringLocation)
                return
            }
            
            me.restaurantsCollection.refreshCollection(
                position: CoordinateModel(coordinate: location.coordinate)
            )
        }
    }
    
    private func receivedNew(collectionDataState: RestaurantsCollection.DataState) {
        switch collectionDataState {
        case .uninitialized, .dataCleared, .dataFiltered:
            collectionDataChange.value = .reload
            
        case .newDataAvailable(let range):
            let indexs = range.map { NSIndexPath(item: $0, section: 0) as IndexPath }
            collectionDataChange.value = .insert(indexs: indexs)
        }
    }
    
    private func receivedNew(collectionLoadingState: RestaurantsCollection.LoadingState) {
        switch collectionLoadingState {
        case .uninitialized:
            break
            
        case .refreshing:
            set(state: .refreshing)
            
        case .errorRefreshing:
            set(state: .errorRefreshing)
            
        case .loadingNextPage:
            set(state: .loadingNextPage)
            
        case .errorLoadingNextPage:
            set(state: .errorLoadingNextPage)
            
        case .withData:
            set(state: .withData)
            
        case .filtering:
            set(state: .filtering)
            
        case .empty:
            set(state: .empty)
        }
    }
    
}

// MARK: Private
extension RestaurantsListViewModel {
    
    private func set(state: State) {
        switch state {
        case .acquiringLocation:
            showFullScreen(
                message: "screen.restaurants.status.acquiring.location"
            )
            
        case .refreshing:
            showFullScreen(
                message: "screen.restaurants.status.refreshing"
            )
            
        case .errorRefreshing:
            showErrorRefreshing()
            
        case .loadingNextPage:
            showBottom(
                message: "screen.restaurants.status.loadingmore"
            )
            
        case .errorLoadingNextPage:
            showErrorLoadingNextPage()
            
        case .filtering:
            showFullScreenLoading()
            
        case .empty:
            showEmptyMessage()
            
        case .withData:
            hideAllMessages()
        }
    }
    
    private func hideAllMessages() {
        fullScreenState.clear()
        fullScreenStateVisible.value = false
        
        bottomScreenState.clear()
        bottomScreenStateVisible.value = false
    }
    
    private func showFullScreenLoading() {
        fullScreenState.showOnlyLoading()
        fullScreenStateVisible.value = true
        
        bottomScreenState.clear()
        bottomScreenStateVisible.value = false
    }
    
    private func showEmptyMessage() {
        fullScreenState.set(
            isLoading: false,
            message: "screen.restaurants.status.empty"
        )
        fullScreenStateVisible.value = true
        
        bottomScreenState.clear()
        bottomScreenStateVisible.value = false
    }
    
    private func showFullScreen(message: String) {
        fullScreenState.set(message: message)
        fullScreenStateVisible.value = true
        
        bottomScreenState.clear()
        bottomScreenStateVisible.value = false
    }
    
    private func showBottom(message: String) {
        fullScreenState.clear()
        fullScreenStateVisible.value = false
        
        bottomScreenState.set(message: message)
        bottomScreenStateVisible.value = true
    }
    
    private func showErrorRefreshing() {
        fullScreenState.set(
            isLoading: false,
            message: "screen.restaurants.status.refreshing.error",
            buttonTitle: "global.button.retry",
            isButtonHidden: false,
            onButtonActionClosure: { [weak self] in
                self?.restaurantsCollection.refreshCollection()
            }
        )
        fullScreenStateVisible.value = true
        
        bottomScreenState.clear()
        bottomScreenStateVisible.value = false
    }
    
    private func showErrorLoadingNextPage() {
        fullScreenState.clear()
        fullScreenStateVisible.value = false
        
        bottomScreenState.set(
            isLoading: false,
            message: "screen.restaurants.status.loadingmore.error",
            buttonTitle: "global.button.retry",
            isButtonHidden: false,
            onButtonActionClosure: { [weak self] in
                self?.restaurantsCollection.retryNextPage()
            }
        )
        bottomScreenStateVisible.value = true
    }
    
}
