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

// MARK: Bounce
extension UIView {
    
    public func fastBounce() {
        bounce(duration: 0.33, usingSpringWithDamping: 0.6, initialSpringVelocity: 2.0)
    }
    
    public func longgerBounce() {
        bounce(duration: 0.66, usingSpringWithDamping: 0.3, initialSpringVelocity: 4.0)
    }
    
    public func bounce(
        duration: TimeInterval,
        usingSpringWithDamping: CGFloat,
        initialSpringVelocity: CGFloat
    ) {
        transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        
        UIView.animate(
            withDuration: duration,
            delay: 0,
            usingSpringWithDamping: usingSpringWithDamping,
            initialSpringVelocity: initialSpringVelocity,
            options: .allowUserInteraction,
            animations: { self.transform = .identity },
            completion: nil
        )
    }
    
}

// MARK: Fade
extension UIView {
    
    public func fadeIn(withDuration duration: TimeInterval) {
        alpha = 0.0
        isHidden = true
        UIView.animate(
            withDuration: duration,
            animations: { self.alpha = 1.0 },
            completion: { _ in self.isHidden = false }
        )
    }
    
    public func fadeOut(withDuration duration: TimeInterval) {
        alpha = 1.0
        isHidden = false
        UIView.animate(
            withDuration: duration,
            animations: { self.alpha = 0.0 },
            completion: { _ in self.isHidden = true }
        )
    }
    
}
