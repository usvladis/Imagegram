//
//  PhotoService.swift
//  Imagegram
//
//  Created by Владислав Усачев on 17.06.2024.
//

import Foundation

struct Photo{
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    var isLiked: Bool
}
