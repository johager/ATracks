//
//  CoreDataStack.swift
//  ATracks
//
//  Created by James Hager on 4/18/22.
//

import CoreData
import os.log

class CoreDataStack: NSObject {
    
    static let shared = CoreDataStack()
    
    private let modelName = "ATracks"
    
    var logger: Logger?
    
    lazy var file = Func.sourceFileNameFromFullPath(#file)
    
    // MARK: - Init
    
    private override init() {
        super.init()
        logger = Func.logger(for: file)
    }
    
    deinit{
        print("=== CoreDataStack.deinit ===")
        NotificationCenter.default.removeObserver(self)
    }
    
    var context: NSManagedObjectContext { persistentContainer.viewContext }
    
    //lazy var persistentContainer: NSPersistentContainer = {
    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: modelName)
        container.persistentStoreDescriptions.first?.url = persistentStoreURL
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("=== CoreDataStack.persistentContainer - error loading persistent stores: \(error.localizedDescription)\n---\n\(error)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return container
    }()
    
    var persistentStoreURL: URL {
        modelDirectoryURL.appendingPathComponent(modelName)
    }
    
    var modelDirectoryURL: URL {
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
        else { fatalError("=== CoreDataStack.modelDirectoryURL - Error finding directory") }
        
        print("=== CoreDataStack.modelDirectoryURL ===\n\(url)\n---  ---  ---  ---")
        return url
    }
    
    func saveContext() {
        print("<<< saveContext >>>")

        guard context.hasChanges else { return }
        
        do {
            try context.save()
        } catch let error as NSError {
            if logger == nil {
                logger = Func.logger(for: file)
            }
            logger!.notice("save(context) - Error: \(error.localizedDescription, privacy: .public)")
            if let detailedErrors = error.userInfo[NSDetailedErrorsKey] as? [NSError] {
                for detailedError in detailedErrors {
                    logger!.notice("save(context) - Detailed Error: \(detailedError.localizedDescription, privacy: .public)")
                    logger!.notice("save(context) - - userInfo: \(detailedError.userInfo, privacy: .public)")
                }
            }
            abort()
        }
    }
}
