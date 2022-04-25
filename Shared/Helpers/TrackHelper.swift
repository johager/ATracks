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
    
    var elevationPlotVals = [Double]()  // for axis 0 to 1
    
    var minElevation: Double = 0
    var maxElevation: Double = 0

    var axisXVals: [Double] { [0, 0, 1] }
    var axisYVals: [Double] { [1, 0, 0] }
    
    var yAxisMin: Double!
    var yAxisMax: Double!
    var yAxisDelta: Double!
    var yAxisScale: Double!
    var yAxisNumGridLines: Int16 = 0
    
    var hasElevationData: Bool { yAxisNumGridLines > 0 }
    
    private var trackPoints: [TrackPoint]!
    
    lazy var file = Func.sourceFileNameFromFullPath(#file)
    
    // MARK: - Init
    
    init(track: Track) {
        self.track = track
        self.trackPoints = track.trackPoints
        setPlotVals()
    }
    
    // MARK: - Plot Methods
    
    func setPlotVals() {
        
        let nSmoothPasses = 11
        let nSmoothRange = 7
        
        guard trackPoints.count > nSmoothRange else { return }
        
        // raw values
        
        var e = [Double]()
        for trackPoint in trackPoints {
            xVals.append(trackPoint.timestamp.timeIntervalSince(trackPoints[0].timestamp))
            e.append(trackPoint.altitude * 3.28084)
        }

        // smooth values
        
        elevations = smoothed(e, nSmoothPasses: nSmoothPasses, nSmoothRange: nSmoothRange)
        
        minElevation = elevations.min()!
        maxElevation = elevations.max()!
        
//        print("=== \(file).\(#function) - minElevation / maxElevation: \(minElevation) / \(maxElevation) ===")
        
        setGridVals(for: elevations)
        
        for elevation in elevations {
            elevationPlotVals.append(yFor(elevation))
        }
    }
    
    func smoothed(_ x: [Double], nSmoothPasses: Int, nSmoothRange: Int) -> [Double] {
        let nOffset = (nSmoothRange - 1) / 2
        
        var xInit = x
        var xSmoothed: [Double]!
        
        for _ in 0..<nSmoothPasses {
            xSmoothed = [Double]()
            
            for _ in 0..<nOffset {
                xSmoothed.append(0)
            }

            for i in nOffset..<(xInit.count - nOffset) {
                xSmoothed.append(smoothed(xInit, at: i, nSmoothRange: nSmoothRange))
            }

            setEnds(&xSmoothed, nOffset: nOffset)
            
            xInit = xSmoothed
        }
        
        return xSmoothed
    }
    
    func smoothed(_ x: [Double], at i: Int, nSmoothRange: Int) -> Double {
        let nOffset = (nSmoothRange - 1) / 2
        var sum: Double = 0
        for iOffset in -nOffset...nOffset {
            sum += x[i + iOffset]
        }
        return sum / Double(nSmoothRange)
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
        
        //print("=== \(file).\(#function) - yMin: \(yMin), yMax: \(yMax), delY: \(yMax - yMin) ===")

        setGridValsFor(minVal: yMin, maxVal: yMax)
        
        //print("--- \(file).\(#function) - yMin: \(yMin), yMax: \(yMax) | min: \(yAxisMin!), max: \(yAxisMax!), delta: \(yAxisDelta!), numGridLines: \(yAxisNumGridLines!)")
        
        if yAxisNumGridLines > 5 {
            setGridValsFor(minVal: yAxisMin, maxVal: yAxisMax)
            
            //print("--- \(file).\(#function) - yMin: \(yMin), yMax: \(yMax) | min: \(yAxisMin!), max: \(yAxisMax!), delta: \(yAxisDelta!), numGridLines: \(yAxisNumGridLines!)")
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
        } else if delta > 1.3 {
            delta = 2
        } else if delta > 0.5 {
            delta = 1
            
        } else {
            delta = 0.5
        }
        
        //print("--- \(file).\(#function) - minAxis: \(minAxis), maxAxis: \(maxAxis), delVal: \(delVal) | delta top/bot: \(deltaTop) / \(delta)")
        
        return delta
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
        
        //print("=== \(file).\(#function) - yVal: \(yVal) ===")
        
        return (xVals, yVals)
    }
    
    func gridLabelInfo(forIndex index: Int16, andPlotHeight plotHeight: CGFloat) -> (text: String, offset: CGPoint) {
        
        let y = gridY(for: index)
        let yVal = yFor(y)
        
        let text = y.stringAsInt
        let offset = CGPoint(x: 6, y: plotHeight * (1 - yVal) - 16)
        
        //print("=== \(file).\(#function) - yVal: \(yVal), text: \(text), offset: \(offset) ===")
        
        return (text, offset)
    }
    
    func gridY(for index: Int16) -> Double {
        return yAxisMin + yAxisDelta * Double(index)
    }
    
    // MARK: - Location Methods
    
    func showData(at xFraction: CGFloat) -> Double? {
        
        //print("=== \(file).\(#function) - xFraction: \(xFraction) ===")
        let xRange = xVals.last! - xVals[0]
        //print("--- \(file).\(#function) - xRange: \(xRange)")
        let x = xRange * xFraction
        //print("--- \(file).\(#function) - x: \(x)")
        
        guard let index = xVals.firstIndex(where: { $0 > x }) else { return nil }
        
        //print("--- \(file).\(#function) - index: \(index)")
        
        let userInfo = [Key.clLocationCoordinate2D: trackPoints[index].clLocationCoordinate2D]
        
        NotificationCenter.default.post(name: .showInfoForLocation, object: nil, userInfo: userInfo)
        
        return elevations[index]
    }
}
