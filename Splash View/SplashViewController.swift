//
//  SplashViewController.swift
//  Imagegram
//
//  Created by Владислав Усачев on 07.05.2024.
//
import UIKit
import ProgressHUD
class SplashViewController: UIViewController{
    
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    private let oAuth2Service = OAuth2Service.shared
    private let storage = OAuth2TokenStorage.shared
    private let profileService = ProfileService()
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let token = storage.token {
            fetchProfile(token)
        }else{
            performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
        }
    }
    
    private func switchToTabBarController() {
        DispatchQueue.main.async { [weak self] in
            guard self != nil else { return }
            // Получаем экземпляр `window` приложения
            guard let window = UIApplication.shared.windows.first else {
                assertionFailure("Invalid window configuration")
                return
            }
            
            // Создаём экземпляр нужного контроллера из Storyboard с помощью ранее заданного идентификатора
            let tabBarController = UIStoryboard(name: "Main", bundle: .main)
                .instantiateViewController(withIdentifier: "TabBarViewController")
            
            // Установим в `rootViewController` полученный контроллер
            window.rootViewController = tabBarController
        }
    }
    
    private func switchToAuthNavigationController() {
        // Получаем экземпляр `window` приложения
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        // Создаём экземпляр нужного контроллера из Storyboard с помощью ранее заданного идентификатора
        let authNavigationController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "AuthNavigationController")
           
        // Установим в `rootViewController` полученный контроллер
        window.rootViewController = authNavigationController
    }
}

extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Проверим, что переходим на авторизацию
        if segue.identifier == showAuthenticationScreenSegueIdentifier {
            
            // Доберёмся до первого контроллера в навигации. Мы помним, что в программировании отсчёт начинается с 0?
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers[0] as? AuthViewController
            else {
                assertionFailure("Failed to prepare for \(showAuthenticationScreenSegueIdentifier)")
                return
            }
            
            // Установим делегатом контроллера наш SplashViewController
            viewController.delegate = self
            
        } else {
            super.prepare(for: segue, sender: sender)
           }
    }
}
extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.fetchOAuthToken(code)
        }
    }

    private func fetchOAuthToken(_ code: String) {
        UIBlockingProgressHUD.show()
        oAuth2Service.fetchOAuthToken(withCode: code) { [weak self] responce in
            guard let self = self else { return }
            UIBlockingProgressHUD.dismiss()
            switch responce {
            case .success(let token):
                self.fetchProfile(token)
            case .failure(let error):
                print("Error fetching token: \(error)")
                break
            }
        }
    }
    
    func fetchProfile(_ token: String) {
        
        profileService.fetchProfile(token) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let profileResult):
                let profile = Profile(
                    username: profileResult.username,
                    name: "\(profileResult.first_name) \(profileResult.last_name)",
                    loginName: "@\(profileResult.username)",
                    bio: profileResult.bio ?? "N/A")
                
                ProfileStore.shared.profile = profile
                ProfileImageService.shared.fetchProfileImageURL(username: profileResult.username) { result in
                    switch result {
                    case .success(let avatarURL):
                        print("Avatar URL: \(avatarURL)")
                        self.switchToTabBarController()
                    case .failure(let error):
                        print("Error fetching avatar URL: \(error)")
                        self.switchToTabBarController()
                    }
                    
                }
            case .failure(let error):
                print("Error fetching user profile: \(error)")
            }
        }
    }
}
