//
//  ImagesListCell.swift
//  Imagegram
//
//  Created by Владислав Усачев on 09.04.2024.
//

import UIKit

class ImagesListCell: UITableViewCell{    static let reuseIdentifire = "ImagesListCell"
    
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var dataLabel: UILabel!


}
