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
                .foregroundColor(.text)
            Spacer()
            Text(String(format: "%.2f", track.distance) + " mi")
                .font(.footnote)
                .foregroundColor(.textSecondary)
        }
    }
}

// MARK: - Previews

//struct TrackRow_Previews: PreviewProvider {
//    static var previews: some View {
//        TrackRow()
//    }
//}
