//
//  PhotoEntitie+CoreDataProperties.swift
//  ClickrFlickr
//
//  Created by Artur Olar on 12/7/17.
//  Copyright © 2017 Artur Olar. All rights reserved.
//
//

import Foundation
import CoreData


extension PhotoEntitie {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PhotoEntitie> {
        return NSFetchRequest<PhotoEntitie>(entityName: "PhotoEntitie")
    }

    @NSManaged public var imageID: String
    @NSManaged public var imageURL: String?
    @NSManaged public var photoDescription: String?
    @NSManaged public var title: String?
    @NSManaged public var aspectRatio: String?

}
