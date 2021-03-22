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
import RxDataSources
import ZomatoFoundation
import ZomatoUIKit
import Zomato

final class RestaurantsListView: UIView {
    
    private let (collectionView, flowLayout) = UICollectionView.make {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 40
        flowLayout.sectionInset = UIConstants.defaultPadding
        
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.canGrow(.vertical)
        
        return (collectionView: collectionView, layout: flowLayout)
    }
    
    private let fullScreenStateView = FullScreenStateView().with {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isHidden = true
    }
    
    private let bottomStateView = BottomStateView().with {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.resistGrowing(.vertical)
        $0.isHidden = true
    }
    
    private let restaurantCellConfigurator = RestaurantCellConfigurator()
    
    private var disposeBag = DisposeBag()
    var viewModel: RestaurantsListViewModel? {
        didSet {
            disposeBag = DisposeBag()
            if let viewModel = viewModel {
                bind(to: viewModel, disposeBag: disposeBag)
            }
        }
    }
    
    init() {
        super.init(frame: .zero)
        
        setupViewHierarchy()
        setupConstraints()
        
        restaurantCellConfigurator.register(in: collectionView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let margins = flowLayout.sectionInset.left + flowLayout.sectionInset.right
        // On bigger screens we can have multiple cards per row
        let width = min((frame.width - margins), 350)
        
        flowLayout.itemSize = CGSize(
            width: width,
            height: 400
        )
    }
    
}

// MARK: UICollectionViewDataSourcePrefetching
extension RestaurantsListView: UICollectionViewDataSourcePrefetching {
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        guard !indexPaths.isEmpty else {
            return
        }
        guard let lastItem = indexPaths.sorted().last?.item else {
            return
        }
        viewModel?.input.preload.onNext(lastItem)
    }
    
}

// MARK: Private
extension RestaurantsListView {
    
    private func setupViewHierarchy() {
        addSubviews(
            collectionView,
            bottomStateView,
            fullScreenStateView
        )
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leftAnchor.constraint(equalTo: leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: rightAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            bottomStateView.leftAnchor.constraint(equalTo: leftAnchor),
            bottomStateView.rightAnchor.constraint(equalTo: rightAnchor),
            bottomStateView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            fullScreenStateView.topAnchor.constraint(equalTo: topAnchor),
            fullScreenStateView.leftAnchor.constraint(equalTo: leftAnchor),
            fullScreenStateView.rightAnchor.constraint(equalTo: rightAnchor),
            fullScreenStateView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
}

// MARK: Bind
extension RestaurantsListView {
    
    private func bind(
        to viewModel: RestaurantsListViewModel,
        disposeBag: DisposeBag
    ) {
        fullScreenStateView.viewModel = viewModel.output.fullScreenState
        bottomStateView.viewModel = viewModel.output.bottomScreenState
        
        disposeBag.insert(
            viewModel.output.fullScreenStateVisibleReadOnly
                .distinctUntilChanged()
                .drive(with: fullScreenStateView) { (fullScreenStateView, isVisible) in
                    if isVisible {
                        fullScreenStateView.fadeIn(withDuration: 0.66)
                    } else {
                        fullScreenStateView.fadeOut(withDuration: 0.33)
                    }
                },
            
            viewModel.output.bottomScreenStateVisibleReadOnly
                .distinctUntilChanged()
                .not()
                .drive(bottomStateView.rx.isHidden),
            
            collectionView.rx
                .prefetchItems
                .compactMap { indexPaths -> Int? in
                    guard !indexPaths.isEmpty else {
                        return nil
                    }
                    return indexPaths.sorted().last?.item
                }
                .bind(to: viewModel.input.preload),
            
            viewModel.output
                .restaurants
                .bind(
                    to: collectionView.rx.items(
                        dataSource: dataSource(viewModel: viewModel)
                    )
                )
        )
    }
    
    private func dataSource(
        viewModel: RestaurantsListViewModel
    ) -> RxCollectionViewSectionedAnimatedDataSource<RestaurantsListViewModel.Section> {
        let preloadInput = viewModel.input.preload
        let userLocation = viewModel.output.userLocation
        let restaurantManager = viewModel.restaurantManager
        let cellConfigurator = restaurantCellConfigurator
        
        return .init { (_, collectionView, indexPath, item) -> UICollectionViewCell in
            preloadInput.onNext(indexPath.item)
            return cellConfigurator.dequeueReusableCell(
                collectionView,
                cellForItemAt: indexPath,
                userCoordinate: userLocation,
                sectionElement: item,
                restaurantManager: restaurantManager
            )
        }
    }
    
}
