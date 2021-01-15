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

enum RestaurantApi {
    case search(offset: Int, pageSize: Int, position: CoordinateModel, sort: Sort)
}

extension RestaurantApi: ApiEndPoint {
    
    public var requiresAuth: Bool {
        return true
    }
    
    public var scheme: String {
        return "https"
    }
    
    public var baseUrl: String {
        return "developers.zomato.com/api/v2.1"
    }
    
    public var path: String {
        switch self {
        case .search:
            return "search"
        }
    }
    
    public var parameters: [HttpQueryParameter] {
        switch self {
        case .search(let offset, let pageSize, let position, let sort):
            var parameters = [
                HttpQueryParameter(name: "start", value: offset),
                HttpQueryParameter(name: "lat", value: position.latitude),
                HttpQueryParameter(name: "lon", value: position.longitude),
                HttpQueryParameter(name: "count", value: pageSize)
            ]
            
            switch sort {
            case .dontSort:
                break
                
            case .distance:
                parameters.append(
                    HttpQueryParameter(name: "sort", value: "real_distance")
                )
            }
            
            return parameters
        }
    }
    
    public var method: HttpMethod {
        return .get
    }
    
}
