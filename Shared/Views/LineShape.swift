//
//  LineShape.swift
//  ATracks (iOS)
//
//  Created by James Hager on 4/20/22.
//
//  Based on https://swdevnotes.com/swift/2021/create-a-line-chart-in-swiftui/
//

import SwiftUI

struct LineShape: Shape {
    
    var xVals: [Double]
    var yVals: [Double]
    
    func path(in rect: CGRect) -> Path {
        
        let yOrigin = rect.height
        let yMin = yVals.min()!
        
        print("\(#function) - xVals.count: \(xVals.count)")
        print("\(#function) - rect: \(rect)")
        let xScale = rect.width / (xVals.last! - xVals[0])
        let yScale = rect.height / (yVals.max()! - yMin)
        
        print("\(#function) - xScale: \(xScale)")
        print("\(#function) - yScale: \(yScale)")
        
        var path = Path()
        path.move(to: CGPoint(x: xVals[0], y: yVals[0] * yScale))
        
        for i in 0..<xVals.count {
            let x = xVals[i] * xScale
            let y = yOrigin - (yVals[i] - yMin) * yScale
            print("\(#function) - i: \(i), x: \(x), y: \(y)")
            path.addLine(to: CGPoint(x: xVals[i] * xScale, y: y))
        }
        
        return path
    }
    
//    func yFor(_ yVal: CGFloat) -> CGFloat {
//        return yOrigin - (yVal - min) * scale
//    }
}
