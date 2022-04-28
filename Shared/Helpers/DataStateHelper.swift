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
    static let dataStateCurrent = 4
    
    static let hasOnboardedKey = "hasOnboarded"
    
    static let userDefaultsCreatedKey = "userDefaultsCreated"
    
    static let file = "DataStateHelper"
    
    // MARK: - Onboarding Methods
    
    static var shouldOnboard: Bool {
        !UserDefaults.standard.bool(forKey: hasOnboardedKey)
    }
    
    static func setHasOnboarded() {
        UserDefaults.standard.set(true, forKey: hasOnboardedKey)
        UserDefaults.standard.synchronize()
    }
    
    // MARK: - Data State Methods
    
    static func checkDataState() {
        //print("=== \(file).\(#function) ===")
        
        // dataState values
        //    1: Initial
        //    2: Use dataStateKey to determine if userDefaultSettings have been set
        //    3: DataModel 2: Track altitude info and hasFinalSteps
        //    4: DataModel 3: Track.deviceName, deviceUUID, and isTracking
        
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
        
        if dataStateSaved < 4 {
            prepForDataState4(context:  context)
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
        // DataModel 2: Track altitude info and hasFinalSteps
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
    
    static func prepForDataState4(context:  NSManagedObjectContext) {
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
}
