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

final class RestaurantCollectionViewCellAccessibilityModel {
    
    let output = Output()
    private var disposeBag = DisposeBag()
    
    func bind(to viewModel: RestaurantCollectionViewCellViewModel?) {
        disposeBag = DisposeBag()
        if let viewModel = viewModel {
            bind(viewModel: viewModel, disposeBag: disposeBag)
        }
    }
    
    private func bind(
        viewModel: RestaurantCollectionViewCellViewModel,
        disposeBag: DisposeBag
    ) {
        disposeBag.insert(
            viewModel.output.isFavouriteReadOnly
                .drive(with: self) { (me, newValue) in
                    switch newValue {
                    case .unknown:
                        me.output.favouriteButtonAccessibility.clear()
                        
                    case .favourite:
                        me.output.favouriteButtonAccessibility.label.accept(
                            L10n.Accessibility.Screen.Restaurants.List.Element.buttonDislike.value
                        )
                        me.output.favouriteButtonAccessibility.set(traits: .button, .image, .selected)
                        
                    case .notFavourite:
                        me.output.favouriteButtonAccessibility.label.accept(
                            L10n.Accessibility.Screen.Restaurants.List.Element.buttonLike.value
                        )
                        me.output.favouriteButtonAccessibility.set(traits: .button, .image)
                    }
                },
            
            viewModel.output.distanceReadOnly
                .map { distance -> String in
                    switch distance {
                    case .near(let title):
                        return title
                    case .nearby(let title):
                        return title
                    case .far(let title):
                        return title
                    case .unknown(let title):
                        return title
                    }
                }
                .drive(with: output.distanceAccessibility.value) { $0.accept($1) },
            
            viewModel.output.nameReadOnly
                .drive(with: output.nameAccessibility.value) { $0.accept($1) },
            
            viewModel.output.cuisinesReadOnly
                .drive(with: output.cuisinesAccessibility.value) { $0.accept($1) },
            
            viewModel.output.timingsReadOnly
                .drive(with: output.timingsAccessibility.value) { $0.accept($1) },
            
            viewModel.output.priceRangeReadOnly
                .drive(with: output.priceRangeAccessibility.value) { $0.accept($1) }
        )
    }
    
}

// MARK: - RestaurantCollectionViewCellAccessibilityModel.Output
extension RestaurantCollectionViewCellAccessibilityModel {
    
    struct Output {
        let distanceAccessibility = AccessibilityElementModel(
            L10n.Accessibility.Screen.Restaurants.List.Element.labelDistance,
            traits: [.text]
        )
        let nameAccessibility = AccessibilityElementModel(
            L10n.Accessibility.Screen.Restaurants.List.Element.labelName,
            traits: [.text]
        )
        let cuisinesAccessibility = AccessibilityElementModel(
            L10n.Accessibility.Screen.Restaurants.List.Element.labelCuisines,
            traits: [.text]
        )
        let timingsAccessibility = AccessibilityElementModel(
            L10n.Accessibility.Screen.Restaurants.List.Element.labelTimings,
            traits: [.text]
        )
        let priceRangeAccessibility = AccessibilityElementModel(
            L10n.Accessibility.Screen.Restaurants.List.Element.labelPriceRange,
            traits: [.text]
        )
        let favouriteButtonAccessibility = AccessibilityElementModel()
    }
    
}
