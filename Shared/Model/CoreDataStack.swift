//
//  CoreDataStack.swift
//  ATracks
//
//  Created by James Hager on 4/18/22.
//

import CoreData

class CoreDataStack: NSObject {
    
    static let shared = CoreDataStack()
    
    private let modelName = "ATracks"
    
    private override init() { }
    
    deinit{
        print("=== CoreDataStack.deinit ===")
        NotificationCenter.default.removeObserver(self)
    }
    
    lazy var context: NSManagedObjectContext = {
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = psc
        managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return managedObjectContext
    }()
    
    lazy var psc: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        let options = [
            NSMigratePersistentStoresAutomaticallyOption: true,
            NSInferMappingModelAutomaticallyOption: true
        ]
        
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: psURL, options: options)
        } catch  {
            print(">> Error adding persistent store.")
        }
        
        return coordinator
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: modelName, withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var psURL: URL = {
        return modelDirectoryURL.appendingPathComponent(modelName)
    }()
    
    lazy var modelDirectoryURL: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    func saveContext() {
        print("<<< saveContext >>>")
        guard context.hasChanges else { return }
        
        do {
            try context.save()
        } catch let error as NSError {
            print(">>> Error: \(error.localizedDescription)")
            if let detailedErrors = error.userInfo[NSDetailedErrorsKey] as? [NSError] {
                for detailedError in detailedErrors {
                    print("--> Detailed Error: \(detailedError.localizedDescription)")
                    print(detailedError.userInfo)
                }
            }
            abort()
        }
    }
}
