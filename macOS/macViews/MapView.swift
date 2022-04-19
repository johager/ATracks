//
//  MapView.swift
//  ATracks (macOS)
//
//  Created by James Hager on 4/18/22.
//

import SwiftUI
import MapKit

struct MapView: NSViewRepresentable {
    
    @ObservedObject var track: Track
    
    let mapViewHelper = MapViewHelper()
    
    // MARK: - NSViewRepresentable
    
    func makeNSView(context: Context) -> MKMapView {
        
        mapViewHelper.setUpView(forTrack: track)
        mapViewHelper.mapView.delegate = context.coordinator
        
        return mapViewHelper.mapView
    }
    
    func updateNSView(_ view: MKMapView, context: Context) {
        print(#function)
    }
    
    func makeCoordinator() -> MapViewCoordinator {
        MapViewCoordinator(self)
    }
}