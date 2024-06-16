//
//  ImageListPresenterMock.swift
//  ImagegramTests
//
//  Created by Владислав Усачев on 15.06.2024.
//

import XCTest
@testable import Imagegram

class ImagesListPresenterMock: ImagesListPresenterProtocol {
    var numberOfPhotos: Int {
        return photos.count
    }
    
    var photos: [Photo] = []
    
    var fetchPhotosCalled = false
    var changeLikeStatusCalled = false
    var photoIndexChanged: Int?
    
    func fetchPhotos() {
        fetchPhotosCalled = true
    }
    
    func photo(at index: Int) -> Photo {
        return photos[index]
    }
    
    func changeLikeStatus(for photo: Photo, at indexPath: IndexPath) {
        changeLikeStatusCalled = true
        photoIndexChanged = indexPath.row
    }
}
