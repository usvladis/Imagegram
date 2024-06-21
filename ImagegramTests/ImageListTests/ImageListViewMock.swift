//
//  ImageListViewMock.swift
//  ImagegramTests
//
//  Created by Владислав Усачев on 15.06.2024.
//

import XCTest
@testable import Imagegram

class ImagesListServiceMock: ImagesListService {
    var fetchPhotosNextPageCalled = false
    var changeLikeCalled = false
    var photosMock: [Photo] = []

    override func fetchPhotosNextPage() {
        fetchPhotosNextPageCalled = true
    }

    override func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        changeLikeCalled = true
        completion(.success(()))
    }
}

class ImagesListViewMock: ImagesListViewProtocol {
    var reloadDataCalled = false
    var updateCellCalled = false
    var showErrorCalled = false

    func reloadData() {
        reloadDataCalled = true
    }

    func updateCell(at indexPath: IndexPath) {
        updateCellCalled = true
    }

    func showError(message: String) {
        showErrorCalled = true
    }
}

