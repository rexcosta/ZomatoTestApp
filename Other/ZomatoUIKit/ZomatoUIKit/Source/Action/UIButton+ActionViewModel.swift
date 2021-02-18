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

extension UIButton {
    
    public func bind(action: ActionViewModel) -> Disposable {
        return CompositeDisposable(
            action.title.asDriver().drive(rx.title(for: .normal)),
            action.image.asDriver().drive(rx.image(for: .normal)),
            action.isEnabled.asDriver().drive(rx.isEnabled),
            action.isHidden.asDriver().drive(rx.isHidden),
            rx.controlEvent(.touchUpInside).subscribe(action.action)
        )
    }
    
    public func bind(action: ReadOnlyActionViewModel) -> Disposable {
        return CompositeDisposable(
            action.title.drive(rx.title(for: .normal)),
            action.image.drive(rx.image(for: .normal)),
            action.isEnabled.drive(rx.isEnabled),
            action.isHidden.drive(rx.isHidden),
            rx.controlEvent(.touchUpInside).subscribe(action.action)
        )
    }
    
}
