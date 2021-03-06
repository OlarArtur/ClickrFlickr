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
    
    static func getJsonForSearchPhoto(searchText: String, completion: @escaping ([Photo]?)->()) {
        guard let string = CallingFlickrAPIwithOauth.methodPhotosSearch(oauthText: searchText) else {return}
        
        FetchJSON.fetchJson(fromUrl: string) { (json) in
            
            guard let json = json else {
                completion(nil)
                return
            }
            do {
                _ = try ParsePhotos.parsePhotos(json: json, completion: { (photo) in
                    completion(photo)
                })
            } catch {
                let error = ErrorAlertController()
                error.showErrorAlertController(title: "ERROR! Fetching JSON for search Photo", message: "Try again?")
                completion(nil)
            }
        }
    }
    
}
