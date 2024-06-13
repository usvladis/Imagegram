//
//  ProfileAlertController.swift
//  Imagegram
//
//  Created by Владислав Усачев on 10.06.2024.
//

import UIKit

final class ProfileAlertPresenter {
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func showAlert(logoutHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: "🚪", message: "Уверен что хочешь выйти?", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Нет", style: .cancel, handler: nil)
        let logout = UIAlertAction(title: "Да", style: .destructive) { _ in
            logoutHandler()
        }
        
        alert.addAction(cancel)
        alert.addAction(logout)
        viewController?.present(alert, animated: true, completion: nil)
        
    }
}
