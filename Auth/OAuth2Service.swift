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
        assert(Thread.isMainThread)
        if task != nil {
            if lastCode != code {
                task?.cancel()
            } else {
                completion(.failure(AuthServiceError.invalidRequest))
                return
            }
        } else {
            if lastCode == code {
                completion(.failure(AuthServiceError.invalidRequest))
                return
            }
        }
        lastCode = code
        guard
            let request = makeTokenRequest(code: code)
        else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let tokenResponse):
                    let accessToken = tokenResponse.access_token
                    OAuth2TokenStorage.shared.token = accessToken
                    print("Success! Access token: \(accessToken)")
                    completion(.success(accessToken))
                case .failure(let error):
                    print("[OAuth2Service fetchOAuthToken]: NetworkError - \(error.localizedDescription) with code \(code)")
                    completion(.failure(error))
                }
            }
            self?.task = nil
            self?.lastCode = nil
        }
        
        self.task = task
        task.resume()
    }
}

