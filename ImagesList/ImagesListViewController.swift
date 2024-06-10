//
//  ImagesListViewController.swift
//  Imagegram
//
//  Created by Владислав Усачев on 04.04.2024.
//

import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private var photos: [Photo] = []
    private let imageListService = ImagesListService()
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.dateFormat = "dd MMMM yyyy"
        formatter.locale = NSLocale(localeIdentifier: "ru_Ru") as Locale
        return formatter
    }()
    
    @IBOutlet private var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        NotificationCenter.default.addObserver(self, selector: #selector(updateTableViewAnimated), name: ImagesListService.didChangeNotification, object: nil)
        
        imageListService.fetchPhotosNextPage()
    }
    
    @objc private func updateTableViewAnimated() {
        let oldPhotos = photos.count
        let newPhotos = imageListService.photos.count
        photos = imageListService.photos
        if oldPhotos != newPhotos {
            tableView.performBatchUpdates{
                let indexPath = (oldPhotos..<newPhotos).map { i in
                    IndexPath(row: i, section: 0)
                }
                tableView.insertRows(at: indexPath, with: .automatic)
            } completion: { _ in }
        }
    }
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        if let url = URL(string: photo.thumbImageURL) {
            cell.cellImage.kf.setImage(with: url,
                                       placeholder: UIImage(named: "placeholder_card"))
        }
        if let createdAt = photo.createdAt {
            let dateString = dateFormatter.string(from: createdAt)
            cell.dataLabel.text = dateString
        } else {
            cell.dataLabel.text = "Дата неизвестна"
        }
        
        cell.likeButton.tintColor = photo.isLiked ? .ypRed : .gray
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Invalid segue destination")
                return
            }
            let photo = photos[indexPath.row]
            guard let url = URL(string: photo.largeImageURL) else {return}
            viewController.imageURL = url
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension ImagesListViewController: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
        }
}

extension ImagesListViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifire, for: indexPath)
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        configCell(for: imageListCell, with: indexPath)
        imageListCell.delegate = self
        return imageListCell
    }
    
}

extension ImagesListViewController {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == photos.count {
        imageListService.fetchPhotosNextPage()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            let photo = photos[indexPath.row]
            let aspectRatio = photo.size.height / photo.size.width
            return tableView.bounds.width * aspectRatio
        }
}

extension ImagesListViewController: ImagesListCellDelegate{
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        // Покажем лоадер
        UIBlockingProgressHUD.show()
        imageListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { result in
            switch result {
            case .success:
                // Синхронизируем массив картинок с сервисом
                self.photos = self.imageListService.photos
                // Изменим индикацию лайка картинки
                cell.setIsLiked(self.photos[indexPath.row].isLiked)
                print (self.photos[indexPath.row].isLiked)
                // Уберём лоадер
                UIBlockingProgressHUD.dismiss()
            case .failure(let error):
                // Уберём лоадер
                UIBlockingProgressHUD.dismiss()
                // Покажем, что что-то пошло не так
                // TODO: Показать ошибку с использованием UIAlertController
                print("Error changing like: \(error)")
            }
        }
    }
}


