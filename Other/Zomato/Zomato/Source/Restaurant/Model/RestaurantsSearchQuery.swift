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
import RxSwift

public struct RestaurantsSearchQuery {
    public let position: CoordinateModel
    public let sort: Sort
    public let filter: RestaurantFilterModel?
    
    public init(
        position: CoordinateModel,
        sort: Sort = .dontSort,
        filter: RestaurantFilterModel? = nil
    ) {
        self.position = position
        self.sort = sort
        self.filter = filter
    }
    
    public func set(
        position: CoordinateModel,
        sort: Sort,
        filter: RestaurantFilterModel?
    ) -> RestaurantsSearchQuery {
        return RestaurantsSearchQuery(
            position: position,
            sort: sort,
            filter: filter
        )
    }
    
}

extension RestaurantsSearchQuery {
    
    public func set(position: CoordinateModel) -> RestaurantsSearchQuery {
        return set(position: position, sort: sort, filter: filter)
    }
    
    public func set(sort: Sort) -> RestaurantsSearchQuery {
        return set(position: position, sort: sort, filter: filter)
    }
    
    public func set(sort: Sort, filter: RestaurantFilterModel?) -> RestaurantsSearchQuery {
        return set(position: position, sort: sort, filter: filter)
    }
    
}

// MARK: RestaurantsSearchQuery Equatable
extension RestaurantsSearchQuery: Equatable {
    
    public static func == (
        lhs: RestaurantsSearchQuery,
        rhs: RestaurantsSearchQuery
    ) -> Bool {
        return lhs.position == rhs.position && lhs.sort == rhs.sort && compareFilters(lhs.filter, rhs.filter)
    }
    
    private static func compareFilters(_ lhs: RestaurantFilterModel?, _ rhs: RestaurantFilterModel?) -> Bool {
        switch (lhs, rhs) {
        case (.none, .none):
            return true
        case (.some, .none), (.none, .some):
            return false
        case (.some(let lhsQuery), .some(let rhsQuery)):
            return lhsQuery == rhsQuery
        }
    }
    
}
