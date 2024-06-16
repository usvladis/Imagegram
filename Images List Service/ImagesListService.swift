//
//  ImagesListService.swift
//  Imagegram
//
//  Created by Владислав Усачев on 05.06.2024.
//

import Foundation
import UIKit
struct Photo{
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    var isLiked: Bool
}
struct PhotoResult: Codable{
    let id: String
    let created_at: Date
    let width: Int
    let height: Int
    let likes: Int
    let liked_by_user: Bool
    let description: String?
    let urls: UrlsResult
}

struct UrlsResult: Codable{
    let full: String
    let regular: String
}

class ImagesListService{
    private (set) var photos: [Photo] = []
    private var isLoading = false
    private var lastLoadedPage: Int?
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    func fetchPhotosNextPage() {
        guard !isLoading else {return}
        let nextPage = (lastLoadedPage ?? 0) + 1
        isLoading = true
        let urlString = "https://api.unsplash.com/photos?page=\(nextPage)&per_page=10&client_id=\(Constants.accessKey)"
        guard let url = URL(string: urlString) else {
            isLoading = false
            return
        }
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else {return}
            defer { self.isLoading = false }
            
            if let error = error {
                print("[ImageListService fetchPhotosNextPage]: NetworkError - \(error.localizedDescription)")
                return
            }
            
            guard let data = data else { return }
            
            do{
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let photoResult = try decoder.decode([PhotoResult].self, from: data)
                let newPhoto = photoResult.map { result in
                    Photo(id: result.id,
                          size: CGSize(width: result.width, height: result.height),
                          createdAt: result.created_at,
                          welcomeDescription: result.description,
                          thumbImageURL: result.urls.regular,
                          largeImageURL: result.urls.regular,
                          isLiked: result.liked_by_user)
                }
                DispatchQueue.main.async {
                    let uniqueNewPhotos = newPhoto.filter { newPhoto in
                        !self.photos.contains(where: { $0.id == newPhoto.id })
                    }
                    self.photos.append(contentsOf: uniqueNewPhotos)
                    self.lastLoadedPage = nextPage
                    NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: self)
                }
            } catch {
                print("[ImageListService fetchPhotosNextPage]: NetworkError - \(error.localizedDescription)")
            }
        }
        task.resume()
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        let urlString = "https://api.unsplash.com/photos/\(photoId)/\(isLike ? "like" : "unlike")?client_id=\(OAuth2TokenStorage.shared.token!)"
        guard let url = URL(string: urlString) else {return}
        var request = URLRequest(url: url)
        request.httpMethod = isLike ? "POST" : "DELETE"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                    print("[ImageListService changeLike]: NetworkError - \(error.localizedDescription)")
                }
                return
            }
            
            if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                self.photos[index].isLiked = isLike
                NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: self)
            }
            
            DispatchQueue.main.async {
                completion(.success(()))
            }
        }
        task.resume()
    }
    
}
