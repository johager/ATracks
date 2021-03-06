//
//  Date+.swift
//  ATracks
//
//  Created by James Hager on 4/18/22.
//

import Foundation

extension Date {
    
    var stringForDebug: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd, HH:mm:ss"
        return dateFormatter.string(from: self)
    }
    
    var stringForTrackName: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd, h:mm a"
        return dateFormatter.string(from: self)
    }
    
    func stringForTrack(timezone: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd, h:mm a"
        dateFormatter.timeZone = TimeZone(abbreviation: timezone)
        return dateFormatter.string(from: self)
    }
    
    func stringForTrackName(timezone: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd, h:mm a"
        dateFormatter.timeZone = TimeZone(abbreviation: timezone)
        return dateFormatter.string(from: self)
    }
}
