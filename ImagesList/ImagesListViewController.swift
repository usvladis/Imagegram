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
        tableView.estimatedRowHeight = 200
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        NotificationCenter.default.addObserver(self, selector: #selector(updatePhotos), name: ImagesListService.didChangeNotification, object: nil)
              
              imageListService.fetchPhotosNextPage()
        // Do any additional setup after loading the view.
    }
    
    @objc private func updatePhotos() {
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
        let photo = photos[indexPath.row] //Получаем имя
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
        return imageListCell
    }
    
}

extension ImagesListViewController {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == photos.count {
        imageListService.fetchPhotosNextPage()
        }
    }
}
