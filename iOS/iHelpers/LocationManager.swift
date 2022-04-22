//
//  LocationManager.swift
//  ATracks
//
//  Created by James Hager on 4/18/22.
//

import Foundation
import CoreLocation

class LocationManager: NSObject {
    
    static let shared = LocationManager()
    
    var location: CLLocation!
    
    private let locationManager = CLLocationManager()
    
    private let shouldTrack = true
    
    private var isAvailGPS = false
    private var isTracking = false

    private var track: Track!
    
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
    
    func requestAlwaysAuthorization() {
        locationManager.requestAlwaysAuthorization()
    }
    
    func startLocationUpdates() {
        print(#function)
        locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    func stopLocationUpdates() {
        print(#function)
        locationManager.stopMonitoringSignificantLocationChanges()
        locationManager.stopUpdatingLocation()
    }
    
    func startTracking() {
        isTracking = true
        
        let trackName = Date().stringForTrackName
        print("\(#function) - trackName: \(trackName)")
        
        track = Track(name: trackName)
    }
    
    func stopTracking() {
        print("\(#function)")
        isTracking = false
        location = nil
        track = nil
    }
    
    func startHeadingUpdates() {
        print(#function)
        locationManager.startUpdatingHeading()
    }
    
    func stopHeadingUpdates() {
        print(#function)
        locationManager.stopUpdatingHeading()
    }
    
    // MARK: - Scene Lifecycle
    
    func sceneDidBecomeActive() {
        
        guard shouldTrack else { return }
        
        //startHeadingUpdates()
        
        if isTracking {
            return
        }
        startHeadingUpdates()
        startLocationUpdates()
    }
    
    func sceneDidBecomeInActive() {
 
        guard shouldTrack else { return }
        
        //stopHeadingUpdates()
        
        if isTracking {
            return
        }
        stopHeadingUpdates()
        stopLocationUpdates()
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {

        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestAlwaysAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            break
        case .denied:
            // pop up alert explaining why tracking is important to your app
            break
        case .restricted:
            break
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        print("=== \(#function) - locations: \(locations.count)")
        
        guard let location = locations.last else { return }
        
        self.location = location
        
        if isTracking {
            TrackManager.shared.createTrackPoint(from: location, in: track)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
    }
}
