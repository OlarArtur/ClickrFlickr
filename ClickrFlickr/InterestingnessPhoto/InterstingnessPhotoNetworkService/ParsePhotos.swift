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
    
    static func parsePhotos(json: AnyObject, completion: @escaping ([Photo])->() ) throws {
        
        guard let photos = json["photos"] as? [String: Any] else { throw FlickOauthError.NetworkServiseError }
        
        guard let photo = photos["photo"] as? [[String: Any]] else { throw FlickOauthError.NetworkServiseError }
        
        DispatchQueue.global().async {
            let arrayPhoto = photo.flatMap{Photo(dict: $0)}
            DispatchQueue.main.async {
                completion(arrayPhoto)
            }
        }
    }

    static func parsePhotoEntities(json: AnyObject, completion: @escaping (Bool)->()) throws {
        
        guard let photos = json["photos"] as? [String: Any] else {
            completion(false)
            throw FlickOauthError.NetworkServiseError
        }
        guard let photo = photos["photo"] as? [[String: Any]] else {
            completion(false)
            throw FlickOauthError.NetworkServiseError
        }
        
        var uniques = [String]()
        
        let context = CoreDatastack.default.writeManagedObjectContext
        context.perform {
            
            let fetchRequest: NSFetchRequest<PhotoEntitie> = PhotoEntitie.fetchRequest()
            do {
                let photoEntities = try context.fetch(fetchRequest)
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
                    _ = PhotoEntitie(dict: photo[index], context: context)
                }
            }
            CoreDatastack.default.saveContext()
            completion(true)
        }
        
    }
    
}
