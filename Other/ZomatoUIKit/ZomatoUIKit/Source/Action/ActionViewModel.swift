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

public struct ActionViewModel {
    
    public let title: BehaviorRelay<String?>
    public let image: BehaviorRelay<UIImage?>
    public let isEnabled: BehaviorRelay<Bool>
    public let isHidden: BehaviorRelay<Bool>
    public let action: PublishSubject<Void>
    
    public init(
        title: BehaviorRelay<String?> = BehaviorRelay<String?>(value: nil),
        image: BehaviorRelay<UIImage?> = BehaviorRelay<UIImage?>(value: nil),
        isEnabled: BehaviorRelay<Bool> = BehaviorRelay<Bool>(value: true),
        isHidden: BehaviorRelay<Bool> = BehaviorRelay<Bool>(value: false),
        action: PublishSubject<Void> = PublishSubject<Void>()
    ) {
        self.title = title
        self.image = image
        self.isEnabled = isEnabled
        self.isHidden = isHidden
        self.action = action
    }
    
    public init(
        title: String? = nil,
        image: UIImage? = nil,
        isEnabled: Bool = true,
        isHidden: Bool = false,
        action: PublishSubject<Void> = PublishSubject<Void>()
    ) {
        self.init(
            title: BehaviorRelay<String?>(value: title),
            image: BehaviorRelay<UIImage?>(value: image),
            isEnabled: BehaviorRelay<Bool>(value: isEnabled),
            isHidden: BehaviorRelay<Bool>(value: isHidden),
            action: action
        )
    }
    
}
