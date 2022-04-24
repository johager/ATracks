//
//  MapView.swift
//  ATracks
//
//  Created by James Hager on 4/18/22.
//
//  Based on https://codakuma.com/the-line-is-a-dot-to-you/
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    
    @ObservedObject var track: Track
    @State var shouldTrackPoint: Bool
    var delegate: MapViewDelegate?
    
    let mapViewHelper = MapViewHelper()
    
    let file = "MapView"
    
    // MARK: - UIViewRepresentable
    
    func makeUIView(context: Context) -> MKMapView {
        //print("=== \(file).\(#function) - shouldTrackPoint: \(shouldTrackPoint) ===")
        mapViewHelper.setUpView(forTrack: track, shouldTrackPoint: shouldTrackPoint)
        mapViewHelper.delegate = delegate
        mapViewHelper.mapView.delegate = context.coordinator
        
        return mapViewHelper.mapView
    }
    
    func updateUIView(_ view: MKMapView, context: Context) {
        //print("=== \(file).\(#function) - shouldTrackPoint: \(shouldTrackPoint) ===")
        mapViewHelper.updateView(forTrack: track)
    }
    
    func makeCoordinator() -> MapViewCoordinator {
        MapViewCoordinator(self)
    }
}
