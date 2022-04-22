//
//  TrackHelper.swift
//  ATracks
//
//  Created by James Hager on 4/20/22.
//

import Foundation
import CoreGraphics
import CoreLocation

class TrackHelper {
    
    var track: Track!
    
    var xVals = [Double]()
    var elevations = [Double]()
//    var speeds = [Double]()
    
    var elevationPlotVals = [Double]()  // for axis 0 to 1
    
    var minElevation: Double = 0
    var maxElevation: Double = 0
    
//    var minSpeed: Double = 0
//    var maxSpeed: Double = 0

    var axisXVals: [Double] {
        return [0, 0, 1]
    }
    
    var axisYVals: [Double] {
        return [1, 0, 0]
    }
    
    var yAxisMin: Double!
    var yAxisMax: Double!
    var yAxisDelta: Double!
    var yAxisScale: Double!
    var yAxisNumGridLines: Int16!
    
    private var trackPoints: [TrackPoint]!
    
    // MARK: - Init
    
    init(track: Track) {
        self.track = track
        self.trackPoints = track.trackPoints
        setPlotVals()
    }
    
    // MARK: - Plot Methods
    
    func setPlotVals() {
        
        let nSmooth = 21
        
        guard trackPoints.count > nSmooth else { return }
        
        // raw values
        
        var e = [Double]()
//        var s = [Double]()
        for i in 0..<trackPoints.count {
            xVals.append(trackPoints[i].timestamp.timeIntervalSince(trackPoints[0].timestamp))
            e.append(trackPoints[i].altitude * 3.28084)
//            s.append(trackPoints[i].speed * 2.23694)
        }

        // smooth values
        
        elevations = smoothed(e, nSmooth: nSmooth)
//        speeds = smoothed(s, nSmooth: nSmooth)
        
        minElevation = elevations.min()!
        maxElevation = elevations.max()!
        
//        minSpeed = speeds.min()!
//        maxSpeed = speeds.max()!
        
//        print("\(#function) - minElevation / maxElevation: \(minElevation) / \(maxElevation)")
//        print("\(#function) - minSpeed / maxSpeed: \(minSpeed) / \(maxSpeed)")
        
        setGridVals(for: elevations)
        
        for elevation in elevations {
            elevationPlotVals.append(yFor(elevation))
        }
    }
    
    func smoothed(_ x: [Double], nSmooth: Int) -> [Double] {
        let nOffset = (nSmooth - 1) / 2
        
        var xSmoothed = [Double]()
        
        for _ in 0..<nOffset {
            xSmoothed.append(0)
        }

        for i in nOffset..<(x.count - nOffset) {
            xSmoothed.append(smoothed(x, at: i, nSmooth: nSmooth))
        }

        setEnds(&xSmoothed, nOffset: nOffset)
        
        return xSmoothed
    }
    
    func smoothed(_ x: [Double], at i: Int, nSmooth: Int) -> Double {
        let nOffset = (nSmooth - 1) / 2
        var sum: Double = 0
        for iOffset in -nOffset...nOffset {
            sum += x[i + iOffset]
        }
        return sum / Double(nSmooth)
    }
    
    func setEnds(_ x: inout [Double], nOffset: Int) {
        for i in 0..<nOffset {
            x[i] = x[nOffset]
            x.append(x.last!)
        }
    }
    
    func yFor(_ yVal: Double) -> Double {
        return (yVal - yAxisMin) * yAxisScale
    }
    
    // MARK: - Plot Axis Methods
    
    func setGridVals(for yVals: [Double]) {
        let yMin = yVals.min()!
        let yMax = yVals.max()!
        let (min, max, delta) = axisValues(minVal: yMin, maxVal: yMax)
        
        yAxisMin = min
        yAxisMax = max
        yAxisDelta = delta
        yAxisScale = 1 / (yAxisMax - yAxisMin)
        yAxisNumGridLines = Int16((max - min) / delta)
        
        print("\(#function) - yMin: \(yMin), yMax: \(yMax) | min: \(min), max: \(max), delta: \(delta), numGridLines: \(yAxisNumGridLines!)")
    }
    
    func axisValues(minVal: Double, maxVal: Double, axisMax: Double? = nil) -> (min: Double, max: Double, delta: Double) {
        
        var minAxis = minVal
        var maxAxis = maxVal
        
        if let axisMax = axisMax {
            maxAxis = max(maxAxis, axisMax)
        }
        
        var delta = (maxAxis - minAxis) / 5
        
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
        } else if delta > 1.3 {
            delta = 2
        } else if delta > 0.5 {
            delta = 1
            
        } else {
            delta = 0.5
        }
        
        adjustMinMaxAxis(minAxis: &minAxis, maxAxis: &maxAxis, delta: delta)
        
        return (minAxis, maxAxis, delta)
    }

    func adjustMinMaxAxis(minAxis: inout Double, maxAxis: inout Double, delta: Double) {
        
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
        
        //print("\(#function) - yVal: \(yVal)")
        
        return (xVals, yVals)
    }
    
    func gridLabelInfo(forIndex index: Int16, andPlotHeight plotHeight: CGFloat) -> (text: String, offset: CGPoint) {
        
        let y = gridY(for: index)
        let yVal = yFor(y)
        
        let text = y.stringAsInt
        let offset = CGPoint(x: 6, y: plotHeight * (1 - yVal) - 16)
        
        //print("\(#function) - yVal: \(yVal), text: \(text), offset: \(offset)")
        
        return (text, offset)
    }
    
    func gridY(for index: Int16) -> Double {
        return yAxisMin + yAxisDelta * Double(index)
    }
    
    // MARK: - Location Methods
    
    func plotData(at xFraction: CGFloat) -> Double? {
        
        //print("\(#function) - xFraction: \(xFraction)")
        let xRange = xVals.last! - xVals[0]
        //print("\(#function) - xRange: \(xRange)")
        let x = xRange * xFraction
        //print("\(#function) - x: \(x)")
        
        guard let index = xVals.firstIndex(where: { $0 > x }) else { return nil }
        
        //print("\(#function) - index: \(index)")
        
        let userInfo = [Key.clLocationCoordinate2D: trackPoints[index].clLocationCoordinate2D]
        
        NotificationCenter.default.post(name: .moveTrackMarker, object: nil, userInfo: userInfo)
        
        return elevations[index]
    }
}
