//
//  OAuth2TokenStorage.swift
//  Imagegram
//
//  Created by Владислав Усачев on 07.05.2024.
//

import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage{
    static let shared = OAuth2TokenStorage()
    private let tokenKey = "accessToken"
        
    var token: String? {
        get {
            return KeychainWrapper.standard.string(forKey: tokenKey)
        }
        set {
            if let newValue = newValue {
                KeychainWrapper.standard.set(newValue, forKey: tokenKey)
            } else {
                KeychainWrapper.standard.removeObject(forKey: tokenKey)
            }
        }
    }
        
    private init() {}
}
