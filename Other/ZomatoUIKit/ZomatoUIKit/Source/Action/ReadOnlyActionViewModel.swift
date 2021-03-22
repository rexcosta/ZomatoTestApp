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

public struct ReadOnlyOutputActionViewModel<Output> {
    
    public let title: Driver<String?>
    public let image: Driver<UIImage?>
    public let isEnabled: Driver<Bool>
    public let isHidden: Driver<Bool>
    public let action: Observable<Output>
    
    public init(
        actionModel: OutputActionViewModel<Output>
    ) {
        self.title = actionModel.title.asDriver()
        self.image = actionModel.image.asDriver()
        self.isEnabled = actionModel.isEnabled.asDriver()
        self.isHidden = actionModel.isHidden.asDriver()
        self.action = actionModel.action.asObservable()
    }
    
}

public struct ReadOnlyActionViewModel {
    
    public let title: Driver<String?>
    public let image: Driver<UIImage?>
    public let isEnabled: Driver<Bool>
    public let isHidden: Driver<Bool>
    
    public init(
        actionModel: ActionViewModel
    ) {
        self.title = actionModel.title.asDriver()
        self.image = actionModel.image.asDriver()
        self.isEnabled = actionModel.isEnabled.asDriver()
        self.isHidden = actionModel.isHidden.asDriver()
    }
    
}
