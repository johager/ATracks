//
//  UserDefaultsHelper.swift
//  ATracks
//
//  Created by James Hager on 4/23/22.
//

import Foundation

enum UserDefaultsHelper {
    
    static let dataStateKey = "dataState"
    static let dataStateCurrent = 1
    
    static let userDefaultsCreatedKey = "userDefaultsCreated"
    
    static let file = "UserDefaultsHelper"
    
    // MARK: - Methods
    
    static func setUserDefaultsIfNeeded() {
        let userDefaults = UserDefaults.standard
        let userDefaultsCreated = userDefaults.bool(forKey: userDefaultsCreatedKey)
        
        if userDefaultsCreated {
            print("=== \(file).\(#function) - don't set defaults ===")
            return
        }
        
        print("=== \(file).\(#function) - set defaults ===")
        userDefaults.set(true, forKey: userDefaultsCreatedKey)
        setDataStateCurrent()
        setUserDefaultSettings()
        userDefaults.synchronize()
    }
    
    static func getDataState() -> Int {
        return UserDefaults.standard.integer(forKey: dataStateKey)
    }
    
    static func setDataStateCurrent() {
        UserDefaults.standard.set(dataStateCurrent, forKey: dataStateKey)
    }
    
    static func setUserDefaultSettings() {
        #if os(iOS)
        LocationManagerSettings.shared.setDefaults()
        #endif
    }
}
