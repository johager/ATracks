//
//  LocationManager.swift
//  ATracks
//
//  Created by James Hager on 4/18/22.
//

import SwiftUI
import CoreLocation
import os.log

class LocationManager: NSObject {
    
    static let shared = LocationManager()
    
    var location: CLLocation!
    var shouldAutoStop: Bool { settingsProvider.useAutoStop }
    
    private let locationManager = CLLocationManager()
    
    private var appIsActive = false
    {
        didSet {
            logger?.notice("appIsActive didSet \(self.appIsActive, privacy: .public)")
        }
    }
    
    var shouldTrack = true
//    var shouldTrack = false
    
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
    var track: Track!
    
    var settingsProvider: LocationManagerSettingsProvider = LocationManagerSettings.shared
    
    #if targetEnvironment(simulator)
    private let autoStopTime: TimeInterval? = 10  // time for auto-stop on simulator (if set)
    private let useSimulatedAltitude = true
    #endif
    
    private var logger: Logger?
    
    lazy var file = Func.sourceFileNameFromFullPath(#file)
    
    // MARK: - Init
    
    private override init() {
        super.init()
        locationManager.activityType = .fitness
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 2
        locationManager.pausesLocationUpdatesAutomatically = false
        
        logger = Func.logger(for: file)
    }
    
    // MARK: - Methods
    
    func isTracking(_ someTrack: Track) -> Bool {
        guard
            isTracking,
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
        //print("=== \(file).\(#function) - name: '\(name)' ===")
        logger?.notice("\(#function, privacy: .public) - name: '\(name, privacy: .private(mask: .hash))'")
        
        if isTracking {
            stopTracking()
        }
        
        track = TrackManager.shared.createTrack(name: name)
        isTracking = true
    }
    
    func stopTracking(forDelete: Bool = false) {
        //print("=== \(file).\(#function) - forDelete: \(forDelete) ===")
        logger?.notice("\(#function, privacy: .public) - forDelete: \(forDelete, privacy: .public)")
        if !forDelete {
//            TrackManager.shared.stopTracking(track)
            TrackManager.shared.stopTracking()
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
        
        #if targetEnvironment(simulator)
        if let autoStopTime {
            if dTime > autoStopTime {
                logger?.notice("\(#function, privacy: .public) - call stopTracking() due to autoStopTime")
                stopTracking()
            }
            return
        }
        #endif
        
        guard shouldCheckAutoStop
        else {
            shouldCheckAutoStop = dTime > autoStopMinTimeIntToStart && dLoc > autoStopMinDistToStart
            return
        }
        
        if dLoc < autoStopMinDistToStop {
            logger?.notice("\(#function, privacy: .public) - call stopTracking()")
            stopTracking()
        }
    }
    
//    func reportCapabilities() -> (locationServices: Bool, significantLocationChangeMonitoring: Bool, heading: Bool) {
//        let locationServices = CLLocationManager.locationServicesEnabled()
//        let significantLocationChangeMonitoring = CLLocationManager.significantLocationChangeMonitoringAvailable()
//        let heading = CLLocationManager.headingAvailable()
//        return (locationServices, significantLocationChangeMonitoring, heading)
//    }
    
    // MARK: - Scene Lifecycle
    
    func sceneDidBecomeActive() {
        //print("=== \(file).\(#function) - shouldTrack: \(shouldTrack), appIsActive: \(appIsActive) ===")
        logger?.notice("\(#function, privacy: .public) - shouldTrack: \(self.shouldTrack, privacy: .public)")
        
        guard shouldTrack else { return }
        
        appIsActive = true
        
        guard isTracking else {
            startLocationManagerUpdates()
            return
        }
        
        guard let track = LocationManager.shared.track else { return }
        
        TrackManager.shared.updateSummaryDataAndSteps(for: track)
    }
    
    func sceneDidBecomeInactive() {
        //print("=== \(file).\(#function) - shouldTrack: \(shouldTrack), appIsActive: \(appIsActive) ===")
        logger?.notice("\(#function, privacy: .public) - shouldTrack: \(self.shouldTrack, privacy: .public)")
 
        guard shouldTrack else { return }
        
        appIsActive = false
        
        if isTracking {
            return
        }
        stopLocationManagerUpdates()
    }
    
    #if targetEnvironment(simulator)
    func locationWithSimulatedAltitude(from location: CLLocation) -> CLLocation {

        let altitude: Double
        if let firstLocation = firstLocation {
            let dt = location.timestamp.timeIntervalSince(firstLocation.timestamp)
            altitude = 0.1 * dt
        } else {
            altitude = 0
        }
        
        return CLLocation(coordinate: location.coordinate,
                          altitude: altitude,
                          horizontalAccuracy: location.horizontalAccuracy,
                          verticalAccuracy: 10,
                          timestamp: location.timestamp)
    }
    #endif
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
        
//        logger?.notice("didUpdateLocations - isTracking: \(self.isTracking, privacy: .public), track exists: \(self.track != nil)")
        
        if let logger {
            if let memory = Func.memoryMB() {
                logger.notice("didUpdateLocations - isTracking: \(self.isTracking, privacy: .public), track exists: \(self.track != nil), appIsActive: \(self.appIsActive, privacy: .public), memory: \(memory, privacy: .public) MB")
            } else {
                logger.notice("didUpdateLocations - isTracking: \(self.isTracking, privacy: .public), track exists: \(self.track != nil), appIsActive: \(self.appIsActive, privacy: .public), memory: nil")
            }
        }
        
        #if targetEnvironment(simulator)
        if useSimulatedAltitude {
            self.location = locationWithSimulatedAltitude(from: location)
        } else {
            self.location = location
        }
        #else
        self.location = location
        #endif
        
        guard isTracking else { return }
        
        TrackManager.shared.createTrackPoint(from: self.location, in: track)
        
        checkAutoStop()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
    }
}
