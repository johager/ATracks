//
//  MapViewHelper.swift
//  ATracks
//
//  Created by James Hager on 4/18/22.
//

import Foundation
import MapKit

class MapViewHelper: NSObject {
    
    #if os(iOS)
    let view = UIView()
    var trackPointCalloutLabel: AALabelWithPadding!
    #else
    let view = NSView()
    var trackPointCalloutLabel: NSTextField!
    #endif
    
    let mapView = MKMapView()
    
    var track: Track!
    
    private var trackIsTrackingOnThisDevice: Bool { TrackHelper.trackIsTrackingOnThisDevice(track) }
    
    private var lastTrackPoint: TrackPoint?
    
    private var startPointAnnotation: MKPointAnnotation!
    private var trackPointAnnotation: MKPointAnnotation!
    
    private var isPhone: Bool { DeviceType.current() == .phone }
    
    private var region: MKCoordinateRegion {
        guard let trackPointsSet = track.trackPointsSet,
              trackPointsSet.count > 1
        else {
            #if os(iOS)
            if trackIsTrackingOnThisDevice {
                if let location = LocationManager.shared.location {
                    return MKCoordinateRegion(
                        center: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude),
                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    )
                }
            }
            #endif
            return MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 37.33, longitude: -122.01),
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
        }
        
        #if os(iOS)
        if trackIsTrackingOnThisDevice {
            if let location = LocationManager.shared.location {
                return MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude),
                    span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                )
            }
        }
        #endif
        
        var minLat: Double = 100
        var maxLat: Double = -100
        var minLon: Double = 200
        var maxLon: Double = -200
        
        for trackPoint in track.trackPoints {
            minLat = min(minLat, trackPoint.latitude)
            maxLat = max(maxLat, trackPoint.latitude)
            minLon = min(minLon, trackPoint.longitude)
            maxLon = max(maxLon, trackPoint.longitude)
        }
        
        return MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2, longitude: (minLon + maxLon) / 2),
            span: MKCoordinateSpan(latitudeDelta: 1.8 * (maxLat - minLat), longitudeDelta: 1.8 * (maxLon - minLon))
        )
    }
    
    private var center: CLLocationCoordinate2D {
        #if os(iOS)
            if let location = LocationManager.shared.location {
                return CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            } else {
                return CLLocationCoordinate2D(latitude: 37.33, longitude: -122.01)
            }
        #elseif os(macOS)
            return CLLocationCoordinate2D(latitude: 37.33, longitude: -122.01)
        #endif
    }
    
    lazy var file = Func.sourceFileNameFromFullPath(#file)
    
    // MARK: - Init
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Public Methods
    
    func setUpView(forTrack track: Track) {
        print("=== \(file).\(#function)  ===")
        
        self.track = track
        
        setUpView()
        setUpTracking()
        
        NotificationCenter.default.addObserver(self,
            selector: #selector(handleDidStopTrackingNotification(_:)),
            name: .didStopTracking, object: nil)
        
        NotificationCenter.default.addObserver(self,
            selector: #selector(handleShowInfoForLocationNotification(_:)),
            name: .showInfoForLocation, object: nil)
    }
    
    func updateView(forTrack track: Track) {
        
        guard startPointAnnotation == nil else { return }
        
        self.track = track
        
        let trackPoints = track.trackPoints
        
        guard trackPoints.count > 0 else { return }
        
        // track
        let coordinates = trackPoints.map { $0.clLocationCoordinate2D }
        let routeOverlay = MKPolyline(coordinates: coordinates, count: coordinates.count)
        mapView.addOverlay(routeOverlay, level: .aboveRoads)
        
        // annotation
        startPointAnnotation = AAPointAnnotation(coordinate: coordinates.first!, imageNameBase: "mapMarker", imageOffsetY: -18)
        mapView.addAnnotation(startPointAnnotation)
    }
    
    // MARK: - Private Methods
    
    private func setUpView() {
        mapView.isPitchEnabled = false
        mapView.showsCompass = true
        
        if DisplaySettings.shared.mapViewSatellite {
            mapView.mapType = .hybrid
        } else {
            mapView.mapType = .standard
        }
        
        view.addSubview(mapView)
        mapView.pin(top: view.topAnchor, trailing: view.trailingAnchor, bottom: view.bottomAnchor, leading: view.leadingAnchor)
        
        #if os(iOS)
        let scaleView = MKScaleView(mapView: mapView)
        mapView.addSubview(scaleView)
//        scaleView.pin(top: nil, trailing: nil, bottom: mapView.safeAreaLayoutGuide.bottomAnchor, leading: nil, margin: [0, 0, 14, 0])
//        scaleView.centerXAnchor.constraint(equalTo: mapView.centerXAnchor, constant: 12).isActive = true
        let mapSafeArea = mapView.safeAreaLayoutGuide
        scaleView.pin(top: mapSafeArea.topAnchor, trailing: nil, bottom: nil, leading: mapSafeArea.leadingAnchor, margin: [6, 0, 0, 12])
        scaleView.scaleVisibility = .visible
        #endif
        
        addLatLonLabel()
    }
    
    func addLatLonLabel() {
        #if os(iOS)
        trackPointCalloutLabel = AALabelWithPadding(horPadding: 8, vertPadding: 4 )
        let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: isPhone ? .footnote : .body)
        let monospacedNumbersDescriptor = descriptor.addingAttributes([
            UIFontDescriptor.AttributeName.featureSettings: [
                [UIFontDescriptor.FeatureKey.type: kNumberSpacingType,
                 UIFontDescriptor.FeatureKey.selector: kMonospacedNumbersSelector]
            ]
        ])
        trackPointCalloutLabel.font = UIFont(descriptor: monospacedNumbersDescriptor, size: 0)
        trackPointCalloutLabel.adjustsFontForContentSizeCategory = true
        trackPointCalloutLabel.numberOfLines = 0
        trackPointCalloutLabel.textAlignment = .center
        trackPointCalloutLabel.text = ""
        trackPointCalloutLabel.textColor = UIColor(.trackPointCalloutText)
        trackPointCalloutLabel.isHidden = true
        
        trackPointCalloutLabel.layer.backgroundColor = UIColor(.trackPointCalloutBackground).cgColor
        trackPointCalloutLabel.layer.borderColor = UIColor(.trackPointCalloutBorder).cgColor
        trackPointCalloutLabel.layer.borderWidth = 0.5
        trackPointCalloutLabel.layer.cornerRadius = 6
        
        #else
        trackPointCalloutLabel = NSTextField()
        #endif
        
        view.addSubview(trackPointCalloutLabel)
        trackPointCalloutLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        trackPointCalloutLabel.pin(top: nil, trailing: nil, bottom: view.safeAreaLayoutGuide.bottomAnchor, leading: nil, margin: [0, 0, 8, 0])
    }
    
    private func setUpTracking() {
        #if os(iOS)
        if trackIsTrackingOnThisDevice {
            setMapToTrack()
        } else {
            setMapNoTrack()
        }
        
        #elseif os(macOS)
        setMapNoTrack()
        #endif
    }
    
    private func setMapNoTrack() {
        TrackManager.shared.delegate = nil
        mapView.isRotateEnabled = false
        //mapView.showsUserLocation = false
        mapView.userTrackingMode = .none
        mapView.region = region
    }
    
    private func setMapToTrack() {
        TrackManager.shared.delegate = self
        mapView.isRotateEnabled = true
        //mapView.showsUserLocation = true
        #if os(iOS)
        mapView.userTrackingMode = .followWithHeading
        let mapCamera = MKMapCamera(lookingAtCenter: center, fromDistance: 1500, pitch: 0, heading: 0)
        mapView.camera = mapCamera
        mapView.cameraZoomRange = MKMapView.CameraZoomRange(minCenterCoordinateDistance: 1000)
        #endif
        
        lastTrackPoint = track.trackPoints.last
        
        Func.afterDelay(0.7) {
            self.centerMap()
        }
    }
    
    func centerMap() {
        print("=== \(file).\(#function) ===")
        mapView.setRegion(region, animated: true)
    }
    
    func moveTrackMarker(to clLocationCoordinate2D: CLLocationCoordinate2D) {
        
        if trackPointAnnotation == nil {
            trackPointAnnotation = AAPointAnnotation(coordinate: clLocationCoordinate2D, imageNameBase: "mapPointMarker")
        } else {
            mapView.removeAnnotation(trackPointAnnotation)
            trackPointAnnotation.coordinate = clLocationCoordinate2D
        }

        mapView.addAnnotation(trackPointAnnotation)
    }
    
    func updateLatLonLabel(for clLocationCoordinate2D: CLLocationCoordinate2D, elevation: Any?) {
        
        var string = clLocationCoordinate2D.stringWithThreeDecimals
        
        if let elevation = elevation as? Double {
            string += "\n\(elevation.stringAsInt) ft"
        }
        
        #if os(iOS)
            trackPointCalloutLabel.text = string
        #else
            trackPointCalloutLabel.stringValue = string
        #endif
        
        trackPointCalloutLabel.isHidden = false
    }
    
    // MARK: - Notifications
    
    @objc func handleDidStopTrackingNotification(_ notification: Notification) {
        print("=== \(file).\(#function) ===")
        setMapNoTrack()
    }
    
    @objc func handleShowInfoForLocationNotification(_ notification: Notification) {
        
        guard let userInfo = notification.userInfo as? Dictionary<String,Any>,
              let clLocationCoordinate2D = userInfo[Key.clLocationCoordinate2D] as? CLLocationCoordinate2D
        else { return }
        
        //print("=== \(file).\(#function) ===")
        
        moveTrackMarker(to: clLocationCoordinate2D)
        
        updateLatLonLabel(for: clLocationCoordinate2D, elevation: userInfo[Key.elevation])
    }
}

// MARK: - TrackManagerDelegate

extension MapViewHelper: TrackManagerDelegate {
    
    func didMakeNewTrackPoint(_ trackPoint: TrackPoint) {
        
        mapView.setCenter(trackPoint.clLocationCoordinate2D, animated: true)
        
        moveTrackMarker(to: trackPoint.clLocationCoordinate2D)
        
        defer {
            lastTrackPoint = trackPoint
        }
        
        guard let lastTrackPoint = lastTrackPoint else { return }
        
        let coordinates = [lastTrackPoint.clLocationCoordinate2D, trackPoint.clLocationCoordinate2D]
        let routeOverlay = MKPolyline(coordinates: coordinates, count: coordinates.count)
        mapView.addOverlay(routeOverlay, level: .aboveRoads)
    }
}
