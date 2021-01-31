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

import UIKit
import ZomatoFoundation

public struct AccessibilityElementModel: Hashable {
    
    public enum Trait {
        case none
        case text
        case button
        case image
        case link
        case selected
    }
    
    public let identifier: String?
    public let label: String?
    public let value: String?
    public let traits: Set<Trait>
    
    public init(
        identifier: String? = nil,
        label: String? = nil,
        value: String? = nil,
        traits: Set<Trait> = Set<Trait>()
    ) {
        self.identifier = identifier
        self.label = label
        self.value = value
        self.traits = traits
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
            traits: Set(traits)
        )
    }
    
}

// MARK: - Set
extension AccessibilityElementModel {
    
    public func set(identifier: String?) -> AccessibilityElementModel {
        return AccessibilityElementModel(
            identifier: identifier,
            label: label,
            value: value,
            traits: traits
        )
    }
    
    public func set(label: String?) -> AccessibilityElementModel {
        return AccessibilityElementModel(
            identifier: identifier,
            label: label,
            value: value,
            traits: traits
        )
    }
    
    public func set(value: String?) -> AccessibilityElementModel {
        return AccessibilityElementModel(
            identifier: identifier,
            label: label,
            value: value,
            traits: traits
        )
    }
    
}

// MARK: - AccessibilityElementModel Trait
extension AccessibilityElementModel {
    
    public func set(traits: Trait...) -> AccessibilityElementModel {
        return AccessibilityElementModel(
            identifier: identifier,
            label: label,
            value: value,
            traits: Set(traits)
        )
    }
    
    public func set(traits: Set<Trait>) -> AccessibilityElementModel {
        return AccessibilityElementModel(
            identifier: identifier,
            label: label,
            value: value,
            traits: traits
        )
    }
    
    public func append(trait: Trait) -> AccessibilityElementModel {
        var mutableTraits = traits
        mutableTraits.insert(trait)
        return AccessibilityElementModel(
            identifier: identifier,
            label: label,
            value: value,
            traits: mutableTraits
        )
    }
    
    public func append(traits: [Trait]) -> AccessibilityElementModel {
        var mutableTraits = traits
        mutableTraits.append(contentsOf: traits)
        return AccessibilityElementModel(
            identifier: identifier,
            label: label,
            value: value,
            traits: Set<Trait>(mutableTraits)
        )
    }
    
    public func remove(trait: Trait) -> AccessibilityElementModel {
        var mutableTraits = traits
        mutableTraits.remove(trait)
        return AccessibilityElementModel(
            identifier: identifier,
            label: label,
            value: value,
            traits: mutableTraits
        )
    }
    
}
