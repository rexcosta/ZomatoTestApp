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
import Kingfisher

final class RestaurantCollectionViewCell: UICollectionViewCell {
    
    private let contentStackView = UIStackView().with {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.axis = .vertical
        $0.isLayoutMarginsRelativeArrangement = true
        $0.layoutMargins = UIConstants.defaultMargins
        $0.spacing = UIConstants.defaultSpacing
    }
    
    private let thumbnailImageView = UIImageView().with {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentMode = .scaleAspectFill
        $0.layer.masksToBounds = true
    }
    private let favouriteButton = UIButton(type: .system).with {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.tintColor = Theme.shared.primaryColor
    }
    private let distanceLabel = RoundEdgesLabel().with {
        $0.translatesAutoresizingMaskIntoConstraints = false
        _ = $0.label.withLabelStyle
    }
    private let nameLabel = UILabel().withTitleStyle
    private let cuisinesLabel = UILabel().withTextStyle
    private let timingsLabel = UILabel().withTextStyle.with {
        $0.lineBreakMode = .byTruncatingTail
    }
    private let priceRangeLabel = UILabel().withTextStyle
    
    let viewModel = RestaurantCollectionViewCellViewModel()
    let accessibilityModel = RestaurantCollectionViewCellAccessibilityModel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
        setupViewHierarchy()
        setupConstraints()
        
        bind(to: viewModel)
        bind(
            accessibilityModel: accessibilityModel,
            to: viewModel
        )
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
extension RestaurantCollectionViewCell {
    
    private func setupViews() {
        backgroundColor = .clear
        contentView.backgroundColor = Theme.shared.cellBackgroundColor
        set(cornerRadius: 12.0)
        set(
            shadowColor: .black,
            shadowOpacity: 0.3
        )
        
        favouriteButton.addTarget(
            self,
            action: #selector(onUserDidPressFavouriteAction),
            for: .touchUpInside
        )
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(onUserDidPressFavouriteAction))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delaysTouchesBegan = true
        contentView.addGestureRecognizer(doubleTap)
    }
    
    private func setupViewHierarchy() {
        contentView.addSubviews(
            thumbnailImageView,
            favouriteButton,
            distanceLabel,
            contentStackView
        )
        contentStackView.addArrangedSubviews(
            nameLabel,
            cuisinesLabel,
            timingsLabel,
            priceRangeLabel
        )
    }
    
    private func setupConstraints() {
        nameLabel.resistGrowing(.vertical)
        cuisinesLabel.canGrow(.vertical)
        timingsLabel.resistGrowing(.vertical)
        timingsLabel.canShrink(.vertical)
        priceRangeLabel.resistGrowing(.vertical)
        
        NSLayoutConstraint.activate([
            thumbnailImageView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor),
            thumbnailImageView.leftAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leftAnchor),
            thumbnailImageView.rightAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.rightAnchor),
            thumbnailImageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.6),
            thumbnailImageView.bottomAnchor.constraint(equalTo: contentStackView.topAnchor),
            
            favouriteButton.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 8),
            favouriteButton.rightAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.rightAnchor, constant: -8),
            favouriteButton.heightAnchor.constraint(equalToConstant: 40),
            favouriteButton.widthAnchor.constraint(equalTo: favouriteButton.heightAnchor),
            
            distanceLabel.rightAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.rightAnchor, constant: -8),
            distanceLabel.bottomAnchor.constraint(equalTo: thumbnailImageView.bottomAnchor, constant: -8),
            
            contentStackView.leftAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leftAnchor),
            contentStackView.rightAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.rightAnchor),
            contentStackView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
}

// MARK: Bind
extension RestaurantCollectionViewCell {
    
    private func bind(
        accessibilityModel: RestaurantCollectionViewCellAccessibilityModel,
        to viewModel: RestaurantCollectionViewCellViewModel
    ) {
        accessibilityModel.bind(viewModel: viewModel)
        
        distanceLabel.label.bindAccessibility(to: accessibilityModel.distanceAccessibility)
        nameLabel.bindAccessibility(to: accessibilityModel.nameAccessibility)
        cuisinesLabel.bindAccessibility(to: accessibilityModel.cuisinesAccessibility)
        timingsLabel.bindAccessibility(to: accessibilityModel.timingsAccessibility)
        priceRangeLabel.bindAccessibility(to: accessibilityModel.priceRangeAccessibility)
        favouriteButton.bindAccessibility(to: accessibilityModel.favouriteButtonAccessibility)
    }
    
    private func bind(to viewModel: RestaurantCollectionViewCellViewModel) {
        nameLabel.bindText(to: viewModel.name)
        cuisinesLabel.bindText(to: viewModel.cuisines)
        timingsLabel.bindText(to: viewModel.timings)
        priceRangeLabel.bindText(to: viewModel.priceRange)
        
        viewModel.distance.observeOnMainContext(
            fire: true,
            whileTargetAlive: distanceLabel
        ) { (distanceLabel, distance) in
            switch distance {
            case .near(let title):
                distanceLabel.set(
                    text: title,
                    backgroundColor: Theme.shared.distance.near
                )
                
            case .nearby(let title):
                distanceLabel.set(
                    text: title,
                    backgroundColor: Theme.shared.distance.nearby
                )
                
            case .far(let title):
                distanceLabel.set(
                    text: title,
                    backgroundColor: Theme.shared.distance.far
                )
                
            case .unknown(let title):
                distanceLabel.set(
                    text: title,
                    backgroundColor: Theme.shared.distance.far
                )
            }
        }
        
        viewModel.favouriteButton.observeOnMainContext(
            fire: true,
            whileTargetAlive: favouriteButton
        ) { (favouriteButton, newValue) in
            switch newValue {
            case .unknown(let isHidden, let image):
                favouriteButton.isHidden = isHidden
                favouriteButton.setImage(image, for: .normal)
                
            case .favourite(let isHidden, let image):
                favouriteButton.isHidden = isHidden
                favouriteButton.setImage(image, for: .normal)
                favouriteButton.fastBounce()
                
            case .notFavourite(let isHidden, let image):
                favouriteButton.isHidden = isHidden
                favouriteButton.setImage(image, for: .normal)
                favouriteButton.fastBounce()
            }
        }
        
        viewModel.thumbnailImage.observeOnMainContext(
            fire: true,
            whileTargetAlive: thumbnailImageView
        ) { (thumbnailImageView, url) in
            thumbnailImageView.kf.setImage(
                with: url,
                placeholder: Asset.placeholder.image
            )
        }
    }
    
}

// MARK: Listeners
extension RestaurantCollectionViewCell {
    
    @objc
    private func onUserDidPressFavouriteAction() {
        viewModel.onUserDidPressFavouriteAction()
    }
    
}
