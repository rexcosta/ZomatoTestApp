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

struct RestaurantModel: RestaurantModelProtocol {
    
    let id: String
    let name: String
    let location: LocationModel?
    let priceRange: RestaurantPriceRange
    let thumbnailUrl: URL?
    let timings: String?
    let cuisines: [String]
    let phoneNumbers: [String]
    let isFavourite = Property<RestaurantFavouriteStatus>(.unknown)
    
    init(
        id: String,
        name: String,
        location: LocationModel?,
        priceRange: RestaurantPriceRange,
        thumbnailUrl: URL?,
        timings: String?,
        cuisines: [String]?,
        phoneNumbers: [String]?
    ) {
        self.id = id
        self.name = name
        self.location = location
        self.priceRange = priceRange
        self.thumbnailUrl = thumbnailUrl
        self.timings = timings
        self.cuisines = cuisines ?? [String]()
        self.phoneNumbers = phoneNumbers ?? [String]()
    }
    
}