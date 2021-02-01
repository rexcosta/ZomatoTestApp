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

struct RestaurantsDtoModelMapper: ObjectMapper {
    
    private let locationDtoModelMapper = LocationDtoModelMapper()
    
    func mapInput(_ input: SearchResultDTO<RestaurantDto>) -> PageModel<RestaurantModel> {
        return PageModel(
            totalResults: input.resultsFound,
            offset: input.resultsStart,
            pageSize: input.resultsShown,
            elements: input.elements.compactMap { from(restaurantDto: $0) }
        )
    }
    
    private func from(restaurantDto: RestaurantDto) -> RestaurantModel? {
        let priceRange: RestaurantPriceRange
        if let rawPriceRange = restaurantDto.priceRange {
            switch rawPriceRange {
            case 1:
                priceRange = .cheap
            case 2:
                priceRange = .moderate
            case 3:
                priceRange = .expensive
            case 4:
                priceRange = .veryExpensive
            default:
                priceRange = .unknow
            }
        } else {
            priceRange = .unknow
        }
        
        let thumbnailUrl: URL?
        if let rawThumbnailUrl = restaurantDto.thumb {
            thumbnailUrl = URL(string: rawThumbnailUrl)
        } else {
            thumbnailUrl = nil
        }
        
        return RestaurantModel(
            id: restaurantDto.id,
            name: restaurantDto.name,
            location: locationDtoModelMapper.mapInput(restaurantDto.location),
            priceRange: priceRange,
            thumbnailUrl: thumbnailUrl,
            timings: restaurantDto.timings,
            cuisines: restaurantDto.cuisines?.components(separatedBy: ","),
            phoneNumbers: restaurantDto.phoneNumbers?.components(separatedBy: ",")
        )
    }
    
}
