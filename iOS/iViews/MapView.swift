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
    
    @Environment(\.colorScheme) private var colorScheme
    
    @ObservedObject var track: Track
    
    let mapViewHelper = MapViewHelper()
    
    var isDark: Bool { colorScheme == .dark }
    
    let file = "MapView"
    
    // MARK: - UIViewRepresentable
    
    func makeUIView(context: Context) -> UIView {
        //print("=== \(file).\(#function) - shouldTrackPoint: \(shouldTrackPoint) ===")
        mapViewHelper.setUpView(forTrack: track)
        mapViewHelper.mapView.delegate = context.coordinator
        
        return mapViewHelper.view
    }
    
    func updateUIView(_ view: UIView, context: Context) {
        //print("=== \(file).\(#function) - shouldTrackPoint: \(shouldTrackPoint) ===")
        mapViewHelper.updateView(forTrack: track)
    }
    
    func makeCoordinator() -> MapViewCoordinator {
        MapViewCoordinator(self)
    }
}
