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
import Zomato
import UIKit

final class RestaurantCollectionViewCellViewModel {
    
    private var favouriteObserverToken: ObserverToken?
    
    let thumbnailImage = Property<URL?>(nil)
    let name = Property<String?>(nil)
    let distance = Property<String?>(nil)
    let distanceColor = Property<UIColor?>(nil)
    let cuisines = Property<String?>(nil)
    let timings = Property<String?>(nil)
    let priceRange = Property<String?>(nil)
    let isFavouriteButtonHidden = Property<Bool>(true)
    let isFavouriteButtonImage = Property<UIImage?>(nil)
    private var onUserDidPressFavouriteActionClosure: (() -> Void)?
    
    func set(
        userCoordinate: CoordinateModel?,
        restaurant: RestaurantModelProtocol,
        restaurantManager: RestaurantManagerProtocol
    ) {
        thumbnailImage.value = restaurant.thumbnailUrl
        if restaurant.thumbnailUrl == nil {
            Log.verbose(
                "RestaurantCollectionViewCellViewModel",
                "Restaurant \(restaurant.name) dont have thumb"
            )
        }
        
        updateDistance(
            userCoordinate: userCoordinate,
            restaurantCoordinate: restaurant.location?.coordinate
        )
        name.value = restaurant.name
        cuisines.value = restaurant.cuisines.joined(separator: ",")
        timings.value = restaurant.timings
        priceRange.value = restaurant.priceRange.localized
        
        favouriteObserverToken = restaurant.isFavourite.observeWhileTokenAndTargetAliveOnMainContext(
            fire: true,
            target: self
        ) { (me, status) in
            switch status {
            case .unknown:
                me.isFavouriteButtonHidden.value = true
                me.isFavouriteButtonImage.value = nil
                
            case .favourite:
                me.isFavouriteButtonHidden.value = false
                me.isFavouriteButtonImage.value = UIImage(named: "like-fill")
                
            case .notFavourite:
                me.isFavouriteButtonHidden.value = false
                me.isFavouriteButtonImage.value = UIImage(named: "like-empty")
            }
        }
        
        onUserDidPressFavouriteActionClosure = {
            switch restaurant.isFavourite.value {
            case .favourite:
                restaurant.isFavourite.value = .notFavourite
            case .notFavourite:
                restaurant.isFavourite.value = .favourite
            case .unknown:
                return
            }
            restaurantManager.save(restaurant: restaurant) { _ in
                // Ignoring error, but could have a layout to indicate the error while saving
            }
        }
    }
    
    func onUserDidPressFavouriteAction() {
        onUserDidPressFavouriteActionClosure?()
    }
    
    private func updateDistance(
        userCoordinate: CoordinateModel?,
        restaurantCoordinate: CoordinateModel?
    ) {
        guard
            let userCoordinate = userCoordinate,
            let restaurantCoordinate = restaurantCoordinate
        else {
            distance.value = "screen.restaurants.list.element.nodistance".localized
            distanceColor.value = Theme.shared.distance.far
            return
        }
        
        let distanceInMeters = userCoordinate.distanceInMeters(to: restaurantCoordinate)
        distance.value = "screen.restaurants.list.element.distance".localized(
            name: "${distance}",
            value: String(format: "%.0f", distanceInMeters)
        )
        
        switch distanceInMeters {
        case 0..<300:
            distanceColor.value = Theme.shared.distance.near
        case 300..<600:
            distanceColor.value = Theme.shared.distance.nearby
        default:
            distanceColor.value = Theme.shared.distance.far
        }
    }
    
}
