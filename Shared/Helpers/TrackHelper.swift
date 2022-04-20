//
//  TrackHelper.swift
//  ATracks
//
//  Created by James Hager on 4/20/22.
//

import Foundation

class TrackHelper {
    
    var xVals = [Double]()
    var elevations = [Double]()
//    var speeds = [Double]()
    
    var minElevation: Double = 0
    var maxElevation: Double = 0
    
//    var minSpeed: Double = 0
//    var maxSpeed: Double = 0
    
    // MARK: - Init
    
    init(track: Track) {
        setPlotVals(for: track)
    }
    
    // MARK: - Methods
    
    func setPlotVals(for track: Track) {
        let trackPoints = track.trackPoints
        
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
}
