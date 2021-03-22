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

import RxSwift
import ZomatoFoundation

struct RestaurantsCollectionHelpers {
    
    static func defaultSearchRestaurants(
        restaurantManager: RestaurantManagerProtocol
    ) -> RestaurantManagerProtocol.RestaurantsCollection {
        return RestaurantManagerProtocol.RestaurantsCollection(
            collectionName: "RestaurantsCollection",
            dependencies: .init(
                dataProvider: RestaurantsCollectionHelpers.defaultDataProvider(restaurantManager),
                refreshStrategy: RestaurantsCollectionHelpers.defaultRefreshStrategy(),
                filterStrategy: RestaurantsCollectionHelpers.defaultFilterStrategy(),
                errorMapper: RestaurantsCollectionHelpers.defaultErrorMapper()
            )
        )
    }
    
    static func defaultDataProvider(
        _ restaurantManager: RestaurantManagerProtocol
    ) -> RestaurantManagerProtocol.RestaurantsCollection.DataProvider {
        return { (collectionName, offset, query) in
            guard let query = query else {
                Log.error(collectionName, "No query provided unable to search")
                #if DEBUG
                return Single.error(ZomatoError(context: .unknown, cause: nil))
                #else
                return Single.just(
                    RestaurantManagerProtocol.RestaurantsCollection.Page(
                        totalResults: 0,
                        offset: 0,
                        pageSize: 0,
                        elements: [RestaurantModelProtocol]()
                    )
                )
                #endif
            }
            return restaurantManager.searchRestaurants(
                offset: offset,
                position: query.position,
                sort: query.sort
            )
            .map {
                return RestaurantManagerProtocol.RestaurantsCollection.Page(
                    totalResults: $0.totalResults,
                    offset: $0.offset,
                    pageSize: $0.pageSize,
                    elements: $0.elements
                )
            }
        }
    }
    
    static func defaultRefreshStrategy() -> RestaurantManagerProtocol.RestaurantsCollection.RefreshStrategy {
        return { (collectionName, oldQuery, newQuery) in
            switch (oldQuery?.sort, newQuery?.sort) {
            case (.none, .none):
                // Nothing changed
                Log.info(collectionName, "Sort didnt change both nil")
                
            case (.none, .some):
                // We have changes need to apply new sort
                Log.info(collectionName, "Need to add apply new sort")
                return .refresh
                
            case (.some, .none):
                // We have changes need to remove sort
                Log.info(collectionName, "Need to add remove sort")
                return .refresh
                
            case (.some(let oldSort), .some(let newSort)):
                // Compare to see if sort changed
                if oldSort != newSort {
                    Log.info(collectionName, "Sort did change will apply new sort")
                    return .refresh
                }
            }
            
            switch (oldQuery?.filter, newQuery?.filter) {
            case (.none, .none):
                // Nothing changed
                Log.info(collectionName, "Filter didnt change both nil")
                
            case (.none, .some):
                // We have changes need to apply filter
                Log.info(collectionName, "Need to add new filter")
                return .filter
                
            case (.some, .none):
                // We have changes need to apply filter
                Log.info(collectionName, "Need to remove filter")
                return .filter
                
            case (.some(let oldFilter), .some(let newFilter)):
                if newFilter != oldFilter {
                    // We have changes need to apply new filter
                    Log.info(collectionName, "Need to replace with new filter")
                    return .filter
                }
            }
            
            return .ignore
        }
    }
    
    static func defaultFilterStrategy() -> RestaurantManagerProtocol.RestaurantsCollection.FilterStrategy {
        return { (elementsToFilter, query) -> [RestaurantModelProtocol] in
            let filtered: [RestaurantModelProtocol]
            if let filter = query?.filter {
                filtered = elementsToFilter.filter { filter.shouldFilter(restaurant: $0) }
            } else {
                filtered = elementsToFilter
            }
            return filtered
        }
    }
    
    static func defaultErrorMapper() -> RestaurantManagerProtocol.RestaurantsCollection.ErrorMapper {
        return { AppErrorMapper().mapInput($0) }
    }
    
}
