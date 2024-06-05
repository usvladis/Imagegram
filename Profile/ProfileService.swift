//
//  ProfileService.swift
//  Imagegram
//
//  Created by Владислав Усачев on 18.05.2024.
//

import Foundation
struct ProfileResult: Codable {
    let username: String
    let first_name: String
    let last_name: String
    let bio: String?
    
}

struct Profile{
    let username: String
    let name: String //"first_name + " " + last_name"
    let loginName: String // "@\(username)"
    let bio: String
}
final class ProfileService {
    static let shared = ProfileService()
    private init() {}

    var profile: Profile?
    func fetchProfile(_ token: String, completion: @escaping (Result<ProfileResult, Error>) -> Void) {
        guard let url = URL(string: "https://api.unsplash.com/me") else {
            completion(.failure(NetworkError.urlSessionError))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.objectTask(for: request) { (result: Result<ProfileResult, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let profile):
                    completion(.success(profile))
                case .failure(let error):
                    completion(.failure(error))
                    print("[ProfileService fetchProfile]: NetworkError - \(error.localizedDescription) with token \(token)")
                }
            }
        }
        task.resume()
    }
}
