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

import ZomatoFoundation
import ZomatoUIKit
import RxSwift
import RxCocoa

final class FullScreenStateViewModel {
    
    let isLoading = BehaviorRelay<Bool>(value: false)
    let message = BehaviorRelay<String?>(value: nil)
    let buttonTitle = BehaviorRelay<String?>(value: nil)
    let isButtonHidden = BehaviorRelay<Bool>(value: false)
    let buttonAction = PublishSubject<Void>()
    
}

// MARK: Helpers
extension FullScreenStateViewModel {
    
    func set(
        isLoading: Bool,
        message: String?,
        buttonTitle: String?,
        isButtonHidden: Bool
    ) {
        self.isLoading.accept(isLoading)
        self.message.accept(message)
        self.buttonTitle.accept(buttonTitle)
        self.isButtonHidden.accept(isButtonHidden)
    }
    
    func set(message: String?) {
        set(
            isLoading: true,
            message: message,
            buttonTitle: nil,
            isButtonHidden: true
        )
    }
    
    func setLoading() {
        set(
            isLoading: true,
            message: nil,
            buttonTitle: nil,
            isButtonHidden: true
        )
    }
    
    func clear() {
        set(
            isLoading: false,
            message: nil,
            buttonTitle: nil,
            isButtonHidden: true
        )
    }
    
}
