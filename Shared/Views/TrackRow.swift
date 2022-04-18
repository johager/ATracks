//
//  TrackRow.swift
//  ATracks
//
//  Created by James Hager on 4/18/22.
//

import SwiftUI

struct TrackRow: View {
    @ObservedObject var track: Track
    
    var body: some View {
        HStack(alignment: .center) {
            Text(track.name)
                .font(.body)
            Spacer()
            Text(String(format: "%.2f", track.distance) + " mi")
                .font(.footnote)
        }
    }
}

// MARK: - Previews

//struct TrackRow_Previews: PreviewProvider {
//    static var previews: some View {
//        TrackRow()
//    }
//}
