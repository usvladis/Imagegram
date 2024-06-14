//
//  ProfilePresenterMock.swift
//  ImagegramTests
//
//  Created by Владислав Усачев on 14.06.2024.
//
import Imagegram
import Foundation

class ProfilePresenterMock: ProfilePresenterProtocol {
    
    var viewDidLoadCalled = false
    var logoutCalled = false
    var updateViewCalled = false
    var view: ProfileViewControllerProtocol?

    func viewDidLoad() {
        print("hui")
        viewDidLoadCalled = true
    }

    func logout() {
        logoutCalled = true
    }
    
    func updateView() {
        updateViewCalled = true
    }
}



