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
import Zomato

final class AppCoordinator: BaseCoordinator<Void> {
    
    private let zomato: Zomato
    private let window: UIWindow
    private var launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    
    init(
        zomato: Zomato,
        window: UIWindow,
        launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) {
        self.zomato = zomato
        self.window = window
        self.launchOptions = launchOptions
    }
    
    override func start() -> Observable<CoordinationResult> {
        let navigationController = UINavigationController()
        let navigation = NavigationControllerNavigation(
            navigationController: navigationController
        )
        let searchCoordinator = SearchCoordinator(
            zomato: zomato,
            navigation: navigation
        )
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        return coordinate(to: searchCoordinator)
    }
    
}
