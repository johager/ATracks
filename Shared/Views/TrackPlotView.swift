//
//  TrackPlotView.swift
//  ATracks
//
//  Created by James Hager on 4/20/22.
//

import SwiftUI

struct TrackPlotView: View {
    
    @ObservedObject var track: Track
    @Binding var hasSafeAreaInsets: Bool
    var displayTall: Bool
    
    @State private var plotSize = CGSize(width: 100, height: 100)
    @State private var xVertVals: [Double] = [2, 2]
    private var yVertVals: [Double] = [0, 1]
    
    private var trackHelper: TrackHelper
    
    // MARK: - Init
    
    init(track: Track, hasSafeAreaInsets: Binding<Bool>, displayTall: Bool = false) {
        self.track = track
        self._hasSafeAreaInsets = hasSafeAreaInsets
        self.displayTall = displayTall
        self.trackHelper = TrackHelper(track: track, forPlotting: true)
    }
    
    // MARK: - View
    
    var body: some View {
        VStack(spacing: 0) {            
            HStack(spacing: 0) {
                VStack {
                    Text("Elevation (ft)")
                    Text(" ")
                }
                Spacer()
                if trackHelper.hasAltitudeData {
                    if displayTall {
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Max: ")
                            Text("Min: ")
                            Text("Avg: ")
                            Text("Gain: ")
                        }
                        VStack(alignment: .trailing, spacing: 4) {
                            Text(trackHelper.altitudeMax.stringAsInt)
                            Text(trackHelper.altitudeMin.stringAsInt)
                            Text(trackHelper.altitudeAve.stringAsInt)
                            Text(trackHelper.altitudeGain.stringAsInt)
                        }
                    } else {
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Max: ")
                            Text("Min: ")
                        }
                        VStack(alignment: .trailing, spacing: 4) {
                            Text(trackHelper.altitudeMax.stringAsInt)
                            Text(trackHelper.altitudeMin.stringAsInt)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Avg: ")
                            Text("Gain: ")
                        }
                        VStack(alignment: .trailing, spacing: 4) {
                            Text(trackHelper.altitudeAve.stringAsInt)
                            Text(trackHelper.altitudeGain.stringAsInt)
                        }
                    }
                }
            }
            .padding(.top, displayTall ? 0 : 8)
            .padding(.bottom, 16)
            
            GeometryReader { geometry in
                ZStack {
                    if trackHelper.hasAltitudeData {
                        
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
                        
                        // grid lines
                        ForEach((1...trackHelper.yAxisNumGridLines), id: \.self) {
                            let (xVals, yVals) = trackHelper.gridValues(forIndex: $0)
                            LineShape(xVals: xVals, yVals: yVals)
                                .stroke(Color.plotGrid, lineWidth: 1)
                        }
                    } else {
                        Text("Elevation data\nnot available")
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    // axis
                    LineShape(xVals: trackHelper.axisXVals, yVals: trackHelper.axisYVals)
                        .stroke(Color.plotAxis, lineWidth: 2)
                    
                    // value lines
                    LineShape(xVals: trackHelper.time, yVals: trackHelper.altitudePlotVals)
                        .stroke(Color.plotAltitude, lineWidth: 2)
                    
                    // scrubber
                    LineShape(xVals: xVertVals, yVals: yVertVals)
                        .stroke(Color.plotVertical, lineWidth: 4)
                }
                #if os(iOS)
                .onTouch() { location in
                    plotSize = geometry.size
                    handleTouch(at: location)
                }
                #endif
                .onAppear { plotSize = geometry.size }
            }
            .frame(height: 90)
            .padding(.bottom, hasSafeAreaInsets ? (displayTall ? 8 : 0) : 16)
        }
        .font(.footnote.monospacedDigit())
        .foregroundColor(.text)
        .padding(.leading, displayTall ? 16 : 32)
        .padding(.trailing, displayTall ? 8 : 32)
    }
    
    // MARK: - Methods
    
    func handleTouch(at location: CGPoint) {
        
        guard trackHelper.hasAltitudeData else { return }
        
        let xFraction = location.x / plotSize.width
        print("\(#function) - locationX: \(location.x), plotSize.width: \(plotSize.width), xFraction: \(xFraction)")
        
        guard trackHelper.showData(at: xFraction) else { return }
        
        xVertVals = [xFraction, xFraction]
    }
}

//struct TrackPlotView_Previews: PreviewProvider {
//    static var previews: some View {
//        TrackPlotView()
//    }
//}
