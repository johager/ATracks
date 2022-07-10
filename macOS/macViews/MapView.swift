//
//  MapView.swift
//  ATracks (macOS)
//
//  Created by James Hager on 4/18/22.
//

import SwiftUI

struct MapView: NSViewRepresentable {
    
    typealias Context = NSViewRepresentableContext<MapView>
    typealias NSViewType = NSView
    
    private var mapViewHelper: MapViewHelper!
    
    let file = "MapView"
    
    // MARK: - Init
    
    init(mapViewHelper: MapViewHelper, track: Track, scrubberInfo: ScrubberInfo) {
        self.mapViewHelper = mapViewHelper
        mapViewHelper.setUp(for: track, and: scrubberInfo)
    }
    
    // MARK: - NSViewRepresentable
    
    func makeCoordinator() -> MapViewCoordinator {
        MapViewCoordinator(mapViewHelper: mapViewHelper)
    }
    
    func makeNSView(context: Context) -> NSView {
        //print("=== \(file).\(#function)  ===")
        mapViewHelper.makeView()
        mapViewHelper.mapView.delegate = context.coordinator
        return mapViewHelper.view
    }
    
    func updateNSView(_ view: NSView, context: Context) {
        //print("=== \(file).\(#function)  ===")
        mapViewHelper.updateView()
    }
    
    static func dismantleNSView(_ nsView: NSView, coordinator: MapViewCoordinator) {
        let file = "MapView"
        print("=== \(file).\(#function)  ===")
        coordinator.cleanUp()
    }
}
