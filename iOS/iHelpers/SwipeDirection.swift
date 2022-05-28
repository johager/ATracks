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
        let minDist: CGFloat = 24
        
        if value.startLocation.x < value.location.x - minDist {
            return .right
        }
        if value.startLocation.x > value.location.x + minDist {
            return .left
        }
        if value.startLocation.y < value.location.y - minDist {
            return .down
        }
        if value.startLocation.y > value.location.y + minDist {
            return .up
        }
        
        return .none
    }
}
