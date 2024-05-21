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
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error {
                print("Network request error: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            //Проверяем наличие данных
            guard let data else {
                print("No data received")
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.urlSessionError))
                }
                return
            }
            
            do{
                let profileData = try JSONDecoder().decode(UserResult.self, from: data)
                let avatarURL = profileData.profile_image.small
                self.avatarURL = avatarURL
                DispatchQueue.main.async {
                    completion(.success(avatarURL))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
            
        }.resume()
    }
}
