//
//  ImageListTests.swift
//  ImagegramTests
//
//  Created by Владислав Усачев on 15.06.2024.
//

import XCTest
@testable import Imagegram

class ImagesListPresenterTests: XCTestCase {
    var presenter: ImagesListPresenter!
    var viewMock: ImagesListViewMock!
    var serviceMock: ImagesListServiceMock!

    override func setUp() {
        super.setUp()
        viewMock = ImagesListViewMock()
        serviceMock = ImagesListServiceMock()
        presenter = ImagesListPresenter(view: viewMock)
        presenter.imageListService = serviceMock
    }

    override func tearDown() {
        presenter = nil
        serviceMock = nil
        viewMock = nil
        super.tearDown()
    }

    func testFetchPhotosCallsService() {
        presenter.fetchPhotos()
        XCTAssertTrue(serviceMock.fetchPhotosNextPageCalled, "fetchPhotosNextPage should be called on the service")
    }
    
    func testChangeLikeStatusCallsService() {
        let photo = Photo(id: "1", size: CGSize(width: 1, height: 1), createdAt: Date(), welcomeDescription: nil, thumbImageURL: "url", largeImageURL: "url", isLiked: false)
        presenter.photos = [photo]
        let indexPath = IndexPath(row: 0, section: 0)

        presenter.changeLikeStatus(for: photo, at: indexPath)
        XCTAssertTrue(serviceMock.changeLikeCalled, "changeLike should be called on the service")
    }

    func testChangeLikeStatusSuccessUpdatesView() {
        let photo = Photo(id: "1", size: CGSize(width: 1, height: 1), createdAt: Date(), welcomeDescription: nil, thumbImageURL: "url", largeImageURL: "url", isLiked: false)
        presenter.photos = [photo]
        let indexPath = IndexPath(row: 0, section: 0)
        serviceMock.photosMock = [photo]

        let expectation = self.expectation(description: "Wait for changeLike to complete")

        viewMock.updateCellCalled = false

        serviceMock.changeLike(photoId: photo.id, isLike: true) { _ in
            DispatchQueue.main.async {
                expectation.fulfill()
            }
        }

        presenter.changeLikeStatus(for: photo, at: indexPath)

        waitForExpectations(timeout: 1) { _ in
            XCTAssertTrue(self.viewMock.updateCellCalled, "updateCell should be called on the view")
        }
    }

    
    func testNumberOfPhotos() {
        presenter.photos = [Photo(id: "1", size: CGSize(width: 1, height: 1), createdAt: Date(), welcomeDescription: nil, thumbImageURL: "url", largeImageURL: "url", isLiked: false)]
        XCTAssertEqual(presenter.numberOfPhotos, 1)
    }

    func testPhotoAtIndex() {
        let photo = Photo(id: "1", size: CGSize(width: 1, height: 1), createdAt: Date(), welcomeDescription: nil, thumbImageURL: "url", largeImageURL: "url", isLiked: false)
        presenter.photos = [photo]
        XCTAssertEqual(presenter.photo(at: 0).id, "1")
    }


}
