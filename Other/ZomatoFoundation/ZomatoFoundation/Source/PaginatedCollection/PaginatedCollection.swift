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
import RxRelay

public final class PaginatedCollection<QueryType: Equatable, ElementType, ErrorType: Error & Equatable> {
    
    public let collectionName: String
    public let input: PublishSubject<StateInput>
    public let output: Observable<State>
    
    private let disposeBag = DisposeBag()
    
    public init(
        collectionName: String,
        initialState: State,
        dependencies: Dependencies
    ) {
        self.collectionName = collectionName
        
        input = PublishSubject<StateInput>()
        
        let state = BehaviorRelay<State>(value: initialState)
        output = state.asObservable()
        
        input
            .debugStateInput(system: collectionName)
            .compactMap { input in
                let transition = dependencies.stateReducer(
                    collectionName,
                    state.value,
                    input,
                    dependencies.refreshStrategy,
                    dependencies.preloadStrategy
                )
                
                switch transition {
                case .next(let newState):
                    return newState
                case .noTransition:
                    return nil
                }
            }
            .debugState(system: collectionName, operation: "Apply Transition")
            .flatMapLatest {
                PaginatedCollection.apply(
                    collectionName: collectionName,
                    newState: $0,
                    dependencies: dependencies
                )
            }
            .observe(on: MainScheduler.instance)
            .debugState(system: collectionName, operation: "Receiving")
            .bind(to: state)
            .disposed(by: disposeBag)
    }
    
    public convenience init(
        collectionName: String,
        initialQuery: QueryType? = nil,
        dependencies: Dependencies
    ) {
        self.init(
            collectionName: collectionName,
            initialState: .uninitialized(query: initialQuery),
            dependencies: dependencies
        )
    }
    
}

// MARK: Helpers
extension PaginatedCollection {
    
    private static func apply(
        collectionName: String,
        newState: State,
        dependencies: Dependencies
    ) -> Observable<State> {
        return Observable<State>.create { observable -> Disposable in
            MainScheduler.ensureRunningOnMainThread()
            
            // Move to new state
            observable.onNext(newState)
            
            switch newState {
            case .refreshing(let query):
                // Refresh means data reset
                return requestNewData(
                    collectionName: collectionName,
                    dependencies: dependencies,
                    offset: 0,
                    data: [ElementType](),
                    filteredData: [ElementType](),
                    query: query
                )
                .observe(on: MainScheduler.instance)
                .subscribe(observable)
                
            case .loadingNextPage(let offset, let data, let filteredData, let query):
                return requestNewData(
                    collectionName: collectionName,
                    dependencies: dependencies,
                    offset: offset,
                    data: data,
                    filteredData: filteredData,
                    query: query
                )
                .observe(on: MainScheduler.instance)
                .subscribe(observable)
                
            case .filtering(let data, let page, let query):
                // Apply filter in background
                return applyFilter(dependencies: dependencies, data: data, page: page, query: query)
                    .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .userInteractive))
                    .observe(on: MainScheduler.instance)
                    .subscribe(observable)
                
            default:
                // This should never happen because we only need to handle refreshing/loadingNextPage/filtering
                Log.error(collectionName, "New state dont have handling \(newState)")
                return Observable<State>.empty().subscribe()
            }
        }
    }
    
    private static func requestNewData(
        collectionName: String,
        dependencies: Dependencies,
        offset: Int,
        data: [ElementType],
        filteredData: [ElementType],
        query: QueryType?
    ) -> Observable<State> {
        return dependencies.dataProvider(collectionName, offset, query)
            .map { page -> State in
                guard !page.elements.isEmpty else {
                    return .empty(data: data, page: page, query: query)
                }
                var mutableData = data
                mutableData.append(contentsOf: page.elements)
                
                let newFilteredData = dependencies.filterStrategy(page.elements, query)
                var mutableFilteredData = filteredData
                mutableFilteredData.append(contentsOf: newFilteredData)
                
                return .withData(
                    data: mutableData,
                    filteredData: mutableFilteredData,
                    page: page,
                    query: query
                )
            }
            .catch { error -> PrimitiveSequence<SingleTrait, State> in
                let mappedError = dependencies.errorMapper(error)
                let newErrorState: State
                if offset == 0 {
                    newErrorState = .errorRefreshing(mappedError, query: query)
                } else {
                    newErrorState = .errorLoadingNextPage(
                        mappedError,
                        offset: offset,
                        data: data,
                        filteredData: filteredData,
                        query: query
                    )
                }
                return PrimitiveSequence.just(newErrorState)
            }
            .asObservable()
    }
    
    private static func applyFilter(
        dependencies: Dependencies,
        data: [ElementType],
        page: Page,
        query: QueryType?
    ) -> Observable<State> {
        return Observable<State>.create { observer -> Disposable in
            let newFilteredData = dependencies.filterStrategy(data, query)
            observer.onNext(.withData(data: data, filteredData: newFilteredData, page: page, query: query))
            observer.onCompleted()
            return Disposables.create()
        }
    }
    
}

// MARK: - Types
extension PaginatedCollection {
    
    public enum RefreshStrategyResult {
        case refresh // PaginatedCollection must refresh it's data
        case filter // PaginatedCollection must filter it's data
        case ignore // Query didn't change
    }
    
    public enum Transition {
        case next(State)
        case noTransition
    }
    
    public typealias DataProvider = (
        _ collectionName: String,
        _ offset: Int,
        _ query: QueryType?
    ) -> Single<Page>
    
    public typealias PreloadStrategy = (
        _ collectionName: String,
        _ index: Int,
        _ elements: [ElementType],
        _ page: Page
    ) -> Bool
    
    public typealias RefreshStrategy = (
        _ collectionName: String,
        _ previousQuery: QueryType?,
        _ newQuery: QueryType?
    ) -> RefreshStrategyResult
    
    public typealias FilterStrategy = (
        _ elements: [ElementType],
        _ query: QueryType?
    ) -> [ElementType]
    
    public typealias ErrorMapper = (_ error: Error) -> ErrorType
    
    public typealias StateReducer = (
        _ collectionName: String,
        _ state: State,
        _ input: StateInput,
        _ refreshStrategy: RefreshStrategy,
        _ preloadStrategy: PreloadStrategy
    ) -> Transition
    
    public struct Dependencies {
        public let stateReducer: StateReducer
        public let dataProvider: DataProvider
        public let refreshStrategy: RefreshStrategy
        public let filterStrategy: FilterStrategy
        public let errorMapper: ErrorMapper
        public let preloadStrategy: PreloadStrategy
        
        public init(
            stateReducer: @escaping StateReducer = PaginatedCollection.defaultReduce,
            dataProvider: @escaping DataProvider,
            refreshStrategy: @escaping RefreshStrategy,
            filterStrategy: @escaping FilterStrategy,
            errorMapper: @escaping ErrorMapper,
            preloadStrategy: @escaping PreloadStrategy = PaginatedCollection.defaultPreloadStrategy()
        ) {
            self.stateReducer = stateReducer
            self.dataProvider = dataProvider
            self.refreshStrategy = refreshStrategy
            self.filterStrategy = filterStrategy
            self.errorMapper = errorMapper
            self.preloadStrategy = preloadStrategy
        }
        
    }
    
}
