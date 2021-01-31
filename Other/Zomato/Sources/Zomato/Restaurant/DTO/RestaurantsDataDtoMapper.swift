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

struct RestaurantsDataDtoMapper: ObjectMapper {
    
    private let locationDtoMapper = LocationDtoMapper()
    
    func mapInput(_ input: (Data, URLResponse)) -> SearchResultDTO<RestaurantDto> {
        let data = input.0
        
        let rootRawObject: [String: Any]
        do {
            guard let root = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                return SearchResultDTO.empty()
            }
            rootRawObject = root
        } catch {
            Log.error("RestaurantsDataDtoMapper", "Unable to decode json \(error)")
            return SearchResultDTO.empty()
        }
        
        guard let resultsFound = rootRawObject["results_found"] as? Int,
              let resultsStart = rootRawObject["results_start"] as? Int,
              let resultsShown = rootRawObject["results_shown"] as? Int,
              let restaurantsRawArray = rootRawObject["restaurants"] as? [[String: Any]]
        else {
            return SearchResultDTO.empty()
        }
        
        let restaurants = restaurantsRawArray.compactMap { restaurantContent -> RestaurantDto? in
            guard let restaurantRawObject = restaurantContent["restaurant"] as? [String: Any] else {
                return nil
            }
            return parse(restaurantRawObject: restaurantRawObject)
        }
        
        return SearchResultDTO(
            resultsFound: resultsFound,
            resultsStart: resultsStart,
            resultsShown: resultsShown,
            elements: restaurants
        )
    }
    
    private func parse(restaurantRawObject: [String: Any]) -> RestaurantDto? {
        guard let id = restaurantRawObject["id"] as? String,
              let name = restaurantRawObject["name"] as? String
        else {
            return nil
        }
        
        return RestaurantDto(
            id: id,
            name: name,
            url: restaurantRawObject["url"] as? String,
            deeplink: restaurantRawObject["deeplink"] as? String,
            location: locationDtoMapper.mapInput(
                restaurantRawObject["location"] as? [String: Any]
            ),
            priceRange: restaurantRawObject["price_range"] as? Int,
            currency: restaurantRawObject["currency"] as? String,
            thumb: restaurantRawObject["thumb"] as? String,
            timings: restaurantRawObject["timings"] as? String,
            menuUrl: restaurantRawObject["menu_url"] as? String,
            cuisines: restaurantRawObject["cuisines"] as? String,
            phoneNumbers: restaurantRawObject["phone_numbers"] as? String
        )
    }
    
}
