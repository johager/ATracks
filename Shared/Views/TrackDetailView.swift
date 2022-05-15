//
//  TrackDetailView.swift
//  ATracks
//
//  Created by James Hager on 4/18/22.
//

import SwiftUI

struct TrackDetailView: View {
    
    @Environment(\.colorScheme) private var colorScheme
    
    @ObservedObject var track: Track
    @Binding var hasSafeAreaInsets: Bool
    
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
    
    // MARK: - View
    
    var body: some View {
        GeometryReader {  geometry in
            if geometry.isLandscape {
                HStack(spacing: 0) {
                    if DisplaySettings.shared.placeMapOnRightInLandscape {
                        DetailsOnSideView(track: track, hasSafeAreaInsets: $hasSafeAreaInsets)
                        VerticalDividerView()
                    }
                    
                    ZStack {
                        MapView(track: track)
                            .edgesIgnoringSafeArea(.all)
                            .id(colorScheme)
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
                    
                    if !DisplaySettings.shared.placeMapOnRightInLandscape {
                        VerticalDividerView()
                        DetailsOnSideView(track: track, hasSafeAreaInsets: $hasSafeAreaInsets)
                    }
                }
                
            } else {  // geometry is portrait
                VStack(spacing: 0) {
                    TrackStatsView(track: track, hasSafeAreaInsets: $hasSafeAreaInsets)
                    Rectangle()
                        .edgesIgnoringSafeArea([.trailing, .leading])
                        .foregroundColor(.border)
                        .frame(height: 0.5)
                    ZStack {
                        MapView(track: track)
                            .edgesIgnoringSafeArea([.top, .trailing, .leading])
                            .id(colorScheme)
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
                    Rectangle()
                        .edgesIgnoringSafeArea([.trailing, .leading])
                        .foregroundColor(.border)
                        .frame(height: 0.5)
                    TrackPlotView(track: track, hasSafeAreaInsets: $hasSafeAreaInsets)
                }
            }
        }
        .navigationTitle(track.name)
        #if os(iOS)
        .ignoresSafeArea(.keyboard)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
    
    // MARKL - Methods
    
    #if os(iOS)
    func stopTracking() {
        print("=== TrackDetailView.\(#function) ===")
        LocationManager.shared.stopTracking()
    }
    #endif
}

struct DetailsOnSideView: View {
    
    @ObservedObject var track: Track
    @Binding var hasSafeAreaInsets: Bool
    
    // MARK: - View
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            TrackStatsView(track: track, hasSafeAreaInsets: $hasSafeAreaInsets, displayOnSide: true)
            Spacer()
            Rectangle()
                .edgesIgnoringSafeArea([.trailing, .leading])
                .foregroundColor(.border)
                .frame(height: 0.5)
            Spacer()
            TrackPlotView(track: track, hasSafeAreaInsets: $hasSafeAreaInsets, displayOnSide: true)
        }
    }
}

// MARK: - Previews

//struct TrackDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        TrackDetailView()
//    }
//}
