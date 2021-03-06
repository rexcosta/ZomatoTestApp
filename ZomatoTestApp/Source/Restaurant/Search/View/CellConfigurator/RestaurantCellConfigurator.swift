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

struct RestaurantCellConfigurator {
    
    func register(in collectionView: UICollectionView) {
        collectionView.register(
            RestaurantCollectionViewCell.self,
            forCellWithReuseIdentifier: "restaurant-cell"
        )
    }
    
    func dequeueReusableCell(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath,
        restaurantManager: RestaurantManagerProtocol?,
        restaurant: RestaurantModelProtocol?
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "restaurant-cell",
                for: indexPath
        ) as? RestaurantCollectionViewCell else {
            fatalError()
        }
        
        guard let restaurantManager = restaurantManager,
              let restaurant = restaurant else {
            return cell
        }
        
        cell.viewModel.set(
            restaurant: restaurant,
            restaurantManager: restaurantManager
        )
        return cell
    }
    
}
