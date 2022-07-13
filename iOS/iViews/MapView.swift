//
//  MapView.swift
//  ATracks (iOS)
//
//  Created by James Hager on 4/18/22.
//
//  Based on https://codakuma.com/the-line-is-a-dot-to-you/
//

import SwiftUI
import os.log

struct MapView: UIViewRepresentable {
    
    typealias Context = UIViewRepresentableContext<MapView>
    typealias UIViewType = UIView
    
    @EnvironmentObject private var appState: AppState
    
    private var mapViewHelper: MapViewHelper!
    
    private var logger: Logger?
    
    let file = "MapView"
    
    // MARK: - Init
    
    init(mapViewHelper: MapViewHelper, track: Track, scrubberInfo: ScrubberInfo) {
//        print("=== \(file).\(#function) - \(track.debugName) ===")
        self.mapViewHelper = mapViewHelper
        mapViewHelper.setUp(for: track, and: scrubberInfo)
        logger = Func.logger(for: file)
    }
    
    // MARK: - UIViewRepresentable
    
    func makeCoordinator() -> MapViewCoordinator {
        //print("=== \(file).\(#function) ===")
        return MapViewCoordinator(mapViewHelper: mapViewHelper)
    }
    
    func makeUIView(context: Context) -> UIView {
        //print("=== \(file).\(#function) ===")
        logger?.notice(#function)
        mapViewHelper.makeView()
        mapViewHelper.mapView.delegate = context.coordinator
        return mapViewHelper.view
    }
    
    func updateUIView(_ view: UIView, context: Context) {
        //print("=== \(file).\(#function) - appState.isActive: \(appState.isActive) ===")
        logger?.notice("\(#function) - appState.isActive: \(appState.isActive, privacy: .public)")
        guard appState.isActive else { return }
        mapViewHelper.updateView()
    }
    
    static func dismantleUIView(_ uiView: UIView, coordinator: MapViewCoordinator) {
        //let file = "MapView"
        //print("=== \(file).\(#function) ===")
        coordinator.cleanUp()
    }
}
