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
import Differentiator
import ZomatoFoundation
import ZomatoUIKit
import Zomato

final class RestaurantsListViewModel {
    
    let restaurantManager: RestaurantManagerProtocol
    let restaurantsCollection: RestaurantManagerProtocol.RestaurantsCollection
    
    let input = Input()
    let output: Output
    private let disposeBag = DisposeBag()
    private var retryRefreshDisposable: Disposable?
    private var retryNextPageDisposable: Disposable?
    
    init(
        restaurantManager: RestaurantManagerProtocol,
        restaurantsCollection: RestaurantManagerProtocol.RestaurantsCollection
    ) {
        self.restaurantManager = restaurantManager
        self.restaurantsCollection = restaurantsCollection
        
        output = Output(
            restaurants: restaurantsCollection.elements
                .map { [Section(restaurants: $0)] },
            userLocation: restaurantsCollection.query
                .map { $0?.position }
                .asDriver(onErrorJustReturn: nil)
        )
        
        set(state: .acquiringLocation)
        disposeBag.insert(
            bindRestaurantsCollectionUpdates(to: restaurantsCollection),
            bindLocationUpdatedInput(),
            bindPreloadInput()
        )
    }
    
}

// MARK: Bind Input
extension RestaurantsListViewModel {
    
    private func bindLocationUpdatedInput() -> Disposable {
        input
            .locationUpdated
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(with: self) { (me, location) in
                guard let location = location else {
                    me.set(state: .acquiringLocation)
                    return
                }
                
                let query = RestaurantsSearchQuery(position: location)
                me.restaurantsCollection
                    .input
                    .onNext(.changeQuery(query))
            }
    }
    
    private func bindPreloadInput() -> Disposable {
        return input
            .preload
            .distinctUntilChanged()
            .map {
                RestaurantManagerProtocol.RestaurantsCollection.StateInput.preload(index: $0)
            }
            .subscribe(restaurantsCollection.input)
    }
    
}

// MARK: Bind
extension RestaurantsListViewModel {
    
    private func bindRestaurantsCollectionUpdates(
        to restaurantsCollection: RestaurantManagerProtocol.RestaurantsCollection
    ) -> Disposable {
        restaurantsCollection.output
            .map { RestaurantsListViewModel.State.map(from: $0) }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(with: self) { $0.set(state: $1) }
    }
    
}

// MARK: Private State Change
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
        output.fullScreenState.clear()
        output.fullScreenStateVisible.accept(false)
        
        output.bottomScreenState.clear()
        output.bottomScreenStateVisible.accept(false)
    }
    
    private func showFullScreenLoading() {
        output.fullScreenState.setLoading()
        output.fullScreenStateVisible.accept(true)
        
        output.bottomScreenState.clear()
        output.bottomScreenStateVisible.accept(false)
    }
    
    private func showEmptyMessage() {
        output.fullScreenState.set(
            isLoading: false,
            message: L10n.Localizable.Screen.Restaurants.Status.empty.value,
            buttonTitle: nil,
            isButtonHidden: true
        )
        output.fullScreenStateVisible.accept(true)
        
        output.bottomScreenState.clear()
        output.bottomScreenStateVisible.accept(false)
    }
    
    private func showFullScreen(message: String) {
        output.fullScreenState.set(message: message)
        output.fullScreenStateVisible.accept(true)
        
        output.bottomScreenState.clear()
        output.bottomScreenStateVisible.accept(false)
    }
    
    private func showBottom(message: String) {
        output.fullScreenState.clear()
        output.fullScreenStateVisible.accept(false)
        
        output.bottomScreenState.set(message: message)
        output.bottomScreenStateVisible.accept(true)
    }
    
    private func showErrorRefreshing() {
        output.fullScreenState.set(
            isLoading: false,
            message: L10n.Localizable.Screen.Restaurants.Status.Refreshing.error.value,
            buttonTitle: L10n.Localizable.Global.Button.retry.value,
            isButtonHidden: false
        )
        
        retryRefreshDisposable?.dispose()
        retryNextPageDisposable?.dispose()
        
        retryRefreshDisposable = output.fullScreenState
            .buttonAction
            .subscribe(
                with: self,
                onNext: { (me, _) in
                    me.restaurantsCollection.input.onNext(.refresh)
                }
            )
        output.fullScreenStateVisible.accept(true)
        
        output.bottomScreenState.clear()
        output.bottomScreenStateVisible.accept(false)
    }
    
    private func showErrorLoadingNextPage() {
        output.fullScreenState.clear()
        output.fullScreenStateVisible.accept(false)
        
        output.bottomScreenState.set(
            isLoading: false,
            message: L10n.Localizable.Screen.Restaurants.Status.LoadingMore.error.value,
            buttonTitle: L10n.Localizable.Global.Button.retry.value,
            isButtonHidden: false
        )
        
        retryRefreshDisposable?.dispose()
        retryNextPageDisposable?.dispose()
        
        retryNextPageDisposable = output.bottomScreenState
            .buttonAction
            .subscribe(
                with: self,
                onNext: { (me, _) in
                    me.restaurantsCollection.input.onNext(.retryNextPage)
                }
            )
        output.bottomScreenStateVisible.accept(true)
    }
    
}

// MARK: RestaurantsListViewModel.Input
extension RestaurantsListViewModel {
    
    struct Input {
        let locationUpdated = PublishSubject<CoordinateModel?>()
        let preload = PublishSubject<Int>()
    }
    
}

// MARK: RestaurantsListViewModel.Output
extension RestaurantsListViewModel {
    
    struct Output {
        fileprivate let fullScreenStateVisible = BehaviorRelay<Bool>(value: false)
        let fullScreenStateVisibleReadOnly: Driver<Bool>
        
        let fullScreenState = FullScreenStateViewModel()
        
        fileprivate let bottomScreenStateVisible = BehaviorRelay<Bool>(value: false)
        let bottomScreenStateVisibleReadOnly: Driver<Bool>
        
        let bottomScreenState = BottomStateViewModel()
        
        let restaurants: Observable<[Section]>
        let userLocation: Driver<CoordinateModel?>
        
        init(
            restaurants: Observable<[Section]>,
            userLocation: Driver<CoordinateModel?>
        ) {
            self.restaurants = restaurants
            self.userLocation = userLocation
            
            fullScreenStateVisibleReadOnly = fullScreenStateVisible.asDriver()
            
            bottomScreenStateVisibleReadOnly = bottomScreenStateVisible.asDriver()
        }
    }
    
}

// MARK: RestaurantsListViewModel.State
extension RestaurantsListViewModel {
    
    private enum State {
        case uninitialized
        case acquiringLocation
        case refreshing
        case errorRefreshing
        case loadingNextPage
        case errorLoadingNextPage
        case empty
        case filtering
        case withData
        
        static func map(from loadingState: RestaurantManagerProtocol.RestaurantsCollection.State) -> State {
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
                
            case .empty:
                return .empty
                
            case .filtering:
                return .filtering
                
            case .withData:
                return .withData
            }
        }
    }
    
}

// MARK: - Restaurants Collection
extension RestaurantsListViewModel {
    
    enum SectionElement: IdentifiableType, Equatable {
        case restaurant(RestaurantModelProtocol)
        
        var identity: String {
            switch self {
            case .restaurant(let model):
                return model.id
            }
        }
        
        public static func == (
            lhs: SectionElement,
            rhs: SectionElement
        ) -> Bool {
            return lhs.identity == rhs.identity
        }
    }
    
    struct Section: AnimatableSectionModelType {
        typealias Item = RestaurantsListViewModel.SectionElement
        
        var items: [Item]
        var identity: String = "Restaurants"
        
        init(original: Section, items: [Item]) {
            self = original
            self.items = items
        }
        
        init(restaurants: [RestaurantModelProtocol]) {
            items = restaurants.map { Item.restaurant($0) }
        }
    }
    
}
