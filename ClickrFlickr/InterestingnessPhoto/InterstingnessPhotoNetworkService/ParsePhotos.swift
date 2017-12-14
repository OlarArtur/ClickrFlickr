//
//  ParsePhotos.swift
//  ClickrFlickr
//
//  Created by Artur Olar on 12/6/17.
//  Copyright © 2017 Artur Olar. All rights reserved.
//

import Foundation
import CoreData

class ParsePhotos {

    static func newPhotos(json: AnyObject) throws {
        
        guard let photos = json["photos"] as? [String: Any] else { throw FlickOauthError.NetworkServiseError }
        
        guard let photo = photos["photo"] as? [[String: Any]] else { throw FlickOauthError.NetworkServiseError }
        
        var uniques = [String]()
        
        let fetchRequest: NSFetchRequest<PhotoEntitie> = PhotoEntitie.fetchRequest()
        do {
            let photoEntities = try CoreDatastack.default.mainManagedObjectContext.fetch(fetchRequest)
            uniques = photoEntities.flatMap({ $0.imageID }).sorted()
        } catch {
            print("Error fetch request \(error)")
        }
        
        let uniquesFlickr = photo.flatMap({ $0["id"] as? String}).sorted()
        
        let uniquesSet = Set(uniques)
        var news = Set(uniquesFlickr)
        
        news.subtract(uniquesSet)
        
        for unic in news {
            if let index = photo.index(where: { $0["id"] as? String == unic }) {
                _ = PhotoEntitie(dict: photo[index], context: CoreDatastack.default.mainManagedObjectContext)
                CoreDatastack.default.saveContext()
            }
        }

    }
    
}
