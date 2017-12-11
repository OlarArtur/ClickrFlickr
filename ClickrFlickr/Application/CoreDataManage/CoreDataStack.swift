//
//  CoreDataStack.swift
//  ClickrFlickr
//
//  Created by Artur Olar on 12/6/17.
//  Copyright © 2017 Artur Olar. All rights reserved.
//

import Foundation
import CoreData

class CoreDatastack: NSObject {
    
    static let `default` = CoreDatastack()
    private override init() {}
    
    private let modelName = "ClickrFlickr"
    
    private lazy var managedObjectModel: NSManagedObjectModel = {
        
        guard let modelURL = Bundle.main.url(forResource: modelName, withExtension: "momd") else {
            fatalError("Error loading model from bundle")
        }
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Error init model from \(modelURL)")
        }
        return managedObjectModel
    } ()
    
    private lazy var coordinator: NSPersistentStoreCoordinator = {
        
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        let persistantStoreURL = self.getDocumentsDirectory?.appendingPathComponent("ClickrFlickr.sqlite")
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: persistantStoreURL, options: [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true])
        } catch {
            fatalError("Error adding persistent store \(error)")
        }
        return coordinator
        
    } ()
    
    private lazy var getDocumentsDirectory: URL? = {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        guard let documentsDirectory = paths.first else {return nil}
        return documentsDirectory
    } ()
    
    private(set) lazy var mainManagedObjectContext: NSManagedObjectContext = {
        
        let mangedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        mangedObjectContext.parent = writeManagedObjectContext
        mangedObjectContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        return mangedObjectContext
        
    } ()
    
    private(set) lazy var writeManagedObjectContext: NSManagedObjectContext = {

        let mangedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        mangedObjectContext.persistentStoreCoordinator = coordinator
        mangedObjectContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        return mangedObjectContext
        
    } ()
    
    func saveContext() {
        
        if mainManagedObjectContext.hasChanges {
            mainManagedObjectContext.performAndWait {
                do {
                    try mainManagedObjectContext.save()
                    print("Save")
                } catch {
                    fatalError("Error saving main context \(error)")
                }
            }
        }
        
        if writeManagedObjectContext.hasChanges {
            writeManagedObjectContext.perform {
                do {
                    try self.writeManagedObjectContext.save()
                    print("Private Save")
                } catch {
                    fatalError("Error saving private context \(error)")
                }
            }
        }
        
    }

}
