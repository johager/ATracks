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
import os.log

struct MapView: UIViewRepresentable {
    
    @EnvironmentObject private var appState: AppState
    @ObservedObject private var device = Device.shared
    
    @ObservedObject var track: Track
    var scrubberInfo: ScrubberInfo
    
    let mapViewHelper = MapViewHelper()
    
    private var logger: Logger?
    
    let file = "MapView"
    
    // MARK: - Init
    
    init(track: Track, scrubberInfo: ScrubberInfo) {
        self.track = track
        self.scrubberInfo = scrubberInfo
        
        logger = Func.logger(for: file)
    }
    
    // MARK: - UIViewRepresentable
    
    func makeUIView(context: Context) -> UIView {
        //print("=== \(file).\(#function)  ===")
        logger?.notice(#function)
        mapViewHelper.setUpView(for: track, and: scrubberInfo)
        mapViewHelper.mapView.delegate = context.coordinator
        
        return mapViewHelper.view
    }
    
    func updateUIView(_ view: UIView, context: Context) {
        //print("=== \(file).\(#function) - appState.isActive: \(appState.isActive) ===")
        logger?.notice("\(#function) - appState.isActive: \(appState.isActive, privacy: .public)")
        
        mapViewHelper.updateView(for: track, and: scrubberInfo, appIsActive: appState.isActive)
    }
    
    func makeCoordinator() -> MapViewCoordinator {
        MapViewCoordinator(self)
    }
}
