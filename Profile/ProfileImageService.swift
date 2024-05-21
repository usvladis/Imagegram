//
//  ProfileImageService.swift
//  Imagegram
//
//  Created by Владислав Усачев on 21.05.2024.
//

import Foundation
struct UserResult: Codable{
    let profile_image: ProfileImages
}
struct ProfileImages: Codable{
    let small: String
}
final class ProfileImageService{
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    static let shared = ProfileImageService()
    private init() {}
    
    private (set) var avatarURL: String?
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "https://api.unsplash.com/users/\(username)") else {
            completion(.failure(NetworkError.urlSessionError))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        guard let token = OAuth2TokenStorage.shared.token else {return}
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            switch result {
            case .success(let userResult):
                let avatarURL = userResult.profile_image.small
                self?.avatarURL = avatarURL
                NotificationCenter.default.post(
                    name: ProfileImageService.didChangeNotification,
                    object: self,
                    userInfo: ["URL": avatarURL]
                )
                DispatchQueue.main.async {
                    completion(.success(avatarURL))
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                print("[ProfileImageService fetchProfileImageURL]: NetworkError - \(error.localizedDescription) with username \(username)")
            }
        }
        task.resume()
    }
}
