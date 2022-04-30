//
//  TrackDetailView.swift
//  ATracks
//
//  Created by James Hager on 4/18/22.
//

import SwiftUI

struct TrackDetailView: View {
    
    @ObservedObject var track: Track
    @Binding var hasSafeAreaInsets: Bool
    var deviceType: DeviceType
    
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
    
    var body: some View {
        GeometryReader {  geometry in
            if shouldShowSideBySide(for: geometry) {
                HStack(spacing: 0) {
                    ZStack {
                        MapView(track: track)
                            .edgesIgnoringSafeArea([.trailing, .leading, .bottom])
                        #if os(iOS)
                        if track.isTracking {
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
                    
                    Rectangle()
                        .edgesIgnoringSafeArea([.top, .bottom])
                        .foregroundColor(.border)
                        .frame(width: 0.5)
                    
                    VStack(spacing: 0) {
                        Spacer()
                        TrackStatsView(track: track, displayTall: true)
                        Spacer()
                        Rectangle()
                            .edgesIgnoringSafeArea([.trailing, .leading])
                            .foregroundColor(.border)
                            .frame(height: 0.5)
                        Spacer()
                        TrackPlotView(track: track, hasSafeAreaInsets: $hasSafeAreaInsets, displayTall: true)
                    }
                }
                
            } else {
                VStack(spacing: 0) {
                    TrackStatsView(track: track)
                    Rectangle()
                        .edgesIgnoringSafeArea([.trailing, .leading])
                        .foregroundColor(.border)
                        .frame(height: 0.5)
                    ZStack {
                        MapView(track: track)
                                .edgesIgnoringSafeArea([.trailing, .leading])
                        #if os(iOS)
                        if track.isTracking {
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
        .navigationBarTitleDisplayMode(.inline)
        #endif
        
    }
    
    // MARKL - Methods
    
    func shouldShowSideBySide(for geometry: GeometryProxy) -> Bool {
        #if os(iOS)
        let file = "TrackDetailView"
        let gSize = geometry.size
        print("=== \(file).\(#function) - deviceType: \(deviceType) ===")
        print("=== \(file).\(#function) - gSize width/height: \(gSize.width)/\(gSize.height) ===")
        print("=== \(file).\(#function) - \(deviceType == .iPhone && gSize.width > gSize.height) ===")
        return deviceType == .iPhone && gSize.width > gSize.height
        #else
        return false
        #endif
    }
    
    #if os(iOS)
    func stopTracking() {
        print("=== TrackDetailView.\(#function) ===")
        LocationManager.shared.stopTracking()
    }
    #endif
}

// MARK: - Previews

//struct TrackDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        TrackDetailView()
//    }
//}
