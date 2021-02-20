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

final class RestaurantsViewController: UIViewController {
    
    private let restaurantsListView = RestaurantsListView().with {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private let filterButton = UIBarButtonItem(
        image: Asset.filter.image,
        style: .plain,
        target: nil,
        action: nil
    ).with {
        $0.tintColor = Theme.shared.primaryColor
    }
    
    var viewModel: RestaurantsViewControllerModel?
    
    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupViewHierarchy()
        setupConstraints()
        
        disposeBag = DisposeBag()
        if let viewModel = viewModel {
            bind(to: viewModel, disposeBag: disposeBag)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel?.viewWillAppearEvent.onNext()
    }
    
}

// MARK: Private
extension RestaurantsViewController {
    
    private func setupViews() {
        view.backgroundColor = Theme.shared.backgroundColor
    }
    
    private func setupViewHierarchy() {
        view.addSubview(restaurantsListView)
        
        navigationItem.rightBarButtonItems = [filterButton]
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            restaurantsListView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            restaurantsListView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            restaurantsListView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            restaurantsListView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func bind(
        to viewModel: RestaurantsViewControllerModel,
        disposeBag: DisposeBag
    ) {
        restaurantsListView.viewModel = viewModel.restaurantsListViewModel
        
        disposeBag.insert(
            viewModel.title.drive(rx.title),
            
            viewModel.isFilterEnabledReadOnly.driver
                .drive(filterButton.rx.isEnabled),
            
            filterButton.rx.tap
                .subscribe(viewModel.filterAction)
        )
    }
    
}
