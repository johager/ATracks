//
//  TrackDetailView.swift
//  ATracks
//
//  Created by James Hager on 4/18/22.
//

import SwiftUI
import os.log

struct TrackDetailView: View {
    
    #if os(iOS)
    @Environment(\.horizontalSizeClass) var hSizeClass
    @Environment(\.presentationMode) var presentationMode
    #endif
    @EnvironmentObject var displaySettings: DisplaySettings
    
    @StateObject private var device = Device.shared
    
    @ObservedObject private var track: Track
    private var delegate: TrackStatsViewDelegate?
    
    @StateObject private var mapViewHelper = MapViewHelper()
    @StateObject private var scrubberInfo = ScrubberInfo()
    
    private var trackIsTrackingOnThisDevice: Bool { TrackHelper.trackIsTrackingOnThisDevice(track) }
    
    #if os(iOS)
    @StateObject var locationManagerSettings = LocationManagerSettings.shared
    private var stopTrackingText: String {
        if locationManagerSettings.useAutoStop {
            return "[Stop Tracking]"
        } else {
            return "Stop Tracking"
        }
    }
    #endif
    
    private var logger: Logger?
    
    let file = "TrackDetailView"
    
    // MARK: - Init
    
    init(track: Track, delegate: TrackStatsViewDelegate? = nil) {
        self.track = track
        self.delegate = delegate
        logger = Func.logger(for: file)
        print("=== \(file).\(#function) - \(track.debugName) ===")
    }
    
    // MARK: - View
    
    var body: some View {
        GeometryReader {  geometry in
            HStack(spacing: 0) {
                #if os(macOS)
                VerticalDividerView()
                #endif
                VStack(spacing: 0) {
                    #if os(macOS)
                    HorizontalDividerView()
                    #endif
                    if geometry.isLandscape {
                        HStack(spacing: 0) {
                            if displaySettings.placeMapOnRightInLandscape {
                                DetailsOnSideView(track: track, scrubberInfo: scrubberInfo, delegate: delegate)
                                VerticalDividerView()
                            }
                            
                            ZStack {
                                MapView(mapViewHelper: mapViewHelper, track: track, scrubberInfo: scrubberInfo)
                                    .edgesIgnoringSafeArea(.all)
                                    .id(device.colorScheme)
                                    .id(displaySettings.mapViewSatellite)
//                                    .id(track.id)
                                #if os(iOS)
                                if trackIsTrackingOnThisDevice {
                                    VStack {
                                        Spacer()
                                        Button(action: stopTracking) {
                                            Text(stopTrackingText)
                                        }
                                        .buttonStyle(AAButtonStyle(isEnabled: true))
                                        .padding(.bottom, 8)
                                    }
                                }
                                #endif
                            }
                            .frame(width: geometry.size.width * 0.6)
                            
                            if !displaySettings.placeMapOnRightInLandscape {
                                VerticalDividerView()
                                DetailsOnSideView(track: track, scrubberInfo: scrubberInfo, delegate: delegate)
                            }
                        }
                        
                    } else {  // geometry is portrait
                        VStack(spacing: 0) {
                            #if os(macOS)
                            HorizontalDividerView()
                            #endif
                            TrackStatsView(track: track, delegate: delegate)
                            HorizontalDividerView()
                            ZStack {
                                MapView(mapViewHelper: mapViewHelper, track: track, scrubberInfo: scrubberInfo)
                                    .edgesIgnoringSafeArea([.top, .trailing, .leading])
                                    .id(device.colorScheme)
                                    .id(displaySettings.mapViewSatellite)
//                                    .id(track.id)
                                #if os(iOS)
                                if trackIsTrackingOnThisDevice {
                                    VStack {
                                        Spacer()
                                        Button(action: stopTracking) {
                                            Text(stopTrackingText)
                                        }
                                        .buttonStyle(AAButtonStyle(isEnabled: true))
                                        .padding(.bottom, 8)
                                    }
                                }
                                #endif
                            }
                            HorizontalDividerView()
                            TrackPlotView(track: track, scrubberInfo: scrubberInfo)
                                .id(track.id)
                        }
                        #if os(iOS)
                        .id(hSizeClass)
                        .id(device.detailHorizontalSizeClassIsCompact)
                        #endif
                    }  // end geometry is portrait
                }  // end VStack
            }  // end HStack
            .onChange(of: geometry.size.width) { _ in
                #if os(iOS)
                device.detailHorizontalSizeClassIsCompact = hSizeClass == .compact
                #else
                device.detailHorizontalSizeClassIsCompact = geometry.horizontalSizeClassIsCompact
                #endif
            }
        }
        .navigationTitle(track.name)
        #if os(iOS)
        .ignoresSafeArea(.keyboard)
        .onAppear {
            logger?.notice("onAppear - track: \(track.debugName, privacy: .private(mask: .hash))")
            device.detailHorizontalSizeClassIsCompact = hSizeClass == .compact
        }
        .onDisappear {
            logger?.notice("onDisappear - track: \(track.debugName, privacy: .private(mask: .hash))")
        }
        .navigationBarTitleDisplayMode(.inline)
        #else
        .background(.background)
        #endif
    }
    
    // MARK: - Methods
    
    #if os(iOS)
    func stopTracking() {
        print("=== \(file).\(#function) ===")
        LocationManager.shared.stopTracking()
    }
    #endif
}

// MARK: -

struct DetailsOnSideView: View {
    
    @ObservedObject var track: Track
    var scrubberInfo: ScrubberInfo
    var delegate: TrackStatsViewDelegate?
    
    // MARK: - View
    
    var body: some View {
        VStack(spacing: 0) {
            #if os(macOS)
            HorizontalDividerView()
            #endif
            Spacer()
            TrackStatsView(track: track, displayOnSide: true, delegate: delegate)
            Spacer()
            HorizontalDividerView()
            Spacer()
            TrackPlotView(track: track, scrubberInfo: scrubberInfo, displayOnSide: true)
                .id(track.id)
        }
    }
}

// MARK: - Previews

//struct TrackDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        TrackDetailView()
//    }
//}
