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

extension UILabel {
    
    var withTitleStyle: Self {
        with {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.numberOfLines = 0
            $0.font = UIFont.preferredFont(forTextStyle: .title1)
            $0.textColor = Theme.shared.textColor
        }
    }
    
    var withSubTitleStyle: Self {
        with {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.numberOfLines = 0
            $0.textAlignment = .center
            $0.font = UIFont.preferredFont(forTextStyle: .title2)
            $0.textColor = Theme.shared.textColor
        }
    }
    
    var withTextStyle: Self {
        with {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.numberOfLines = 0
            $0.font = UIFont.preferredFont(forTextStyle: .footnote)
            $0.textColor = Theme.shared.textColor
        }
    }
    
    var withLabelStyle: Self {
        with {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.numberOfLines = 0
            $0.font = UIFont.preferredFont(forTextStyle: .title3)
            $0.textColor = Theme.shared.textColor
        }
    }

}
