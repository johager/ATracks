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
    
    var body: some View {
        VStack(spacing: 0) {
            TrackStatsView(track: track)
            MapView(track: track, shouldTrackPoint: false)
                .edgesIgnoringSafeArea([.trailing, .bottom, .leading])
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
        #endif
    }
    
    // MARKL - Methods
    
    func showTrackDetails() {
        isShowingTrackDetailsView = true
    }
}

// MARK: - Previews

//struct TrackDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        TrackDetailView()
//    }
//}
