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

final class RestaurantCollectionViewCellViewModel {
    
    private let thumbnailImage = BehaviorRelay<URL?>(value: nil)
    var thumbnailImageReadOnly: BehaviorRelayDriver<URL?> {
        return thumbnailImage.readOnlyDriver
    }
    
    private let distance = BehaviorRelay<Distance>(
        value: .unknown(L10n.Localizable.Screen.Restaurants.List.Element.noDistance.value)
    )
    var distanceReadOnly: BehaviorRelayDriver<Distance> {
        return distance.readOnlyDriver
    }
    
    private let name = BehaviorRelay<String?>(value: nil)
    var nameReadOnly: BehaviorRelayDriver<String?> {
        return name.readOnlyDriver
    }
    
    private let cuisines = BehaviorRelay<String?>(value: nil)
    var cuisinesReadOnly: BehaviorRelayDriver<String?> {
        return cuisines.readOnlyDriver
    }
    
    private let timings = BehaviorRelay<String?>(value: nil)
    var timingsReadOnly: BehaviorRelayDriver<String?> {
        return timings.readOnlyDriver
    }
    
    private let priceRange = BehaviorRelay<String?>(value: nil)
    var priceRangeReadOnly: BehaviorRelayDriver<String?> {
        return priceRange.readOnlyDriver
    }
    
    private let favouriteAction = ActionViewModel(isHidden: true)
    var favouriteActionReadOnly: ReadOnlyActionViewModel {
        return ReadOnlyActionViewModel(actionModel: favouriteAction)
    }
    private let isFavourite = BehaviorRelay<RestaurantFavouriteStatus>(value: .unknown)
    var isFavouriteReadOnly: BehaviorRelayDriver<RestaurantFavouriteStatus> {
        return isFavourite.readOnlyDriver
    }
    
    private var disposeBag = DisposeBag()
    
    func set(
        userCoordinate: CoordinateModel?,
        restaurant: RestaurantModelProtocol,
        restaurantManager: RestaurantManagerProtocol
    ) {
        thumbnailImage.accept(restaurant.thumbnailUrl)
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
        
        name.accept(restaurant.name)
        cuisines.accept(restaurant.cuisines.joined(separator: ","))
        timings.accept(restaurant.timings)
        priceRange.accept(restaurant.priceRange.localized)
        
        disposeBag = DisposeBag()
        disposeBag.insert(
            bindFavouriteAction(
                restaurant: restaurant,
                restaurantManager: restaurantManager
            )
        )
    }
    
}

// MARK: Helpers
extension RestaurantCollectionViewCellViewModel {
    
    private func bindFavouriteAction(
        restaurant: RestaurantModelProtocol,
        restaurantManager: RestaurantManagerProtocol
    ) -> Disposable {
        return CompositeDisposable(
            favouriteAction.action
                .observe(on: MainScheduler.instance)
                .subscribe(with: self) { (me, _) in
                    me.toogleIsFavourite(
                        restaurant: restaurant,
                        restaurantManager: restaurantManager
                    )
                },
            
            restaurant.isFavourite
                .observe(on: MainScheduler.instance)
                .subscribe(with: self) { (me, newValue) in
                    me.isFavourite.accept(newValue)
                    
                    switch newValue {
                    case .unknown:
                        me.favouriteAction.image.accept(nil)
                        me.favouriteAction.isHidden.accept(true)
                        
                    case .favourite:
                        me.favouriteAction.image.accept(Asset.likeFill.image)
                        me.favouriteAction.isHidden.accept(false)
                        
                    case .notFavourite:
                        me.favouriteAction.image.accept(Asset.likeEmpty.image)
                        me.favouriteAction.isHidden.accept(false)
                    }
                }
        )
    }
    
    private func updateDistance(
        userCoordinate: CoordinateModel?,
        restaurantCoordinate: CoordinateModel?
    ) {
        guard
            let userCoordinate = userCoordinate,
            let restaurantCoordinate = restaurantCoordinate
        else {
            distance.accept(
                .unknown(
                    L10n.Localizable.Screen.Restaurants.List.Element.noDistance.value
                )
            )
            return
        }
        
        let distanceInMeters = userCoordinate.distanceInMeters(to: restaurantCoordinate)
        let distanceTitle = L10n.Localizable.Screen.Restaurants.List.Element
            .distance(Float(distanceInMeters))
            .value
        
        switch distanceInMeters {
        case 0..<300:
            distance.accept(.near(distanceTitle))
        case 300..<600:
            distance.accept(.nearby(distanceTitle))
        default:
            distance.accept(.far(distanceTitle))
        }
    }
    
    private func toogleIsFavourite(
        restaurant: RestaurantModelProtocol,
        restaurantManager: RestaurantManagerProtocol
    ) {
        switch restaurant.isFavourite.value {
        case .favourite:
            restaurant.isFavourite.accept(.notFavourite)
        case .notFavourite:
            restaurant.isFavourite.accept(.favourite)
        case .unknown:
            return
        }
        
        let saveDisposable = restaurantManager.save(restaurant: restaurant)
            .observe(on: MainScheduler.instance)
            .subscribe(
                with: self,
                onCompleted: nil,
                onError: { (_, _) in
                    // Ignoring error, but could have a layout to indicate the error while saving
                },
                onDisposed: nil
            )
        disposeBag.insert(saveDisposable)
    }
    
}

// MARK: RestaurantCollectionViewCellViewModel.Distance
extension RestaurantCollectionViewCellViewModel {
    
    enum Distance: Equatable {
        case near(_ title: String)
        case nearby(_ title: String)
        case far(_ title: String)
        case unknown(_ title: String)
    }
    
}
