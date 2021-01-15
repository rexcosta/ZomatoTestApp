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
        sort: Sort,
        completion: @escaping (Result<PageModel<RestaurantModelProtocol>, ZomatoError>) -> Void
    ) -> Cancellable {
        let pageSize = 20
        return restaurantNetworkService.request(
            offset: offset,
            pageSize: pageSize,
            position: position,
            sort: sort
        ) { [weak self] result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
                
            case .success(let dtoPage):
                guard let self = self else {
                    completion(.success(PageModel.empty()))
                    return
                }
                let page = self.replaceDtoPageWithProxies(dtoPage: dtoPage)
                completion(.success(page))
            }
        }
    }
    
    func save(
        restaurant: RestaurantModelProtocol,
        completion: @escaping (_ error: ZomatoError?) -> Void
    ) {
        let revertIfErrorSaving = { (_ error: ZomatoError?) -> Void in
            DispatchQueue.main.async {
                defer {
                    completion(error)
                }
                guard error != nil else {
                    return
                }
                
                switch restaurant.isFavourite.value {
                case .favourite, .unknown:
                    restaurant.isFavourite.value = .notFavourite
                    
                case .notFavourite:
                    restaurant.isFavourite.value = .favourite
                }
            }
        }
        
        switch restaurant.isFavourite.value {
        case .favourite:
            restaurantRepository.saveRestaurantFavourite(
                id: restaurant.id,
                isFavourite: true,
                completion: revertIfErrorSaving
            )
            
        case .notFavourite:
            restaurantRepository.saveRestaurantFavourite(
                id: restaurant.id,
                isFavourite: false,
                completion: revertIfErrorSaving
            )
            
        case .unknown:
            break
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
        
        let lazyLoadFavourite = { [weak self] (_ restaurant: RestaurantModel) -> Void in
            self?.loadIsFavouritePropery(for: restaurant)
        }
        
        let restaurantProxyModelPage: PageModel<RestaurantModelProtocol> = PageModel(
            totalResults: restaurantModelPage.totalResults,
            offset: restaurantModelPage.offset,
            pageSize: restaurantModelPage.pageSize,
            elements: restaurantModelPage.elements.map {
                RestaurantModelProxy(
                    restaurantModel: $0,
                    lazyLoadFavourite: lazyLoadFavourite
                )
            }
        )
        
        return restaurantProxyModelPage
    }
    
    private func loadIsFavouritePropery(for restaurant: RestaurantModel) {
        guard restaurant.isFavourite.value == .unknown else {
            return
        }
        
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else { return }
            
            let result = self.restaurantRepository.isRestaurantFavourite(id: restaurant.id)
            DispatchQueue.main.async {
                if result {
                    restaurant.isFavourite.value = .favourite
                } else {
                    restaurant.isFavourite.value = .notFavourite
                }
            }
        }
    }
    
}
