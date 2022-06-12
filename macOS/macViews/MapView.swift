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
    
    func makeNSView(context: Context) -> NSView {
        //print(#function)
        mapViewHelper.setUpView(for: track)
        mapViewHelper.mapView.delegate = context.coordinator
        
        return mapViewHelper.view
    }
    
    func updateNSView(_ view: NSView, context: Context) {
        //print(#function)
        mapViewHelper.updateView(for: track)
    }
    
    func makeCoordinator() -> MapViewCoordinator {
        MapViewCoordinator(self)
    }
}
