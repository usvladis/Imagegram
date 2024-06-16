//
//  ImagesListViewController.swift
//  Imagegram
//
//  Created by Владислав Усачев on 04.04.2024.
//

import UIKit
import Kingfisher

protocol ImagesListViewProtocol: AnyObject {
    func reloadData()
    func updateCell(at indexPath: IndexPath)
    func showError(message: String)
}

final class ImagesListViewController: UIViewController, ImagesListViewProtocol {
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    lazy var presenter: ImagesListPresenterProtocol = ImagesListPresenter(view: self)
    
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.dateFormat = "dd MMMM yyyy"
        formatter.locale = NSLocale(localeIdentifier: "ru_RU") as Locale
        return formatter
    }()
    
    @IBOutlet private var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        presenter.fetchPhotos()
    }
    
    private func setupTableView() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
    func reloadData() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func updateCell(at indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photo = presenter.photo(at: indexPath.row)
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
            guard let url = URL(string: presenter.photo(at: indexPath.row).largeImageURL) else { return }
            viewController.imageURL = url
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

// MARK: - UITableViewDelegate

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
}

// MARK: - UITableViewDataSource

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.numberOfPhotos
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

// MARK: - UITableViewDelegate Methods

extension ImagesListViewController {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == presenter.numberOfPhotos {
            presenter.fetchPhotos()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = presenter.photo(at: indexPath.row)
        let aspectRatio = photo.size.height / photo.size.width
        return tableView.bounds.width * aspectRatio
    }
}

// MARK: - ImagesListCellDelegate

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = presenter.photo(at: indexPath.row)
        UIBlockingProgressHUD.show()
        presenter.changeLikeStatus(for: photo, at: indexPath)
        
    }
}
