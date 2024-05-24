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
    private let profileService = ProfileService.shared
    private let profileImageServce = ProfileImageService.shared
    private var alertPresenter: AlertPresenter?
    private var image = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        alertPresenter = AlertPresenter(viewController: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let token = storage.token {
            fetchProfile(token)
        }else{
            showAuthenticationScreen()
        }
    }
    
    private func setUpView() {
        view.backgroundColor = UIColor(named: "YPBlack")
        image.image = UIImage(named: "splash_screen_logo")
        image.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(image)
        
        NSLayoutConstraint.activate([
            image.widthAnchor.constraint(equalToConstant: 72),
            image.heightAnchor.constraint(equalToConstant: 75),
            image.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            image.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
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
    private func showAuthenticationScreen() {
        guard let authNavigationController = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "AuthNavigationController") as? UINavigationController,
              let authViewController = authNavigationController.viewControllers.first as? AuthViewController
        else {
            fatalError("Unable to instantiate AuthNavigationController or AuthViewController from storyboard")
        }
        
        authViewController.delegate = self
        authNavigationController.modalPresentationStyle = .fullScreen
        present(authNavigationController, animated: true, completion: nil)
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
                alertPresenter?.showAlert(with: "Не удалось войти в систему")
                break
            }
        }
    }
    
    private func fetchProfile(_ token: String) {
        
        profileService.fetchProfile(token) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let profileResult):
                let profile = Profile(
                    username: profileResult.username,
                    name: "\(profileResult.first_name) \(profileResult.last_name)",
                    loginName: "@\(profileResult.username)",
                    bio: profileResult.bio ?? "N/A")
                
                profileService.profile = profile
                profileImageServce.fetchProfileImageURL(username: profileResult.username) { result in
                    switch result {
                    case .success(let avatarURL):
                        self.switchToTabBarController()
                    case .failure(let error):
                        print("Error fetching avatar URL: \(error)")
                        self.switchToTabBarController()
                    }
                    
                }
            case .failure(let error):
                print("Error fetching user profile: \(error)")
                alertPresenter?.showAlert(with: "Не удалось войти в систему")
            }
        }
    }
}
