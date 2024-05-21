//
//  OAuth2Service.swift
//  Imagegram
//
//  Created by Владислав Усачев on 06.05.2024.
//

import Foundation

struct OAuthTokenResponseBody: Codable {
    let access_token: String
    let token_type: String
    let scope: String
    let created_at: Int
}

enum AuthServiceError: Error{
    case invalidRequest
}

final class OAuth2Service{
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    
    static let shared = OAuth2Service()
    private init() {}
    
    func makeTokenRequest(code: String) -> URLRequest? {
        guard let baseURL = Constants.baseURL else {
                return nil
            }
            
            let urlString = "\(baseURL)/oauth/token?client_id=\(Constants.accessKey)&client_secret=\(Constants.secretKey)&redirect_uri=\(Constants.redirectURI)&code=\(code)&grant_type=authorization_code"
            
            guard let url = URL(string: urlString) else {
                return nil
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            return request
    }

    func fetchOAuthToken(withCode code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)                         // 4
        if task != nil {                                    // 5
            if lastCode != code {                           // 6
                task?.cancel()                              // 7
            } else {
                completion(.failure(AuthServiceError.invalidRequest))
                return                                      // 8
            }
        } else {
            if lastCode == code {                           // 9
                completion(.failure(AuthServiceError.invalidRequest))
                return
            }
        }
        lastCode = code                                     // 10
        guard
            let request = makeTokenRequest(code: code)           // 11
        else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }

        let task = urlSession.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {                      // 12
                if let error {
                    print("Network request error: \(error)")
                    completion(.failure(error))
                    return
                }
                //Проверяем наличие ответа
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("Invalid response")
                    completion(.failure(NetworkError.urlSessionError))
                    return
                }
                //Проверяем код ответа
                guard (200 ..< 300) ~= httpResponse.statusCode else {
                    print("HTTP status code error: \(httpResponse.statusCode)")
                    completion(.failure(NetworkError.httpStatusCode(httpResponse.statusCode)))
                    return
                }
                //Проверяем наличие данных
                guard let data else {
                    print("No data received")
                    completion(.failure(NetworkError.urlSessionError))
                    return
                }
                
                do{
                    let tokenResponse = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                    let accessToken = tokenResponse.access_token
                    OAuth2TokenStorage.shared.token = accessToken
                    completion(.success(accessToken))
                    print("Success! Access token: \(accessToken)")
                } catch {
                    print("Error decoding token response: \(error)")
                    completion(.failure(error))
                }
                self?.task = nil                            // 14
                self?.lastCode = nil                        // 15
            }
        }
        self.task = task                                    // 16
        task.resume()                                       // 17
    }

/*

    func fetchOAuthToken(withCode code: String, complition: @escaping (Result<String, Error>) -> Void) {
        guard let request = makeTokenRequest(code: code) else {
            print ("Failed to create token request")
            return
        }
        URLSession.shared.dataTask(with: request) {data, responce, error in
            //Проверяем наличие ошибок
            if let error {
                print("Network request error: \(error)")
                DispatchQueue.main.async {
                    complition(.failure(error))
                }
                return
            }
            //Проверяем наличие ответа
            guard let httpResponse = responce as? HTTPURLResponse else {
                print("Invalid response")
                DispatchQueue.main.async {
                    complition(.failure(NetworkError.urlSessionError))
                }
                return
            }
            //Проверяем код ответа
            guard (200 ..< 300) ~= httpResponse.statusCode else {
                print("HTTP status code error: \(httpResponse.statusCode)")
                DispatchQueue.main.async {
                    complition(.failure(NetworkError.httpStatusCode(httpResponse.statusCode)))
                }
                return
            }
            //Проверяем наличие данных
            guard let data else {
                print("No data received")
                DispatchQueue.main.async {
                    complition(.failure(NetworkError.urlSessionError))
                }
                return
            }
            
            do{
                let tokenResponse = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                let accessToken = tokenResponse.access_token
                OAuth2TokenStorage.shared.token = accessToken
                DispatchQueue.main.async {
                    complition(.success(accessToken))
                }
            } catch {
                print("Error decoding token response: \(error)")
                DispatchQueue.main.async {
                    complition(.failure(error))
                }
            }
        }.resume()
    }
*/
}

