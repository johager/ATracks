//
//  MapViewHelper.swift
//  ATracks
//
//  Created by James Hager on 4/18/22.
//

import Foundation
import Combine
import MapKit
import SwiftUI
import os.log

class MapViewHelper: NSObject, ObservableObject {
    
    #if os(iOS)
    var view: UIView! = UIView()
    var trackPointCalloutLabel: AALabelWithPadding!
    #else
    var view: NSView! = NSView()
    var trackPointCalloutLabel: NSView!
    var trackPointCalloutTextField: NSTextField!
    #endif
    
    var mapView: MKMapView! = MKMapView()
    
    private var trackPointCLLocationSubscription: AnyCancellable?
    private var trackPointCalloutLabelSubscription: AnyCancellable?
    
    weak var track: Track!
    weak var scrubberInfo: ScrubberInfo!
    
    private var trackIsTrackingOnThisDevice: Bool { TrackHelper.trackIsTrackingOnThisDevice(track) }
    
    private var lastTrackPoint: TrackPoint?
    
    private var endPointAnnotation: MKPointAnnotation!
    private var startPointAnnotation: MKPointAnnotation!
    private var trackPointAnnotation: MKPointAnnotation!
    
    private var device: Device { Device.shared }
    
    private var region: MKCoordinateRegion {
        guard
            let trackPointsSet = track.trackPointsSet,
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
    
    private var logger: Logger?
    
    lazy var file = Func.sourceFileNameFromFullPath(#file)
    
    // MARK: - Init
    
    override init() {
        super.init()
        self.logger = Func.logger(for: file)
//        print("=== \(file).\(#function) ===")
    }
    
    deinit {
//        print("=== \(file).\(#function) ===")
        NotificationCenter.default.removeObserver(self)
    }
     
    // MARK: - Public Methods
    
    func setUp(for track: Track, and scrubberInfo: ScrubberInfo) {
//        print("=== \(file).\(#function) - \(track.debugName) ===")
//        print("--- \(file).\(#function) - ........... track.id: \(track.id)")
//        #if os(iOS)
//        print("--- \(file).\(#function) - scrubberInfo.trackID: \(scrubberInfo.trackID)")
//        #endif
        
        if self.track == nil {
//            print("=== \(file).\(#function) - \(track.debugName) - track was nil ===")
            self.track = track
            self.scrubberInfo = scrubberInfo
            return
        }
        
        self.scrubberInfo = scrubberInfo
        
        guard track.id != self.track.id || device.mapViewShouldUpdateDueToColorSchemeChange
        else {
//            print("=== \(file).\(#function) - \(track.debugName) - track is same ===")
            #if os(macOS)
            setUpSubscriptions()
            #endif
            return
        }
        
//        print("=== \(file).\(#function) - \(track.debugName) - track is new ===")
        
        self.track = track
        
        #if os(iOS)
        if Device.shared.isPad {
            setUpSubscriptions()
        }
        #endif
        
        setUpTracking()
        
        prepForNewTrack()
        
        drawTrack()
    }
    
    func makeView() {
//        print("=== \(file).\(#function) - \(track.debugName) - hasBeenSetUp: \(startPointAnnotation != nil) ===")
        
        setUpView()
        setUpTracking()
        
        NotificationCenter.default.addObserver(self,
            selector: #selector(handleScenePhaseChangedToActive(_:)),
            name: .scenePhaseChangedToActive, object: nil)
        
        setUpSubscriptions()
    }
    
    func updateView() {
//        print("=== \(file).\(#function) - \(track.debugName) - hasBeenSetUp: \(startPointAnnotation != nil) ===")
//        print("--- \(file).\(#function) - device.colorScheme: \(device.colorScheme)")
        
//        let shouldUpdate = appIsActive || device.mapViewShouldUpdateDueToColorSchemeChange
//        logger?.notice("updateView - hasBeenSetUp: \(self.startPointAnnotation != nil, privacy: .public), shouldUpdateDueToColorSchemeChange: \(self.device.mapViewShouldUpdateDueToColorSchemeChange, privacy: .public), shouldUpdate: \(shouldUpdate, privacy: .public)")
        
        //logger?.notice("updateView - hasBeenSetUp: \(self.startPointAnnotation != nil, privacy: .public)")
        
        if device.mapViewShouldUpdateDueToColorSchemeChange {
            prepForNewTrack()
            Func.afterDelay(1) {
                self.device.mapViewShouldUpdateDueToColorSchemeChange = false
            }
        }
        
        guard startPointAnnotation == nil else { return }
        
        drawTrack()
        
        setUpSubscriptions()
    }
    
    func centerMap() {
        //print("=== \(file).\(#function) ===")
        
        #if os(iOS)
        if trackIsTrackingOnThisDevice {
            setMapToTrack()
            return
        }
        #endif
        
        mapView.setRegion(region, animated: true)
    }
    
    func cleanUp() {
        //print("=== \(file).\(#function) ===")

        trackPointCLLocationSubscription?.cancel()
        trackPointCLLocationSubscription = nil
        
        trackPointCalloutLabelSubscription?.cancel()
        trackPointCalloutLabelSubscription = nil
    }
    
    // MARK: - Private Methods
    
    private func setUpSubscriptions() {
//        print("=== \(file).\(#function) ===")
//        print("=== \(file).\(#function) - \(track.debugName) ===")
//        print("--- \(file).\(#function) - ........... track.id: \(track.id)")
//        #if os(iOS)
//        print("--- \(file).\(#function) - scrubberInfo.trackID: \(scrubberInfo.trackID)")
//        #endif
        
        #if os(iOS)
        if trackIsTrackingOnThisDevice {
//            print("--- \(file).\(#function) - \(track.debugName), set up observer for didStopTracking")
            NotificationCenter.default.addObserver(self,
                selector: #selector(handleDidStopTrackingNotification(_:)),
                name: .didStopTracking, object: nil)
        } else {
            NotificationCenter.default.removeObserver(self, name: .didStopTracking, object: nil)
        }
        
        if Device.shared.isPad {
            scrubberInfo.setUpFor(track.id)
        }
        #endif
        
        cleanUp()
        
        trackPointCLLocationSubscription = scrubberInfo.$trackPointCLLocationCoordinate2D.sink { clLocationCoordinate2D in
            //print("=== \(self.file).trackPointCLLocationSubscription.sink - clLocationCoordinate2D, \(self.track.debugName) ===")
//            if clLocationCoordinate2D == nil {
//                print("=== \(self.file).trackPointCLLocationSubscription.sink - clLocationCoordinate2D is nil, \(self.track.debugName) ===")
//            } else {
//                print("=== \(self.file).trackPointCLLocationSubscription.sink - clLocationCoordinate2D exists, \(self.track.debugName) ===")
//            }
            self.placeTrackMarker(at: clLocationCoordinate2D)
        }

        trackPointCalloutLabelSubscription = scrubberInfo.$trackPointCalloutLabelString.sink { text in
            //print("=== \(self.file).trackPointCalloutLabelSubscription.sink - calloutLabel, \(self.track.debugName) - text: \(text) ===")
            self.updateTrackPointCalloutLabel(with: text)
        }
    }
    
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
        mapView.camera = MKMapCamera(lookingAtCenter: center, fromDistance: 1500, pitch: 0, heading: 0)
        mapView.cameraZoomRange = MKMapView.CameraZoomRange(minCenterCoordinateDistance: 1000)
        #endif
        
        lastTrackPoint = track.trackPoints.last
    }
    
    private func prepForNewTrack() {
//        print("=== \(file).\(#function) ===")
        
        mapView?.annotations.forEach { mapView.removeAnnotation($0) }
        mapView?.overlays.forEach { mapView.removeOverlay($0) }
        
        endPointAnnotation = nil
        startPointAnnotation = nil
        trackPointAnnotation = nil
    }
    
    private func drawTrack() {
//        print("=== \(file).\(#function) ===")
        
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
        addStartPointAnnotation(at: coordinates.first!)
        
        // track point annotation
        if track.isTracking {
            trackPointAnnotation = AAPointAnnotation(coordinate: coordinates.last!, imageNameBase: "mapPointMarker")
            mapView.addAnnotation(trackPointAnnotation)
            return
            
        } else if let coordinate = scrubberInfo.trackPointCLLocationCoordinate2D {
            trackPointAnnotation = AAPointAnnotation(coordinate: coordinate, imageNameBase: "mapPointMarker")
            mapView.addAnnotation(trackPointAnnotation)
        }
        
        if trackPointAnnotation != nil {
            mapView.removeAnnotation(trackPointAnnotation)
            mapView.addAnnotation(trackPointAnnotation)
        }
        
        addEndPointAnnotation()
    }
    
    private func addStartPointAnnotation(at coordinate: CLLocationCoordinate2D) {
        
        guard startPointAnnotation == nil else { return }
        
        startPointAnnotation = AAPointAnnotation(coordinate: coordinate, imageNameBase: "mapMarkerShape", imageNameBackgroundBase: "mapMarkerFill", forStart: true, imageOffsetY: -18)
        mapView.addAnnotation(startPointAnnotation)
    }
    
    private func addEndPointAnnotation() {
        
        guard endPointAnnotation == nil else { return }
        
        let trackPoints = track.trackPoints
        
        guard
            trackPoints.count > 1,
            trackPoints.last!.clLocation.distance(from: trackPoints.first!.clLocation) > 10
        else { return }
        
        endPointAnnotation = AAPointAnnotation(coordinate: trackPoints.last!.clLocationCoordinate2D, imageNameBase: "mapMarkerShape", imageNameBackgroundBase: "mapMarkerFill", forStart: false, imageOffsetY: -18)
        mapView.addAnnotation(endPointAnnotation)
    }
    
    private func placeTrackMarker(at clLocationCoordinate2D: CLLocationCoordinate2D?) {
//        print("=== \(file).\(#function) ===")
        
        guard let clLocationCoordinate2D = clLocationCoordinate2D
        else {
            removeTrackPointAnnotation()
            return
        }
        
        if trackPointAnnotation == nil {
            trackPointAnnotation = AAPointAnnotation(coordinate: clLocationCoordinate2D, imageNameBase: "mapPointMarker")
            mapView.addAnnotation(trackPointAnnotation)
        } else {
            trackPointAnnotation.coordinate = clLocationCoordinate2D
        }
    }
    
    private func removeTrackPointAnnotation() {
//        print("=== \(file).\(#function) ===")
        if trackPointAnnotation != nil {
            mapView.removeAnnotation(trackPointAnnotation)
            trackPointAnnotation = nil
        }
    }
    
    private func updateTrackPointCalloutLabel(with text: String?) {
        if trackPointCalloutLabel == nil {
            return
        }
        
        guard let text else {
            trackPointCalloutLabel.isHidden = true
            return
        }
        
        #if os(iOS)
        trackPointCalloutLabel.text = text
        #else
        trackPointCalloutTextField.stringValue = text
        #endif

        trackPointCalloutLabel.isHidden = false
    }
    
    // MARK: - Notifications
    
    @objc func handleDidStopTrackingNotification(_ notification: Notification) {
        //print("=== \(file).\(#function) ===")
        logger?.notice("handleDidStopTrackingNotification")
        setMapNoTrack(shouldApplyRegion: false)
        removeTrackPointAnnotation()
        addEndPointAnnotation()
        centerMap()
    }
    
    @objc func handleScenePhaseChangedToActive(_ notification: NSNotification) {
        //print("=== \(file).\(#function) ===")
        //logger?.notice("handleScenePhaseChangedToActive")
        #if os(iOS)
        //print("=== \(file).\(#function) - trackIsTrackingOnThisDevice: \(trackIsTrackingOnThisDevice) ===")
        logger?.notice("handleScenePhaseChangedToActive - trackIsTrackingOnThisDevice: \(self.trackIsTrackingOnThisDevice, privacy: .public)")
        if trackIsTrackingOnThisDevice {
            prepForNewTrack()
            drawTrack()
            centerMap()
        }
        #endif
    }
}

// MARK: - TrackManagerDelegate

extension MapViewHelper: TrackManagerDelegate {
    
    func didMakeNewTrackPoint(_ trackPoint: TrackPoint) {
        print("=== \(file).\(#function) ===")
        
        if mapView == nil {
            return
        }
        
        let coordinate = trackPoint.clLocationCoordinate2D
        
        mapView.setCenter(coordinate, animated: true)
        
        drawTrack()
        addStartPointAnnotation(at: coordinate)
        
        defer {
            lastTrackPoint = trackPoint
        }
        
        guard let lastTrackPoint else { return }
        
        placeTrackMarker(at: trackPoint.clLocationCoordinate2D)
        
        let coordinates = [lastTrackPoint.clLocationCoordinate2D, trackPoint.clLocationCoordinate2D]
        let routeOverlay = MKPolyline(coordinates: coordinates, count: coordinates.count)
        mapView.addOverlay(routeOverlay, level: .aboveRoads)
    }
}
