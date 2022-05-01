//
//  TrackRow.swift
//  ATracks
//
//  Created by James Hager on 4/18/22.
//

import SwiftUI

struct TrackRow: View {
    
    @ObservedObject var track: Track
    
    // MARK: - View
    
    var body: some View {
//        VStack(alignment: .leading) {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text(track.name)
                    .font(.body.monospacedDigit())
                    .foregroundColor(.text)
                if track.isFault {
                    Text("")
                } else {
                    Text(track.dateString)
                        .offset(x: 16)
                }
            }
            Spacer()
            VStack(alignment: .leading, spacing: 4) {
                Text(String(format: "%.2f", track.distance) + " mi")
                Text(track.duration.stringWithUnits)
            }
        }
//            Text("isTracking: " + String(track.isTracking))
//                .offset(x: 16)
//        }
        .font(.footnote.monospacedDigit())
        .foregroundColor(.textSecondary)
    }
}

// MARK: - Previews

//struct TrackRow_Previews: PreviewProvider {
//    static var previews: some View {
//        TrackRow()
//    }
//}
