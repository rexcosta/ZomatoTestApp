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

extension PaginatedCollection {
    
    public static func defaultReduce(
        collectionName: String,
        state: State,
        input: StateInput,
        refreshStrategy: RefreshStrategy,
        preloadStrategy: PreloadStrategy
    ) -> Transition {
        switch state {
        case .uninitialized(let query):
            switch input {
            case .loadNextPage, .retryNextPage, .preload:
                return .noTransition
            case .changeQuery(let newQuery):
                return .next(.refreshing(query: newQuery))
            case .refresh:
                return .next(.refreshing(query: query))
            }
            
        case .refreshing:
            return .noTransition
            
        case .errorRefreshing(_, let query):
            switch input {
            case .changeQuery, .loadNextPage, .retryNextPage, .preload:
                return .noTransition
            case .refresh:
                return .next(.refreshing(query: query))
            }
            
        case .loadingNextPage(_, _, _, let query):
            switch input {
            case .changeQuery, .loadNextPage, .retryNextPage, .preload:
                return .noTransition
            case .refresh:
                return .next(.refreshing(query: query))
            }
            
        case .errorLoadingNextPage(_, let offset, let data, let filteredData, let query):
            switch input {
            case .changeQuery, .loadNextPage, .preload:
                return .noTransition
            case .refresh:
                return .next(.refreshing(query: query))
            case .retryNextPage:
                return .next(.loadingNextPage(
                    offset: offset,
                    data: data,
                    filteredData: filteredData,
                    query: query
                ))
            }
            
        case .empty(let data, let currentPage, let query):
            switch input {
            case .loadNextPage, .retryNextPage, .preload:
                return .noTransition
            case .changeQuery(let newQuery):
                if refreshStrategy(collectionName, query, newQuery) == .filter {
                    return .next(.filtering(data: data, page: currentPage, query: newQuery))
                } else {
                    return .next(.refreshing(query: newQuery))
                }
            case .refresh:
                return .next(.refreshing(query: query))
            }
            
        case .filtering:
            return .noTransition
            
        case .withData(let data, let filteredData, let currentPage, let query):
            switch input {
            case .refresh:
                return .next(.refreshing(query: query))
                
            case .changeQuery(let newQuery):
                if refreshStrategy(collectionName, query, newQuery) == .filter {
                    return .next(.filtering(data: data, page: currentPage, query: newQuery))
                } else {
                    return .next(.refreshing(query: newQuery))
                }
                
            case .loadNextPage:
                guard currentPage.hasNextPage else {
                    return .noTransition
                }
                return .next(.loadingNextPage(
                    offset: currentPage.nextOffset,
                    data: data,
                    filteredData: filteredData,
                    query: query
                ))
                
            case .retryNextPage:
                return .noTransition
                
            case .preload(let index):
                // Only preload if we have a next page
                guard currentPage.hasNextPage else {
                    return .noTransition
                }
                
                guard preloadStrategy(collectionName, index, filteredData, currentPage) else {
                    return .noTransition
                }
                
                return .next(.loadingNextPage(
                    offset: currentPage.nextOffset,
                    data: data,
                    filteredData: filteredData,
                    query: query
                ))
            }
        }
    }

}
