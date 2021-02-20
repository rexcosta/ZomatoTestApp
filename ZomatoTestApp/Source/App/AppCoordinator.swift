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
import Zomato

protocol AppCoordinatorProtocol {
    func goHome()
    func showRestaurantFilterOptions(restaurantsCollection: RestaurantsCollection)
    func showLocationError(_ error: Error) -> LocationErrorViewControllerModel
}

final class AppCoordinator: AppCoordinatorProtocol {
    
    private let zomato: Zomato
    private var locationManager: LocationManager?
    
    private var appRootViewController: UIViewController?
    
    init(zomato: Zomato) {
        self.zomato = zomato
    }
    
    func appLaunch(_ launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> UIWindow {
        let locationManager = LocationManager()
        self.locationManager = locationManager
        
        let rootViewController = RestaurantsViewController()
        let restaurantsCollection = zomato.restaurantManager.searchRestaurants()
        rootViewController.viewModel = RestaurantsViewControllerModel(
            restaurantsListViewModel: RestaurantsListViewModel(
                restaurantManager: zomato.restaurantManager,
                restaurantsCollection: restaurantsCollection
            ),
            restaurantsCollection: restaurantsCollection,
            locationManager: locationManager,
            coordinator: self
        )
        
        let navigationController = UINavigationController(
            rootViewController: rootViewController
        )
        self.appRootViewController = navigationController
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        return window
    }
    
    func goHome() {
        appRootViewController?.dismiss(animated: true, completion: nil)
    }
    
    func showRestaurantFilterOptions(restaurantsCollection: RestaurantsCollection) {
        let filterViewController = RestaurantsFilterViewController()
        filterViewController.viewModel = RestaurantsFilterViewControllerModel(
            restaurantsCollection: restaurantsCollection,
            coordinator: self
        )
        let navigationController = UINavigationController(
            rootViewController: filterViewController
        )
        present(viewController: navigationController)
    }
    
    func showLocationError(_ error: Error) -> LocationErrorViewControllerModel {
        let filterViewController = LocationErrorViewController()
        let viewModel = LocationErrorViewControllerModel(
            coordinator: self,
            error: error
        )
        filterViewController.viewModel = viewModel
        let navigationController = UINavigationController(
            rootViewController: filterViewController
        )
        present(viewController: navigationController)
        return viewModel
    }
    
}

// MARK: Private
extension AppCoordinator {
    
    private func present(viewController: UIViewController) {
        guard let appRootViewController = appRootViewController else {
            return
        }
        
        if let presentedViewController = appRootViewController.presentedViewController {
            presentedViewController.dismiss(animated: true) {
                appRootViewController.present(
                    viewController,
                    animated: true,
                    completion: nil
                )
            }
        } else {
            appRootViewController.present(
                viewController,
                animated: true,
                completion: nil
            )
        }
    }
    
}
