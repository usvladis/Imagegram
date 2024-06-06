//
//  ImagesListCell.swift
//  Imagegram
//
//  Created by Владислав Усачев on 09.04.2024.
//

import UIKit
import Kingfisher

final class ImagesListCell: UITableViewCell{
    static let reuseIdentifire = "ImagesListCell"
    
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var dataLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // Отменяем загрузку, чтобы избежать багов при переиспользовании ячеек
//        fullsizeImageView.kf.cancelDownloadTask()
    }
}
