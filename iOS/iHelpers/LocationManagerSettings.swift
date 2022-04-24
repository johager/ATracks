//
//  LocationManagerSettings.swift
//  ATracks
//
//  Created by James Hager on 4/23/22.
//

import Foundation
import Combine

class LocationManagerSettings: ObservableObject {
    
    static let useAutoStopKey = "useAutoStop"
    static let useAutoStopDefault = true
    
    @Published var useAutoStop: Bool {
        didSet {
            print("=== \(file).\(#function) didSet - \(useAutoStop) ===")
            UserDefaults.standard.set(useAutoStop, forKey: LocationManagerSettings.useAutoStopKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    lazy var file = Func.sourceFileNameFromFullPath(#file)
    
    // MARK: - Init
    
    init() {
        let userDefaults = UserDefaults.standard
        useAutoStop = userDefaults.bool(forKey: LocationManagerSettings.useAutoStopKey)
    }
    
    // MARK: - Methods
    
    static func setDefaults() {
        UserDefaults.standard.set(useAutoStopDefault, forKey: useAutoStopKey)
    }
}
