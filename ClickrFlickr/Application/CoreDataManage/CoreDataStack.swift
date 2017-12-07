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
    
    private lazy var getDocumentsDirectory: URL = {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    } ()
    
    private lazy var coordinator: NSPersistentStoreCoordinator = {
        
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let persistantStoreURL = self.getDocumentsDirectory.appendingPathComponent("ClickrFlickr.sqlite")
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: persistantStoreURL, options: [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: false])
        } catch {
            fatalError("Error adding persistent store \(error)")
        }
        return coordinator
        
    } ()
    
    private(set) lazy var mainManagedObjectContext: NSManagedObjectContext = {
        
        let mangedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        mangedObjectContext.parent = self.privateManagedObjectContext
        mangedObjectContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        return mangedObjectContext
        
    } ()
    
    private lazy var privateManagedObjectContext: NSManagedObjectContext = {

        let mangedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        mangedObjectContext.persistentStoreCoordinator = self.coordinator
        mangedObjectContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        return mangedObjectContext
        
    } ()
    
    func saveMainContext() {
        
        if mainManagedObjectContext.hasChanges || privateManagedObjectContext.hasChanges {
           
            mainManagedObjectContext.performAndWait {
                do {
                    try mainManagedObjectContext.save()
//                    print("Save")
                } catch {
                    fatalError("Error saving main context \(error)")
                }
            }
            
            privateManagedObjectContext.perform {
                do {
                    try self.privateManagedObjectContext.save()
//                    print("Private Save")
                } catch {
                    fatalError("Error saving private context \(error)")
                }
            }
        }
        
    }
    
}
