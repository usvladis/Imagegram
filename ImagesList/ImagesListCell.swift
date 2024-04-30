//
//  ImagesListCell.swift
//  Imagegram
//
//  Created by Владислав Усачев on 09.04.2024.
//

import UIKit

final class ImagesListCell: UITableViewCell{    static let reuseIdentifire = "ImagesListCell"
    
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var dataLabel: UILabel!


}
