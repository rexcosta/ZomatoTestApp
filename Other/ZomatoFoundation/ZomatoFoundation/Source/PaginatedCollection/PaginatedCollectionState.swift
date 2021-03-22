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
    
    public enum State {
        case uninitialized(query: QueryType?)
        case refreshing(query: QueryType?)
        case errorRefreshing(ErrorType, query: QueryType?)
        case loadingNextPage(offset: Int, data: [ElementType], filteredData: [ElementType], query: QueryType?)
        case errorLoadingNextPage(ErrorType, offset: Int, data: [ElementType], filteredData: [ElementType], query: QueryType?)
        case filtering(data: [ElementType], page: Page, query: QueryType?)
        case empty(data: [ElementType], page: Page, query: QueryType?)
        case withData(data: [ElementType], filteredData: [ElementType], page: Page, query: QueryType?)
    }
    
}

// MARK: PaginatedCollection.State Equatable
extension PaginatedCollection.State: Equatable {
    
    public static func == (
        lhs: PaginatedCollection<QueryType, ElementType, ErrorType>.State,
        rhs: PaginatedCollection<QueryType, ElementType, ErrorType>.State
    ) -> Bool {
        switch (lhs, rhs) {
        case (.uninitialized(let lhsQuery), .uninitialized(let rhsQuery)):
            return compareQueries(lhsQuery, rhsQuery)
            
        case (.refreshing(let lhsQuery), .refreshing(let rhsQuery)):
            return compareQueries(lhsQuery, rhsQuery)
            
        case (.errorRefreshing(let lhsError, let lhsQuery), .errorRefreshing(let rhsError, let rhsQuery)):
            return lhsError == rhsError && compareQueries(lhsQuery, rhsQuery)
            
        case (.loadingNextPage(let lhsOffset, _, _, let lhsQuery),
              .loadingNextPage(let rhsOffset, _, _, let rhsQuery)):
            return lhsOffset == rhsOffset && compareQueries(lhsQuery, rhsQuery)
            
        case (.errorLoadingNextPage(let lhsError, let lhsOffset, _, _, let lhsQuery),
              .errorLoadingNextPage(let rhsError, let rhsOffset, _, _, let rhsQuery)):
            return lhsError == rhsError && lhsOffset == rhsOffset && compareQueries(lhsQuery, rhsQuery)
            
        case (.filtering(_, _, let lhsQuery), .filtering(_, _, let rhsQuery)):
            return compareQueries(lhsQuery, rhsQuery)
        
        case (.empty(_, _, let lhsQuery), .empty(_,  _, let rhsQuery)):
            return compareQueries(lhsQuery, rhsQuery)
            
        case (.withData(_, _, _, let lhsQuery), .withData(_, _, _, let rhsQuery)):
            return compareQueries(lhsQuery, rhsQuery)
            
        default:
            return false
        }
    }
    
    private static func compareQueries(_ lhs: QueryType?, _ rhs: QueryType?) -> Bool {
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

#if DEBUG
// MARK: - PaginatedCollection.State Debug
extension PaginatedCollection.State {
    
    public var debugDescription: String {
        switch self {
        case .uninitialized:
            return "uninitialized"
        case .refreshing:
            return "refreshing"
        case .errorRefreshing:
            return "errorRefreshing"
        case .loadingNextPage(let offset, _, _, _):
            return "loadingNextPage \(offset)"
        case .errorLoadingNextPage(_, let offset, _, _, _):
            return "errorLoadingNextPage \(offset)"
        case .empty:
            return "empty"
        case .filtering:
            return "filtering"
        case .withData(_, _, let page, _):
            return "withData \(page.debugDescription)"
        }
    }
    
}
#endif
