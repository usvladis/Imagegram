//
//  OAuth2TokenStorage.swift
//  Imagegram
//
//  Created by Владислав Усачев on 07.05.2024.
//

import Foundation

class OAuth2TokenStorage{
    static let shared = OAuth2TokenStorage()
    private let tokenKey = "accessToken"
        
    var token: String? {
        get {
            return UserDefaults.standard.string(forKey: tokenKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: tokenKey)
        }
    }
        
    init() {}
}
