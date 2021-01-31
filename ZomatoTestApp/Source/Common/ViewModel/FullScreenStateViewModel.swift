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
import ZomatoFoundation

final class FullScreenStateViewModel {
    
    let isLoading = Property<Bool>(false)
    let message = Property<String?>(nil)
    let buttonTitle = Property<String?>(nil)
    let isButtonHidden = Property<Bool>(false)
    private var onButtonActionClosure: (() -> Void)?
    
    func set(
        isLoading: Bool,
        message: String?,
        buttonTitle: String? = nil,
        isButtonHidden: Bool = true,
        onButtonActionClosure: (() -> Void)? = nil
    ) {
        self.isLoading.value = isLoading
        self.message.value = message
        self.buttonTitle.value = buttonTitle
        self.isButtonHidden.value = isButtonHidden
        self.onButtonActionClosure = onButtonActionClosure
    }
    
    func set(message: String?) {
        set(isLoading: true, message: message)
    }
    
    func showOnlyLoading() {
        set(isLoading: true, message: nil)
    }
    
    func clear() {
        set(isLoading: false, message: nil)
    }
    
    func onButtonAction() {
        onButtonActionClosure?()
    }
    
}
