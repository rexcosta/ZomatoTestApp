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
    
    let input: Input
    let output: Output
    
    private var disposeBag = DisposeBag()
    
    init() {
        input = Input()
        output = Output()
    }
    
    func set(
        userCoordinate: Driver<CoordinateModel?>,
        restaurant: RestaurantModelProtocol,
        restaurantManager: RestaurantManagerProtocol
    ) {
        output.thumbnailImage.accept(restaurant.thumbnailUrl)
        if restaurant.thumbnailUrl == nil {
            Log.verbose(
                "RestaurantCollectionViewCellViewModel",
                "Restaurant \(restaurant.name) dont have thumb"
            )
        }
        
        output.name.accept(restaurant.name)
        output.cuisines.accept(restaurant.cuisines.joined(separator: ","))
        output.timings.accept(restaurant.timings)
        output.priceRange.accept(restaurant.priceRange.localized.value)
        
        disposeBag = DisposeBag()
        disposeBag.insert(
            bindFavouriteInput(
                restaurant: restaurant,
                restaurantManager: restaurantManager
            ),
            bindDistanceToUser(
                userCoordinate: userCoordinate,
                restaurant: restaurant
            )
        )
    }
    
}

// MARK: Bind input
extension RestaurantCollectionViewCellViewModel {
    
    private func bindFavouriteInput(
        restaurant: RestaurantModelProtocol,
        restaurantManager: RestaurantManagerProtocol
    ) -> Disposable {
        return CompositeDisposable(
            input.setFavourite
                .flatMap { _ -> Completable in
                    switch restaurant.isFavourite.value {
                    case .favourite:
                        restaurant.isFavourite.accept(.notFavourite)
                    case .notFavourite:
                        restaurant.isFavourite.accept(.favourite)
                    case .unknown:
                        return Completable.empty()
                    }
                    
                    return restaurantManager.save(restaurant: restaurant)
                }
                .observe(on: MainScheduler.instance)
                .subscribe(),
            
            restaurant.isFavourite
                .observe(on: MainScheduler.instance)
                .subscribe(with: self) { (me, newValue) in
                    me.output.isFavourite.accept(newValue)
                    
                    switch newValue {
                    case .unknown:
                        me.output.favouriteAction.image.accept(nil)
                        me.output.favouriteAction.isHidden.accept(true)
                        
                    case .favourite:
                        me.output.favouriteAction.image.accept(Asset.likeFill.image)
                        me.output.favouriteAction.isHidden.accept(false)
                        
                    case .notFavourite:
                        me.output.favouriteAction.image.accept(Asset.likeEmpty.image)
                        me.output.favouriteAction.isHidden.accept(false)
                    }
                }
        )
    }
    
    func bindDistanceToUser(
        userCoordinate: Driver<CoordinateModel?>,
        restaurant: RestaurantModelProtocol
    ) -> Disposable {
        return userCoordinate.drive(with: self) { (me, userCoordinate) in
            me.updateDistance(
                userCoordinate: userCoordinate,
                restaurantCoordinate: restaurant.location?.coordinate
            )
        }
    }
    
}

// MARK: Helpers
extension RestaurantCollectionViewCellViewModel {
    
    private func updateDistance(
        userCoordinate: CoordinateModel?,
        restaurantCoordinate: CoordinateModel?
    ) {
        guard
            let userCoordinate = userCoordinate,
            let restaurantCoordinate = restaurantCoordinate
        else {
            output.distance.accept(
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
            output.distance.accept(.near(distanceTitle))
        case 300..<600:
            output.distance.accept(.nearby(distanceTitle))
        default:
            output.distance.accept(.far(distanceTitle))
        }
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



// MARK: - RestaurantCollectionViewCellViewModel.Input
extension RestaurantCollectionViewCellViewModel {
    
    struct Input {
        let setFavourite = PublishSubject<Void>()
    }
    
}

// MARK: - RestaurantCollectionViewCellViewModel.Output
extension RestaurantCollectionViewCellViewModel {
    
    struct Output {
        
        fileprivate let thumbnailImage: BehaviorRelay<URL?>
        let thumbnailImageReadOnly: Driver<URL?>
        
        fileprivate let distance: BehaviorRelay<Distance>
        let distanceReadOnly: Driver<Distance>
        
        fileprivate let name: BehaviorRelay<String?>
        let nameReadOnly: Driver<String?>
        
        fileprivate let cuisines: BehaviorRelay<String?>
        let cuisinesReadOnly: Driver<String?>
        
        fileprivate let timings: BehaviorRelay<String?>
        let timingsReadOnly: Driver<String?>
        
        fileprivate let priceRange: BehaviorRelay<String?>
        let priceRangeReadOnly: Driver<String?>
        
        fileprivate let favouriteAction: ActionViewModel
        let favouriteActionReadOnly: ReadOnlyActionViewModel
        
        fileprivate let isFavourite: BehaviorRelay<RestaurantFavouriteStatus>
        let isFavouriteReadOnly: Driver<RestaurantFavouriteStatus>
        
        init() {
            thumbnailImage = BehaviorRelay<URL?>(value: nil)
            thumbnailImageReadOnly = thumbnailImage.asDriver()
            
            distance = BehaviorRelay<Distance>(
                value: .unknown(L10n.Localizable.Screen.Restaurants.List.Element.noDistance.value)
            )
            distanceReadOnly = distance.asDriver()
            
            name = BehaviorRelay<String?>(value: nil)
            nameReadOnly = name.asDriver()
            
            cuisines = BehaviorRelay<String?>(value: nil)
            cuisinesReadOnly = cuisines.asDriver()
            
            timings = BehaviorRelay<String?>(value: nil)
            timingsReadOnly = timings.asDriver()
            
            priceRange = BehaviorRelay<String?>(value: nil)
            priceRangeReadOnly = priceRange.asDriver()
            
            favouriteAction = ActionViewModel()
            favouriteActionReadOnly = ReadOnlyActionViewModel(actionModel: favouriteAction)
            
            isFavourite = BehaviorRelay<RestaurantFavouriteStatus>(value: .unknown)
            isFavouriteReadOnly = isFavourite.asDriver()
        }
        
    }
    
}
