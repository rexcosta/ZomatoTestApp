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
import Zomato

final class PriceRangeCollectionViewCellViewModel {
    
    let input: Input
    let output: Output
    
    init(
        priceRange: RestaurantPriceRange,
        isSelected: Bool = false
    ) {
        input = Input(isSelected: isSelected)
        
        let colorDriver = input
            .isSelected
            .asDriver()
            .map { isSelected -> UIColor in
                if isSelected {
                    return Theme.shared.primaryColor
                } else {
                    return Theme.shared.cellBackgroundColor
                }
            }
        
        let selectedPriceRange = input
            .isSelected
            .map { isSelected -> RestaurantPriceRange? in
                if isSelected {
                    return priceRange
                } else {
                    return nil
                }
            }
        
        output = Output(
            title: priceRange.localized,
            selectedPriceRange: selectedPriceRange,
            color: colorDriver
        )
    }
    
}

// MARK: - PriceRangeCollectionViewCellViewModel.Input
extension PriceRangeCollectionViewCellViewModel {
    
    struct Input {
        let isSelected: BehaviorRelay<Bool>
        
        init(isSelected: Bool) {
            self.isSelected = BehaviorRelay<Bool>(value: isSelected)
        }
        
    }
    
}

// MARK: - PriceRangeCollectionViewCellViewModel.Output
extension PriceRangeCollectionViewCellViewModel {
    
    struct Output {
        let title: Driver<String?>
        let selectedPriceRange: Observable<RestaurantPriceRange?>
        let color: Driver<UIColor>
        
        init(
            title: LocalizedString,
            selectedPriceRange: Observable<RestaurantPriceRange?>,
            color: Driver<UIColor>
        ) {
            self.title = BehaviorRelay<String?>(
                value: title.value
            ).asDriver()
            
            self.selectedPriceRange = selectedPriceRange
            self.color = color
        }
        
    }
    
}
