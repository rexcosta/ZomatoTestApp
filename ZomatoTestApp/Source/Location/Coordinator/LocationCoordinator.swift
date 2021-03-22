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

final class LocationCoordinator: BaseCoordinator<Void> {
    
    private let navigation: NavigationProtocol
    private let error: Error
    
    init(
        navigation: NavigationProtocol,
        error: Error
    ) {
        self.navigation = navigation
        self.error = error
    }
    
    override func start() -> Observable<CoordinationResult> {
        let filterViewController = LocationErrorViewController()
        let viewModel = LocationErrorViewControllerModel(
            error: error
        )
        filterViewController.viewModel = viewModel
        let navigationController = UINavigationController(
            rootViewController: filterViewController
        )
        
        let dismiss = navigation.presentObservingDismiss(navigationController, animated: true)
        
        return Observable.merge(viewModel.output.closeAction, dismiss)
            .take(1)
            .do(onNext: { [weak self] _ in self?.navigation.dismiss(animated: true) })
    }
    
}
