//
//  TimeInterval+.swift
//  ATracks
//
//  Created by James Hager on 4/18/22.
//

import Foundation

extension TimeInterval {
    
    var stringWithUnits: String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.zeroFormattingBehavior = .pad
        
        if self < 600 {
            formatter.allowedUnits = [.minute, .second]
        } else {
            formatter.allowedUnits = [.hour, .minute]
        }
        
        let string = formatter.string(from: self)
        guard let string else { return "NA" }
        return string
    }
}
