//
//  MapViewHelper.swift
//  ATracks
//
//  Created by James Hager on 4/18/22.
//

import Foundation
import Combine
import MapKit

class MapViewHelper: NSObject {
    
    #if os(iOS)
    let view = UIView()
    var trackPointCalloutLabel: AALabelWithPadding!
    #else
    let view = NSView()
    var trackPointCalloutLabel: NSView!
    var trackPointCalloutTextField: NSTextField!
    #endif
    
    private var trackPointCLLocationSubscription: AnyCancellable?
    private var trackPointCalloutLabelSubscription: AnyCancellable?
    
    let mapView = MKMapView()
    
    let device = Device.shared
    
    var track: Track!
    var scrubberInfo: ScrubberInfo!
    
    private var trackIsTrackingOnThisDevice: Bool { TrackHelper.trackIsTrackingOnThisDevice(track) }
    
    private var lastTrackPoint: TrackPoint?
    
    private var endPointAnnotation: MKPointAnnotation!
    private var startPointAnnotation: MKPointAnnotation!
    private var trackPointAnnotation: MKPointAnnotation!
    
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
    
    func setUpView(for track: Track, and scrubberInfo: ScrubberInfo) {
        //print("=== \(file).\(#function) - \(track.debugName) ===")
        
        self.track = track
        self.scrubberInfo = scrubberInfo
        //scrubberInfo.describe()
        
        setUpView()
        setUpTracking()
        
        updateTrackPointCalloutLabel()
        
        if trackIsTrackingOnThisDevice {
            NotificationCenter.default.addObserver(self,
                selector: #selector(handleDidStopTrackingNotification(_:)),
                name: .didStopTracking, object: nil)
        }
        
        NotificationCenter.default.addObserver(self,
            selector: #selector(handleScenePhaseChangedToActive(_:)),
            name: .scenePhaseChangedToActive, object: nil)
        
        setUpSubscriptions()
    }
    
    func updateView(for track: Track, and scrubberInfo: ScrubberInfo) {
        //print("=== \(file).\(#function) - \(track.debugName) - hasBeenSetUp: \(startPointAnnotation != nil) ===")
        //scrubberInfo.describe()
        
        guard startPointAnnotation == nil else { return }
        
        self.track = track
        self.scrubberInfo = scrubberInfo
        
        drawTrack()
        updateTrackPointCalloutLabel()
        
        setUpSubscriptions()
    }
    
    func setUpSubscriptions() {
        //print("=== \(file).\(#function) ===")
        
        trackPointCLLocationSubscription = scrubberInfo.$trackPointCLLocationCoordinate2D.sink { clLocationCoordinate2D in
            //print("=== \(self.file).trackPointCLLocationSubscription.sink - clLocationCoordinate2D, \(self.track.debugName) ===")
            self.placeTrackMarker(at: clLocationCoordinate2D)
        }

        trackPointCalloutLabelSubscription = scrubberInfo.$trackPointCalloutLabelString.sink { string in
            //print("=== \(self.file).trackPointCalloutLabelSubscription.sink - calloutLabel, \(self.track.debugName) - string: \(string) ===")
            self.updateTrackPointCalloutLabel()
        }
    }

    func centerMap() {
        print("=== \(file).\(#function) ===")
        
        #if os(iOS)
        if trackIsTrackingOnThisDevice {
            setMapToTrack()
            return
        }
        #endif
        
        mapView.setRegion(region, animated: true)
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
        
//        mapView.mapType = .hybrid
        
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
        
        addTrackPointCalloutLabel()
    }
    
    private func addTrackPointCalloutLabel() {
        #if os(iOS)
        trackPointCalloutLabel = AALabelWithPadding(horPadding: 8, vertPadding: 4 )
        let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: device.isPhone ? .footnote : .body)
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
        
        trackPointCalloutLabel.layer.backgroundColor = UIColor(.trackPointCalloutBackground).cgColor
        trackPointCalloutLabel.layer.borderColor = UIColor(.trackPointCalloutBorder).cgColor
        trackPointCalloutLabel.layer.borderWidth = 0.5
        trackPointCalloutLabel.layer.cornerRadius = device.isPhone ? 6 : 8
        
        let bottomMargin: CGFloat = 8
        
        #else
        trackPointCalloutLabel = NSView()
        trackPointCalloutTextField = NSTextField(wrappingLabelWithString: "")
        
        let descriptor = NSFontDescriptor.preferredFontDescriptor(forTextStyle: .body)
        let monospacedNumbersDescriptor = descriptor.addingAttributes([
            NSFontDescriptor.AttributeName.featureSettings: [
                [NSFontDescriptor.FeatureKey.typeIdentifier: kNumberSpacingType,
                 NSFontDescriptor.FeatureKey.selectorIdentifier: kMonospacedNumbersSelector]
            ]
        ])
        trackPointCalloutTextField.font = NSFont(descriptor: monospacedNumbersDescriptor, size: 0)
        trackPointCalloutTextField.alignment = .center
        trackPointCalloutTextField.textColor = NSColor(.text)
        
        trackPointCalloutLabel.addSubview(trackPointCalloutTextField)
        trackPointCalloutTextField.pin(top: trackPointCalloutLabel.topAnchor, trailing: trackPointCalloutLabel.trailingAnchor, bottom: trackPointCalloutLabel.bottomAnchor, leading: trackPointCalloutLabel.leadingAnchor, margin: [4, 8, 4, 8])
        
        trackPointCalloutLabel.wantsLayer = true
        trackPointCalloutLabel.layer?.backgroundColor = NSColor(.trackPointCalloutBackground).cgColor
        trackPointCalloutLabel.layer?.borderColor = NSColor(.trackPointCalloutBorder).cgColor
        trackPointCalloutLabel.layer?.borderWidth = 0.5
        trackPointCalloutLabel.layer?.cornerRadius = 8
        
        let bottomMargin: CGFloat = 16
        #endif
        
        trackPointCalloutLabel.isHidden = true
        
        view.addSubview(trackPointCalloutLabel)
        trackPointCalloutLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        trackPointCalloutLabel.pin(top: nil, trailing: nil, bottom: view.safeAreaLayoutGuide.bottomAnchor, leading: nil, margin: [0, 0, bottomMargin, 0])
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
    
    private func setMapNoTrack(shouldApplyRegion: Bool = true) {
        TrackManager.shared.delegate = nil
        mapView.isRotateEnabled = false
        //mapView.showsUserLocation = false
        mapView.userTrackingMode = .none
        
        if shouldApplyRegion {
            mapView.region = region
        }
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
    }
    
    private func drawTrack() {
        
        guard startPointAnnotation == nil else { return }
        
        let trackPoints = track.trackPoints
        
        guard trackPoints.count > 0 else { return }
        
        let coordinates = trackPoints.map { $0.clLocationCoordinate2D }
        
        // track
        if trackPoints.count > 1 {
            let routeOverlay = MKPolyline(coordinates: coordinates, count: coordinates.count)
            mapView.addOverlay(routeOverlay, level: .aboveRoads)
        }
        
        // start point annotation
        startPointAnnotation = AAPointAnnotation(coordinate: coordinates.first!, imageNameBase: "mapMarkerShape", imageNameBackgroundBase: "mapMarkerFill", forStart: true, imageOffsetY: -18)
        mapView.addAnnotation(startPointAnnotation)
        
        // end point annotation
        if track.isTracking {
            trackPointAnnotation = AAPointAnnotation(coordinate: coordinates.last!, imageNameBase: "mapPointMarker")
                mapView.addAnnotation(trackPointAnnotation)
            return
        }
        
        if trackPointAnnotation != nil {
            mapView.removeAnnotation(trackPointAnnotation)
            mapView.addAnnotation(trackPointAnnotation)
        }
        
        addEndPointAnnotation()
    }
    
    private func addEndPointAnnotation() {
        
        guard endPointAnnotation == nil else { return }
        
        let trackPoints = track.trackPoints
        
        guard trackPoints.count > 0,
              trackPoints.last!.clLocation.distance(from: trackPoints.first!.clLocation) > 10
        else { return }
        
        endPointAnnotation = AAPointAnnotation(coordinate: trackPoints.last!.clLocationCoordinate2D, imageNameBase: "mapMarkerShape", imageNameBackgroundBase: "mapMarkerFill", forStart: false, imageOffsetY: -18)
        mapView.addAnnotation(endPointAnnotation)
    }
    
    private func placeTrackMarker(at clLocationCoordinate2D: CLLocationCoordinate2D?) {
        
        guard let clLocationCoordinate2D = clLocationCoordinate2D else { return }
        
        if trackPointAnnotation == nil {
            trackPointAnnotation = AAPointAnnotation(coordinate: clLocationCoordinate2D, imageNameBase: "mapPointMarker")
            mapView.addAnnotation(trackPointAnnotation)
        } else {
            trackPointAnnotation.coordinate = clLocationCoordinate2D
        }
    }
    
    private func updateTrackPointCalloutLabel() {
        if trackPointCalloutLabel == nil {
            addTrackPointCalloutLabel()
        }
        
        guard let string = scrubberInfo.trackPointCalloutLabelString else { return }
        
        #if os(iOS)
        trackPointCalloutLabel.text = string
        #else
            trackPointCalloutTextField.stringValue = string
        #endif

        trackPointCalloutLabel.isHidden = false
    }
    
    // MARK: - Notifications
    
    @objc func handleDidStopTrackingNotification(_ notification: Notification) {
        print("=== \(file).\(#function) ===")
        setMapNoTrack(shouldApplyRegion: false)
        
        if trackPointAnnotation != nil {
            mapView.removeAnnotation(trackPointAnnotation)
            trackPointAnnotation = nil
        }
        
        addEndPointAnnotation()
        
        centerMap()
    }
    
    @objc func handleScenePhaseChangedToActive(_ notification: NSNotification) {
        print("=== \(file).\(#function) ===")
        #if os(iOS)
        if trackIsTrackingOnThisDevice {
            centerMap()
        }
        #endif
    }
}

// MARK: - TrackManagerDelegate

extension MapViewHelper: TrackManagerDelegate {
    
    func didMakeNewTrackPoint(_ trackPoint: TrackPoint) {
        
        mapView.setCenter(trackPoint.clLocationCoordinate2D, animated: true)
        
        drawTrack()
        
        defer {
            lastTrackPoint = trackPoint
        }
        
        guard let lastTrackPoint = lastTrackPoint else { return }
        
        placeTrackMarker(at: trackPoint.clLocationCoordinate2D)
        
        let coordinates = [lastTrackPoint.clLocationCoordinate2D, trackPoint.clLocationCoordinate2D]
        let routeOverlay = MKPolyline(coordinates: coordinates, count: coordinates.count)
        mapView.addOverlay(routeOverlay, level: .aboveRoads)
    }
}
