//
//  TrackPlotView.swift
//  ATracks
//
//  Created by James Hager on 4/20/22.
//

import SwiftUI

struct TrackPlotView: View {
    
    @StateObject private var device = Device.shared
    
    @ObservedObject private var track: Track
    @ObservedObject private var scrubberInfo: ScrubberInfo
    private var displayOnSide: Bool
    
    private var trackIsTrackingOnThisDevice: Bool { TrackHelper.trackIsTrackingOnThisDevice(track) }
    
    @State private var plotSize = CGSize(width: 100, height: 100)
    @State private var xVertVals: [Double]
    private var yVertVals: [Double] = [0, 1]
    
    @StateObject private var trackHelper = TrackHelper()
    
//    let file = "TrackPlotView"
    
    // MARK: - Init
    
    init(track: Track, scrubberInfo: ScrubberInfo, displayOnSide: Bool = false) {
        //print("=== \(file).\(#function) - track: \(track.debugName) ===")
        self.track = track
        self.scrubberInfo = scrubberInfo
        self.displayOnSide = displayOnSide
        
        if displayOnSide && DisplaySettings.shared.placeMapOnRightInLandscape && scrubberInfo.xFraction > 1 {
            scrubberInfo.xFraction = -1
        }
        
        xVertVals = [scrubberInfo.xFraction, scrubberInfo.xFraction]
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
                    if displayOnSide {
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Max: ")
                            Text("Min: ")
                            Text("Avg: ")
                            Text("Gain: ")
                        }
                        VStack(alignment: .trailing, spacing: 4) {
                            Text(track.altitudeMax.stringAsInt)
                            Text(track.altitudeMin.stringAsInt)
                            Text(track.altitudeAve.stringAsInt)
                            Text(track.altitudeGain.stringAsInt)
                        }
                    } else {
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Max: ")
                            Text("Min: ")
                        }
                        VStack(alignment: .trailing, spacing: 4) {
                            Text(track.altitudeMax.stringAsInt)
                            Text(track.altitudeMin.stringAsInt)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Avg: ")
                            Text("Gain: ")
                        }
                        VStack(alignment: .trailing, spacing: 4) {
                            Text(track.altitudeAve.stringAsInt)
                            Text(track.altitudeGain.stringAsInt)
                        }
                    }
                }
            }
            .padding(.top, displayOnSide ? 0 : 8)
            .padding(.bottom, 16)
            
            GeometryReader { geometry in
                ZStack {
                    if trackHelper.hasAltitudeData {
                        
                        // axis labels
                        VStack {
                            HStack {
                                ZStack {
                                    ForEach((0...trackHelper.yAxisNumGridLines), id: \.self) {
                                        let (text, offset) = trackHelper.gridLabelInfo(forIndex: $0, andPlotHeight: plotSize.height, deviceType: device.deviceType)
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
//                    LineShape(xVals: trackHelper.time, yVals: trackHelper.altitudePlotValsRaw)
//                        .stroke(Color.plotAltitudeRaw, lineWidth: 3)
                    
                    LineShape(xVals: trackHelper.time, yVals: trackHelper.altitudePlotVals)
                        .stroke(Color.plotAltitude, lineWidth: 2)
                    
                    // scrubber
                    LineShape(xVals: xVertVals, yVals: yVertVals)
                        .stroke(Color.plotVertical, lineWidth: 4)
                }
                .onTouch() { location in
                    plotSize = geometry.size
                    handleTouch(at: location)
                }
                .onAppear { plotSize = geometry.size }
            }
            .frame(height: 90)
            .padding(.bottom, device.hasSafeAreaInsets ? (displayOnSide ? 8 : (device.isPad ? 8 : 0)) : 16)
        }
        .font(device.isPhone ? .footnote.monospacedDigit() : .body.monospacedDigit())
        .foregroundColor(.text)
        .padding(.leading, device.trackPlotStatsLeadingSpace(displayOnSide: displayOnSide))
        .padding(.trailing, device.trackPlotStatsTrailingSpace(displayOnSide: displayOnSide))
        .onAppear {
//            print("=== \(file).onAppear - track: \(track.debugName) ===")
            trackHelper.setUp(for: track)
        }
        .onChange(of: scrubberInfo.xFraction) { xFraction in
            xVertVals = [xFraction, xFraction]
        }
        .onDisappear {
//            print("=== \(file).onDisappear - track: \(track.debugName) ===")
            trackHelper.cleanUp()
        }
    }
    
    // MARK: - Methods
    
    func handleTouch(at location: CGPoint) {
        //print("=== TrackPlotView.\(#function) - hasAltitudeData: \(trackHelper.hasAltitudeData), yAxisNumGridLines: \(trackHelper.yAxisNumGridLines), trackIsTrackingOnThisDevice: \(trackIsTrackingOnThisDevice) ===")
        
        guard trackHelper.hasAltitudeData,
              !trackIsTrackingOnThisDevice
        else { return }
        
        let xFraction = location.x / plotSize.width
        //print("=== TrackPlotView.\(#function) - locationX: \(location.x), plotSize.width: \(plotSize.width), xFraction: \(xFraction)")
        
        guard trackHelper.showData(at: xFraction, for: scrubberInfo) else { return }
        
//        xVertVals = [xFraction, xFraction]
    }
}

//struct TrackPlotView_Previews: PreviewProvider {
//    static var previews: some View {
//        TrackPlotView()
//    }
//}
