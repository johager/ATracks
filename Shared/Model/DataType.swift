//
//  DataType.swift
//  ATracks
//
//  Created by James Hager on 4/18/22.
//

import Foundation

enum DataType: String, CustomStringConvertible {
    
    case track = "Track"
    case trackPoint = "TrackPoint"
    
    var description: String { rawValue }
    
    var entityName: String { rawValue }
}
