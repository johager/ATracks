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
    @State private var plotSize = CGSize(width: 100, height: 100)
    @State private var xVertVals: [Double] = [-1, -1]
    private var yVertVals: [Double] = [0, 1]
    
    private var trackHelper: TrackHelper
    
    // MARK: - View
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                HStack {
                    Text("Elevation (ft)")
                    Spacer()
                    Text("max: \(trackHelper.maxElevation.stringAsInt)")
                }
                Text(elevationString)
            }
            .padding(.top, 8)
            
            HStack {
                Spacer()
                Text("min: \(trackHelper.minElevation.stringAsInt)")
            }
            .padding(.bottom, 8)
            
            GeometryReader { geometry in
                ZStack {
                    // axis labels
                    VStack {
                        HStack {
                            ZStack {
                                ForEach((0...trackHelper.yAxisNumGridLines), id: \.self) {
                                    let (text, offset) = trackHelper.gridLabelInfo(forIndex: $0, andPlotHeight: plotSize.height)
                                    Text(text)
                                        .offset(x: offset.x, y: offset.y)
                                }
                            }
                            Spacer()
                        }
                        Spacer()
                    }
                    
                    // axis
                    LineShape(xVals: trackHelper.axisXVals, yVals: trackHelper.axisYVals)
                        .stroke(Color.plotAxis, lineWidth: 3)
                    
                    // grid lines
                    ForEach((1...trackHelper.yAxisNumGridLines), id: \.self) {
                        let (xVals, yVals) = trackHelper.gridValues(forIndex: $0)
                        LineShape(xVals: xVals, yVals: yVals)
                            .stroke(Color.plotGrid, lineWidth: 1)
                    }
                    
                    // value lines
                    LineShape(xVals: trackHelper.xVals, yVals: trackHelper.elevationPlotVals)
                        .stroke(Color.plotElevation, lineWidth: 2)
//                    LineShape(xVals: trackHelper.xVals, yVals: trackHelper.speedPlotVals)
//                        .stroke(Color.plotSpeed, lineWidth: 1)
                    
                    // scrubber
                    LineShape(xVals: xVertVals, yVals: yVertVals)
                        .stroke(Color.plotVertical, lineWidth: 6)
                }
                #if os(iOS)
                .onTouch(perform: handleTouch)
                #endif
                .task { plotSize = geometry.size }
            }
        }
        .font(.footnote)
        .padding([.trailing, .leading], 32)
    }
    
    // MARK: - Init
    
    init(track: Track) {
        self.track = track
        self.trackHelper = TrackHelper(track: track)
    }
    
    // MARK: - Methods
    
    func handleTouch(_ location: CGPoint) {
        
        let xFraction = location.x / plotSize.width
        //print("\(#function) - locationX: \(location.x), plotSize.width: \(plotSize.width), xFraction: \(xFraction)")
        
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
