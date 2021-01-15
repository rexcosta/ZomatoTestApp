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

struct Theme {
    
    static let shared = Theme()
    
    let backgroundColor = UIColor.theme(
        light: .white,
        dark: .black
    )
    
    let transparentBackgroundColor = UIColor.theme(
        light: UIColor.white.withAlphaComponent(0.7),
        dark: UIColor.black.withAlphaComponent(0.7)
    )
    
    let cellBackgroundColor = UIColor.theme(
        light: .white,
        dark: .gray
    )
    
    let separatorLineColor = UIColor.theme(
        light: .lightGray,
        dark: .white
    )
    
    let shadowColor = UIColor.theme(
        light: .lightGray,
        dark: .white
    )
    
    let textColor = UIColor.theme(
        light: .black,
        dark: .white
    )
    
    let primaryColor = UIColor.theme(
        light: UIColor(red: 0.12, green: 0.53, blue: 0.90, alpha: 1.00),
        dark: UIColor(red: 0.12, green: 0.53, blue: 0.90, alpha: 1.00)
    )
    
}
