//
//  TrackDetailView.swift
//  ATracks
//
//  Created by James Hager on 4/18/22.
//

import SwiftUI

struct TrackDetailView: View {
    @ObservedObject var track: Track
    
    var body: some View {
        VStack {
            TrackDetailsView(track: track)
            MapView(track: track)
                .edgesIgnoringSafeArea([.trailing, .bottom, .leading])
        }
        .navigationTitle(track.name)
    }
}

// MARK: - Previews

//struct TrackDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        TrackDetailView()
//    }
//}
