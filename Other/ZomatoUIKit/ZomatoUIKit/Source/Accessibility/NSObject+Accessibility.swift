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

// MARK: - UIAccessibility + LocalizedString
extension UIAccessibilityIdentification where Self: NSObject {
    
    public func bind(
        accessibilityModel: AccessibilityElementModel
    ) -> Disposable {
        return CompositeDisposable(
            accessibilityModel.identifier.asDriver().drive(rx.accessibilityIdentifier),
            accessibilityModel.label.asDriver().drive(rx.accessibilityLabel),
            accessibilityModel.value.asDriver().drive(rx.accessibilityValue),
            accessibilityModel.traits
                .asDriver()
                .map { UIAccessibilityTraits.convert(traits: $0) }
                .drive(rx.accessibilityTraits)
        )
    }
    
}
