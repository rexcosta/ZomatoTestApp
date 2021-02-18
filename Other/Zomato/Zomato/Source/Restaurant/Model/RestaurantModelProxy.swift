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
import RxRelay
import ZomatoFoundation

struct RestaurantModelProxy: RestaurantModelProtocol {
    
    private let restaurantModel: RestaurantModel
    private let isFavouriteLazyPropertyLoader: LazyPropertyLoader<RestaurantModelProtocol, RestaurantFavouriteStatus>
    
    var id: String {
        return restaurantModel.id
    }
    
    var name: String {
        return restaurantModel.name
    }
    
    var location: LocationModel? {
        return restaurantModel.location
    }
    
    var priceRange: RestaurantPriceRange {
        return restaurantModel.priceRange
    }
    
    var thumbnailUrl: URL? {
        return restaurantModel.thumbnailUrl
    }
    
    var timings: String? {
        return restaurantModel.timings
    }
    
    var cuisines: [String] {
        return restaurantModel.cuisines
    }
    
    var phoneNumbers: [String] {
        return restaurantModel.phoneNumbers
    }
    
    var isFavourite: BehaviorRelay<RestaurantFavouriteStatus> {
        isFavouriteLazyPropertyLoader.loadOnce(input: restaurantModel)
        return restaurantModel.isFavourite
    }
    
    init(
        restaurantModel: RestaurantModel,
        isFavouriteLazyPropertyLoader: LazyPropertyLoader<RestaurantModelProtocol, RestaurantFavouriteStatus>
    ) {
        self.restaurantModel = restaurantModel
        self.isFavouriteLazyPropertyLoader = isFavouriteLazyPropertyLoader
    }
    
}

extension RestaurantModelProxy {
    
    static func makeProxy(
        restaurantModel: RestaurantModel,
        isFavouritePropertyLoader: @escaping (_ input: RestaurantModelProtocol) -> Infallible<RestaurantFavouriteStatus>
    ) -> RestaurantModelProxy {
        return RestaurantModelProxy(
            restaurantModel: restaurantModel,
            isFavouriteLazyPropertyLoader: LazyPropertyLoader(
                propertyLoader: isFavouritePropertyLoader,
                propertySetter: { $0.isFavourite.accept($1) }
            )
        )
    }
    
}
