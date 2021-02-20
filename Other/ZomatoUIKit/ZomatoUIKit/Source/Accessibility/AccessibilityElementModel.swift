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
import RxCocoa
import ZomatoFoundation

public struct AccessibilityElementModel {
    
    public enum Trait {
        case none
        case text
        case button
        case image
        case link
        case selected
    }
    
    public let identifier: BehaviorRelay<String?>
    public let label: BehaviorRelay<String?>
    public let value: BehaviorRelay<String?>
    public let traits: BehaviorRelay<Set<Trait>>
    
    public init(
        identifier: BehaviorRelay<String?>,
        label: BehaviorRelay<String?>,
        value: BehaviorRelay<String?>,
        traits: BehaviorRelay<Set<Trait>>
    ) {
        self.identifier = identifier
        self.label = label
        self.value = value
        self.traits = traits
    }
    
    public init(
        identifier: String? = nil,
        label: String? = nil,
        value: String? = nil,
        traits: Set<Trait>
    ) {
        self.init(
            identifier: BehaviorRelay<String?>(value: identifier),
            label: BehaviorRelay<String?>(value: label),
            value: BehaviorRelay<String?>(value: value),
            traits: BehaviorRelay<Set<Trait>>(value: traits)
        )
    }
    
    public init(
        identifier: String? = nil,
        label: String? = nil,
        value: String? = nil,
        traits: [Trait] = [Trait]()
    ) {
        self.init(
            identifier: identifier,
            label: label,
            value: value,
            traits: Set(traits)
        )
    }
    
    public func clear() {
        identifier.accept(nil)
        label.accept(nil)
        value.accept(nil)
        traits.accept(Set())
    }
    
}

// MARK: - init + LocalizedString
extension AccessibilityElementModel {
    
    public init(
        _ accessibilityString: LocalizedString,
        traits: [Trait] = [Trait]()
    ) {
        self.init(
            identifier: accessibilityString.key,
            label: accessibilityString.value,
            value: nil,
            traits: Set(traits)
        )
    }
    
}

// MARK: - AccessibilityElementModel Trait
extension AccessibilityElementModel {
    
    public func set(traits: Trait...) {
        self.traits.accept(Set(traits))
    }
    
    public func set(traits: Set<Trait>) {
        self.traits.accept(traits)
    }
    
    public func append(trait: Trait) {
        var mutableTraits = traits.value
        mutableTraits.insert(trait)
        traits.accept(mutableTraits)
    }
    
    public func append(traits: [Trait]) {
        var mutableTraits = self.traits.value
        traits.forEach { mutableTraits.insert($0) }
        self.traits.accept(mutableTraits)
    }
    
    public func remove(trait: Trait) {
        var mutableTraits = traits.value
        mutableTraits.remove(trait)
        traits.accept(mutableTraits)
    }
    
    public func remove(traits: [Trait]) {
        var mutableTraits = self.traits.value
        traits.forEach { mutableTraits.remove($0) }
        self.traits.accept(mutableTraits)
    }
    
}
