//
//  DisplaySettings.swift
//  ATracks
//
//  Created by James Hager on 5/1/22.
//

import Foundation
import Combine

class DisplaySettings: ObservableObject {
    
    static let mapViewSatelliteKey = "mapViewSatellite"
    static let mapViewSatelliteDefault = false
    
    static let placeMapOnRightInLandscapeKey = "placeMapOnRightInLandscape"
    static let placeMapOnRightInLandscapeDefault = false
    
    static let shared = DisplaySettings()
    
    @Published var mapViewSatellite: Bool {
        didSet {
            print("=== \(file).\(#function) didSet - \(mapViewSatellite) ===")
            UserDefaults.standard.set(mapViewSatellite, forKey: DisplaySettings.mapViewSatelliteKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    @Published var placeMapOnRightInLandscape: Bool {
        didSet {
            print("=== \(file).\(#function) didSet - \(placeMapOnRightInLandscape) ===")
            UserDefaults.standard.set(placeMapOnRightInLandscape, forKey: DisplaySettings.placeMapOnRightInLandscapeKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    lazy var file = Func.sourceFileNameFromFullPath(#file)
    
    // MARK: - Init
    
    init() {
        let userDefaults = UserDefaults.standard
        mapViewSatellite = userDefaults.bool(forKey: DisplaySettings.mapViewSatelliteKey)
        placeMapOnRightInLandscape = userDefaults.bool(forKey: DisplaySettings.placeMapOnRightInLandscapeKey)
    }
    
    // MARK: - Methods
    
    func setDefaults() {
        mapViewSatellite = DisplaySettings.mapViewSatelliteDefault
        placeMapOnRightInLandscape = DisplaySettings.placeMapOnRightInLandscapeDefault
    }
}
