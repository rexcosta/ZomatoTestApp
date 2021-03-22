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
    
    public func bind(
        input: PublishSubject<Void>,
        output: ReadOnlyActionViewModel
    ) -> Disposable {
        return CompositeDisposable(
            output.title.drive(rx.title(for: .normal)),
            output.image.drive(rx.image(for: .normal)),
            output.isEnabled.drive(rx.isEnabled),
            output.isHidden.drive(rx.isHidden),
            
            rx.controlEvent(.touchUpInside)
                .mapToVoid()
                .subscribe(input)
        )
    }
    
    public func bind<Output>(
        input: PublishSubject<Void>,
        output: ReadOnlyOutputActionViewModel<Output>
    ) -> Disposable {
        return CompositeDisposable(
            output.title.drive(rx.title(for: .normal)),
            output.image.drive(rx.image(for: .normal)),
            output.isEnabled.drive(rx.isEnabled),
            output.isHidden.drive(rx.isHidden),
            
            rx.controlEvent(.touchUpInside)
                .mapToVoid()
                .subscribe(input)
        )
    }
    
}




extension UIBarButtonItem {
    
    public func bind(
        input: PublishSubject<Void>,
        output: ReadOnlyActionViewModel
    ) -> Disposable {
        return CompositeDisposable(
            output.title.asDriver().drive(rx.title),
            output.image.asDriver().drive(rx.image),
            output.isEnabled.asDriver().drive(rx.isEnabled),
            
            rx.tap
                .mapToVoid()
                .subscribe(input)
        )
    }
    
    public func bind<Output>(
        input: PublishSubject<Void>,
        output: ReadOnlyOutputActionViewModel<Output>
    ) -> Disposable {
        return CompositeDisposable(
            output.title.asDriver().drive(rx.title),
            output.image.asDriver().drive(rx.image),
            output.isEnabled.asDriver().drive(rx.isEnabled),
            
            rx.tap
                .mapToVoid()
                .subscribe(input)
        )
    }
    
}
