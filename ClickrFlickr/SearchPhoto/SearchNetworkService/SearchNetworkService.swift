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
    
    static func getJsonForSearchPhoto(searchText: String, completion: @escaping (SearchPhotos)->()) {
        guard let string = CallingFlickrAPIwithOauth.methodPhotosSearch(oauthText: searchText) else {return}
        
        let fetchJSON = FetchJSON()
        fetchJSON.fetchJson(fromUrl: string) { (json) in
            
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
