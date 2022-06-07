//
//  TrackDetailView.swift
//  ATracks
//
//  Created by James Hager on 4/18/22.
//

import SwiftUI

struct TrackDetailView: View {
    
    @Environment(\.colorScheme) private var colorScheme
    #if os(iOS)
    @Environment(\.horizontalSizeClass) var hSizeClass
    @Environment(\.presentationMode) var presentationMode
    #endif
    @EnvironmentObject var displaySettings: DisplaySettings
    
    @ObservedObject private var track: Track
    @ObservedObject private var device: Device
    private var delegate: TrackStatsViewDelegate?
    
    private var trackIsTrackingOnThisDevice: Bool { TrackHelper.trackIsTrackingOnThisDevice(track) }
    
    #if os(iOS)
    @ObservedObject var locationManagerSettings = LocationManagerSettings.shared
    private var stopTrackingText: String {
        if locationManagerSettings.useAutoStop {
            return "[Stop Tracking]"
        } else {
            return "Stop Tracking"
        }
    }
    #endif
    
    let file = "TrackDetailView"
    
    // MARK: - Init
    
    init(track: Track, device: Device, delegate: TrackStatsViewDelegate? = nil) {
        self.track = track
        self.device = device
        self.delegate = delegate
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
                                DetailsOnSideView(track: track, device: device, delegate: delegate)
                                VerticalDividerView()
                            }
                            
                            ZStack {
                                MapView(track: track, device: device)
                                    .edgesIgnoringSafeArea(.all)
                                    .id(colorScheme)
                                    .id(displaySettings.mapViewSatellite)
                                    .id(track.id)
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
                                DetailsOnSideView(track: track, device: device, delegate: delegate)
                            }
                        }
                        
                    } else {  // geometry is portrait
                        VStack(spacing: 0) {
                            #if os(macOS)
                            HorizontalDividerView()
                            #endif
                            TrackStatsView(track: track, device: device, delegate: delegate)
                            HorizontalDividerView()
                            ZStack {
                                MapView(track: track, device: device)
                                    .edgesIgnoringSafeArea([.top, .trailing, .leading])
                                    .id(colorScheme)
                                    .id(displaySettings.mapViewSatellite)
                                    .id(track.id)
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
                            TrackPlotView(track: track, device: device)
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
            device.detailHorizontalSizeClassIsCompact = hSizeClass == .compact
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
    var device: Device
    var delegate: TrackStatsViewDelegate?
    
    // MARK: - View
    
    var body: some View {
        VStack(spacing: 0) {
            #if os(macOS)
            HorizontalDividerView()
            #endif
            Spacer()
            TrackStatsView(track: track, device: device, displayOnSide: true, delegate: delegate)
            Spacer()
            HorizontalDividerView()
            Spacer()
            TrackPlotView(track: track, device: device, displayOnSide: true)
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
