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

// MARK: - UIAccessibility + AccessibilityElementModel
extension UIAccessibilityIdentification where Self: NSObject {
    
    public func bindAccessibility<BindTo>(
        to property: BindTo
    ) where BindTo: Observable, BindTo.ElementType == AccessibilityElementModel {
        property.observeOnMainContext(fire: true, whileTargetAlive: self) { (me, newValue) in
            me.setAccessibility(newValue)
        }
    }
    
    public func setAccessibility(
        _ accessibility: AccessibilityElementModel
    ) {
        let traits = UIAccessibilityTraits.convert(
            traits: accessibility.traits
        )
        
        setAccessibility(
            identifier: accessibility.identifier,
            label: accessibility.label,
            value: accessibility.value,
            traits: traits
        )
    }
    
    public func setAccessibility(
        identifier: String?,
        label: String?,
        value: String?,
        traits: UIAccessibilityTraits
    ) {
        accessibilityIdentifier = identifier
        accessibilityLabel = label
        accessibilityValue = value
        accessibilityTraits = traits
    }
    
}

// MARK: - UIAccessibility + LocalizedString
extension UIAccessibilityIdentification where Self: NSObject {
    
    public func bindAccessibility<BindTo>(
        to property: BindTo
    ) where BindTo: Observable, BindTo.ElementType == LocalizedString {
        property.observeOnMainContext(fire: true, whileTargetAlive: self) { (me, newValue) in
            me.setAccessibility(newValue)
        }
    }
    
    public func setAccessibility(
        _ accessibilityString: LocalizedString
    ) {
        setAccessibility(
            AccessibilityElementModel(accessibilityString)
        )
    }
    
}
