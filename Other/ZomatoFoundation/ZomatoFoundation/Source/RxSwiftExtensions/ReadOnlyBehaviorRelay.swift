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

// https://medium.com/flawless-app-stories/rxswift-read-only-property-and-read-write-property-wrapper-608f3014359f
public final class ReadOnlyBehaviorRelay<Element> {
    
    private let behaviorRelay: BehaviorRelay<Element>
    
    /// Current readonly value of behavior subject
    public var value: Element {
        get {
            return behaviorRelay.value
        }
    }
    
    /// Initializes behavior relay with initial value.
    public init(_ value: Element) {
        behaviorRelay = BehaviorRelay(value: value)
    }
    
    /// Initializes behavior relay with BehaviorRelay.
    public init(_ behaviorRelay: BehaviorRelay<Element>) {
        self.behaviorRelay = behaviorRelay
    }
    
    /// Subscribes observer
    public func subscribe<Observer: ObserverType>(
        _ observer: Observer
    ) -> Disposable where Observer.Element == Element {
        return behaviorRelay.subscribe(observer)
    }
    
    /// - returns: Canonical interface for push style sequence
    public func asObservable() -> Observable<Element> {
        return behaviorRelay.asObservable()
    }
    
}

extension BehaviorRelay {
    
    public var readOnly: ReadOnlyBehaviorRelay<Element> {
        return ReadOnlyBehaviorRelay(self)
    }
    
}
