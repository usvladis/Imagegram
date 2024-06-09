//
//  SingleViewController.swift
//  Imagegram
//
//  Created by Владислав Усачев on 30.04.2024.
//

import UIKit
import Kingfisher

final class SingleViewController: UIViewController{
    var imageURL: URL? {
        didSet {
            guard isViewLoaded, let imageURL else { return }
            UIBlockingProgressHUD.show()
            imageView.kf.setImage(with: imageURL, 
                                  completionHandler: { [weak self] result in
                UIBlockingProgressHUD.dismiss()
                switch result {
                case .success(let value):
                    self?.setupImageView(value.image)
                case .failure(let error):
                    print("Error loading image: \(error)")
                }
            })
        }
    }

    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25

        guard let imageURL else { return }
        UIBlockingProgressHUD.show()
        imageView.kf.setImage(with: imageURL, 
                              completionHandler: { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            switch result {
            case .success(let value):
                self?.setupImageView(value.image)
            case .failure(let error):
                print("Error loading image: \(error)")
            }
        })
    }

    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapShareButton(_ sender: UIButton) {
        guard let image = imageView.image else { return }
        let share = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        present(share, animated: true, completion: nil)
    }
    
}

extension SingleViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
           // После зумирования вычисляем новый центр изображения относительно контента ScrollView
        let offsetX = max((scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5, 0)
        let offsetY = max((scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5, 0)
        imageView.center = CGPoint(
            x: scrollView.contentSize.width * 0.5 + offsetX,
            y: scrollView.contentSize.height * 0.5 + offsetY)
       }
}

extension SingleViewController{
    private func setupImageView(_ image: UIImage) {
        let screenSize = UIScreen.main.bounds.size
        
        // Вычисляем соотношение сторон изображения
        let aspectRatio = image.size.width / image.size.height
        
        // Вычисляем новые размеры изображения в зависимости от высоты изображения и высоты экрана
        var newWidth: CGFloat
        var newHeight: CGFloat
        
        newHeight = screenSize.height
        newWidth = newHeight * aspectRatio
        
        // Устанавливаем новые размеры изображения
        imageView.frame.size = CGSize(width: newWidth, height: newHeight)
        
        // Устанавливаем изображение по центру экрана
        imageView.center = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
    }
}
