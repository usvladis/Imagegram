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
    weak var delegate: ImagesListCellDelegate? 
    
    @IBAction private func likeButtonClicked() {
        delegate?.imageListCellDidTapLike(self)
    }
    override func awakeFromNib() {
            super.awakeFromNib()
            // Initialization code
            likeButton.accessibilityIdentifier = "likeButton"
        }
    func setIsLiked(_ isLiked: Bool) {
        likeButton.tintColor = isLiked ? .ypRed : .gray
    }
}
