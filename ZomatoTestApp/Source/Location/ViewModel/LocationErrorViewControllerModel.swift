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
import Zomato

protocol LocationErrorViewControllerModelProtocol {
    var title: Driver<String?> { get }
    var errorMessage: Driver<String?> { get }
    var closeAction: PublishSubject<Void> { get }
}

final class LocationErrorViewControllerModel: LocationErrorViewControllerModelProtocol {
    
    let title = BehaviorRelay<String?>(
        value: L10n.Localizable.Screen.Permissions.Location.title.value
    ).asDriver()
    
    let errorMessage = BehaviorRelay<String?>(
        value: L10n.Localizable.Screen.Permissions.Location.error.value
    ).asDriver()
    
    let closeAction = PublishSubject<Void>()
    
    private let disposeBag = DisposeBag()
    
    init(
        coordinator: AppCoordinator,
        error: Location.LocationError
    ) {
        disposeBag.insert(
            bindCloseAction(coordinator: coordinator)
        )
    }
    
    private func bindCloseAction(
        coordinator: AppCoordinator
    ) -> Disposable {
        return closeAction.subscribe { _ in
            coordinator.goHome()
        }
    }
    
}
