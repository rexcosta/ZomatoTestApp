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
    
    let title = BehaviorRelay<String?>(
        value: L10n.Localizable.Screen.Restaurants.title.value
    ).asDriver()
    
    private let isFilterEnabled = BehaviorRelay<Bool>(value: false)
    var isFilterEnabledReadOnly: BehaviorRelayDriver<Bool> {
        return isFilterEnabled.readOnlyDriver
    }
    
    let filterAction = PublishSubject<Void>()
    let viewWillAppearEvent = PublishSubject<Void>()
    
    private let disposeBag = DisposeBag()
    
    init(
        restaurantsListViewModel: RestaurantsListViewModel,
        restaurantsCollection: RestaurantsCollection,
        locationManager: LocationManagerProtocol,
        coordinator: AppCoordinatorProtocol
    ) {
        self.restaurantsListViewModel = restaurantsListViewModel
        
        disposeBag.insert(
            bindFilterAction(to: restaurantsCollection, coordinator: coordinator),
            bindUpdateFilterEnabled(restaurantsCollection: restaurantsCollection),
            bindViewWillAppearEvent(locationManager: locationManager, coordinator: coordinator)
        )
    }
    
}

// MARK: Helpers
extension RestaurantsViewControllerModel {
    
    private func bindFilterAction(
        to restaurantsCollection: RestaurantsCollection,
        coordinator: AppCoordinatorProtocol
    ) -> Disposable {
        return filterAction
            .subscribe { _ in
                coordinator.showRestaurantFilterOptions(
                    restaurantsCollection: restaurantsCollection
                )
            }
    }
    
    private func bindUpdateFilterEnabled(
        restaurantsCollection: RestaurantsCollection
    ) -> Disposable {
        return restaurantsCollection
            .loadingStateReadOnly
            .asObservable()
            .distinctUntilChanged()
            .map { loadingState -> Bool in
                switch loadingState {
                case .uninitialized,
                     .refreshing,
                     .errorRefreshing,
                     .errorLoadingNextPage,
                     .loadingNextPage,
                     .filtering:
                    return false
                    
                case .empty:
                    // We have a list empty but we are filtering
                    // User can choose to remove filter to have results again
                    if restaurantsCollection.filterReadOnly.value != nil {
                        return true
                    } else {
                        return false
                    }
                    
                case .withData:
                    return true
                }
            }
            .observe(on: MainScheduler.instance)
            .bind(to: isFilterEnabled)
    }
    
    private func bindViewWillAppearEvent(
        locationManager: LocationManagerProtocol,
        coordinator: AppCoordinatorProtocol
    ) -> Disposable {
        return viewWillAppearEvent.subscribe(
            with: self
        ) { (me, _) in
            me.updateLocation(locationManager: locationManager, coordinator: coordinator)
        }
    }
    
}

// MARK: Location
extension RestaurantsViewControllerModel {
    
    private func updateLocation(
        locationManager: LocationManagerProtocol,
        coordinator: AppCoordinatorProtocol
    ) {
        let disposable = locationManager
            .currentLocation()
            .map { CoordinateModel(location: $0) }
            .subscribe(
                onNext: { [weak restaurantsListViewModel] coordinate in
                    restaurantsListViewModel?.locationUpdatedEvent.onNext(coordinate)
                },
                onError: { [weak self] error in
                    self?.restaurantsListViewModel.locationUpdatedEvent.onNext(nil)
                    self?.onLocationError(
                        error,
                        locationManager: locationManager,
                        coordinator: coordinator
                    )
                }
            )
        
        disposeBag.insert(disposable)
    }
    
    private func onLocationError(
        _ error: Error,
        locationManager: LocationManagerProtocol,
        coordinator: AppCoordinatorProtocol
    ) {
        let disposable = coordinator.showLocationError(error)
            .closeAction
            .subscribe(
                with: self,
                onNext: { (me, _) in
                    me.updateLocation(locationManager: locationManager, coordinator: coordinator)
                }
            )
        
        disposeBag.insert(disposable)
    }
    
}
