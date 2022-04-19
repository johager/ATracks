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
    
    var isTrackingTrack: Track? {
        guard isTracking else { return nil }
        return track
    }
    
    private let locationManager = CLLocationManager()
    
    private var isAvailGPS = false
    private var isTracking = false
    private var location: CLLocation!
    
    private var track: Track!
    
    // MARK: - Init
    
    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 2
    }
    
    // MARK: - Methods
    
    func requestAlwaysAuthorization() {
        locationManager.requestAlwaysAuthorization()
    }
    
    func startUpdating() {
        print(#function)
        locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    func stopUpdating() {
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
    }
    
    // MARK: - Scene Lifecycle
    
    func sceneDidBecomeActive() {
        if isTracking {
            return
        }
        startUpdating()
    }
    
    func sceneDidBecomeInActive() {
        if isTracking {
            return
        }
        stopUpdating()
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
        print("=== \(#function) - locations: \(locations.count)")
        
        guard let location = locations.last else { return }
        
        if isTracking {
            TrackManager.shared.createTrackPoint(from: location, in: track)
        }
    }
}
