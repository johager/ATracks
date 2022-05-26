//
//  LocationManager.swift
//  ATracks
//
//  Created by James Hager on 4/18/22.
//

import SwiftUI
import CoreLocation

class LocationManager: NSObject {
    
    static let shared = LocationManager()
    
    var location: CLLocation!
    var shouldAutoStop: Bool { settingsProvider.useAutoStop }
    
    private let locationManager = CLLocationManager()
    
    private var appIsActive = false
    
    var shouldTrack = true
    
    private var isAvailGPS = false
    
    var isTracking = false {
        didSet {
            if isTracking {
                NotificationCenter.default.post(name: .didStartTracking, object: nil)
            } else {
                NotificationCenter.default.post(name: .didStopTracking, object: nil)
            }
        }
    }
    
    let autoStopMinDistToStart: Double = 20
    let autoStopMinDistToStop: Double = 8 //4 //2
    let autoStopMinTimeIntToStart: TimeInterval = 30

    var firstLocation: CLLocation!
    private var shouldCheckAutoStop = false
    private var track: Track!
    
    var settingsProvider: LocationManagerSettingsProvider = LocationManagerSettings.shared
    
    lazy var file = Func.sourceFileNameFromFullPath(#file)
    
    // MARK: - Init
    
    private override init() {
        super.init()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 2
    }
    
    // MARK: - Methods
    
    func isTracking(_ someTrack: Track) -> Bool {
        guard isTracking,
              let selfTrack = self.track,
              selfTrack === someTrack
        else { return false }
        return true
    }
    
    func startLocationManagerUpdates() {
        print("=== \(file).\(#function) ===")
        locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.startUpdatingHeading()
    }
    
    func stopLocationManagerUpdates() {
        print("=== \(file).\(#function) ===")
        locationManager.stopUpdatingHeading()
        locationManager.stopMonitoringSignificantLocationChanges()
        locationManager.stopUpdatingLocation()
    }
    
    func startTracking(name: String) {
        print("=== \(file).\(#function) - name: '\(name)' ===")
        
        if isTracking {
            stopTracking()
        }
        
        track = TrackManager.shared.createTrack(name: name)
        isTracking = true
    }
    
    func stopTracking(forDelete: Bool = false) {
        print("=== \(file).\(#function)")
        if !forDelete {
            if let track = track {
                TrackManager.shared.stopTracking(track)
            } else {
                TrackManager.shared.stopTracking()
            }
        }
        track = nil
        isTracking = false
        location = nil
        firstLocation = nil
        shouldCheckAutoStop = false
        
        if !appIsActive {
            sceneDidBecomeInactive()
        }
    }
    
    func checkAutoStop() {

        if firstLocation == nil {
            firstLocation = location
            return
        }
        
        guard shouldAutoStop else { return }
        
        print("=== \(file).\(#function) - first: \(firstLocation.timestamp.stringForDebug), lat/lon \(firstLocation.coordinate.latitude), \(firstLocation.coordinate.longitude) ===")
        print("--- \(file).\(#function) -   cur: \(location.timestamp.stringForDebug), lat/lon \(location.coordinate.latitude), \(location.coordinate.longitude)")
        let dTime = location.timestamp.timeIntervalSince(firstLocation.timestamp)
        let dLoc = location.distance(from: firstLocation)
        print("--- \(file).\(#function) - isTracking: \(isTracking), dTime: \(dTime), dLoc: \(dLoc), shouldCheckAutoStop: \(shouldCheckAutoStop)")
        
        guard shouldCheckAutoStop
        else {
            shouldCheckAutoStop = dTime > autoStopMinTimeIntToStart && dLoc > autoStopMinDistToStart
            return
        }
        
        if dLoc < autoStopMinDistToStop {
            stopTracking()
        }
    }
    
    func reportCapabilities() -> (locationServices: Bool, significantLocationChangeMonitoring: Bool, heading: Bool) {
        let locationServices = CLLocationManager.locationServicesEnabled()
        let significantLocationChangeMonitoring = CLLocationManager.significantLocationChangeMonitoringAvailable()
        let heading = CLLocationManager.headingAvailable()
        return (locationServices, significantLocationChangeMonitoring, heading)
    }
    
    // MARK: - Scene Lifecycle
    
    func sceneDidBecomeActive() {
        print("=== \(file).\(#function) - shouldTrack: \(shouldTrack), appIsActive: \(appIsActive) ===")
        
        guard shouldTrack else { return }
        
        appIsActive = true
        
        if isTracking {
            return
        }
        startLocationManagerUpdates()
    }
    
    func sceneDidBecomeInactive() {
        print("=== \(file).\(#function) - shouldTrack: \(shouldTrack), appIsActive: \(appIsActive) ===")
 
        guard shouldTrack else { return }
        
        appIsActive = false
        
        if isTracking {
            return
        }
        stopLocationManagerUpdates()
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {

        switch manager.authorizationStatus {
        case .notDetermined:
            print("=== \(file).\(#function) - authorizationStatus: .notDetermined ===")
            manager.requestAlwaysAuthorization()
        case .authorizedAlways:
            print("=== \(file).\(#function) - authorizationStatus: .authorizedAlways ===")
            break
        case .authorizedWhenInUse:
            print("=== \(file).\(#function) - authorizationStatus: .authorizedWhenInUse ===")
            manager.requestAlwaysAuthorization()
        case .denied:
            print("=== \(file).\(#function) - authorizationStatus: .denied ===")
            // pop up alert explaining why tracking is important to your app
            break
        case .restricted:
            print("=== \(file).\(#function) - authorizationStatus: .restricted ===")
            break
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        print("=== \(file).\(#function) - locations: \(locations.count) ===")
        
        guard let location = locations.last else { return }
        
        self.location = location
        
        guard isTracking else { return }
        
        TrackManager.shared.createTrackPoint(from: location, in: track)
        
        checkAutoStop()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
    }
}
