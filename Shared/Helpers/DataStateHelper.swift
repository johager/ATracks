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
    static let dataStateCurrent = 3
    
    static let userDefaultsCreatedKey = "userDefaultsCreated"
    
    static let file = "DataStateHelper"
    
    // MARK: - Methods
    
    static func checkDataState() {
        //print("=== \(file).\(#function) ===")
        
        // dataState values
        //    1: Initial
        //    2: Use dataStateKey to determine if userDefaultSettings have been set
        //    3: DataModel 2: altitude info and hasFinalSteps
        
        let userDefaults = UserDefaults.standard
        
        if userDefaults.object(forKey: dataStateKey) == nil {
            print("=== \(file).\(#function) - dataState saved/current: nil/\(dataStateCurrent) ===")
            setUserDefaultSettings()
            setDataStateCurrent()
            userDefaults.synchronize()
            return
        }
        
        let dataStateSaved = savedDataState()
        print("=== \(file).\(#function) - dataState saved/current: \(dataStateSaved)/\(dataStateCurrent) ===")
        
        if dataStateSaved == dataStateCurrent {
            return
        }
        
        let context = CoreDataStack.shared.context
        
        if dataStateSaved < 2 {
            userDefaults.removeObject(forKey: userDefaultsCreatedKey)
        }
        
        if dataStateSaved < 3 {
            prepForDataState3(context:  context)
        }
        
        CoreDataStack.shared.saveContext()
        
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
        #if os(iOS)
        LocationManagerSettings.shared.setDefaults()
        #endif
    }
    
    // MARK: - Data State Conversion Methods
    
    static func prepForDataState3(context:  NSManagedObjectContext) {
        // DataModel 2: altitude info and hasFinalSteps
        print("=== \(file).\(#function) ===")
        
        let fetchRequest = Track.fetchRequest
        
        do {
            let tracks = try context.fetch(fetchRequest)
            for track in tracks {
                track.setTrackSummaryData()
            }
        } catch let error as NSError {
            print("Fetch error: \(error.localizedDescription)\n---\n\(error.userInfo)")
        }
    }
}
