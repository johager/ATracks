//
//  AppStateHelper.swift
//  ATracks
//
//  Created by James Hager on 4/23/22.
//

import Foundation

enum AppStateHelper {
    
    static let dataStateKey = "dataState"
    static let dataStateCurrent = 1
    
    static let userDefaultsCreatedKey = "userDefaultsCreated"
    
    static let file = "AppStateHelper"
    
    // MARK: - Methods
    
    static func checkAppState() {
        print("=== \(file).\(#function) ===")
        setUserDefaultsIfNeeded()
        checkDataState()
    }
    
    // MARK: - User Defaults Methods
    
    static func setUserDefaultsIfNeeded() {
        let userDefaults = UserDefaults.standard
        let userDefaultsCreated = userDefaults.bool(forKey: userDefaultsCreatedKey)
        
        if userDefaultsCreated {
            print("=== \(file).\(#function) - don't set defaults ===")
            return
        }
        
        print("=== \(file).\(#function) - set defaults ===")
        userDefaults.set(true, forKey: userDefaultsCreatedKey)
        setUserDefaultSettings()
    }
    
    static func setUserDefaultSettings() {
        #if os(iOS)
        LocationManagerSettings.shared.setDefaults()
        #endif
    }
    
    // MARK: - Data State Methods
    
    static func checkDataState() {
        let userDefaults = UserDefaults.standard
        
        defer {
            setDataStateCurrent()
            userDefaults.synchronize()
        }
        
        let dataState: Int
        if UserDefaults.standard.object(forKey: dataStateKey) != nil {
            dataState = getDataState()
            print("=== \(file).\(#function) - dataState: \(dataState), dataStateCurrent: \(dataStateCurrent) ===")
        } else {
            print("=== \(file).\(#function) - dataState: nil, dataStateCurrent: \(dataStateCurrent) ===")
            return
        }
        
        if dataState < 2 {
            // do update
        }
    }
    
    static func getDataState() -> Int {
        return UserDefaults.standard.integer(forKey: dataStateKey)
    }
    
    static func setDataStateCurrent() {
        UserDefaults.standard.set(dataStateCurrent, forKey: dataStateKey)
    }
}
