//
//  TrackPlotView.swift
//  ATracks
//
//  Created by James Hager on 4/20/22.
//

import SwiftUI

struct TrackPlotView: View {
    
    @ObservedObject private var track: Track
    @ObservedObject private var device: Device
    private var displayOnSide: Bool
    private var deviceType: DeviceType
    
    private var trackIsTrackingOnThisDevice: Bool { TrackHelper.trackIsTrackingOnThisDevice(track) }
    
    @State private var plotSize = CGSize(width: 100, height: 100)
    @State private var xVertVals: [Double] = [2, 2]
    private var yVertVals: [Double] = [0, 1]
    
    private var trackHelper: TrackHelper
    
    private var isPad: Bool { deviceType == .pad }
    private var isPhone: Bool { deviceType == .phone }
    private var placeMapOnRightInLandscape: Bool { DisplaySettings.shared.placeMapOnRightInLandscape }
    
    private var leadingSpace: CGFloat {
        if displayOnSide {
            if device.hasSafeAreaInsets {
                return placeMapOnRightInLandscape ? 8 : 16
            } else {
                return 16
            }
        } else {
            return 32
        }
    }

    private var trailingSpace: CGFloat {
        if displayOnSide {
            if device.hasSafeAreaInsets {
                return placeMapOnRightInLandscape ? 16 : 8
            } else {
                return 16
            }
        } else {
            return 32
        }
    }
    
    // MARK: - Init
    
    init(track: Track, device: Device, displayOnSide: Bool = false) {
        self.track = track
        self.device = device
        self.displayOnSide = displayOnSide
        self.deviceType = DeviceType.current()
        self.trackHelper = TrackHelper(track: track, forPlotting: true)
        
        if displayOnSide && placeMapOnRightInLandscape {
            xVertVals = [-1, -1]
        }
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
                                        let (text, offset) = trackHelper.gridLabelInfo(forIndex: $0, andPlotHeight: plotSize.height, deviceType: deviceType)
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
                .onTouch() { location in
                    plotSize = geometry.size
                    handleTouch(at: location)
                }
                .onAppear { plotSize = geometry.size }
            }
            .frame(height: 90)
            .padding(.bottom, device.hasSafeAreaInsets ? (displayOnSide ? 8 : (isPad ? 8 : 0)) : 16)
        }
        .font(isPhone ? .footnote.monospacedDigit() : .body.monospacedDigit())
        .foregroundColor(.text)
        .padding(.leading, leadingSpace)
        .padding(.trailing, trailingSpace)
    }
    
    // MARK: - Methods
    
    func handleTouch(at location: CGPoint) {
        //print("=== TrackPlotView.\(#function) - hasAltitudeData: \(trackHelper.hasAltitudeData), yAxisNumGridLines: \(trackHelper.yAxisNumGridLines), trackIsTrackingOnThisDevice: \(trackIsTrackingOnThisDevice) ===")
        
        guard trackHelper.hasAltitudeData,
              !trackIsTrackingOnThisDevice
        else { return }
        
        #if os(macOS)
        guard location.x > 0, location.y > 0, location.y < plotSize.height else { return }
        #endif
        
        let xFraction = location.x / plotSize.width
        //print("=== TrackPlotView.\(#function) - locationX: \(location.x), plotSize.width: \(plotSize.width), xFraction: \(xFraction)")
        
        guard trackHelper.showData(at: xFraction) else { return }
        
        xVertVals = [xFraction, xFraction]
    }
}

//struct TrackPlotView_Previews: PreviewProvider {
//    static var previews: some View {
//        TrackPlotView()
//    }
//}
