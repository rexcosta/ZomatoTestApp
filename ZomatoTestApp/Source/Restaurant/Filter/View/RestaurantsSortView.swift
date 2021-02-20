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

final class RestaurantsSortView: UIView {
    
    private let sortByLocationLabel = UILabel().withLabelStyle
    private let sortByLocationSwitch = UISwitch().with {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.onTintColor = Theme.shared.primaryColor
    }
    
    private var disposeBag = DisposeBag()
    var viewModel: RestaurantsSortViewModel? {
        didSet {
            if let viewModel = viewModel {
                bind(to: viewModel)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViewHierarchy()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: Private
extension RestaurantsSortView {
    
    private func setupViewHierarchy() {
        addSubviews(
            sortByLocationLabel,
            sortByLocationSwitch
        )
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            heightAnchor.constraint(greaterThanOrEqualTo: sortByLocationSwitch.heightAnchor),
            
            sortByLocationLabel.topAnchor.constraint(equalTo: topAnchor),
            sortByLocationLabel.leftAnchor.constraint(equalTo: leftAnchor),
            sortByLocationLabel.rightAnchor.constraint(lessThanOrEqualTo: sortByLocationSwitch.leftAnchor),
            sortByLocationLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            sortByLocationSwitch.centerYAnchor.constraint(equalTo: centerYAnchor),
            sortByLocationSwitch.rightAnchor.constraint(equalTo: rightAnchor)
        ])
    }
    
    private func bind(to viewModel: RestaurantsSortViewModel) {
        disposeBag.insert(
            viewModel.title.drive(sortByLocationLabel.rx.text),
            
            viewModel.isSortActive.twoWayBind(to: sortByLocationSwitch.rx.isOn)
        )
    }
    
}
