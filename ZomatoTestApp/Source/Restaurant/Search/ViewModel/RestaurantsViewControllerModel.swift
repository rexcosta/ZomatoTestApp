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

final class RestaurantsViewControllerModel {
    
    let restaurantsListViewModel: RestaurantsListViewModel
    
    let input: Input
    let output: Output
    private let disposeBag = DisposeBag()
    
    init(
        restaurantsListViewModel: RestaurantsListViewModel,
        restaurantsCollection: RestaurantManagerProtocol.RestaurantsCollection,
        locationManager: LocationManagerProtocol
    ) {
        self.restaurantsListViewModel = restaurantsListViewModel
        input = Input()
        
        output = Output(
            title: L10n.Localizable.Screen.Restaurants.title,
            showFilterOptions: OutputActionViewModel(
                image: Asset.filter.image
            )
        )
        
        disposeBag.insert(
            bindShowFilterOptionsInput(with: restaurantsCollection),
            bindApplyFilterOptionsInput(with: restaurantsCollection),
            bindLocationInput(to: locationManager),
            bindUpdateFilterEnabled(to: restaurantsCollection)
        )
    }
    
}

// MARK: Bind Input
extension RestaurantsViewControllerModel {
    
    private func bindShowFilterOptionsInput(
        with restaurantsCollection: RestaurantManagerProtocol.RestaurantsCollection
    ) -> Disposable {
        return input
            .showFilterOptions
            .withLatestFrom(restaurantsCollection.query)
            .compactMap { $0 }
            .map { (filter: $0.filter, sort: $0.sort) }
            .subscribe(output.showFilterOptions.action)
        
    }
    
    private func bindApplyFilterOptionsInput(
        with restaurantsCollection: RestaurantManagerProtocol.RestaurantsCollection
    ) -> Disposable {
        return input
            .applyFilterOptions
            .withLatestFrom(restaurantsCollection.query) { ($0, $1) }
            .subscribe(onNext: { (filterOptions, query) in
                guard let query = query else {
                    return
                }
                
                let newQuery = query.set(
                    sort: filterOptions.sort,
                    filter: filterOptions.filter
                )
                restaurantsCollection.input.onNext(.changeQuery(newQuery))
            })
    }
    
    private func bindLocationInput(
        to locationManager: LocationManagerProtocol
    ) -> Disposable {
        return Observable.merge(input.retryLocation, input.viewWillAppear)
            .flatMap { _ -> Observable<CoordinateModel?> in
                locationManager
                    .currentLocation()
                    .do(onError: { [weak self] error in
                        self?.output.showLocationError.onNext(error)
                    })
                    .catch { _ in Observable.just(nil) }
                    .map { CoordinateModel(location: $0) }
            }
            .observe(on: MainScheduler.instance)
            .subscribe(restaurantsListViewModel.input.locationUpdated)
    }
    
}

// MARK: Helpers
extension RestaurantsViewControllerModel {
    
    private func bindUpdateFilterEnabled(
        to restaurantsCollection: RestaurantManagerProtocol.RestaurantsCollection
    ) -> Disposable {
        return restaurantsCollection
            .output
            .map { state -> Bool in
                switch state {
                case .uninitialized,
                     .refreshing,
                     .errorRefreshing,
                     .errorLoadingNextPage,
                     .loadingNextPage,
                     .filtering:
                    return false
                    
                case .empty(_, _, let query):
                    // We have a list empty but we are filtering
                    // User can choose to remove filter to have results again
                    if query?.filter != nil {
                        return true
                    } else {
                        return false
                    }
                    
                case .withData:
                    return true
                }
            }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(to: output.showFilterOptions.isEnabled)
    }
    
}

// MARK: - RestaurantsViewControllerModel.Input
extension RestaurantsViewControllerModel {
    
    struct Input {
        let viewWillAppear = PublishSubject<Void>()
        let retryLocation = PublishSubject<Void>()
        let showFilterOptions = PublishSubject<Void>()
        let applyFilterOptions = PublishSubject<(filter: RestaurantFilterModel?, sort: Sort)>()
    }

}

// MARK: - RestaurantsViewControllerModel.Output
extension RestaurantsViewControllerModel {
    
    struct Output {
        let title: Driver<String>
        
        fileprivate let showFilterOptions: OutputActionViewModel<(filter: RestaurantFilterModel?, sort: Sort)>
        let showFilterOptionsReadOnly: ReadOnlyOutputActionViewModel<(filter: RestaurantFilterModel?, sort: Sort)>
        
        fileprivate let showLocationError = PublishSubject<Error>()
        let showLocationErrorReadOnly: Observable<Error>
        
        init(
            title: LocalizedString,
            showFilterOptions: OutputActionViewModel<(filter: RestaurantFilterModel?, sort: Sort)>
            
        ) {
            self.title = BehaviorRelay<String>(
                value: title.value
            ).asDriver()
            
            self.showFilterOptions = showFilterOptions
            showFilterOptionsReadOnly = ReadOnlyOutputActionViewModel(actionModel: showFilterOptions)
            
            showLocationErrorReadOnly = showLocationError.asObservable()
        }
        
    }
    
}
