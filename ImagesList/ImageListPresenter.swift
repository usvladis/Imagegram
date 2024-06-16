//
//  ImageListPresenter.swift
//  Imagegram
//
//  Created by Владислав Усачев on 15.06.2024.
//

import UIKit
import ProgressHUD

protocol ImagesListPresenterProtocol {
    var numberOfPhotos: Int { get }
    func fetchPhotos()
    func photo(at index: Int) -> Photo
    func changeLikeStatus(for photo: Photo, at indexPath: IndexPath)
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    var imageListService = ImagesListService()
    var photos: [Photo] = []
    private weak var view: ImagesListViewProtocol?
    
    init(view: ImagesListViewProtocol) {
        self.view = view
        NotificationCenter.default.addObserver(self, selector: #selector(updatePhotos), name: ImagesListService.didChangeNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: ImagesListService.didChangeNotification, object: nil)
    }
    
    func fetchPhotos() {
        imageListService.fetchPhotosNextPage()
    }
    
    func changeLikeStatus(for photo: Photo, at indexPath: IndexPath) {
        imageListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                switch result {
                case .success:
                    self.photos = self.imageListService.photos
                    self.view?.updateCell(at: indexPath)
                case .failure(let error):
                    self.view?.showError(message: "Error changing like: \(error)")
                }
            }
        }
    }
    
    var numberOfPhotos: Int {
        return photos.count
    }
    
    func photo(at index: Int) -> Photo {
        return photos[index]
    }
    
    @objc func updatePhotos() {
        photos = imageListService.photos
        view?.reloadData()
    }
}
