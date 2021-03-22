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

final class RestaurantsFilterByPriceViewModel {
    
    let output: Output
    
    init(
        filter: RestaurantFilterModel?,
        possibleFilters: [RestaurantPriceRange] = RestaurantsFilterByPriceViewModel.possiblePriceRangeFilters()
    ) {
        let shouldFilter = { (_ priceRange: RestaurantPriceRange) in
            return filter?.shouldFilter(
                priceRange: priceRange
            ) ?? false
        }
        
        let possiblePricesModels = BehaviorRelay<[PriceRangeCollectionViewCellViewModel]>(
            value: possibleFilters.map {
                return PriceRangeCollectionViewCellViewModel(
                    priceRange: $0,
                    isSelected: shouldFilter($0)
                )
            }
        )
        
        let selectedPricesRange = possiblePricesModels
            .flatMap { possiblePrices -> Observable<[RestaurantPriceRange]> in
                return Observable
                    .combineLatest(possiblePrices.map { $0.output.selectedPriceRange })
                    .map { $0.compactMap { $0 } }
            }
        
        output = Output(
            title: L10n.Localizable.Screen.Restaurants.Filter.priceRange,
            prices: possiblePricesModels.asObservable(),
            selectedPrices: selectedPricesRange
        )
    }
    
}

// MARK: - RestaurantsFilterByPriceViewModel.Output
extension RestaurantsFilterByPriceViewModel {
    
    struct Output {
        
        let title: Driver<String?>
        let prices: Observable<[PriceRangeCollectionViewCellViewModel]>
        let selectedPrices: Observable<[RestaurantPriceRange]>
        
        init(
            title: LocalizedString,
            prices: Observable<[PriceRangeCollectionViewCellViewModel]>,
            selectedPrices: Observable<[RestaurantPriceRange]>
        ) {
            self.title = BehaviorRelay<String?>(
                value: title.value
            ).asDriver()
            
            self.prices = prices
            self.selectedPrices = selectedPrices
        }
        
    }
    
}

// MARK: Static helpers
extension RestaurantsFilterByPriceViewModel {
    
    private static func possiblePriceRangeFilters() -> [RestaurantPriceRange] {
        return [
            .cheap,
            .moderate,
            .expensive,
            .veryExpensive
        ]
    }
    
}
