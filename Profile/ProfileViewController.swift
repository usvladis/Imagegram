//
//  ProfileViewController.swift
//  Imagegram
//
//  Created by Владислав Усачев on 30.04.2024.
//

import UIKit
import Kingfisher

public protocol ProfileViewControllerProtocol: AnyObject{
    func switchToSplashView()
    func updateLabels(name: String, loginName: String, bio: String)
    func showImage(with url: URL)
    
}

final class ProfileViewController: UIViewController, ProfileViewControllerProtocol {
    private var profileImageServiceObserver: NSObjectProtocol?
    lazy var presenter: ProfilePresenterProtocol = ProfilePresenter(view: self)

    private var image = UIImageView()
    private var nameLabel = UILabel()
    private var nickNameLabel = UILabel()
    private var descriptionLabel = UILabel()
    private var button = UIButton()
    private var alertPresenter: ProfileAlertPresenter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //presenter = ProfilePresenter(view: self)
        alertPresenter = ProfileAlertPresenter(viewController: self)
        setUpView()
        presenter.viewDidLoad()
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main                                       
            ) { [weak self] _ in
                self?.presenter.updateView()
            }
    }
    
    private func setUpView(){
        view.backgroundColor = UIColor(named: "YPBlack")
        
        setUpImage()
        setUpLabels()
        setUpButton()
    }
    private func setUpImage(){

        image.layer.cornerRadius = 35
        image.layer.masksToBounds = true
        image.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(image)
        
        NSLayoutConstraint.activate([
            image.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            image.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            image.widthAnchor.constraint(equalToConstant: 70),
            image.heightAnchor.constraint(equalToConstant: 70)
        ])
    }
    
    private func setUpLabels(){
        nameLabel.textColor = .white
        nameLabel.font = UIFont(name: "YSDisplay-Bold", size: 23)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        
        nickNameLabel.textColor = UIColor(named: "YPGray")
        nickNameLabel.font = UIFont(name: "YSDisplay-Medium", size: 13)
        nickNameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nickNameLabel)
        
        descriptionLabel.textColor = .white
        descriptionLabel.font = UIFont(name: "YSDisplay-Medium", size: 13)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nickNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            nickNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: nickNameLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: nickNameLabel.leadingAnchor)
        ])
    }
    
    private func setUpButton(){
        button = UIButton(type: .system)
        button.accessibilityIdentifier = "logoutButton"
        button.setImage(UIImage(named: "logout_button"), for: .normal)
        button.tintColor = UIColor(named: "YPRed")
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
        view.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 48),
            button.heightAnchor.constraint(equalToConstant: 48),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            button.centerYAnchor.constraint(equalTo: image.centerYAnchor)
        ])
    }

    @IBAction private func didTapLogoutButton() {
        alertPresenter?.showAlert { [weak self] in
            self?.presenter.logout()
        }
    }
    
}

extension ProfileViewController{
    func switchToSplashView() {
        DispatchQueue.main.async { [weak self] in
            guard self != nil else { return }
            guard let window = UIApplication.shared.windows.first else {
                assertionFailure("Invalid window configuration")
                return
            }
            let splashViewController = SplashViewController()
            window.rootViewController = splashViewController
            window.makeKeyAndVisible()
        }
    }
    
    func showImage(with url: URL) {
            image.kf.setImage(with: url, placeholder: UIImage(named: "placeholder"))
        }
    
    func updateLabels(name: String, loginName: String, bio: String) {
        nameLabel.text = name
        nickNameLabel.text = loginName
        descriptionLabel.text = bio
    }
}
