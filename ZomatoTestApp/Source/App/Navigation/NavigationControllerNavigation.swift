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

final class NavigationControllerNavigation: NSObject, NavigationProtocol {
    
    private let navigationController: UINavigationController
    
    private var dismissClosures: [String: DismissClosure] = [:]
    private var backClosures: [String: NavigationBackClosure] = [:]
    private var didShowClosures: [String: NavigationShowClosure] = [:]
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        super.init()
        self.navigationController.delegate = self
    }
    
    func setContent(_ viewController: UIViewController, animated: Bool) {
        navigationController.setViewControllers([viewController], animated: animated)
    }
    
    func push(
        _ viewController: UIViewController,
        animated: Bool,
        onNavigateBack backClosure: NavigationBackClosure?,
        onDidShow showClosure: NavigationShowClosure?
    ) {
        if let backClosure = backClosure {
            backClosures.updateValue(backClosure, forKey: viewController.description)
        }
        if let showClosure = showClosure {
            didShowClosures.updateValue(showClosure, forKey: viewController.description)
        }
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func pop(_ animated: Bool) {
        navigationController.popViewController(animated: animated)
    }
    
    func popToRoot(_ animated: Bool) {
        navigationController.popToRootViewController(animated: animated)
    }
    
    func present(
        _ viewControllerToPresent: UIViewController,
        animated: Bool,
        onDismiss: DismissClosure?,
        onDidShow: PresentClosure?
    ) {
        if let onDismiss = onDismiss {
            dismissClosures.updateValue(onDismiss, forKey: viewControllerToPresent.description)
        }
        if #available(iOS 13.0, *) {
            viewControllerToPresent.presentationController?.delegate = self
        }
        navigationController.present(
            viewControllerToPresent,
            animated: true,
            completion: onDidShow
        )
    }
    
    func dismiss(animated: Bool) {
        let completion: (() -> Void)?
        if let presentedViewController = navigationController.presentedViewController {
            completion = dismissClosures.removeValue(forKey: presentedViewController.description)
        } else {
            completion = nil
        }
        navigationController.presentedViewController?.dismiss(animated: true, completion: completion)
    }
    
}

// MARK: Helpers
extension NavigationControllerNavigation {
    
    private func executeBackClosure(_ viewController: UIViewController) {
        guard let closure = backClosures.removeValue(forKey: viewController.description) else { return }
        closure()
    }
    
    private func executeDidShowClosure(_ viewController: UIViewController) {
        guard let closure = didShowClosures.removeValue(forKey: viewController.description) else {
            return
        }
        closure()
    }
    
}

// MARK: - UIAdaptivePresentationControllerDelegate
extension NavigationControllerNavigation: UIAdaptivePresentationControllerDelegate {
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        guard let closure = dismissClosures.removeValue(forKey: presentationController.presentedViewController.description) else {
            return
        }
        closure()
    }
    
}

// MARK: - UINavigationControllerDelegate
extension NavigationControllerNavigation: UINavigationControllerDelegate {
    
    func navigationController(
        _ navigationController: UINavigationController,
        didShow viewController: UIViewController,
        animated: Bool
    ) {
        
        if let previousController = navigationController.transitionCoordinator?.viewController(forKey: .from) {
            
            // If the previous controller is not in the controllers stack we moved backwards
            if !navigationController.viewControllers.contains(previousController) {
                executeBackClosure(previousController)
                return
            }
        }
        
        guard let topViewController = navigationController.topViewController else {
            return
        }
        
        // If the new controller is in top of stack we are showing this controller
        if topViewController === viewController {
            executeDidShowClosure(viewController)
        }
    }
    
}
