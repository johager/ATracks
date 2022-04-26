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
    
    var context: NSManagedObjectContext {
        let context = persistentContainer.viewContext
        context.automaticallyMergesChangesFromParent = true
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }
    
    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: modelName)
        container.persistentStoreDescriptions.first?.url = psURL
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("=== CoreDataStack.persistentContainer - error loading persistent stores: \(error.localizedDescription)\n---\n\(error)")
            }
        }
        return container
    }()
    
    var psURL: URL {
        modelDirectoryURL.appendingPathComponent(modelName)
    }
    
    var modelDirectoryURL: URL {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }
    
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
