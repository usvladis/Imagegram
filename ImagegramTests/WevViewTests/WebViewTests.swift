//
//  ImagegramTests.swift
//  ImagegramTests
//
//  Created by Владислав Усачев on 04.04.2024.
//

import XCTest
@testable import Imagegram

final class WebViewTests: XCTestCase {

    func testViewControllerCallsViewDidLoad() {
        //Given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "WebViewViewController") as! WebViewViewController
        let presenter = WebViewPresenterSpy() //Spy
        viewController.presenter = presenter
        presenter.view = viewController
        
        //When
        viewController.loadViewIfNeeded()
        
        //Then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testPresenterCallsLoadRequest () {
        //Given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "WebViewViewController") as! WebViewViewController
        let presenter = WebViewPresenterSpy() //Spy
        viewController.presenter = presenter
        presenter.view = viewController
        
        //When
        _ = viewController.view
        
        //Then
        XCTAssertTrue(presenter.loadRequestCalled)
    }
    
    func testProgressVisibleWhenLessThenOne() {
        //Given
        let authHelper = AuthHelper() //Dummy
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 0.6
        
        //When
        let shouldHideProgress = presenter.shouldProgressHidden(for: progress)
        
        //Then
        XCTAssertFalse(shouldHideProgress)
        
    }
    
    func testProgressHiddenWhenOne() {
        //Given
        let authHelper = AuthHelper() //Dummy
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 1
        
        //When
        let shouldHideProgress = presenter.shouldProgressHidden(for: progress)
        
        //Then
        XCTAssertTrue(shouldHideProgress)
    }
    
    func testAuthHelperAuthURL() {
        //Given
        let configuration = AuthConfiguration.standart
        let authHelper = AuthHelper(configuration: configuration)
        
        //When
        let url = authHelper.authURL()
        let urlString = url!.absoluteString
        
        //Then
        XCTAssertTrue(urlString.contains(configuration.authURLString))
        XCTAssertTrue(urlString.contains(configuration.accessKey))
        XCTAssertTrue(urlString.contains(configuration.redirectURI))
        XCTAssertTrue(urlString.contains("code"))
        XCTAssertTrue(urlString.contains(configuration.accessScope))
        
    }
    
    func testCodeFromURL() {
        let authHelper = AuthHelper(configuration: .standart)
        
        var urlComponents = URLComponents(string: "https://unsplash.com/oauth/authorize/native")!
        
        urlComponents.queryItems = [URLQueryItem(name: "code", value: "test code")]
        
        let url = urlComponents.url!
        
        let code = authHelper.code(from: url)
        XCTAssertEqual(code, "test code")
    }
}
