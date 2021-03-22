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

#if DEBUG

extension ObservableType  {
    
    public func debugStateInput<QueryType: Equatable, ElementType, ErrorType: Error & Equatable>(
        system: String
    ) -> Observable<Self.Element> where
        Self.Element == PaginatedCollection<QueryType, ElementType, ErrorType>.StateInput {
        return Observable.create { observer in
            Log.verbose(system, "Subscribed StateInput")
            
            let subscription = self.subscribe { e in
                switch e {
                case .next(let value):
                    switch value {
                    case .preload:
                        // Ignore preload logging, to spammy
                        break
                    default:
                        Log.verbose(system, "Next StateInput \(value.debugDescription)")
                    }
                    observer.on(.next(value))
                    
                case .error(let error):
                    Log.error(system, "Error StateInput \(error)")
                    observer.on(.error(error))
                    
                case .completed:
                    Log.verbose(system, "Completed StateInput")
                    observer.on(.completed)
                }
            }
            
            return Disposables.create {
                Log.verbose(system, "Disposing StateInput")
                subscription.dispose()
            }
        }
    }
    
    public func debugState<QueryType: Equatable, ElementType, ErrorType: Error & Equatable>(
        system: String,
        operation: String
    ) -> Observable<Self.Element> where
        Self.Element == PaginatedCollection<QueryType, ElementType, ErrorType>.State {
        return Observable.create { observer in
            Log.verbose(system, "Subscribed State \(operation)")
            
            let subscription = self.subscribe { event in
                switch event {
                case .next(let value):
                    Log.verbose(system, "Next State \(operation) \(value.debugDescription)")
                    observer.on(.next(value))
                    
                case .error(let error):
                    Log.error(system, "Error State \(operation) \(error)")
                    observer.on(.error(error))
                    
                case .completed:
                    Log.verbose(system, "Completed State \(operation) ")
                    observer.on(.completed)
                }
            }
            
            return Disposables.create {
                Log.verbose(system, "Disposing State \(operation) ")
                subscription.dispose()
            }
        }
    }
    
 }

#else

extension ObservableType  {
    
    public func debugStateInput<QueryType: Equatable, ElementType, ErrorType: Error & Equatable>(
        system: String
    ) -> Observable<Self.Element> where
        Self.Element == PaginatedCollection<QueryType, ElementType, ErrorType>.StateInput {
        return self
    }
    
    public func debugState<QueryType: Equatable, ElementType, ErrorType: Error & Equatable>(
        system: String,
        operation: String
    ) -> Observable<Self.Element> where
        Self.Element == PaginatedCollection<QueryType, ElementType, ErrorType>.State {
        return self
    }
    
 }

#endif
