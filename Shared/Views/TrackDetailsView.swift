//
//  TrackDetailsView.swift
//  ATracks
//
//  Created by James Hager on 4/18/22.
//

import SwiftUI

struct TrackDetailsView: View {
    @ObservedObject var track: Track
    
    var body: some View {
        VStack {
            HStack {
                Text("Duration: \(track.duration.stringWithHrMin)")
                    .font(.footnote)
                Spacer()
                Text("Distance: \(String(format: "%.2f", track.distance)) mi")
                    .font(.footnote)
            }
            .padding([.trailing, .leading], 32)
            
            
        }
    }
}

//struct TrackDetailsView_Previews: PreviewProvider {
//    static var previews: some View {
//        TrackDetailsView(track: <#T##Track#>)
//    }
//}
