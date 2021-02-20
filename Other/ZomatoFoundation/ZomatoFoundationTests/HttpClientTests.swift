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

import XCTest
import RxSwift
import RxBlocking
@testable import ZomatoFoundation

class HttpClientTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testHttpRequestWith200() throws {
        let expectedResultString = """
        {
          "userId": 1,
          "id": 1,
          "title": "delectus aut autem",
          "completed": false
        }
        """
        let expectedResultData = expectedResultString.data(using: .utf8)
        XCTAssertNotNil(expectedResultData)
        
        let httpClient = HttpClient(session: URLSession.shared)
        
        let myRequest = NetworkRequest(
            url: "https://jsonplaceholder.typicode.com/todos/1"
        )
        
        let result = httpClient
            .request(myRequest)
            .toBlocking()
            .materialize()
        
        switch result {
        case .completed(let elements):
            XCTAssertEqual(elements.count, 1, "[HttpClientTests] Http request should only return 1 result")
            let result = elements.first
            XCTAssertEqual(expectedResultData, result?.data)
            XCTAssertEqual(200, result?.httpResponse.statusCode)
            
        case .failed(_, let error):
            XCTFail("[HttpClientTests] Should succed \(error)")
        }
    }
    
    func testHttpRequestWith404() throws {
        let httpClient = HttpClient(session: URLSession.shared)
        
        let myRequest = NetworkRequest(
            url: "https://jsonplaceholder.typicode.com/posts/ewad"
        )
        
        let result = httpClient
            .request(myRequest)
            .toBlocking()
            .materialize()
        
        switch result {
        case .completed:
            XCTFail("[HttpClientTests] Should had error")
            
        case .failed(_, let error):
            guard let networkError = error as? NetworkError else {
                XCTFail("[HttpClientTests] Should have NetworkError but got \(error)")
                return
            }
            guard case let NetworkError.invalidStatusCode(code) = networkError else {
                XCTFail("[HttpClientTests] Should have NetworkError.invalidStatusCode but got \(networkError)")
                return
            }
            
            XCTAssertEqual(404, code)
        }
    }
    
    func testHttpRequestWith() throws {
        let httpClient = HttpClient(session: URLSession.shared)
        
        let myRequest = NetworkRequest(
            url: "´"
        )
        
        let result = httpClient
            .request(myRequest)
            .toBlocking()
            .materialize()
        
        switch result {
        case .completed:
            XCTFail("[HttpClientTests] Should had error")
            
        case .failed(_, let error):
            guard let networkError = error as? NetworkError else {
                XCTFail("[HttpClientTests] Should have NetworkError but got \(error)")
                return
            }
            guard case NetworkError.unableToBuildRequest = networkError else {
                XCTFail("[HttpClientTests] Should have NetworkError.unableToBuildRequest but got \(networkError)")
                return
            }
        }
    }

}
