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
import Zomato

final class SearchCoordinator: BaseCoordinator<Void> {
    
    private let disposeBag = DisposeBag()
    
    private let zomato: Zomato
    private let navigation: NavigationProtocol
    private var restaurantsViewController: RestaurantsViewController?
    
    private var locationManager: LocationManager?
    
    init(
        zomato: Zomato,
        navigation: NavigationProtocol
    ) {
        self.zomato = zomato
        self.navigation = navigation
    }
    
    override func start() -> Observable<CoordinationResult> {
        let restaurantsViewController = RestaurantsViewController()
        self.restaurantsViewController = restaurantsViewController
        
        let locationManager = LocationManager()
        self.locationManager = locationManager
        
        let restaurantsCollection = zomato.restaurantManager.searchRestaurants()
        
        let viewModel = RestaurantsViewControllerModel(
            restaurantsListViewModel: RestaurantsListViewModel(
                restaurantManager: zomato.restaurantManager,
                restaurantsCollection: restaurantsCollection
            ),
            restaurantsCollection: restaurantsCollection,
            locationManager: locationManager
        )
        
        restaurantsViewController.viewModel = viewModel
        
        viewModel.output
            .showFilterOptionsReadOnly
            .action
            .flatMap { [weak self] filterOptions -> Observable<FilterRestaurantsCoordinator.CoordinationResult> in
                guard let self = self else { return Observable.empty() }
                return self.coordinateToFilterRestaurants(
                    filter: filterOptions.filter,
                    sort: filterOptions.sort
                )
            }
            .subscribe(
                with: viewModel,
                onNext: { (viewModel, result) in
                    switch result {
                    case .applyFilterOptions(let filter, let sort):
                        viewModel.input.applyFilterOptions.onNext((filter: filter, sort: sort))
                        
                    case .cancel:
                        break
                    }
                }
            )
            .disposed(by: disposeBag)
        
        viewModel.output
            .showLocationErrorReadOnly
            .flatMap { [weak self] error -> Observable<Void> in
                guard let self = self else { return Observable.empty() }
                return self.coordinateToLocationError(error)
            }
            .subscribe(viewModel.input.retryLocation)
            .disposed(by: disposeBag)
        
        navigation.setContent(restaurantsViewController, animated: true)
        
        return Observable.never()
    }
    
}

extension SearchCoordinator {
    
    private func coordinateToFilterRestaurants(
        filter: RestaurantFilterModel?,
        sort: Sort
    ) -> Observable<FilterRestaurantsCoordinator.CoordinationResult> {
        let filterRestaurantsCoordinator = FilterRestaurantsCoordinator(
            navigation: navigation,
            filter: filter,
            sort: sort
        )
        return coordinate(to: filterRestaurantsCoordinator)
    }
    
    private func coordinateToLocationError(_ error: Error) -> Observable<Void> {
        let locationCoordinator = LocationCoordinator(navigation: navigation, error: error)
        return coordinate(to: locationCoordinator)
    }
    
}
