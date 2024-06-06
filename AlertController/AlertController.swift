//
//  AlertController.swift
//  Imagegram
//
//  Created by Владислав Усачев on 21.05.2024.
//

import UIKit

class AlertPresenter {
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func showAlert(with message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ОК", style: .default))
            viewController?.present(alert, animated: true)
    }
}
