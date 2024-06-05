//
//  URLSession+data.swift
//  Imagegram
//
//  Created by Владислав Усачев on 07.05.2024.
//

import Foundation

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
}

extension URLSession {
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()
        
        let task = data(for: request) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    do {
                        let decodedObject = try decoder.decode(T.self, from: data)
                        completion(.success(decodedObject))
                    } catch {
                        completion(.failure(error))
                        print("[URLSession objectTask]: DecodingError - \(error.localizedDescription)")
                    }
                case .failure(let error):
                    completion(.failure(error))
                    print("[URLSession objectTask]: NetworkError - \(error.localizedDescription)")
                }
            }
        }
        
        return task
    }
    
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let task = dataTask(with: request) { data, response, error in
            if let data = data, let response = response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if 200 ..< 300 ~= statusCode {
                    fulfillCompletionOnTheMainThread(.success(data))
                } else {
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(statusCode)))
                    print("[URLSession data]: HTTPStatusCodeError - \(statusCode)")
                }
            } else if let error = error {
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error)))
                print("[URLSession data]: URLRequestError - \(error.localizedDescription)")
            } else {
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError))
                print("[URLSession data]: URLSessionError - No data or error received")
            }
        }
        
        task.resume()
        return task
    }
}
