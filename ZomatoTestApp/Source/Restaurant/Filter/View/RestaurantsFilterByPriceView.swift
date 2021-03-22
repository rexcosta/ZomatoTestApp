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

final class RestaurantsFilterByPriceView: UIView {
    
    private let filterByPriceRangeLabel = UILabel().withLabelStyle
    
    private let (collectionView, flowLayout) = UICollectionView.make {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumInteritemSpacing = 20
        flowLayout.minimumLineSpacing = 20
        flowLayout.sectionInset = UIConstants.defaultPadding
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.allowsMultipleSelection = true
        collectionView.canGrow(.vertical)
        
        return (collectionView: collectionView, layout: flowLayout)
    }
    
    private let priceRangeCellConfigurator = PriceRangeCellConfigurator()
    
    private var disposeBag = DisposeBag()
    var viewModel: RestaurantsFilterByPriceViewModel? {
        didSet {
            disposeBag = DisposeBag()
            if let viewModel = viewModel {
                bind(to: viewModel, disposeBag: disposeBag)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViewHierarchy()
        setupConstraints()
        
        priceRangeCellConfigurator.register(in: collectionView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let margins = flowLayout.sectionInset.left + flowLayout.sectionInset.right
        // On bigger screens we can have multiple cards per row
        let width = min((frame.width - margins), 200)
        
        flowLayout.itemSize = CGSize(
            width: width,
            height: 50
        )
    }
    
}

// MARK: Private
extension RestaurantsFilterByPriceView {
    
    private func setupViewHierarchy() {
        addSubviews(
            filterByPriceRangeLabel,
            collectionView
        )
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            filterByPriceRangeLabel.topAnchor.constraint(equalTo: topAnchor),
            filterByPriceRangeLabel.leftAnchor.constraint(equalTo: leftAnchor),
            filterByPriceRangeLabel.rightAnchor.constraint(equalTo: rightAnchor),
            filterByPriceRangeLabel.bottomAnchor.constraint(
                equalTo: collectionView.topAnchor,
                constant: -UIConstants.defaultSpacing
            ),
            
            collectionView.leftAnchor.constraint(equalTo: leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: rightAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func bind(
        to viewModel: RestaurantsFilterByPriceViewModel,
        disposeBag: DisposeBag
    ) {
        disposeBag.insert(
            viewModel.output.title.drive(filterByPriceRangeLabel.rx.text),
            
            viewModel.output.prices.bind(
                to: collectionView.rx.items(
                    cellIdentifier: "filter-price-cell",
                    cellType: PriceRangeCollectionViewCell.self
                )
            ) { (_, viewModel, cell) in
                cell.viewModel = viewModel
            },
            
            collectionView.rx.modelDeselected(PriceRangeCollectionViewCellViewModel.self).subscribe(onNext: { intem in
                intem.input.isSelected.accept(false)
            }),
            
            collectionView.rx.modelSelected(PriceRangeCollectionViewCellViewModel.self).subscribe(onNext: { intem in
                intem.input.isSelected.accept(true)
            })
        )
    }
    
}
