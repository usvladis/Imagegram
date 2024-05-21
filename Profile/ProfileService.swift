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
    func fetchProfile(_ token: String, completion: @escaping (Result<ProfileResult, Error>) -> Void) {
        guard let url = URL(string: "https://api.unsplash.com/me") else {
            completion(.failure(NetworkError.urlSessionError))
                return
            }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
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
                let profileData = try JSONDecoder().decode(ProfileResult.self, from: data)
                completion(.success(profileData))
            } catch {
                completion(.failure(error))
            }
            
        }.resume()
    }
}
