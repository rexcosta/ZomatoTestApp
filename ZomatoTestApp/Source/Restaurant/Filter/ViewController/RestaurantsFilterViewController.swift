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
import RxCocoa
import ZomatoFoundation
import ZomatoUIKit

final class RestaurantsFilterViewController: UIViewController {
    
    private let cancelButton = UIBarButtonItem(
        title: nil,
        style: .plain,
        target: nil,
        action: nil
    ).with {
        $0.tintColor = Theme.shared.primaryColor
    }
    private let contentStackView = UIStackView().with {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.axis = .vertical
        $0.isLayoutMarginsRelativeArrangement = true
        $0.layoutMargins = UIConstants.defaultMargins
        $0.spacing = UIConstants.defaultSpacing
    }
    private let restaurantsSortView = RestaurantsSortView().with {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    private let restaurantsFilterByPriceView = RestaurantsFilterByPriceView().with {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    private let applyFilterButton = UIButton().withPrimaryStyle
    
    private var disposeBag = DisposeBag()
    var viewModel: RestaurantsFilterViewControllerModel?
    
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
    
}

// MARK: Private
extension RestaurantsFilterViewController {
    
    private func setupViews() {
        view.backgroundColor = Theme.shared.backgroundColor
        
        navigationItem.rightBarButtonItems = [
            cancelButton
        ]
    }
    
    private func setupViewHierarchy() {
        view.addSubview(contentStackView)
        contentStackView.addArrangedSubviews(
            restaurantsSortView,
            UIView().with({
                $0.backgroundColor = Theme.shared.separatorLineColor
                $0.heightAnchor.constraint(equalToConstant: 1).isActive = true
            }),
            restaurantsFilterByPriceView,
            applyFilterButton
        )
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            contentStackView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            contentStackView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func bind(
        to viewModel: RestaurantsFilterViewControllerModel,
        disposeBag: DisposeBag
    ) {
        restaurantsSortView.viewModel = viewModel.sortViewModel
        restaurantsFilterByPriceView.viewModel = viewModel.filterByPriceViewModel
        
        disposeBag.insert(
            viewModel.output.title.drive(rx.title),
            
            applyFilterButton.bind(
                input: viewModel.input.applyFilterOptions,
                output: viewModel.output.applyFilterReadOnly
            ),
            
            cancelButton.bind(
                input: viewModel.input.cancel,
                output: viewModel.output.cancelReadOnly
            )
        )
    }
    
}
