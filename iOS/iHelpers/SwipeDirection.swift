//
//  SwipeDirection.swift
//  ATracks (iOS)
//
//  Created by James Hager on 5/27/22.
//

import SwiftUI

enum SwipeDirection: String, CustomStringConvertible {
    case left
    case right
    case up
    case down
    case none
    
    var description: String { return rawValue }
    
    static func from(_ value: DragGesture.Value) -> SwipeDirection {
        let direction = atan2(value.translation.width, value.translation.height)
        
        let pi = Double.pi
        let pio4 = pi / 4
        let tpio4 = 3 * pi / 4
        
        switch direction {
        case (-pio4..<pio4):
            return .down
        case (pio4..<tpio4):
            return .right
        case (tpio4...pi), (-pi..<(-tpio4)):
            return .up
        case (-tpio4..<(-pio4)):
            return .left
        default:
            return .none
        }
    }
}
