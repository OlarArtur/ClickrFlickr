//
//  GetPhotoNetworkService.swift
//  ClickrFlickr
//
//  Created by Artur Olar on 11/15/17.
//  Copyright © 2017 Artur Olar. All rights reserved.
//

import Foundation

class GetPhotoNetworkservice {
    
    private init() {}
    
    static func getJsonForSearchPhoto(userId: String, completion: @escaping (SearchPhotos)->()) {
        guard let string = CallingFlickrAPIwithOauth.methodPeopleGetPhoto(userId: userId) else {return}
        
        FetchJSON.fetchJson(fromUrl: string) { (json) in
            
            guard let json = json else {return}
            do {
                let searchPhoto = try SearchPhotos(json: json)
                completion(searchPhoto)
            } catch {
                let error = ErrorAlertController()
                error.showErrorAlertController(title: "ERROR! Fetching JSON for search Photo", message: "Try again?")
            }
        }
    }
    
}
