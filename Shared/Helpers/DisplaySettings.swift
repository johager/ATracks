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
    
    static let placeButtonsOnRightInLandscapeKey = "placeButtonsOnRightInLandscape"
    static let placeButtonsOnRightInLandscapeDefault = false
    
    static let placeMapOnRightInLandscapeKey = "placeMapOnRightInLandscape"
    static let placeMapOnRightInLandscapeDefault = false
    
    static let shared = DisplaySettings()
    
    @Published var mapViewSatellite: Bool {
        didSet {
            print("=== \(file).\(#function) didSet \(mapViewSatellite) ===")
            UserDefaults.standard.set(mapViewSatellite, forKey: DisplaySettings.mapViewSatelliteKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    #if os(iOS)
    @Published var placeButtonsOnRightInLandscape: Bool {
        didSet {
            print("=== \(file).\(#function) didSet \(placeButtonsOnRightInLandscape) ===")
            UserDefaults.standard.set(placeButtonsOnRightInLandscape, forKey: DisplaySettings.placeButtonsOnRightInLandscapeKey)
            UserDefaults.standard.synchronize()
        }
    }
    #endif
    
    @Published var placeMapOnRightInLandscape: Bool {
        didSet {
            print("=== \(file).\(#function) didSet \(placeMapOnRightInLandscape) ===")
            UserDefaults.standard.set(placeMapOnRightInLandscape, forKey: DisplaySettings.placeMapOnRightInLandscapeKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    lazy var file = Func.sourceFileNameFromFullPath(#file)
    
    // MARK: - Init
    
    init() {
        let userDefaults = UserDefaults.standard
        mapViewSatellite = userDefaults.bool(forKey: DisplaySettings.mapViewSatelliteKey)
        #if os(iOS)
        placeButtonsOnRightInLandscape = userDefaults.bool(forKey: DisplaySettings.placeButtonsOnRightInLandscapeKey)
        #endif
        placeMapOnRightInLandscape = userDefaults.bool(forKey: DisplaySettings.placeMapOnRightInLandscapeKey)
    }
    
    // MARK: - Methods
    
    func setDefaults() {
        mapViewSatellite = DisplaySettings.mapViewSatelliteDefault
        #if os(iOS)
        placeButtonsOnRightInLandscape = DisplaySettings.placeButtonsOnRightInLandscapeDefault
        #endif
        placeMapOnRightInLandscape = DisplaySettings.placeMapOnRightInLandscapeDefault
    }
}
