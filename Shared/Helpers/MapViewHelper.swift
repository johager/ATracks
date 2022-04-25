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
    var latLonLabel: AALabelWithPadding!
    #else
    let view = NSView()
    var latLonLabel: NSTextField!
    #endif
    
    let mapView = MKMapView()
    
    var track: Track!
    
    private var lastTrackPoint: TrackPoint?
    
    private var startPointAnnotation: MKPointAnnotation!
    private var trackPointAnnotation: MKPointAnnotation!
    
    private var region: MKCoordinateRegion {
        guard let trackPointsSet = track.trackPointsSet,
              trackPointsSet.count > 1
        else {
            return MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 37.33, longitude: -122.01),
                span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
            )
        }
        
        let trackCoordinates = track.trackPoints.map { $0.clLocationCoordinate2D }
        let trackLats = trackCoordinates.map { $0.latitude }
        let trackLons = trackCoordinates.map { $0.longitude }
        
        let minLat = trackLats.min()!
        let maxLat = trackLats.max()!
        let minLon = trackLons.min()!
        let maxLon = trackLons.max()!
        
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
    
    func setUpView(forTrack track: Track, shouldTrackPoint: Bool = false) {
        self.track = track
        setUpView(shouldTrackPoint: shouldTrackPoint)
        setUpTracking()
        
        if shouldTrackPoint {
            NotificationCenter.default.addObserver(self,
                selector: #selector(handleDidStopTrackingNotification(_:)),
                name: .didStopTracking, object: nil)
            
            NotificationCenter.default.addObserver(self,
                selector: #selector(handleShowInfoForLocationNotification(_:)),
                name: .showInfoForLocation, object: nil)
        }
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
    
    private func setUpView(shouldTrackPoint: Bool) {
        mapView.isPitchEnabled = false
        mapView.showsCompass = true
        
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
        
        if shouldTrackPoint {
            addLatLonLabel()
        }
    }
    
    func addLatLonLabel() {
        #if os(iOS)
        latLonLabel = AALabelWithPadding(horPadding: 8, vertPadding: 4 )
        if let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .footnote).withDesign(.monospaced) {
            latLonLabel.font = UIFont(descriptor: descriptor, size: 0)
        } else {
            latLonLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
        }
        latLonLabel.adjustsFontForContentSizeCategory = true
        latLonLabel.numberOfLines = 0
        latLonLabel.textAlignment = .center
        latLonLabel.text = ""
        latLonLabel.textColor = UIColor(.latLonCalloutText)
        latLonLabel.isHidden = true
        
        latLonLabel.layer.backgroundColor = UIColor(.latLonCalloutBackground).cgColor
        latLonLabel.layer.borderColor = UIColor(.latLonCalloutBorder).cgColor
        latLonLabel.layer.borderWidth = 2
        latLonLabel.layer.cornerRadius = 6
        
        #else
        latLonLabel = NSTextField()
        #endif
        
        view.addSubview(latLonLabel)
        latLonLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        latLonLabel.pin(top: nil, trailing: nil, bottom: view.safeAreaLayoutGuide.bottomAnchor, leading: nil, margin: [0, 0, 4, 0])
    }
    
    private func setUpTracking() {
        #if os(iOS)
            if LocationManager.shared.isTracking(track) {
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
//        mapView.cameraZoomRange = MKMapView.CameraZoomRange(minCenterCoordinateDistance: 1000)
        #endif
        
        lastTrackPoint = track.trackPoints.last
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
    
    func updateLatLonLabel(for clLocationCoordinate2D: CLLocationCoordinate2D) {
        #if os(iOS)
            latLonLabel.text = clLocationCoordinate2D.stringWithThreeDecimals
            latLonLabel.isHidden = false
        #else
            latLonLabel.stringValue = clLocationCoordinate2D.stringWithThreeDecimals
        #endif
        latLonLabel.isHidden = false
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
        updateLatLonLabel(for: clLocationCoordinate2D)
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
