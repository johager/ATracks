//
//  MapView.swift
//  ATracks (iOS)
//
//  Created by James Hager on 4/18/22.
//
//  Based on https://codakuma.com/the-line-is-a-dot-to-you/
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    
    @ObservedObject var track: Track
    var scrubberInfo: ScrubberInfo
    
    let mapViewHelper = MapViewHelper()
    
    let file = "MapView"
    
    // MARK: - UIViewRepresentable
    
    func makeUIView(context: Context) -> UIView {
        //print("=== \(file).\(#function) - shouldTrackPoint: \(shouldTrackPoint) ===")
        mapViewHelper.setUpView(for: track, and: scrubberInfo)
        mapViewHelper.mapView.delegate = context.coordinator
        
        return mapViewHelper.view
    }
    
    func updateUIView(_ view: UIView, context: Context) {
        //print("=== \(file).\(#function) - shouldTrackPoint: \(shouldTrackPoint) ===")
        mapViewHelper.updateView(for: track, and: scrubberInfo)
    }
    
    func makeCoordinator() -> MapViewCoordinator {
        MapViewCoordinator(self)
    }
}
