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
import Zomato

final class PriceRangeCollectionViewCell: UICollectionViewCell {
    
    private let priceLabel = UILabel().withSubTitleStyle
    
    private var disposeBag = DisposeBag()
    var viewModel: PriceRangeCollectionViewCellViewModel? {
        didSet {
            disposeBag = DisposeBag()
            if let viewModel = viewModel {
                bind(to: viewModel, disposeBag: disposeBag)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
        setupViewHierarchy()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.shadowPath = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: contentView.layer.cornerRadius
        ).cgPath
    }
    
}

// MARK: Private
extension PriceRangeCollectionViewCell {
    
    private func setupViews() {
        backgroundColor = .clear
        contentView.backgroundColor = Theme.shared.cellBackgroundColor
        set(cornerRadius: 12.0)
        set(
            shadowColor: .black,
            shadowOpacity: 0.3
        )
    }
    
    private func setupViewHierarchy() {
        contentView.addSubviews(
            priceLabel
        )
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            priceLabel.topAnchor.constraint(
                equalTo: contentView.safeAreaLayoutGuide.topAnchor,
                constant: UIConstants.defaultPadding.top
            ),
            priceLabel.leftAnchor.constraint(
                equalTo: contentView.safeAreaLayoutGuide.leftAnchor,
                constant: UIConstants.defaultPadding.left
            ),
            priceLabel.rightAnchor.constraint(
                equalTo: contentView.safeAreaLayoutGuide.rightAnchor,
                constant: -UIConstants.defaultPadding.right
            ),
            priceLabel.bottomAnchor.constraint(
                equalTo: contentView.safeAreaLayoutGuide.bottomAnchor,
                constant: -UIConstants.defaultPadding.bottom
            )
        ])
    }
    
    private func bind(
        to viewModel: PriceRangeCollectionViewCellViewModel,
        disposeBag: DisposeBag
    ) {
        disposeBag.insert(
            viewModel.output.title.drive(priceLabel.rx.text),
            viewModel.output.color.drive(contentView.rx.backgroundColor)
        )
    }
    
}
