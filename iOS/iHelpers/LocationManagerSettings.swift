//
//  LocationManagerSettings.swift
//  ATracks
//
//  Created by James Hager on 4/23/22.
//

import Foundation
import Combine

protocol LocationManagerSettingsProvider {
    var useAutoStop: Bool { get }
}

class LocationManagerSettings: LocationManagerSettingsProvider, ObservableObject {
    
    static let useAutoStopKey = "useAutoStop"
    static let useAutoStopDefault = true
    
    static let useDefaultTrackNameKey = "useDefaultTrackName"
    static let useDefaultTrackNameDefault = false
    
    static let shared = LocationManagerSettings()
    
    @Published var useAutoStop: Bool {
        didSet {
            print("=== \(file).\(#function) didSet - \(useAutoStop) ===")
            UserDefaults.standard.set(useAutoStop, forKey: LocationManagerSettings.useAutoStopKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    @Published var useDefaultTrackName: Bool {
        didSet {
            print("=== \(file).\(#function) didSet - \(useDefaultTrackName) ===")
            UserDefaults.standard.set(useDefaultTrackName, forKey: LocationManagerSettings.useDefaultTrackNameKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    lazy var file = Func.sourceFileNameFromFullPath(#file)
    
    // MARK: - Init
    
    init() {
        let userDefaults = UserDefaults.standard
        useAutoStop = userDefaults.bool(forKey: LocationManagerSettings.useAutoStopKey)
        useDefaultTrackName = userDefaults.bool(forKey: LocationManagerSettings.useDefaultTrackNameKey)
    }
    
    // MARK: - Methods
    
    func setDefaults() {
        useAutoStop = LocationManagerSettings.useAutoStopDefault
        useDefaultTrackName = LocationManagerSettings.useDefaultTrackNameDefault
    }
}
