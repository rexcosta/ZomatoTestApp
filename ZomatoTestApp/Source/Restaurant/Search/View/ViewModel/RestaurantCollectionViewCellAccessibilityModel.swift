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

import UIKit
import ZomatoFoundation
import ZomatoUIKit
import Zomato

final class RestaurantCollectionViewCellAccessibilityModel {
    
    let distanceAccessibility = Property<AccessibilityElementModel>(
        AccessibilityElementModel(
            L10n.Accessibility.Screen.Restaurants.List.Element.labelDistance,
            traits: [.text]
        )
    )
    let nameAccessibility = Property<AccessibilityElementModel>(
        AccessibilityElementModel(
            L10n.Accessibility.Screen.Restaurants.List.Element.labelName,
            traits: [.text]
        )
    )
    let cuisinesAccessibility = Property<AccessibilityElementModel>(
        AccessibilityElementModel(
            L10n.Accessibility.Screen.Restaurants.List.Element.labelCuisines,
            traits: [.text]
        )
    )
    let timingsAccessibility = Property<AccessibilityElementModel>(
        AccessibilityElementModel(
            L10n.Accessibility.Screen.Restaurants.List.Element.labelTimings,
            traits: [.text]
        )
    )
    let priceRangeAccessibility = Property<AccessibilityElementModel>(
        AccessibilityElementModel(
            L10n.Accessibility.Screen.Restaurants.List.Element.labelPriceRange,
            traits: [.text]
        )
    )
    let favouriteButtonAccessibility = Property<AccessibilityElementModel>(
        AccessibilityElementModel()
    )
    
    func bind(viewModel: RestaurantCollectionViewCellViewModel) {
        viewModel.favouriteButton.observeOnMainContext(
            fire: true,
            whileTargetAlive: favouriteButtonAccessibility
        ) { (favouriteButtonAccessibility, newValue) in
            switch newValue {
            case .unknown:
                favouriteButtonAccessibility.value = AccessibilityElementModel()
                
            case .favourite:
                favouriteButtonAccessibility.value = AccessibilityElementModel(
                    L10n.Accessibility.Screen.Restaurants.List.Element.buttonDislike,
                    traits: [.button, .selected]
                )
                
            case .notFavourite:
                favouriteButtonAccessibility.value = AccessibilityElementModel(
                    L10n.Accessibility.Screen.Restaurants.List.Element.buttonLike,
                    traits: [.button]
                )
            }
        }
        
        viewModel.distance.observeOnMainContext(
            fire: true,
            whileTargetAlive: distanceAccessibility
        ) { (distanceAccessibility, newValue) in
            let accessibilityValue: String
            switch newValue {
            case .near(let title):
                accessibilityValue = title
            case .nearby(let title):
                accessibilityValue = title
            case .far(let title):
                accessibilityValue = title
            case .unknown(let title):
                accessibilityValue = title
            }
            distanceAccessibility.value = distanceAccessibility.value.set(
                value: accessibilityValue
            )
        }
        
        viewModel.name.observeOnMainContext(
            fire: true,
            whileTargetAlive: nameAccessibility
        ) { (nameAccessibility, newValue) in
            nameAccessibility.value = nameAccessibility.value.set(
                value: newValue
            )
        }
        
        viewModel.cuisines.observeOnMainContext(
            fire: true,
            whileTargetAlive: cuisinesAccessibility
        ) { (cuisinesAccessibility, newValue) in
            cuisinesAccessibility.value = cuisinesAccessibility.value.set(
                value: newValue
            )
        }
        
        viewModel.timings.observeOnMainContext(
            fire: true,
            whileTargetAlive: timingsAccessibility
        ) { (timingsAccessibility, newValue) in
            timingsAccessibility.value = timingsAccessibility.value.set(
                value: newValue
            )
        }
        
        viewModel.priceRange.observeOnMainContext(
            fire: true,
            whileTargetAlive: priceRangeAccessibility
        ) { (priceRangeAccessibility, newValue) in
            priceRangeAccessibility.value = priceRangeAccessibility.value.set(
                value: newValue
            )
        }
    }
    
}
