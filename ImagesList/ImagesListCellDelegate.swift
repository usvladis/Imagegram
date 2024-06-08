//
//  ImagesListCellDelegate.swift
//  Imagegram
//
//  Created by Владислав Усачев on 07.06.2024.
//

import Foundation

protocol ImagesListCellDelegate: AnyObject{
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}
