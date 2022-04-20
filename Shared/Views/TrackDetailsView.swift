//
//  TrackDetailsView.swift
//  ATracks
//
//  Created by James Hager on 4/20/22.
//

import SwiftUI

struct TrackDetailsView: View {
    
    @ObservedObject var track: Track
    
    // MARK: - View
    
    var body: some View {
        VStack(spacing: 0) {
            TrackStatsView(track: track)
            MapView(track: track, shouldTrackPoint: true)
                .edgesIgnoringSafeArea([.trailing, .leading])
            TrackPlotView(track: track)
                .frame(height: 150)
        }
        .navigationTitle(track.name)
    }
}

//struct TrackDetailsView_Previews: PreviewProvider {
//    static var previews: some View {
//        TrackDetailsView()
//    }
//}
