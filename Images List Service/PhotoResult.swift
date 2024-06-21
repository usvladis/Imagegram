//
//  PhotoResult.swift
//  Imagegram
//
//  Created by Владислав Усачев on 17.06.2024.
//

import Foundation

struct PhotoResult: Codable{
    let id: String
    let created_at: Date
    let width: Int
    let height: Int
    let likes: Int
    let liked_by_user: Bool
    let description: String?
    let urls: UrlsResult
}
