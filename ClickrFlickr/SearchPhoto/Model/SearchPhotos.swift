//
//  SearchPhotos.swift
//  ClickrFlickr
//
//  Created by Artur Olar on 11/9/17.
//  Copyright © 2017 Artur Olar. All rights reserved.
//

import Foundation


class SearchPhotos {
    
    var searchPhoto: [Photo]
    
    init (json: AnyObject) throws {
        
        guard let photos = json["photos"] as? [String: Any] else { throw FlickOauthError.NetworkServiseError }
        
        guard let photo = photos["photo"] as? [[String: Any]] else { throw FlickOauthError.NetworkServiseError }
        
        self.searchPhoto = photo.flatMap(Photo.init(dict:))
        
//        var searchPhoto = [Photo]()
//        for element in photo {
//            guard let photo = Photo(dict: element) else { throw FlickOauthError.NetworkServiseError }
//            searchPhoto.append(photo)
//        }
//        self.searchPhoto = searchPhoto
    }
    
}
