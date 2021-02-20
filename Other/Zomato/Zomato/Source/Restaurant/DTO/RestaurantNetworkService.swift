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

final class RestaurantNetworkService {
    
    private let network: NetworkProtocol
    private let apiRequestBuilder: ApiRequestBuilder
    
    init(network: NetworkProtocol, apiRequestBuilder: ApiRequestBuilder) {
        self.network = network
        self.apiRequestBuilder = apiRequestBuilder
    }
    
}

// MARK: RestaurantNetworkServiceProtocol
extension RestaurantNetworkService: RestaurantNetworkServiceProtocol {
    
    func request(
        offset: Int,
        pageSize: Int,
        position: CoordinateModel,
        sort: Sort
    ) -> Single<SearchResultDTO<RestaurantDto>> {
        
        let request = apiRequestBuilder.make(
            endPoint: RestaurantApi.search(
                offset: offset,
                pageSize: pageSize,
                position: position,
                sort: sort
            )
        )
        
        return network.request(request)
            .map { dataTuple -> SearchResultDTO<RestaurantDto> in
                var page = RestaurantsDataDtoMapper().mapInput(dataTuple)
                // API will return results found, but we can only query 100 max results
                // We limit here, upper layers dont need to know abot this limitation
                if page.resultsFound > 100 {
                    page = SearchResultDTO(
                        resultsFound: 100,
                        resultsStart: page.resultsStart,
                        resultsShown: page.resultsShown,
                        elements: page.elements
                    )
                }
                
                return page
            }
            .catch {
                throw AppErrorMapper(
                    context: ZomatoErrorContext.NetworkErrorContext.searchRestaurants
                ).mapInput($0)
            }
    }
    
}
