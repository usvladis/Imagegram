//
//  Imagegram_Tests.swift
//  Imagegram Tests
//
//  Created by Владислав Усачев on 05.06.2024.
//
@testable import Imagegram
import XCTest

final class Imagegram_Tests: XCTestCase {
    func testExample()  {
        let service = ImagesListService()
        let expectation = self.expectation(description: "Wait for notification")
        NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main) { _ in
                expectation.fulfill()
            }
        service.fetchPhotosNextPage()
        wait(for: [expectation], timeout: 10)
        
        XCTAssertEqual(service.photos.count, 10)
    }
}
