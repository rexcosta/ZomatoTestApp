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

public final class HttpClient {
    
    public typealias RequestTranformer = (NetworkRequest) -> URLRequest?
    
    private let session: URLSession
    private let requestTranformer: RequestTranformer
    
    public init(
        session: URLSession,
        requestTranformer: RequestTranformer? = nil
    ) {
        self.session = session
        if let requestTranformer = requestTranformer {
            self.requestTranformer = requestTranformer
        } else {
            self.requestTranformer = {
                return $0.transformToRequest()
            }
        }
    }
    
}

extension HttpClient: NetworkProtocol {
    
    public func request(
        _ request: NetworkRequest,
        completion: @escaping RequestCompletion
    ) -> Cancellable {
        guard let urlRequest = requestTranformer(request) else {
            session.delegateQueue.addOperation {
                completion(.failure(NetworkError.unableToBuildRequest(request)))
            }
            return EmptyCancellable()
        }
        
        Log.verbose("HttpClient", "Will request \(urlRequest)")
        
        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                if let urlError = error as? URLError {
                    Log.error("HttpClient", "Received URLError \(urlError) for \(urlRequest)")
                    completion(.failure(NetworkError.networkError(cause: urlError)))
                    return
                }
                Log.error("HttpClient", "Received unknown \(error) for \(urlRequest)")
                completion(.failure(NetworkError.unknown(cause: error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                assertionFailure("[HttpClient] Response must be HTTPURLResponse for \(urlRequest)")
                completion(.failure(NetworkError.unknown(cause: nil)))
                return
            }
            
            guard 200..<300 ~= httpResponse.statusCode else {
                Log.error("HttpClient", "Invalid status code received \(httpResponse.statusCode) for \(urlRequest)")
                completion(.failure(NetworkError.invalidStatusCode(code: httpResponse.statusCode)))
                return
            }
            
            guard let data = data else {
                Log.error("HttpClient", "Didnt received any data for \(urlRequest)")
                completion(.failure(NetworkError.unknown(cause: nil)))
                return
            }
            
            completion(.success((data: data, httpResponse: httpResponse)))
        }
        task.resume()
        return NetworkDataTask(task: task)
    }
    
}

// MARK: - NetworkDataTask
private struct NetworkDataTask: Cancellable {
    
    private let task: URLSessionDataTask
    
    init(task: URLSessionDataTask) {
        self.task = task
    }
    
    func cancel() {
        task.cancel()
    }
    
}
