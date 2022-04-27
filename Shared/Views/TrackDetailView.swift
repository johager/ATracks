//
//  TrackDetailView.swift
//  ATracks
//
//  Created by James Hager on 4/18/22.
//

import SwiftUI

struct TrackDetailView: View {
    
    @ObservedObject var track: Track
    
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
        VStack(spacing: 0) {
            TrackStatsView(track: track)
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
            TrackPlotView(track: track)
                .frame(height: 150)
        }
        .navigationTitle(track.name)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
//        #if os(iOS)
//        .toolbar {
//            ToolbarItem(placement: .navigationBarTrailing) {
//                Button(action: showTrackDetails) {
//                    Image(systemName: "ellipsis")
//                        .tint(.textSelectable)
//                }
//            }
//        }
//        #endif
    }
    
    // MARKL - Methods
    
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
