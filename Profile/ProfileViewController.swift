//
//  ProfileViewController.swift
//  Imagegram
//
//  Created by Владислав Усачев on 30.04.2024.
//

import UIKit
import Kingfisher
final class ProfileViewController: UIViewController{
    private var profileImageServiceObserver: NSObjectProtocol?      // 1

    private var image = UIImageView()
    private var nameLabel = UILabel()
    private var nickNameLabel = UILabel()
    private var descriptionLabel = UILabel()
    private var button = UIButton()
    let profileService = ProfileService()
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        updateLabels()
        profileImageServiceObserver = NotificationCenter.default    // 2
            .addObserver(
                forName: ProfileImageService.didChangeNotification, // 3
                object: nil,                                        // 4
                queue: .main                                        // 5
            ) { [weak self] _ in
                guard let self = self else { return }
            }
    }
    
    private func setUpView(){
        view.backgroundColor = UIColor(named: "YPBlack")
        
        setUpImage()
        setUpLabels()
        setUpButton()
    }
    private func setUpImage(){
        image = UIImageView()
        if let avatarURLString = ProfileImageService.shared.avatarURL,
           let avatarURL = URL(string: avatarURLString) {
            image.kf.setImage(with: avatarURL, placeholder: UIImage(named: "placeholder"))
        } else {
            image.image = UIImage(named: "placeholder")
        }
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
    }
}

extension ProfileViewController {
    func updateLabels() {
        guard let profile = ProfileStore.shared.profile else { return }
        nameLabel.text = profile.name
        nickNameLabel.text = profile.loginName
        descriptionLabel.text = profile.bio
    }
}

final class ProfileStore {
    static let shared = ProfileStore()
    private init() {}

    var profile: Profile?
}
