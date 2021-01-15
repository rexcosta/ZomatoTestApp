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

import ZomatoFoundation
import Zomato
import UIKit

final class BottomStateView: UIView {
    
    private let activiewIndicatorView = UIActivityIndicatorView(style: .gray).with {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.hidesWhenStopped = true
        $0.color = Theme.shared.primaryColor
    }
    
    private let messageLabel = UILabel().withSubTitleStyle
    
    private let actionButton = UIButton(type: .system).withPrimaryStyle
    
    var viewModel: BottomStateViewModel? {
        didSet {
            if let viewModel = viewModel {
                bind(to: viewModel)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupViewHierarchy()
        setupConstraints()
        
        backgroundColor = Theme.shared.transparentBackgroundColor
        layer.cornerRadius = 12
        layer.masksToBounds = true
        
        set(shadowColor: Theme.shared.shadowColor, shadowOpacity: 0.6)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.shadowPath = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: layer.cornerRadius
        ).cgPath
    }
    
}

// MARK: Private
extension BottomStateView {
    
    private func setupViews() {
        actionButton.addTarget(
            self,
            action: #selector(onStateButtonPress),
            for: .touchUpInside
        )
    }
    
    private func setupViewHierarchy() {
        addSubviews(
            activiewIndicatorView,
            messageLabel,
            actionButton
        )
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            activiewIndicatorView.topAnchor.constraint(
                equalTo: topAnchor,
                constant: UIConstants.defaultPadding.top
            ),
            activiewIndicatorView.centerXAnchor.constraint(equalTo: centerXAnchor),
            activiewIndicatorView.bottomAnchor.constraint(
                equalTo: messageLabel.topAnchor,
                constant: -(UIConstants.defaultSpacing * 2)
            ),
            
            messageLabel.leftAnchor.constraint(
                equalTo: leftAnchor,
                constant: UIConstants.defaultPadding.left
            ),
            messageLabel.rightAnchor.constraint(
                equalTo: rightAnchor,
                constant: -UIConstants.defaultPadding.right
            ),
            messageLabel.bottomAnchor.constraint(
                equalTo: actionButton.topAnchor,
                constant: -UIConstants.defaultPadding.bottom
            ),
            
            actionButton.centerXAnchor.constraint(
                equalTo: centerXAnchor
            ),
            actionButton.widthAnchor.constraint(
                greaterThanOrEqualTo: widthAnchor,
                multiplier: 0.6
            ),
            actionButton.leftAnchor.constraint(
                greaterThanOrEqualTo: leftAnchor,
                constant: UIConstants.defaultPadding.left
            ),
            actionButton.rightAnchor.constraint(
                lessThanOrEqualTo: rightAnchor,
                constant: -UIConstants.defaultPadding.right
            ),
            actionButton.bottomAnchor.constraint(
                equalTo: safeAreaLayoutGuide.bottomAnchor,
                constant: -UIConstants.defaultPadding.bottom
            )
        ])
    }
    
    private func bind(to viewModel: BottomStateViewModel) {
        activiewIndicatorView.bindIsAnimating(to: viewModel.isLoading)
        actionButton.bindTitle(to: viewModel.buttonTitle, for: .normal)
        actionButton.bindIsHidden(to: viewModel.isButtonHidden)
        viewModel.message.observeOnMainContext(
            fire: true,
            whileTargetAlive: messageLabel
        ) { (me, newValue) in
            guard let newValue = newValue else {
                me.text = nil
                return
            }
            me.text = newValue
            me.longgerBounce()
        }
    }
    
}

// MARK: Listeners
extension BottomStateView {
    
    @objc
    private func onStateButtonPress() {
        viewModel?.onButtonAction()
    }
    
}
