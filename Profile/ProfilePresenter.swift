//
//  ProfilePresenter.swift
//  Imagegram
//
//  Created by Владислав Усачев on 14.06.2024.
//

import Foundation

public protocol ProfilePresenterProtocol: AnyObject{
    func viewDidLoad()
    func logout()
    func updateView()
}

final class ProfilePresenter: ProfilePresenterProtocol{
    weak var view: ProfileViewControllerProtocol?
    var logoutService = ProfileLogoutService.shared
    var profileService = ProfileService.shared
    
    
    init(view: ProfileViewControllerProtocol) {
        self.view = view
    }
    
    func viewDidLoad() {
        updateView()
    }
    
    func logout() {
        logoutService.clearAllUserData()
        view?.switchToSplashView()
    }
    
    func updateView() {
        guard let profile = profileService.profile else { return }
        view?.updateLabels(name: profile.name, loginName: profile.loginName, bio: profile.bio)
        if let avatarURLString = ProfileImageService.shared.avatarURL,
           let avatarURL = URL(string: avatarURLString) {
            view?.showImage(with: avatarURL)
        }
    }
}
