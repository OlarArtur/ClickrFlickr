//
//  PhotoEntitie+CoreDataClass.swift
//  ClickrFlickr
//
//  Created by Artur Olar on 12/6/17.
//  Copyright © 2017 Artur Olar. All rights reserved.
//
//

import Foundation
import CoreData

@objc(PhotoEntitie)
public class PhotoEntitie: NSManagedObject {
    
    convenience init? (dict: [String: Any], context: NSManagedObjectContext) {
        guard let title = dict["title"] as? String,
            let farm = dict["farm"] as? Int,
            let heightS = dict["height_s"] as? String,
            let widthS = dict["width_s"] as? String,
            let server = dict["server"] as? String,
            let id = dict["id"] as? String,
            let secret = dict["secret"] as? String,
            let descriptionDict = dict["description"] as? [String: Any],
            let description = descriptionDict["_content"] as? String else { return nil }
        
        guard let photoEntitie = NSEntityDescription.entity(forEntityName: "PhotoEntitie", in: context) else {return nil}
        
        self.init(entity: photoEntitie, insertInto: context)
        
        guard let height = Float(heightS), let width = Float(widthS) else { return nil }
        
        self.aspectRatio = String(height / width)
        self.imageURL = "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret).jpg"
        self.imageID = id
        self.title = title
        
        guard let htmlData = description.data(using: String.Encoding.utf8, allowLossyConversion: false) else {
            self.photoDescription = description
            return
        }
        guard let attributedString = try? NSAttributedString(data: htmlData, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil) else {
            self.photoDescription = description
            return
        }
        self.photoDescription = attributedString.string
    }
    
}
