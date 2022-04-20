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
        
        guard xVals.count > 1 else { return Path() }
        
        let yOrigin = rect.height
        let yMin = yVals.min()!
        
//        print("\(#function) - xVals.count: \(xVals.count)")
//        print("\(#function) - rect: \(rect)")
        
        let xScale: CGFloat
        let yScale: CGFloat
        
        if xVals.count > 2 {
            xScale = rect.width / (xVals.last! - xVals[0])
            yScale = rect.height / (yVals.max()! - yMin)
        } else {
            xScale = rect.width
            yScale = rect.height
        }
        
//        print("\(#function) - xScale: \(xScale)")
//        print("\(#function) - yScale: \(yScale)")
        
        var path = Path()
        
        var x = xVals[0] * xScale
        var y = yOrigin - (yVals[0] - yMin) * yScale
        path.move(to: CGPoint(x: x, y: y))
        
        for i in 1..<xVals.count {
            x = xVals[i] * xScale
            y = yOrigin - (yVals[i] - yMin) * yScale
//            print("\(#function) - i: \(i), x: \(x), y: \(y)")
            path.addLine(to: CGPoint(x: xVals[i] * xScale, y: y))
        }
        
        return path
    }
}
