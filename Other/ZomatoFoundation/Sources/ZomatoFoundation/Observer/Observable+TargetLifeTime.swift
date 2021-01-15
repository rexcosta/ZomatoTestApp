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

public class ObserverToken {
    
    public init() { }
    
}

extension Observable {
    
    public func observe<TargetType>(
        fire: Bool,
        whileTargetAlive target: TargetType,
        observer: @escaping (_ target: TargetType, _ value: ElementType) -> Void
    ) where TargetType: AnyObject {
        let newObserver = { [weak target] (_ newValue: ElementType) -> ObserverLifeTime in
            guard let target = target else {
                return .release
            }
            observer(target, newValue)
            return .retain
        }
        observe(fire: fire, observer: newObserver)
    }
    
    public func observeWhileTokenAlive(
        fire: Bool,
        observer: @escaping (_ value: ElementType) -> Void
    ) -> ObserverToken {
        let token = ObserverToken()
        let newObserver = { [weak token] (_ newValue: ElementType) -> ObserverLifeTime in
            guard token != nil else {
                return .release
            }
            observer(newValue)
            return .retain
        }
        observe(fire: fire, observer: newObserver)
        return token
    }
    
    public func observeWhileTokenAndTargetAlive<TargetType>(
        fire: Bool,
        target: TargetType,
        observer: @escaping (_ target: TargetType, _ value: ElementType) -> Void
    ) -> ObserverToken where TargetType: AnyObject {
        let token = ObserverToken()
        let newObserver = { [weak token, weak target] (_ newValue: ElementType) -> ObserverLifeTime in
            guard token != nil else {
                return .release
            }
            guard let target = target else {
                return .release
            }
            observer(target, newValue)
            return .retain
        }
        observe(fire: fire, observer: newObserver)
        return token
    }
    
}
