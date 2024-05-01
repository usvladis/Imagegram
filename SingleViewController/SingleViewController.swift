//
//  SingleViewController.swift
//  Imagegram
//
//  Created by Владислав Усачев on 30.04.2024.
//

import UIKit

final class SingleViewController: UIViewController{
    var image: UIImage? {
        didSet {
            guard isViewLoaded, let image else { return }

            imageView.image = image
            imageView.frame.size = image.size
            setupImageView(image)
        }
    }

    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25

        guard let image else { return }
        imageView.image = image
        imageView.frame.size = image.size
        setupImageView(image)
    }

    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapShareButton(_ sender: UIButton) {
        guard let image else { return }
        let share = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        present(share, animated: true, completion: nil)
    }
    
    private func setupImageView(_ image: UIImage) {
        let screenSize = UIScreen.main.bounds.size
        
        // Вычисляем соотношение сторон изображения
        let aspectRatio = image.size.width / image.size.height
        
        // Вычисляем максимальные размеры изображения, учитывая размеры экрана
        let maxWidth = screenSize.width
        let maxHeight = screenSize.height
        
        // Вычисляем новые размеры изображения, учитывая его соотношение сторон и максимальные размеры
        var newWidth = min(image.size.width, maxWidth)
        var newHeight = newWidth / aspectRatio
        
        // Если новая высота больше максимальной, уменьшаем новую ширину и высоту до максимальных значений
        if newHeight > maxHeight {
            newHeight = maxHeight
            newWidth = newHeight * aspectRatio
        }
        
        // Устанавливаем новые размеры изображения
        imageView.frame.size = CGSize(width: newWidth, height: newHeight)
        
        // Устанавливаем изображение по центру экрана
        imageView.center = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
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

