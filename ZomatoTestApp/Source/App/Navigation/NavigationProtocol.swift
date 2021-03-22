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

import UIKit
import RxSwift

protocol NavigationProtocol: class {
    
    typealias NavigationShowClosure = (() -> Void)
    typealias NavigationBackClosure = (() -> Void)
    typealias PresentClosure = (() -> Void)
    typealias DismissClosure = (() -> Void)
    
    func setContent(
        _ viewController: UIViewController,
        animated: Bool
    )
    
    func push(
        _ viewController: UIViewController,
        animated: Bool,
        onNavigateBack: NavigationBackClosure?,
        onDidShow: NavigationShowClosure?
    )
    
    func pop(
        _ animated: Bool
    )
    
    func popToRoot(
        _ animated: Bool
    )
    
    func present(
        _ viewControllerToPresent: UIViewController,
        animated: Bool,
        onDismiss: DismissClosure?,
        onDidShow: PresentClosure?
    )
    
    func dismiss(
        animated: Bool
    )
    
}

// MARK: Present
extension NavigationProtocol {
    
    func present(
        _ viewControllerToPresent: UIViewController,
        animated: Bool
    ) {
        present(viewControllerToPresent, animated: animated, onDismiss: nil, onDidShow: nil)
    }
    
    func present(
        _ viewControllerToPresent: UIViewController,
        animated: Bool,
        onDidShow: PresentClosure?
    ) {
        present(viewControllerToPresent, animated: animated, onDismiss: nil, onDidShow: onDidShow)
    }
    
    func present(
        _ viewControllerToPresent: UIViewController,
        animated: Bool,
        onDismiss: DismissClosure?
    ) {
        present(viewControllerToPresent, animated: animated, onDismiss: onDismiss, onDidShow: nil)
    }
    
    func presentObservingDismiss(
        _ viewControllerToPresent: UIViewController,
        animated: Bool
    ) -> Observable<Void> {
        let dismissSubject = PublishSubject<Void>()
        present(viewControllerToPresent, animated: animated, onDismiss: {
            dismissSubject.onNext()
            dismissSubject.onCompleted()
        })
        return dismissSubject
    }
    
}

// MARK: Push
extension NavigationProtocol {
    
    func push(
        _ viewController: UIViewController,
        animated: Bool
    ) {
        push(viewController, animated: animated, onNavigateBack: nil, onDidShow: nil)
    }
    
    func push(
        _ viewController: UIViewController,
        animated: Bool,
        onDidShow: NavigationShowClosure?
    ) {
        push(viewController, animated: animated, onNavigateBack: nil, onDidShow: onDidShow)
    }
    
    func push(
        _ viewController: UIViewController,
        animated: Bool,
        onNavigateBack: NavigationBackClosure?
    ) {
        push(viewController, animated: animated, onNavigateBack: onNavigateBack, onDidShow: nil)
    }
    
    func push(
        _ viewController: UIViewController,
        animated: Bool
    ) -> Observable<Void> {
        let goBackSubject = PublishSubject<Void>()
        push(viewController, animated: animated, onNavigateBack: {
            goBackSubject.onNext()
            goBackSubject.onCompleted()
        })
        return goBackSubject
    }
    
}
