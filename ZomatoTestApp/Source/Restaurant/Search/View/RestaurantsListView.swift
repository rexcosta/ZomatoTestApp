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
    
    var viewModel: RestaurantsListViewModel? {
        didSet {
            if let viewModel = viewModel {
                bind(to: viewModel)
            }
        }
    }
    
    init() {
        super.init(frame: .zero)
        
        setupViewHierarchy()
        setupConstraints()
        
        restaurantCellConfigurator.register(in: collectionView)
        collectionView.dataSource = self
        collectionView.prefetchDataSource = self
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

// MARK: UICollectionViewDataSource
extension RestaurantsListView: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.numberOfRestaurants() ?? 0
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        
        // If the collectionview has few items
        // like for example 1, UICollectionViewDataSourcePrefetching will not be called
        // because we dont want our business logic to be responsible for this we preload manualy
        DispatchQueue.main.async {
            self.viewModel?.preloadElement(at: indexPath.item)
        }
        
        return restaurantCellConfigurator.dequeueReusableCell(
            collectionView,
            cellForItemAt: indexPath,
            viewModel: viewModel
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
        viewModel?.preloadElement(at: lastItem)
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
    
    private func bind(to viewModel: RestaurantsListViewModel) {
        viewModel.readOnlyCollectionDataChange.observeOnMainContext(
            fire: true,
            whileTargetAlive: self
        ) { (me, dataChange) in
            me.receivedNew(viewModelDataChange: dataChange)
        }
        
        fullScreenStateView.viewModel = viewModel.fullScreenState
        viewModel.fullScreenStateVisible.observeOnMainContext(
            fire: true,
            whileTargetAlive: fullScreenStateView
        ) { (fullScreenStateView, isVisible) in
            if isVisible {
                fullScreenStateView.fadeIn(withDuration: 0.66)
            } else {
                fullScreenStateView.fadeOut(withDuration: 0.33)
                
            }
        }
        
        bottomStateView.viewModel = viewModel.bottomScreenState
        viewModel.bottomScreenStateVisible.observeOnMainContext(
            fire: true,
            whileTargetAlive: bottomStateView
        ) { (bottomStateView, newValue) in
            bottomStateView.isHidden = !newValue
        }
    }
    
    private func receivedNew(viewModelDataChange: RestaurantsListViewModel.DataChange) {
        switch viewModelDataChange {
        case .reload:
            collectionView.reloadData()
            
        case .insert(let indexs):
            collectionView.performBatchUpdates({
                collectionView.insertItems(at: indexs)
            }, completion: nil)
        }
    }
    
}
