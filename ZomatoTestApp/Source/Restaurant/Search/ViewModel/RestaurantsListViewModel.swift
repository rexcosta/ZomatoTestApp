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

final class RestaurantsListViewModel {
    
    private let collectionDataChange = BehaviorRelay<DataChange>(value: .reload)
    var collectionDataChangeReadOnly: BehaviorRelayDriver<DataChange> {
        return collectionDataChange.readOnlyDriver
    }
    
    private let fullScreenStateVisible = BehaviorRelay<Bool>(value: false)
    var fullScreenStateVisibleReadOnly: BehaviorRelayDriver<Bool> {
        return fullScreenStateVisible.readOnlyDriver
    }
    let fullScreenState = FullScreenStateViewModel()
    
    private let bottomScreenStateVisible = BehaviorRelay<Bool>(value: false)
    var bottomScreenStateVisibleReadOnly: BehaviorRelayDriver<Bool> {
        return bottomScreenStateVisible.readOnlyDriver
    }
    let bottomScreenState = BottomStateViewModel()
    
    let restaurantManager: RestaurantManagerProtocol
    let restaurantsCollection: RestaurantsCollection
    
    var userLocation: CoordinateModel? {
        return restaurantsCollection.userLocation
    }
    
    private let disposeBag = DisposeBag()
    private var retryRefreshDisposable: Disposable?
    private var retryNextPageDisposable: Disposable?
    
    init(
        restaurantManager: RestaurantManagerProtocol,
        restaurantsCollection: RestaurantsCollection,
        locationManager: LocationManagerProtocol
    ) {
        self.restaurantManager = restaurantManager
        self.restaurantsCollection = restaurantsCollection
        
        set(state: .acquiringLocation)
        
        bind(to: locationManager, disposeBag: disposeBag)
        bind(to: restaurantsCollection, disposeBag: disposeBag)
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
    
    private func bind(
        to restaurantsCollection: RestaurantsCollection,
        disposeBag: DisposeBag
    ) {
        disposeBag.insert(
            restaurantsCollection.loadingStateReadOnly
                .asObservable()
                .map { RestaurantsListViewModel.State.from(loadingState: $0) }
                .distinctUntilChanged()
                .observe(on: MainScheduler.instance)
                .withUnretained(self)
                .bind { $0.set(state: $1) },
            
            restaurantsCollection.dataStateReadOnly
                .asObservable()
                .map { DataChange.from(dataState: $0) }
                .distinctUntilChanged()
                .observe(on: MainScheduler.instance)
                .withUnretained(self)
                .bind { $0.collectionDataChange.accept($1) }
        )
    }
    
    private func bind(
        to locationManager: LocationManagerProtocol,
        disposeBag: DisposeBag
    ) {
        disposeBag.insert(
            locationManager.userLocationReadOnly.driver
                .distinctUntilChanged()
                .drive(with: self) { (me, location) in
                    guard let location = location else {
                        me.set(state: .acquiringLocation)
                        return
                    }
                    
                    me.restaurantsCollection.refreshCollection(
                        position: CoordinateModel(coordinate: location.coordinate)
                    )
                }
        )
    }
    
}

// MARK: Private
extension RestaurantsListViewModel {
    
    private func set(state: State) {
        switch state {
        case .uninitialized:
            hideAllMessages()
            
        case .acquiringLocation:
            showFullScreen(
                message: L10n.Localizable.Screen.Restaurants.Status.acquiringLocation.value
            )
            
        case .refreshing:
            showFullScreen(
                message: L10n.Localizable.Screen.Restaurants.Status.refreshing.value
            )
            
        case .errorRefreshing:
            showErrorRefreshing()
            
        case .loadingNextPage:
            showBottom(
                message: L10n.Localizable.Screen.Restaurants.Status.loadingMore.value
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
        fullScreenStateVisible.accept(false)
        
        bottomScreenState.clear()
        bottomScreenStateVisible.accept(false)
    }
    
    private func showFullScreenLoading() {
        fullScreenState.setLoading()
        fullScreenStateVisible.accept(true)
        
        bottomScreenState.clear()
        bottomScreenStateVisible.accept(false)
    }
    
    private func showEmptyMessage() {
        fullScreenState.set(
            isLoading: false,
            message: L10n.Localizable.Screen.Restaurants.Status.empty.value,
            buttonTitle: nil,
            isButtonHidden: true
        )
        fullScreenStateVisible.accept(true)
        
        bottomScreenState.clear()
        bottomScreenStateVisible.accept(false)
    }
    
    private func showFullScreen(message: String) {
        fullScreenState.set(message: message)
        fullScreenStateVisible.accept(true)
        
        bottomScreenState.clear()
        bottomScreenStateVisible.accept(false)
    }
    
    private func showBottom(message: String) {
        fullScreenState.clear()
        fullScreenStateVisible.accept(false)
        
        bottomScreenState.set(message: message)
        bottomScreenStateVisible.accept(true)
    }
    
    private func showErrorRefreshing() {
        fullScreenState.set(
            isLoading: false,
            message: L10n.Localizable.Screen.Restaurants.Status.Refreshing.error.value,
            buttonTitle: L10n.Localizable.Global.Button.retry.value,
            isButtonHidden: false
        )
        retryRefreshDisposable?.dispose()
        retryRefreshDisposable = fullScreenState
            .buttonAction
            .withUnretained(self)
            .subscribe { (me, _) in
                me.restaurantsCollection.refreshCollection()
            }
        fullScreenStateVisible.accept(true)
        
        bottomScreenState.clear()
        bottomScreenStateVisible.accept(false)
    }
    
    private func showErrorLoadingNextPage() {
        fullScreenState.clear()
        fullScreenStateVisible.accept(false)
        
        bottomScreenState.set(
            isLoading: false,
            message: L10n.Localizable.Screen.Restaurants.Status.LoadingMore.error.value,
            buttonTitle: L10n.Localizable.Global.Button.retry.value,
            isButtonHidden: false
        )
        retryNextPageDisposable?.dispose()
        retryNextPageDisposable = bottomScreenState
            .buttonAction
            .withUnretained(self)
            .subscribe { (me, _) in
                me.restaurantsCollection.retryNextPage()
            }
        bottomScreenStateVisible.accept(true)
    }
    
}

// MAK: RestaurantsListViewModel.DataChange
extension RestaurantsListViewModel {
    
    enum DataChange: Equatable {
        case reload
        case insert(indexs: [IndexPath])
        
        static func from(dataState: RestaurantsCollection.DataState) -> DataChange {
            switch dataState {
            case .uninitialized, .dataCleared, .dataFiltered:
                return .reload
                
            case .newDataAvailable(let range):
                let indexs = range.map { NSIndexPath(item: $0, section: 0) as IndexPath }
                return .insert(indexs: indexs)
            }
        }
    }
    
}

// MAK: RestaurantsListViewModel.State
extension RestaurantsListViewModel {
    
    private enum State {
        case uninitialized
        case acquiringLocation
        case refreshing
        case errorRefreshing
        case loadingNextPage
        case errorLoadingNextPage
        case filtering
        case empty
        case withData
        
        static func from(loadingState: RestaurantsCollection.LoadingState) -> State {
            switch loadingState {
            case .uninitialized:
                return .uninitialized
                
            case .refreshing:
                return .refreshing
                
            case .errorRefreshing:
                return .errorRefreshing
                
            case .loadingNextPage:
                return .loadingNextPage
                
            case .errorLoadingNextPage:
                return .errorLoadingNextPage
                
            case .withData:
                return .withData
                
            case .filtering:
                return .filtering
                
            case .empty:
                return .empty
            }
        }
    }
    
}
