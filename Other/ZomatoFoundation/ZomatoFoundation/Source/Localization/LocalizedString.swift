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

import Foundation

public struct LocalizedString: Hashable {
    
    public let key: String
    public var value: String
    
    public init(
        key: String,
        value: String
    ) {
        self.key = key
        self.value = value
    }
    
}

extension LocalizedString {
    
    public func apply(replacerName: String, replacerValue: String) -> LocalizedString {
        return apply(
            replacers: [LocalizedReplacer(name: replacerName, value: replacerValue)]
        )
    }
    
    public func apply(replacer: LocalizedReplacer) -> LocalizedString {
        return apply(replacers: [replacer])
    }
    
    public func apply(replacers: [LocalizedReplacer]) -> LocalizedString {
        var localizedString = value
        replacers.forEach {
            localizedString = localizedString.replacingOccurrences(
                of: $0.name,
                with: $0.value
            )
        }
        return LocalizedString(key: key, value: localizedString)
    }
    
}
