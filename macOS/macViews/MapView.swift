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
    
    let mapViewHelper = MapViewHelper()
    
    var isDark: Bool { colorScheme == .dark }
    
    // MARK: - NSViewRepresentable
    
    func makeNSView(context: Context) -> NSView {
        //print(#function)
        mapViewHelper.setUpView(forTrack: track)
        mapViewHelper.mapView.delegate = context.coordinator
        
        return mapViewHelper.view
    }
    
    func updateNSView(_ view: NSView, context: Context) {
        //print(#function)
        mapViewHelper.updateView(forTrack: track)
    }
    
    func makeCoordinator() -> MapViewCoordinator {
        MapViewCoordinator(self)
    }
}
