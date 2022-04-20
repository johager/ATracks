//
//  TrackPlotView.swift
//  ATracks
//
//  Created by James Hager on 4/20/22.
//

import SwiftUI

struct TrackPlotView: View {
    
    @ObservedObject var track: Track
    
    private var trackHelper: TrackHelper
    
    var body: some View {
        VStack {
            HStack {
                Text("Elevation (ft) min: \(trackHelper.minElevation.stringAsInt), max: \(trackHelper.maxElevation.stringAsInt)")
                Spacer()
            }
            .font(.footnote)
            .padding([.top, .bottom], 8)
            .padding([.trailing, .leading], 32)
            
            ZStack {
                LineShape(xVals: trackHelper.xVals, yVals: trackHelper.elevations)
                    .stroke(Color.plotElevation, lineWidth: 1)
//                LineShape(xVals: trackHelper.xVals, yVals: trackHelper.speeds)
//                    .stroke(Color.plotSpeed, lineWidth: 1)
            }
        }
    }
    
    // MARK: - Init
    
    init(track: Track) {
        self.track = track
        self.trackHelper = TrackHelper(track: track)
    }
}

//struct TrackPlotView_Previews: PreviewProvider {
//    static var previews: some View {
//        TrackPlotView()
//    }
//}
