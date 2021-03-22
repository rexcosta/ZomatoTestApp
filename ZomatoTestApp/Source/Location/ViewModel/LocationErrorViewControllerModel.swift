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
import ZomatoUIKit
import Zomato

final class LocationErrorViewControllerModel {
    
    let input: Input
    let output: Output
    private let disposeBag = DisposeBag()
    
    init(error: Error) {
        input = Input()
        output = Output(
            title: L10n.Localizable.Screen.Permissions.Location.title,
            closeTitle: L10n.Localizable.Global.Button.ok,
            errorMessage: AppErrorLocalizationMapper().mapInput(error),
            closeAction: input.closeAction.asObservable()
        )
    }
    
}

// MARK: - LocationErrorViewControllerModel.Input
extension LocationErrorViewControllerModel {
    
    struct Input {
        let closeAction = PublishSubject<Void>()
    }
    
}

// MARK: - LocationErrorViewControllerModel.Output
extension LocationErrorViewControllerModel {
    
    struct Output {
        let title: Driver<String?>
        let closeTitle: Driver<String?>
        let errorMessage: Driver<String?>
        let closeAction: Observable<Void>
        
        init(
            title: LocalizedString,
            closeTitle: LocalizedString,
            errorMessage: LocalizedString,
            closeAction: Observable<Void>
        ) {
            self.title = BehaviorRelay<String?>(
                value: title.value
            ).asDriver()
            
            self.closeTitle = BehaviorRelay<String?>(
                value: closeTitle.value
            ).asDriver()
            
            self.errorMessage = BehaviorRelay<String?>(
                value: errorMessage.value
            ).asDriver()
            
            self.closeAction = closeAction
        }
    }
    
}
