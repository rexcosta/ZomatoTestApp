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

import Zomato
import ZomatoFoundation

struct AppErrorLocalizationMapper: ObjectMapper {
    
    func mapInput(_ input: Error) -> LocalizedString {
        switch input {
        case let zomatoError as ZomatoError:
            let prefix = "error.zomato"
            let name = zomatoError.context.name
            let code = zomatoError.context.code
            return translate(prefix: prefix, name: name, code: code)
            
        case let zomatoAppError as ZomatoAppError:
            let prefix = "error.zomato.app"
            let name = zomatoAppError.context.name
            let code = zomatoAppError.context.code
            return translate(prefix: prefix, name: name, code: code)
            
        default:
            let prefix = "error.zomato.app"
            let name = ZomatoErrorContext.unknown.name
            let code = ZomatoErrorContext.unknown.code
            return translate(prefix: prefix, name: name, code: code)
        }
    }
    
    private func translate(prefix: String, name: String, code: Int) -> LocalizedString {
        let key = "\(prefix).\(name).\(code)"
        let value = Bundle.main.localizedString(forKey: key, value: nil, table: "Errors")
        return LocalizedString(key: key, value: "\(value) (\(code))")
    }
    
}
