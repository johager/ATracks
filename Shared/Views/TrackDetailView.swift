//
//  TrackDetailView.swift
//  ATracks
//
//  Created by James Hager on 4/18/22.
//

import SwiftUI

struct TrackDetailView: View {
    
    @ObservedObject var track: Track
    
    @State private var isShowingTrackDetailsView = false
    @State private var isTracking = false
    
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
                MapView(track: track, shouldTrackPoint: false)
                    .edgesIgnoringSafeArea([.trailing, .bottom, .leading])
                #if os(iOS)
                if isTracking {
                    VStack {
                        Spacer()
                        Button(action: stopTracking) {
                            Text(stopTrackingText)
                        }
                        .buttonStyle(AAButtonStyle(isEnabled: true))
                    }
                    .onReceive(NotificationCenter.default.publisher(for: .didStopTracking)) { _ in
                        isTracking = false
                    }
                }
                #endif
            }
            NavigationLink(destination: TrackDetailsView(track: track), isActive: $isShowingTrackDetailsView) { EmptyView() }
        }
        .navigationTitle(track.name)
        #if os(iOS)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: showTrackDetails) {
                    Image(systemName: "ellipsis")
                        .tint(.textSelectable)
                }
            }
        }
        .task {
            isTracking = LocationManager.shared.isTracking
        }
        #endif
    }
    
    // MARKL - Methods
    
    func showTrackDetails() {
        isShowingTrackDetailsView = true
    }
    
    #if os(iOS)
    func stopTracking() {
        print("=== TrackDetailView.\(#function) ===")
        LocationManager.shared.stopTracking()
        isTracking = false
    }
    #endif
}

// MARK: - Previews

//struct TrackDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        TrackDetailView()
//    }
//}
