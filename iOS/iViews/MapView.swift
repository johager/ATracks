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
    
    let mapViewHelper = MapViewHelper()
    
    // MARK: - UIViewRepresentable
    
    func makeUIView(context: Context) -> MKMapView {
        
        mapViewHelper.setUpView(forTrack: track, shouldTrackPoint: shouldTrackPoint)
        mapViewHelper.mapView.delegate = context.coordinator
        
        return mapViewHelper.mapView
    }
    
    func updateUIView(_ view: MKMapView, context: Context) {
        print(#function)
    }
    
    func makeCoordinator() -> MapViewCoordinator {
        MapViewCoordinator(self)
    }
}
