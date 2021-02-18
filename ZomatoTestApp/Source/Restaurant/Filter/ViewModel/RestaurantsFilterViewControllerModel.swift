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
import RxCocoa
import ZomatoFoundation
import ZomatoUIKit
import Zomato

final class RestaurantsFilterViewControllerModel {
    
    let sortViewModel: RestaurantsSortViewModel
    let filterByPriceViewModel: RestaurantsFilterByPriceViewModel
    
    let title = BehaviorRelay<String?>(
        value: L10n.Localizable.Screen.Restaurants.Filter.title.value
    ).asDriver()
    
    let applyFilterAction = PublishSubject<Void>()
    let closeAction = PublishSubject<Void>()
    
    private let disposeBag = DisposeBag()
    
    init(restaurantsCollection: RestaurantsCollection, coordinator: AppCoordinatorProtocol) {
        sortViewModel = RestaurantsSortViewModel(
            restaurantsCollection: restaurantsCollection
        )
        filterByPriceViewModel = RestaurantsFilterByPriceViewModel(
            restaurantsCollection: restaurantsCollection
        )
        
        disposeBag.insert(
            bindCloseAction(coordinator: coordinator),
            bindApplyFilterAction(restaurantsCollection: restaurantsCollection, coordinator: coordinator)
        )
    }
    
}

// MARK: Helpers
extension RestaurantsFilterViewControllerModel {
    
    private func bindCloseAction(
        coordinator: AppCoordinatorProtocol
    ) -> Disposable {
        return closeAction.subscribe { _ in
            coordinator.goHome()
        }
    }
    
    private func bindApplyFilterAction(
        restaurantsCollection: RestaurantsCollection,
        coordinator: AppCoordinatorProtocol
    ) -> Disposable {
        return applyFilterAction
            .withUnretained(self)
            .subscribe { (me, _) in
                let sort = me.sortViewModel.sort
                let pricesToFilter = me.filterByPriceViewModel.pricesToFilter
                
                if pricesToFilter.isEmpty {
                    restaurantsCollection.set(
                        sort: sort,
                        filter: nil
                    )
                } else {
                    restaurantsCollection.set(
                        sort: sort,
                        filter: RestaurantFilterModel(prices: pricesToFilter)
                    )
                }
                
                coordinator.goHome()
            }
    }
    
}
