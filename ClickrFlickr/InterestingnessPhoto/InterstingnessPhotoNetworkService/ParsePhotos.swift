//
//  ParsePhotos.swift
//  ClickrFlickr
//
//  Created by Artur Olar on 12/6/17.
//  Copyright © 2017 Artur Olar. All rights reserved.
//

import Foundation

class ParsePhotos {
    
    var parsePhoto: [PhotoEntitie]
    
    var stack = CoreDatastack()

    init (json: AnyObject) throws {
        
        guard let photos = json["photos"] as? [String: Any] else { throw FlickOauthError.NetworkServiseError }
        
        guard let photo = photos["photo"] as? [[String: Any]] else { throw FlickOauthError.NetworkServiseError }
        
        var parsePhoto = [PhotoEntitie]()
        
        for element in photo {
            
            guard let photoEntitie = PhotoEntitie(dict: element, context: stack.mainManagedObjectContext) else { throw FlickOauthError.NetworkServiseError }
            stack.saveMainContext()
            
            parsePhoto.append(photoEntitie)
        }
        
        self.parsePhoto = parsePhoto
    }
    
}
