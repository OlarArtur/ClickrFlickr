//
//  InterestingnessPhotoNetworkService.swift
//  ClickrFlickr
//
//  Created by Artur Olar on 11/15/17.
//  Copyright © 2017 Artur Olar. All rights reserved.
//

import Foundation

class InterestingnessPhotoNetworkservice {
    
    private init() {}
    
    static func parseJsonForInterestingnessPhoto(completion: @escaping (Bool)->()) {
        guard let string = CallingFlickrAPIwithOauth.methodInterestingnessGetList() else {
            completion(false)
            return
        }
        
        FetchJSON.fetchJson(fromUrl: string) { (json) in
            
            guard let json = json else {
                completion(false)
                return
            }
            do {
                try ParsePhotos.parsePhotoEntities(json: json) { success in
                    completion(success)
                }
            } catch {
                completion(false)
                let error = ErrorAlertController()
                error.showErrorAlertController(title: "ERROR! Fetching JSON for search Photo", message: "Try again?")
            }
        }
    }
    
}
