//
//  SearchNetworkService.swift
//  ClickrFlickr
//
//  Created by Artur Olar on 11/9/17.
//  Copyright © 2017 Artur Olar. All rights reserved.
//

import Foundation

class SearchNetworkservice {
    
    private init() {}
    
    static func getJsonForSearchPhoto(searchText: String, completion: @escaping ([Photo])->()) {
        guard let string = CallingFlickrAPIwithOauth.methodPhotosSearch(oauthText: searchText) else {return}
        
        FetchJSON.fetchJson(fromUrl: string) { (json) in
            
            guard let json = json else {return}
            do {
//                let start = Date()
            
//                let searchPhoto = try SearchPhotos(json: json)
                _ = try ParsePhotos.parsePhotos(json: json, completion: { (photo) in
                    completion(photo)
                })
//                let end = Date()
//                print(start.timeIntervalSince(end))
//                completion(searchPhoto)
            } catch {
                let error = ErrorAlertController()
                error.showErrorAlertController(title: "ERROR! Fetching JSON for search Photo", message: "Try again?")
            }
        }
    }
    
}
