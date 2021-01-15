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

public struct Log {
    
    private init() { }
    
    public static func logAppInfo() {
        let bundleInfo = Bundle.main.infoDictionary ?? [String: Any]()
        let version = bundleInfo["CFBundleShortVersionString"] ?? ""
        let build = bundleInfo["CFBundleVersion"] ?? ""
        let appName = bundleInfo["CFBundleName"] ?? ""
        log("I", "App", "\(appName) v\(version) \(build)")
    }
    
    public static func verbose(_ system: String, _ message: String) {
        log("V", system, message)
    }
    
    public static func info(_ system: String, _ message: String) {
        log("I", system, message)
    }
    
    public static func warning(_ system: String, _ message: String) {
        log("W", system, message)
    }
    
    public static func error(_ system: String, _ message: String) {
        log("E", system, message)
    }
    
    private static func log(_ level: String, _ system: String, _ message: String) {
        let thread = Thread.isMainThread ? "M" : "B"
        NSLog("[\(level)][\(thread)][\(system)] \(message)")
    }
    
}
