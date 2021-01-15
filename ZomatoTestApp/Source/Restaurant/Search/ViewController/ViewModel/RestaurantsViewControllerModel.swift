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

final class RestaurantsViewControllerModel {
    
    let title = "screen.restaurants.title".localized
    let restaurantsListViewModel: RestaurantsListViewModel
    private let coordinator: AppCoordinator
    
    private let isFilterButtonEnabled = Property<Bool>(false, skipRepeated: true)
    var readOnlyIsFilterButtonEnabled: ReadOnlyProperty<Bool> {
        return isFilterButtonEnabled.readOnly
    }
    
    init(restaurantsListViewModel: RestaurantsListViewModel, coordinator: AppCoordinator) {
        self.restaurantsListViewModel = restaurantsListViewModel
        self.coordinator = coordinator
        
        bind(to: restaurantsListViewModel.restaurantsCollection)
    }
    
    private func bind(to restaurantsCollection: RestaurantsCollection) {
        restaurantsCollection.readOnlyLoadingState.observeOnMainContext(
            fire: true,
            whileTargetAlive: self
        ) { (me, state) in
            switch state {
            case .uninitialized, .refreshing, .errorRefreshing, .errorLoadingNextPage, .loadingNextPage, .filtering, .empty:
                me.isFilterButtonEnabled.value = false
                
            case .withData:
                me.isFilterButtonEnabled.value = true
            }
        }
    }
    
    func onFilterOptionsAction() {
        coordinator.showRestaurantFilterOptions(
            restaurantsCollection: restaurantsListViewModel.restaurantsCollection
        )
    }
    
}
