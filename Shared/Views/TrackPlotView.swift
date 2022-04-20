//
//  TrackPlotView.swift
//  ATracks
//
//  Created by James Hager on 4/20/22.
//

import SwiftUI

struct TrackPlotView: View {
    
    @ObservedObject var track: Track
    
    @State private var elevationString = ""
    @State private var plotWidth: CGFloat = 100
    @State private var xVertVals: [Double] = [-1, -1]
    private var yVertVals: [Double] = [0, 1]
    
    private var trackHelper: TrackHelper
    
    // MARK: - View
    
    var body: some View {
        VStack {
            ZStack {
                HStack {
                    Text("min: \(trackHelper.minElevation.stringAsInt)")
                    Spacer()
                    Text("max: \(trackHelper.maxElevation.stringAsInt)")
                }
                Text(elevationString)
            }
            .padding([.top, .bottom], 8)
            .padding([.trailing, .leading], 32)
            
            GeometryReader { geometry in
                ZStack {
                    LineShape(xVals: trackHelper.xVals, yVals: trackHelper.elevations)
                        .stroke(Color.plotElevation, lineWidth: 3)
    //                LineShape(xVals: trackHelper.xVals, yVals: trackHelper.speeds)
    //                    .stroke(Color.plotSpeed, lineWidth: 1)
                    LineShape(xVals: xVertVals, yVals: yVertVals)
                        .stroke(Color.plotVertical, lineWidth: 6)
                }
                #if os(iOS)
                .onTouch(perform: handleTouch)
                #endif
                .task { plotWidth = geometry.size.width }
            }
            
            Text("Elevation (ft)")
            .padding(.top, 8)
        }
        .font(.footnote)
    }
    
    // MARK: - Init
    
    init(track: Track) {
        self.track = track
        self.trackHelper = TrackHelper(track: track)
    }
    
    // MARK: - Methods
    
    func handleTouch(_ location: CGPoint) {
        
        let xFraction = location.x / plotWidth
        //print("\(#function) - locationX: \(location.x), plotWidth: \(plotWidth), xFraction: \(xFraction)")
        
        guard let elevation = trackHelper.plotData(at: xFraction) else { return }
        
        elevationString = "\(elevation.stringAsInt)"
        xVertVals = [xFraction, xFraction]
    }
}

//struct TrackPlotView_Previews: PreviewProvider {
//    static var previews: some View {
//        TrackPlotView()
//    }
//}
