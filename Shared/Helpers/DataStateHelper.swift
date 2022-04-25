//
//  DataStateHelper.swift
//  ATracks
//
//  Created by James Hager on 4/23/22.
//

import Foundation

enum DataStateHelper {
    
    static let dataStateKey = "dataState"
    static let dataStateCurrent = 2
    
    static let userDefaultsCreatedKey = "userDefaultsCreated"
    
    static let file = "DataStateHelper"
    
    // MARK: - Methods
    
    static func checkDataState() {
        print("=== \(file).\(#function) ===")
        
        // dataState values
        //    1: Initial
        //    2: Use dataStateKey to determine if userDefaultSettings have been set
        
        let userDefaults = UserDefaults.standard
        
        defer {
            setDataStateCurrent()
            userDefaults.synchronize()
        }
        
        let dataState: Int
        if userDefaults.object(forKey: dataStateKey) != nil {
            dataState = getDataState()
            print("=== \(file).\(#function) - dataState: \(dataState), dataStateCurrent: \(dataStateCurrent) ===")
        } else {
            print("=== \(file).\(#function) - dataState: nil, dataStateCurrent: \(dataStateCurrent) ===")
            setUserDefaultSettings()
            return
        }
        
        if dataState < 2 {
            userDefaults.removeObject(forKey: userDefaultsCreatedKey)
        }
    }
    
    static func getDataState() -> Int {
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
}
