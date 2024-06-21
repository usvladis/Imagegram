//
//  ProfileTests.swift
//  ImagegramTests
//
//  Created by Владислав Усачев on 14.06.2024.
//

import XCTest
@testable import Imagegram

final class ProfileTests: XCTestCase {
    
    func testViewControllerCallsViewDidLoad(){
        //Given
        let presenter = ProfilePresenterMock()
        let viewController = ProfileViewController()
        viewController.presenter = presenter
        
        //When
        viewController.loadViewIfNeeded()
        
        //Then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testLogoutCalled() {
        //Given
        let presenter = ProfilePresenterMock()
        let viewController = ProfileViewController()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //When
        presenter.logout()
        
        //Then
        XCTAssertTrue(presenter.logoutCalled)
    }
}
