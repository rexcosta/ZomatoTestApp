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

public class Property<T: Equatable>: Observable {
    
    private var observersUnfairLock = os_unfair_lock()
    private var observers = [((T) -> ObserverLifeTime)]()
    private let skipRepeated: Bool
    private var lastValue: T
    
    public var value: T {
        didSet {
            os_unfair_lock_lock(&observersUnfairLock)
            defer {
                os_unfair_lock_unlock(&observersUnfairLock)
            }
            
            if skipRepeated && lastValue == value {
                return
            }
            
            lastValue = value
            
            observers = observers.filter { observer -> Bool in
                return observer(value) == .retain
            }
        }
    }
    
    public var readOnly: ReadOnlyProperty<T> {
        return ReadOnlyProperty(self)
    }
    
    public init(_ initialValue: T) {
        value = initialValue
        lastValue = initialValue
        skipRepeated = false
    }
    
    public init(_ initialValue: T, skipRepeated: Bool) {
        value = initialValue
        lastValue = initialValue
        self.skipRepeated = skipRepeated
    }
    
    public func observe(
        fire: Bool,
        observer: @escaping (_ value: T) -> ObserverLifeTime
    ) {
        guard fire else {
            append(observer: observer)
            return
        }
        guard observer(value) == .retain else {
            return
        }
        append(observer: observer)
    }
    
    private func append(observer: @escaping (_ value: T) -> ObserverLifeTime) {
        os_unfair_lock_lock(&observersUnfairLock)
        defer {
            os_unfair_lock_unlock(&observersUnfairLock)
        }
        observers.append(observer)
    }
    
}
