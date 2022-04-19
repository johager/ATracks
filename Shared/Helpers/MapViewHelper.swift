//
//  MapViewHelper.swift
//  ATracks
//
//  Created by James Hager on 4/18/22.
//

import Foundation
import MapKit

class MapViewHelper: NSObject {
    
    let mapView = MKMapView()
    
    var track: Track!
    
    private var lastTrackPoint: TrackPoint?
    
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
    
    // MARK: - Methods
    
    func setUpView(forTrack track: Track) {
        self.track = track
        setUpView()
        setUpTracking()
        drawTrack()
    }
    
    func setUpView() {
        mapView.isPitchEnabled = false
        mapView.showsCompass = true
        mapView.region = region
        
        #if os(iOS)
            let scaleView = MKScaleView(mapView: mapView)
            mapView.addSubview(scaleView)
            scaleView.pin(top: nil, trailing: nil, bottom: mapView.safeAreaLayoutGuide.bottomAnchor, leading: nil, margin: [0, 0, 14, 0])
            scaleView.centerXAnchor.constraint(equalTo: mapView.centerXAnchor, constant: 12).isActive = true

            scaleView.scaleVisibility = .visible
        #endif
    }
    
    func drawTrack() {
        let trackPoints = track.trackPoints
        
        guard trackPoints.count > 0 else { return }
        
        // track
        let coordinates = trackPoints.map { $0.clLocationCoordinate2D }
        let routeOverlay = MKPolyline(coordinates: coordinates, count: coordinates.count)
        mapView.addOverlay(routeOverlay, level: .aboveRoads)
        
        // annotation
        let pin = MKPointAnnotation()
        pin.coordinate = coordinates.first!
        mapView.addAnnotation(pin)
    }
    
    func setUpTracking() {
        setMapNoTrack()
        
        #if os(iOS)
        guard let isTrackingTrack = LocationManager.shared.isTrackingTrack else { return }
        print("\(#function) - got LocationManager.shared.isTrackingTrack")
        
        guard track === isTrackingTrack else { return }
        print("\(#function) - track === isTrackingTrack")
        
        setMapToTrack()
        #endif
    }
    
    func setMapNoTrack() {
        TrackManager.shared.delegate = nil
        mapView.isRotateEnabled = false
        mapView.showsUserLocation = false
        mapView.userTrackingMode = .none
    }
    
    func setMapToTrack() {
        TrackManager.shared.delegate = self
        mapView.isRotateEnabled = true
        mapView.showsUserLocation = true
        #if os(iOS)
            mapView.userTrackingMode = .followWithHeading
        #endif
        
        lastTrackPoint = track.trackPoints.last
    }
}

// MARK: - MKMapViewDelegate

extension MapViewHelper: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = .systemRed
            renderer.lineWidth = 5
            return renderer
        }
        return MKOverlayRenderer()
    }
}

// MARK: - TrackManagerDelegate

extension MapViewHelper: TrackManagerDelegate {
    
    func didMakeNewTrackPoint(_ trackPoint: TrackPoint) {
        
        mapView.setCenter(trackPoint.clLocationCoordinate2D, animated: true)
        
        defer {
            lastTrackPoint = trackPoint
        }
        
        guard let lastTrackPoint = lastTrackPoint else { return }
        
        let coordinates = [lastTrackPoint.clLocationCoordinate2D, trackPoint.clLocationCoordinate2D]
        let routeOverlay = MKPolyline(coordinates: coordinates, count: coordinates.count)
        mapView.addOverlay(routeOverlay, level: .aboveRoads)
    }
}
