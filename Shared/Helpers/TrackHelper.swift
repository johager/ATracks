//
//  TrackHelper.swift
//  ATracks
//
//  Created by James Hager on 4/20/22.
//

import Foundation
import Combine
import CoreGraphics
import CoreLocation

class TrackHelper: NSObject, ObservableObject {
    
    var track: Track!
    
    var time = [Double]()
    var altitudes = [Double]()
    
    var altitudePlotVals = [Double]()  // for axis 0 to 1
    
//    var altitudesRaw = [Double]()
//    var altitudePlotValsRaw = [Double]()  // for axis 0 to 1
    
    var altitudeMin: Double = 0
    var altitudeMax: Double = 0
    var altitudeAve: Double = 0
    var altitudeGain: Double = 0

    var axisXVals: [Double] { [0, 0, 1] }
    var axisYVals: [Double] { [1, 0, 0] }
    
    var yAxisMin: Double!
    var yAxisMax: Double!
    var yAxisDelta: Double!
    var yAxisScale: Double!
    var yAxisNumGridLines: Int16 = 0 {
        didSet {
            //print("=== \(file).\(#function) didSet \(yAxisNumGridLines) ===")
            hasAltitudeData = yAxisNumGridLines > 0
        }
    }
    
    @Published var hasAltitudeData = false
    
    private var trackPoints: [TrackPoint]!
    
//    private let uuidString = UUID().uuidString
    
    lazy var file = Func.sourceFileNameFromFullPath(#file)
    
    // MARK: - Static Properties
    
    static let timeKey = "time"
    static let altitudesKey = "altitudes"
//    static let altitudesRawKey = "altitudesRaw"
    
    // MARK: - Init
    
    override init() {
        super.init()
//        print("=== \(file).\(#function) - uuidString: \(uuidString) ===")
    }
    
    init(track: Track, shouldSetPlotVals: Bool = false) {
        super.init()
//        print("=== \(file).\(#function) - track: \(track.debugName), uuidString: \(uuidString) ===")
        self.track = track
        
        guard track.altitudeIsValid else { return }
        
        setAltitudeData()
        
        guard shouldSetPlotVals else { return }
        
        setPlotVals()
    }
    
//    deinit {
//        print("=== \(file).\(#function) - track: \(track.debugName) ===")
//        print("=== \(file).\(#function) - uuidString: \(uuidString) ===")
//        #if os(iOS)
//        NotificationCenter.default.removeObserver(self)
//        #endif
//    }
    
    // MARK: - Set Up Methods
    
    func setUp(for track: Track) {
//        print("=== \(file).\(#function) - track: \(track.debugName), uuidString: \(uuidString) ===")
        
        guard track.altitudeIsValid else { return }

        if self.track != nil && track.id == self.track.id {
            return
        }
        
        self.track = track
        
        setAltitudeData()
        
        setPlotVals()
        
        #if os(iOS)
        if TrackHelper.trackIsTrackingOnThisDevice(track) {
            NotificationCenter.default.addObserver(self,
                selector: #selector(handleAltitudeChanged(_:)),
                name: Notification.Name.altitudeChanged(for: track), object: nil)
        }
        #endif
    }
    
    func cleanUp() {
//        print("=== \(file).\(#function) - uuidString: \(uuidString) ===")
        #if os(iOS)
        NotificationCenter.default.removeObserver(self)
        #endif
    }
    
    // MARK: - Altitude Methods
    
    func setAltitudeData() {
        
        let nLowPass = 2
        let nKalman = 3
        
        trackPoints = track.trackPoints
        
        guard trackPoints.count > 2 else { return }
        
        // raw values
        
        var altRaw = [Double]()
        for trackPoint in trackPoints {
            time.append(trackPoint.timestamp.timeIntervalSince(trackPoints[0].timestamp))
            altRaw.append(trackPoint.altitude * 3.28084)  // convert meters to feet
        }

//        altitudesRaw = altRaw
        
        // smooth values
        
        altitudes = smoothed(altRaw, nLowPass: nLowPass, nKalman: nKalman)
        
        // summary values
        
        altitudeMin = altitudes.min()!
        altitudeMax = altitudes.max()!
        
        altitudeAve = 0
        altitudeGain = 0
        
        for i in 1..<altitudes.count {
            let dt = trackPoints[i].timestamp.timeIntervalSince(trackPoints[i - 1].timestamp)
            altitudeAve += (altitudes[i] + altitudes[i - 1]) / 2 * dt
            let dAltitude = altitudes[i] - altitudes[i - 1]
            if dAltitude > 0 {
                altitudeGain += dAltitude
            }
        }
        
        altitudeAve /= trackPoints[trackPoints.count - 1].timestamp.timeIntervalSince(trackPoints[0].timestamp)
        
//        let minString = altitudeMin.stringWithFourDecimals
//        let maxString = altitudeMax.stringWithFourDecimals
//        let aveString = altitudeAve.stringWithFourDecimals
//        let gainString = altitudeGain.stringWithFourDecimals
//        print("=== \(file).\(#function) - altitude min / max: \(minString) / \(maxString), ave: \(aveString), gain: \(gainString) ===")
    }
    
    func smoothed(_ x: [Double], nLowPass: Int, nKalman: Int) -> [Double] {
        
        // low-pass settings
        let alpha1: Double = 0.75
        let alpha2: Double = 0.25
        
        // Kalman setttings
        let accuracy: Double = 10
        let decay: Double = 3
        
        let sigmaSquared: Double = accuracy * accuracy
        
        var xSmoothed = x
        
        for _ in 0..<nLowPass {
            xSmoothed = lowPassSmoothedForward(xSmoothed, alpha: alpha1)
            xSmoothed = lowPassSmoothedBackward(xSmoothed, alpha: alpha1)
        }
        
        for _ in 0..<nKalman {
            xSmoothed = kalmanSmoothedForward(xSmoothed, sigmaSquared: sigmaSquared, decay: decay)
            xSmoothed = kalmanSmoothedBackward(xSmoothed, sigmaSquared: sigmaSquared, decay: decay)
        }

        for _ in 0..<nLowPass {
            xSmoothed = lowPassSmoothedForward(xSmoothed, alpha: alpha2)
            xSmoothed = lowPassSmoothedBackward(xSmoothed, alpha: alpha2)
        }
        
        return xSmoothed
    }
    
    func lowPassSmoothedForward(_ x: [Double], alpha: Double) -> [Double] {
        // low-pass filter (forward in i)
        
        var xSmoothed = [x[0]]
        
        for i in 1..<x.count {
            xSmoothed.append(xSmoothed[i - 1] + alpha * (x[i] - xSmoothed[i - 1]))
        }
        
        return xSmoothed
    }
    
    func lowPassSmoothedBackward(_ x: [Double], alpha: Double) -> [Double] {
        // low-pass filter (backward in i)
        
        var xSmoothed = x
        
        for i in (0..<x.count - 1).reversed() {
            xSmoothed[i] = xSmoothed[i + 1] + alpha * (x[i] - xSmoothed[i + 1])
        }
        
        return xSmoothed
    }
    
    func kalmanSmoothedForward(_ x: [Double], sigmaSquared: Double, decay: Double) -> [Double] {
        // Kalman filter (forward in i)
        
        var xSmoothed = [x[0]]
        
        var variance = sigmaSquared
        
        for i in 1..<x.count {
            variance += (time[i] - time[i - 1]) * decay
            let gain = variance / (variance + sigmaSquared)
            xSmoothed.append(x[i - 1] + gain * (x[i] - x[i - 1]))
            variance *= 1 - gain
        }
        
        return xSmoothed
    }
    
    func kalmanSmoothedBackward(_ x: [Double], sigmaSquared: Double, decay: Double) -> [Double] {
        // Kalman filter (backward in i)
        
        var xSmoothed = x
        
        var variance = sigmaSquared
        
        for i in (0..<x.count - 1).reversed() {
            variance += (time[i + 1] - time[i]) * decay
            let gain = variance / (variance + sigmaSquared)
            xSmoothed[i] = x[i + 1] + gain * (x[i] - x[i + 1])
            variance *= 1 - gain
        }
        
        return xSmoothed
    }
    
    #if os(iOS)
    @objc func handleAltitudeChanged(_ notification: NSNotification) {
        //print("=== \(file).\(#function) ===")
        
        guard
            let userInfo = notification.userInfo as? Dictionary<String,Any>,
            let time = userInfo[TrackHelper.timeKey] as? [Double],
            let altitudes = userInfo[TrackHelper.altitudesKey] as? [Double]
//            let altitudesRaw = userInfo[TrackHelper.altitudesRawKey] as? [Double]
        else {
            //print("=== \(file).\(#function) - bad userInfo, uuidString: \(uuidString) ===")
            return
        }
        
        //print("--- \(file).\(#function) - altitudes.count: \(altitudes.count)")
        //print("=== \(file).\(#function) - altitudes.count: \(altitudes.count), uuidString: \(uuidString) ===")
        
        self.time = time
        self.altitudes = altitudes
//        self.altitudesRaw = altitudesRaw
        
        trackPoints = track.trackPoints
        
        setPlotVals()
    }
    #endif
    
    // MARK: - Plot Methods
    
    func setPlotVals() {
        
        guard altitudes.count > 1 else { return }
        
        setGridVals(for: altitudes)
        
        var altitudePlotVals = [Double]()
        
        for altitude in altitudes {
            altitudePlotVals.append(yFor(altitude))
        }
        
        self.altitudePlotVals = altitudePlotVals
        
//        var altitudePlotValsRaw = [Double]()
//        for altitudeRaw in altitudesRaw {
//            altitudePlotValsRaw.append(yFor(altitudeRaw))
//        }
//        self.altitudePlotValsRaw = altitudePlotValsRaw
    }
    
    func yFor(_ yVal: Double) -> Double {
        return (yVal - yAxisMin) * yAxisScale
    }
    
    // MARK: - Plot Axis Methods
    
    func setGridVals(for yVals: [Double]) {
        let yMin = yVals.min()!
        let yMax = yVals.max()!
        
        //print("=== \(file).\(#function) - yMin: \(yMin), yMax: \(yMax), delY: \(yMax - yMin) ===")

        setGridValsFor(minVal: yMin, maxVal: yMax)
        
        //print("--- \(file).\(#function) - yMin: \(yMin), yMax: \(yMax) | min: \(yAxisMin!), max: \(yAxisMax!), delta: \(yAxisDelta!), numGridLines: \(yAxisNumGridLines)")
        
        if yAxisNumGridLines > 5 {
            setGridValsFor(minVal: yAxisMin, maxVal: yAxisMax)
            
            //print("--- \(file).\(#function) - yMin: \(yMin), yMax: \(yMax) | min: \(yAxisMin!), max: \(yAxisMax!), delta: \(yAxisDelta!), numGridLines: \(yAxisNumGridLines)")
        }
    }
    
    func setGridValsFor(minVal: Double, maxVal: Double) {
        
        var minAxis = minVal
        var maxAxis = maxVal
        
        let delta = deltaFor(minAxis: minAxis, maxAxis: maxAxis)
        adjustMinMaxAxis(minAxis: &minAxis, maxAxis: &maxAxis, delta: delta)
        
        yAxisMin = minAxis
        yAxisMax = maxAxis
        yAxisDelta = delta
        yAxisScale = 1 / (yAxisMax - yAxisMin)
        yAxisNumGridLines = Int16((maxAxis - minAxis) / delta)
    }
    
    func deltaFor(minAxis: Double, maxAxis: Double) -> Double {
        
        var delta = (maxAxis - minAxis) / 4
        
        //let delVal = maxAxis - minAxis
        //let deltaTop = delta
        
        if delta > 5000 {
            delta = 10000
            
        } else if delta > 3000 {
            delta = 5000
        } else if delta > 2100 {
            delta = 2500
        } else if delta > 1300 {
            delta = 2000
        } else if delta > 500 {
            delta = 1000
            
        } else if delta > 300 {
            delta = 500
        } else if delta > 210 {
            delta = 250
        } else if delta > 130 {
            delta = 200
        } else if delta > 50 {
            delta = 100
            
        } else if delta > 30 {
            delta = 50
        } else if delta > 21 {
            delta = 25
        } else if delta > 13 {
            delta = 20
        } else if delta > 5 {
            delta = 10
            
        } else if delta > 3 {
            delta = 5
        } else if delta > 2.1 {
            delta = 3
        } else if delta > 1.3 {
            delta = 2
            
        } else {
            delta = 1
        }
        
        //print("--- \(file).\(#function) - minAxis: \(minAxis), maxAxis: \(maxAxis), delVal: \(delVal) | delta top/bot: \(deltaTop) / \(delta)")
        
        return delta
    }

    func adjustMinMaxAxis(minAxis: inout Double, maxAxis: inout Double, delta: Double) {
        
        if minAxis == maxAxis {
            minAxis -= delta
            maxAxis += delta
            return
        }
        
        var remainder = minAxis.remainder(dividingBy: delta)
        if remainder > 0 {
            minAxis -= remainder
        } else if remainder < 0 {
            minAxis -= delta + remainder
        }
        
        remainder = maxAxis.remainder(dividingBy: delta)
        if remainder > 0 {
            maxAxis += delta - remainder
        } else if remainder < 0 {
            maxAxis -= remainder
        }
    }
    
    func gridValues(forIndex index: Int16) -> (xVals: [Double], yVals: [Double]) {
        
        let yVal = yFor(gridY(for: index))
        
        let xVals: [Double] = [0, 1]
        let yVals = [yVal, yVal]
        
        //print("=== \(file).\(#function) - yVal: \(yVal) ===")
        
        return (xVals, yVals)
    }
    
    func gridLabelInfo(forIndex index: Int16, andPlotHeight plotHeight: CGFloat, deviceType: DeviceType) -> (text: String, offset: CGPoint) {
        
        let y = gridY(for: index)
        let yVal = yFor(y)
        
        let text = y.stringAsInt
        
        let dy: CGFloat
        if deviceType == .pad {
            dy = 20.5
        } else {
            dy = 17
        }
        let offset = CGPoint(x: 6, y: plotHeight * (1 - yVal) - dy)
        
        //print("=== \(file).\(#function) - yVal: \(yVal), text: \(text), offset: \(offset) ===")
        
        return (text, offset)
    }
    
    func gridY(for index: Int16) -> Double {
        return yAxisMin + yAxisDelta * Double(index)
    }
    
    // MARK: - Location Methods
    
    func showData(at xFraction: CGFloat, for scrubberInfo: ScrubberInfo) -> Bool {
        
        guard time.count > 1 else { return false }
        
        //print("=== \(file).\(#function) - xFraction: \(xFraction) ===")
        let xRange = time.last! - time[0]
        //print("--- \(file).\(#function) - xRange: \(xRange)")
        let x = xRange * xFraction
        //print("--- \(file).\(#function) - x: \(x)")
        
        guard let index = time.firstIndex(where: { $0 > x }) else { return false }
        
        //print("--- \(file).\(#function) - index: \(index)")
        
        let clLocationCoordinate2D = trackPoints[index].clLocationCoordinate2D
        
        var calloutLabelString = clLocationCoordinate2D.stringWithThreeDecimals
        
        if track.altitudeIsValid {
            calloutLabelString += "\n\(altitudes[index].stringAsInt) ft"
        }
        
        scrubberInfo.xFraction = xFraction
        scrubberInfo.trackPointCLLocationCoordinate2D = clLocationCoordinate2D
        scrubberInfo.trackPointCalloutLabelString = calloutLabelString
        
        return true
    }
    
    // MARK: - Static Methods
    
    static func trackIsTrackingOnThisDevice(_ track: Track) -> Bool {
        return track.isTracking && track.deviceUUID == TrackManager.shared.deviceUUID
    }
}
