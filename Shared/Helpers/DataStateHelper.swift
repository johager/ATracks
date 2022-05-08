//
//  DataStateHelper.swift
//  ATracks
//
//  Created by James Hager on 4/23/22.
//

import Foundation
import CoreData

enum DataStateHelper {
    
    static let dataStateKey = "dataState"
    static let dataStateCurrent = 8
    
    static let userDefaultsCreatedKey = "userDefaultsCreated"
    
    static let file = "DataStateHelper"
    
    // MARK: - Methods
    
    static func checkDataState() {
        //print("=== \(file).\(#function) ===")
        
        // dataState values
        //    1: Initial
        //    2: Use dataStateKey to determine if userDefaultSettings have been set
        //    3: DataModel 2: Track altitude info and hasFinalSteps
        //    4: DataModel 3: Track.deviceName, deviceUUID, and isTracking
        //    5: LocationManagerSettings.useDefaultTrackName
        //    6: DisplaySettings
        //    7: DisplaySettings.placeButtonsOnRightInLandscape
        //    8: New Track.hasFinalSteps
        
        let userDefaults = UserDefaults.standard
        
        if userDefaults.object(forKey: dataStateKey) == nil {
            print("=== \(file).\(#function) - dataState saved/current: nil/\(dataStateCurrent) ===")
            setUserDefaultSettings()
            setDataStateCurrent()
            userDefaults.synchronize()
            return
        }
        
        //UserDefaults.standard.set(7, forKey: dataStateKey)
        
        let dataStateSaved = savedDataState()
        print("=== \(file).\(#function) - dataState saved/current: \(dataStateSaved)/\(dataStateCurrent) ===")
        
        if dataStateSaved == dataStateCurrent {
            return
        }
        
        let context = CoreDataStack.shared.context
        var shouldSaveContext = false
        
        if dataStateSaved < 2 {
            userDefaults.removeObject(forKey: userDefaultsCreatedKey)
        }
        
        if dataStateSaved < 3 {
            prepForDataState3(context: context, shouldSaveContext: &shouldSaveContext)
        }
        
        if dataStateSaved < 4 {
            prepForDataState4(context: context, shouldSaveContext: &shouldSaveContext)
        }
        
        if dataStateSaved < 5 {
            prepForDataState5()
        }
        
        if dataStateSaved < 6 {
            DisplaySettings.shared.setDefaults()
        }
        
        if dataStateSaved < 7 {
            prepForDataState7()
        }
        
        if dataStateSaved < 8 {
            prepForDataState8(context: context, shouldSaveContext: &shouldSaveContext)
        }
        
        if shouldSaveContext {
            CoreDataStack.shared.saveContext()
        }
        
        setDataStateCurrent()
        userDefaults.synchronize()
    }
    
    static func savedDataState() -> Int {
        return UserDefaults.standard.integer(forKey: dataStateKey)
    }
    
    static func setDataStateCurrent() {
        UserDefaults.standard.set(dataStateCurrent, forKey: dataStateKey)
    }
    
    static func setUserDefaultSettings() {
        print("=== \(file).\(#function) ===")
        DisplaySettings.shared.setDefaults()
        #if os(iOS)
        LocationManagerSettings.shared.setDefaults()
        #endif
    }
    
    static func performBatchUpdate(_ batchUpdateRequest: NSBatchUpdateRequest, in context: NSManagedObjectContext, purpose: String? = nil) {
        
        if let purpose = purpose {
            let entityName = batchUpdateRequest.entityName
            print("=== \(file).\(#function) - \(entityName): \(purpose) ===")
        }
        
        batchUpdateRequest.resultType = .updatedObjectIDsResultType
        
        do {
            let result = try context.execute(batchUpdateRequest) as? NSBatchUpdateResult
            
            guard let objectIDArray = result?.result as? [NSManagedObjectID] else { return }
            
            let changes = [NSUpdatedObjectsKey : objectIDArray]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [context])
            
        } catch {
            let updateError = error as NSError
            print("\(updateError), \(updateError.userInfo)")
        }
    }
    
    // MARK: - Data State Conversion Methods
    
    static func prepForDataState3(context:  NSManagedObjectContext, shouldSaveContext: inout Bool) {
        // DataModel 2: Track altitude info and hasFinalSteps
        print("=== \(file).\(#function) ===")
        
        let fetchRequest = Track.fetchRequest
        
        do {
            let tracks = try context.fetch(fetchRequest)
            if tracks.count > 0 {
                shouldSaveContext = true
            }
            for track in tracks {
                track.setTrackSummaryData()
            }
        } catch let error as NSError {
            print("Fetch error: \(error.localizedDescription)\n---\n\(error.userInfo)")
        }
    }
    
    static func prepForDataState4(context:  NSManagedObjectContext, shouldSaveContext: inout Bool) {
        // DataModel 3: Track.deviceName, deviceUUID, and isTracking
        print("=== \(file).\(#function) ===")
        
        let deviceUUID = Func.deviceUUID
        
        guard deviceUUID == "187F59C0-ECEA-4A77-AE3B-6ED1CD213F6A" else { return }
        
        let deviceName = Func.deviceName
        
        let simName = "iPhone 13 Mini"
        let simUUID = "C0424B10-ADC8-4D82-A86B-6FD034EE9177"
        
        let fetchRequest = Track.fetchRequest
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Track.dateKey, ascending: false)]
        
        do {
            let tracks = try context.fetch(fetchRequest)
            if tracks.count > 0 {
                shouldSaveContext = true
            }
            for track in tracks {
                print("--- \(file).\(#function) - name: \(track.name), isTracking: \(track.isTracking)")
                if let firstTrackPoint = track.trackPoints.first {
                    if firstTrackPoint.longitude < -115 {
                        print("--- \(file).\(#function) - set sim")
                        track.deviceName = simName
                        track.deviceUUID = simUUID
                    } else {
                        print("--- \(file).\(#function) - set device")
                        track.deviceName = deviceName
                        track.deviceUUID = deviceUUID
                    }
                }
            }
        } catch let error as NSError {
            print("Fetch error: \(error.localizedDescription)\n---\n\(error.userInfo)")
        }
    }
    
    static func prepForDataState5() {
        // LocationManagerSettings.useDefaultTrackName
        
        #if os(iOS)
        UserDefaults.standard.set(LocationManagerSettings.useDefaultTrackNameDefault, forKey: LocationManagerSettings.useDefaultTrackNameKey)
        #endif
    }
    
    static func prepForDataState7() {
        // DisplaySettings.placeButtonsOnRightInLandscape
        print("=== \(file).\(#function) ===")
        
        #if os(iOS)
        UserDefaults.standard.set(DisplaySettings.placeButtonsOnRightInLandscapeDefault, forKey: DisplaySettings.placeButtonsOnRightInLandscapeKey)
        #endif
    }
    
    //
    static func prepForDataState8(context:  NSManagedObjectContext, shouldSaveContext: inout Bool) {
        // New Track.hasFinalSteps
        
        #if targetEnvironment(simulator)
        print("=== \(file).\(#function) - simulator ===")
        return
        #endif
        
        print("=== \(file).\(#function) ===")
        
        guard DeviceType.current() == .phone else { return }
        
        let batchUpdateRequest = NSBatchUpdateRequest(entityName: DataType.track.entityName)
        batchUpdateRequest.predicate = NSPredicate(format: "%K == %@", Track.altitudeIsValidKey, NSNumber(value: true))
        batchUpdateRequest.propertiesToUpdate = [Track.hasFinalStepsKey: false]
        
        performBatchUpdate(batchUpdateRequest, in: context, purpose: "Set hasFinalSteps false for altitudeIsValid")
        
        batchUpdateRequest.predicate = NSPredicate(format: "%K == %@", Track.altitudeIsValidKey, NSNumber(value: false))
        batchUpdateRequest.propertiesToUpdate = [Track.hasFinalStepsKey: true]
        
        performBatchUpdate(batchUpdateRequest, in: context, purpose: "Set hasFinalSteps true for !altitudeIsValid")
        
        shouldSaveContext = true
    }
}
