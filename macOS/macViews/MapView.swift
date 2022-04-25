//
//  MapView.swift
//  ATracks (macOS)
//
//  Created by James Hager on 4/18/22.
//

import SwiftUI
import MapKit

struct MapView: NSViewRepresentable {
    
    @Environment(\.colorScheme) private var colorScheme
    
    @ObservedObject var track: Track
    @State var shouldTrackPoint: Bool
    
    let mapViewHelper = MapViewHelper()
    
    var isDark: Bool { colorScheme == .dark }
    
    // MARK: - NSViewRepresentable
    
    func makeNSView(context: Context) -> MKMapView {
        //print(#function)
        mapViewHelper.setUpView(forTrack: track, shouldTrackPoint: shouldTrackPoint)
        mapViewHelper.mapView.delegate = context.coordinator
        
        return mapViewHelper.mapView
    }
    
    func updateNSView(_ view: MKMapView, context: Context) {
        //print(#function)
        mapViewHelper.updateView(forTrack: track)
    }
    
    func makeCoordinator() -> MapViewCoordinator {
        MapViewCoordinator(self)
    }
}
