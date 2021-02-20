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
import RxSwift

final class RestaurantManager {
    
    private let restaurantNetworkService: RestaurantNetworkServiceProtocol
    private let restaurantRepository: RestaurantRepositoryProtocol
    
    init(
        restaurantNetworkService: RestaurantNetworkServiceProtocol,
        restaurantRepository: RestaurantRepositoryProtocol
    ) {
        self.restaurantNetworkService = restaurantNetworkService
        self.restaurantRepository = restaurantRepository
    }
    
}

// MARK: RestaurantManagerProtocol
extension RestaurantManager: RestaurantManagerProtocol {
    
    func searchRestaurants(
        offset: Int,
        position: CoordinateModel,
        sort: Sort
    ) -> Single<PageModel<RestaurantModelProtocol>> {
        let pageSize = 20
        return restaurantNetworkService.request(
            offset: offset,
            pageSize: pageSize,
            position: position,
            sort: sort
        )
        .map { [weak self] dtoPage -> PageModel<RestaurantModelProtocol> in
            guard let self = self else {
                return PageModel.empty()
            }
            return self.replaceDtoPageWithProxies(
                dtoPage: dtoPage
            )
        }
    }
    
    func save(
        restaurant: RestaurantModelProtocol
    ) -> Completable {
        return Completable.create { completable -> Disposable in
            
            let isFavourite: Bool
            switch restaurant.isFavourite.value {
            case .favourite:
                isFavourite = true
                
            case .notFavourite:
                isFavourite = false
                
            case .unknown:
                completable(.completed)
                return Disposables.create()
            }
            
            return self.restaurantRepository.saveRestaurantFavourite(
                id: restaurant.id,
                isFavourite: isFavourite
            )
            .observe(on: MainScheduler.instance)
            .subscribe(
                onCompleted: {
                    completable(.completed)
                },
                onError: { error in
                    // Revert change
                    if isFavourite {
                        restaurant.isFavourite.accept(.notFavourite)
                    } else {
                        restaurant.isFavourite.accept(.favourite)
                    }
                    completable(.error(error))
                    
                },
                onDisposed: nil
            )
        }.subscribe(on: MainScheduler.instance)
    }
    
    func isRestaurantFavourite(
        restaurant: RestaurantModelProtocol
    ) -> Single<RestaurantFavouriteStatus> {
        return restaurantRepository
            .isRestaurantFavourite(id: restaurant.id)
            .map { result -> RestaurantFavouriteStatus in
                if result {
                    return .favourite
                } else {
                    return .notFavourite
                }
            }
    }
    
    func searchRestaurants() -> RestaurantsCollection {
        return RestaurantsCollection(restaurantManager: self)
    }
    
}

// MARK: Private
extension RestaurantManager {
    
    private func replaceDtoPageWithProxies(
        dtoPage: SearchResultDTO<RestaurantDto>
    ) -> PageModel<RestaurantModelProtocol> {
        let restaurantModelPage = RestaurantsDtoModelMapper().mapInput(dtoPage)
        
        let isFavouritePropertyLoader = { [weak self] (restaurant: RestaurantModelProtocol) -> Infallible<RestaurantFavouriteStatus> in
            guard let self = self else {
                return Infallible.empty()
            }
            guard restaurant.isFavourite.value == .unknown else {
                return Infallible.empty()
            }
            
            return self.isRestaurantFavourite(restaurant: restaurant)
                .asInfallible(onErrorJustReturn: RestaurantFavouriteStatus.unknown)
        }
        
        let restaurantProxyModelPage: PageModel<RestaurantModelProtocol> = PageModel(
            totalResults: restaurantModelPage.totalResults,
            offset: restaurantModelPage.offset,
            pageSize: restaurantModelPage.pageSize,
            elements: restaurantModelPage.elements.map { restaurant in
                RestaurantModelProxy.makeProxy(
                    restaurantModel: restaurant,
                    isFavouritePropertyLoader: isFavouritePropertyLoader
                )
            }
        )
        
        return restaurantProxyModelPage
    }
    
}
