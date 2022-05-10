//
//  NSManagedObjectContext+.swift
//  ATracks
//
//  Created by James Hager on 5/10/22.
//

import CoreData

extension NSManagedObjectContext {
    
    func execute(_ batchUpdateRequest: NSBatchUpdateRequest, purpose: String? = nil) {
        
        if let purpose = purpose {
            let entityName = batchUpdateRequest.entityName
            print("=== NSManagedObjectContext.\(#function) - \(entityName): \(purpose) ===")
        }
        
        batchUpdateRequest.resultType = .updatedObjectIDsResultType
        
        do {
            let result = try self.execute(batchUpdateRequest) as? NSBatchUpdateResult
            
            guard let objectIDArray = result?.result as? [NSManagedObjectID] else { return }
            
            let changes = [NSUpdatedObjectsKey : objectIDArray]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [self])
            
        } catch {
            let updateError = error as NSError
            print("\(updateError), \(updateError.userInfo)")
        }
    }
}
