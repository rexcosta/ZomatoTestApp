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

public final class RoundEdgesLabel: UIView {
    
    public let label = UILabel()
    
    private var leftConstraint: NSLayoutConstraint?
    private var rightConstraint: NSLayoutConstraint?
    
    public init() {
        super.init(frame: .zero)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        
        let leftConstraint = label.leftAnchor.constraint(equalTo: leftAnchor)
        let rightConstraint = label.rightAnchor.constraint(equalTo: rightAnchor)
        
        self.leftConstraint = leftConstraint
        self.rightConstraint = rightConstraint
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor),
            leftConstraint,
            rightConstraint,
            label.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        layer.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        let halfHeight = frame.height / 2.0
        
        layer.cornerRadius = halfHeight
        
        leftConstraint?.constant = halfHeight
        rightConstraint?.constant = -halfHeight
    }
    
}
