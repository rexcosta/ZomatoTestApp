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
    
    private let possiblePrices: [PriceRangeCollectionViewCellViewModel]
    
    let title = BehaviorRelay<String?>(
        value: L10n.Localizable.Screen.Restaurants.Filter.priceRange.value
    ).asDriver()
    
    init(restaurantsCollection: RestaurantsCollection) {
        possiblePrices = [
            PriceRangeCollectionViewCellViewModel(priceRange: .cheap),
            PriceRangeCollectionViewCellViewModel(priceRange: .moderate),
            PriceRangeCollectionViewCellViewModel(priceRange: .expensive),
            PriceRangeCollectionViewCellViewModel(priceRange: .veryExpensive)
        ]
        
        guard let filter = restaurantsCollection.filterReadOnly.value else {
            return
        }
        
        possiblePrices.forEach { possiblePriceModel in
            let shouldFilter = filter.shouldFilter(
                priceRange: possiblePriceModel.priceRange
            )
            possiblePriceModel.isSelected.accept(shouldFilter)
        }
    }
    
    var pricesToFilter: [RestaurantPriceRange] {
        return possiblePrices
            .filter { $0.isSelected.value }
            .map { $0.priceRange }
    }
    
}

extension RestaurantsFilterByPriceViewModel {
    
    func numberOfPrices() -> Int {
        return possiblePrices.count
    }
    
    func price(at index: Int) -> PriceRangeCollectionViewCellViewModel? {
        return possiblePrices[index]
    }
    
    func selectPrice(at index: Int, selected: Bool) {
        possiblePrices[index].isSelected.accept(selected)
    }
    
}
