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

final class LocationErrorViewController: UIViewController {
    
    private let okButton = UIBarButtonItem(
        title: L10n.Localizable.Global.Button.ok.value,
        style: .plain,
        target: nil,
        action: nil
    )
    
    private let messageLabel = UILabel().withSubTitleStyle
    
    private var disposeBag = DisposeBag()
    var viewModel: LocationErrorViewControllerModelProtocol?
    
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
extension LocationErrorViewController {
    
    private func setupViews() {
        view.backgroundColor = Theme.shared.backgroundColor
        
        navigationItem.rightBarButtonItems = [
            okButton
        ]
    }
    
    private func setupViewHierarchy() {
        view.addSubview(messageLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            messageLabel.leftAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leftAnchor,
                constant: UIConstants.defaultPadding.left
            ),
            messageLabel.rightAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.rightAnchor,
                constant: -UIConstants.defaultPadding.right
            ),
            messageLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func bind(
        to viewModel: LocationErrorViewControllerModelProtocol,
        disposeBag: DisposeBag
    ) {
        disposeBag.insert(
            viewModel.title.drive(rx.title),
            
            viewModel.errorMessage.drive(messageLabel.rx.text),
            
            okButton.rx.tap
                .subscribe(viewModel.closeAction)
        )
    }
    
}
