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

extension Observable {
    
    public func observeOnMainContext<TargetType>(
        fire: Bool,
        whileTargetAlive target: TargetType,
        observer: @escaping (_ target: TargetType, _ value: ElementType) -> Void
    ) where TargetType: AnyObject {
        observe(fire: fire, whileTargetAlive: target) { (target, newValue) in
            DispatchQueue.main.async {
                observer(target, newValue)
            }
        }
    }
    
    public func observeWhileTokenAliveOnMainContext(
        fire: Bool,
        observer: @escaping (_ value: ElementType) -> Void
    ) -> ObserverToken {
        return observeWhileTokenAlive(fire: fire) { newValue in
            if Thread.isMainThread {
                observer(newValue)
            } else {
                DispatchQueue.main.async {
                    observer(newValue)
                }
            }
        }
    }
    
    public func observeWhileTokenAndTargetAliveOnMainContext<TargetType>(
        fire: Bool,
        target: TargetType,
        observer: @escaping (_ target: TargetType, _ value: ElementType) -> Void
    ) -> ObserverToken where TargetType: AnyObject {
        return observeWhileTokenAndTargetAlive(fire: fire, target: target) { (target, newValue) in
            DispatchQueue.main.async {
                observer(target, newValue)
            }
        }
    }
    
    public func observe<TargetType>(
        fire: Bool,
        queue: DispatchQueue,
        whileTargetAlive target: TargetType,
        observer: @escaping (_ target: TargetType, _ value: ElementType) -> Void
    ) where TargetType: AnyObject {
        observe(fire: fire, whileTargetAlive: target) { (target, newValue) in
            queue.async {
                observer(target, newValue)
            }
        }
    }
    
}
