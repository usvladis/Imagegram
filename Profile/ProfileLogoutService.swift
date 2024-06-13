//
//  ProfileLogoutService.swift
//  Imagegram
//
//  Created by Владислав Усачев on 09.06.2024.
//

import Foundation
import WebKit
import SwiftKeychainWrapper
import Kingfisher

final class ProfileLogoutService{
    static let shared = ProfileLogoutService()
    private let storage = OAuth2TokenStorage.shared
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared

    
    private init () { }
    
    func clearAllUserData() {
        clearCookies()
        deleteToken()
        clearCash()
        print("Logout success!")
    }
    
    private func clearCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast) //Очищаем куки из хранилища
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
    
    private func deleteToken() {
        storage.deleteToken()
    }
    
    private func clearCash() {
        profileService.clearProfileData()
        profileImageService.deleteProfileImage()
        ImageCache.default.clearMemoryCache()
        ImageCache.default.clearDiskCache {
            print("Disk cache cleared")
        }
    }
}
