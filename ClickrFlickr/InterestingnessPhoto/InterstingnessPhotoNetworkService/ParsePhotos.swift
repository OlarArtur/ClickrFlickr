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
        
        let arrayPhoto = photo.flatMap{Photo(dict: $0)}
        completion(arrayPhoto)
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
//            let sorDescriptor = NSSortDescriptor(key: "imageID", ascending: true)
//            fetchRequest.sortDescriptors = [sorDescriptor]
            
            do {
                let photoEntities = try context.fetch(fetchRequest)
                uniques = photoEntities.map({ $0.imageID })
            
                for entitie in photoEntities {
                    if let index = photo.index(where: { $0["id"] as? String == entitie.imageID }) {
                        if index != entitie.indexOfPopular{
                            entitie.indexOfPopular = Int16(index)
                        }
                    } else {
                        context.delete(entitie)
                    }
                }
                
            } catch {
                context.rollback()
                CoreDatastack.default.saveContext(context: context)
                print("Error fetch request \(error)")
                completion(false)
            }
            let uniquesFlickr = photo.flatMap({ $0["id"] as? String})
            
            let uniquesSet = Set(uniques)
            
            var news = Set(uniquesFlickr)
            
            news.subtract(uniquesSet)
                
            var batchToSave = 0
            
            var indexes = [Int]()
            for unic in news {
                if let index = photo.index(where: { $0["id"] as? String == unic }) {
                    indexes.append(index)
                }
            }
            
            let sortedIndexes = indexes.sorted()
            
            for index in sortedIndexes {
                _ = PhotoEntitie(dict: photo[index], index: index ,context: context)
                
                batchToSave += 1
                if batchToSave == 10 {
                    CoreDatastack.default.saveContext(context: context)
                    batchToSave = 0
                }
            }
            CoreDatastack.default.saveContext(context: context)
            completion(true)
        }
        
    }
    
}
