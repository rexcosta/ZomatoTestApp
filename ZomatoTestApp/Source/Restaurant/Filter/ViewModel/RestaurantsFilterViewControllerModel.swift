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
    
    let input: Input
    let output: Output
    private let disposeBag = DisposeBag()
    
    init(filter: RestaurantFilterModel?, sort: Sort) {
        sortViewModel = RestaurantsSortViewModel(
            sort: sort
        )
        filterByPriceViewModel = RestaurantsFilterByPriceViewModel(
            filter: filter
        )
        input = Input()
        output = Output(
            title: L10n.Localizable.Screen.Restaurants.Filter.title,
            applyFilter: OutputActionViewModel(
                title: L10n.Localizable.Screen.Restaurants.Filter.applyFilter.value
            ),
            cancel: OutputActionViewModel(
                title: L10n.Localizable.Global.Button.cancel.value
            )
        )
        
        disposeBag.insert(
            bindFilterAction(currentFilter: filter, currentSort: sort),
            input.cancel.subscribe(output.cancel.action)
        )
    }
    
}

// MARK: Bind
extension RestaurantsFilterViewControllerModel {
    
    func bindFilterAction(
        currentFilter: RestaurantFilterModel?,
        currentSort: Sort
    ) -> Disposable {
        let filterInputs = Observable.combineLatest(
            sortViewModel.output.sort,
            filterByPriceViewModel.output.selectedPrices
        )
        
        return CompositeDisposable(
            input
                .applyFilterOptions
                .withLatestFrom(filterInputs)
                .map { (sort, selectedPrices) -> (filter: RestaurantFilterModel?, sort: Sort) in
                    if selectedPrices.isEmpty {
                        return (filter: nil, sort: sort)
                    } else {
                        return (filter: RestaurantFilterModel(prices: selectedPrices), sort: sort)
                    }
                }
                .subscribe(output.applyFilter.action),
            
            filterInputs
                .map { (newSort, pricesToFilter) -> Bool in
                    return RestaurantsFilterViewControllerModel.hasChanges(
                        currentSort: currentSort,
                        newSort: newSort,
                        pricesToFilter: pricesToFilter,
                        currentFilter: currentFilter
                    )
                }
                .asDriver(onErrorJustReturn: false)
                .drive(output.applyFilter.isEnabled)
        )
    }
    
}

// MARK: - RestaurantsFilterViewControllerModel.Input
extension RestaurantsFilterViewControllerModel {
    
    struct Input {
        let applyFilterOptions = PublishSubject<Void>()
        let cancel = PublishSubject<Void>()
    }
    
}

// MARK: - RestaurantsFilterViewControllerModel.Output
extension RestaurantsFilterViewControllerModel {
    
    struct Output {
        let title: Driver<String?>
        
        fileprivate let applyFilter: OutputActionViewModel<(filter: RestaurantFilterModel?, sort: Sort)>
        let applyFilterReadOnly: ReadOnlyOutputActionViewModel<(filter: RestaurantFilterModel?, sort: Sort)>
        
        fileprivate let cancel: OutputActionViewModel<Void>
        let cancelReadOnly: ReadOnlyOutputActionViewModel<Void>
        
        init(
            title: LocalizedString,
            applyFilter: OutputActionViewModel<(filter: RestaurantFilterModel?, sort: Sort)>,
            cancel: OutputActionViewModel<Void>
        ) {
            self.title = BehaviorRelay<String?>(
                value: title.value
            ).asDriver()
            
            self.applyFilter = applyFilter
            self.applyFilterReadOnly = ReadOnlyOutputActionViewModel(actionModel: applyFilter)
            
            self.cancel = cancel
            self.cancelReadOnly = ReadOnlyOutputActionViewModel(actionModel: cancel)
        }
        
    }
    
}

// MARK: Static helpers
extension RestaurantsFilterViewControllerModel {
    
    static func hasChanges(
        currentSort: Sort,
        newSort: Sort,
        pricesToFilter: [RestaurantPriceRange],
        currentFilter: RestaurantFilterModel?
    ) -> Bool {
        guard newSort == currentSort else {
            // User changed sort
            return true
        }
        
        guard let currentFilter = currentFilter else {
            // We didn't had any filter, need to check if user selected filter
            return !pricesToFilter.isEmpty
        }
        
        let newFilter = RestaurantFilterModel(prices: pricesToFilter)
        return newFilter != currentFilter
    }
    
}
