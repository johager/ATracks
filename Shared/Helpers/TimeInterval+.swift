//
//  TimeInterval+.swift
//  ATracks
//
//  Created by James Hager on 4/18/22.
//

import Foundation

extension TimeInterval {
    
    var stringWithHrMin: String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.zeroFormattingBehavior = .pad
        formatter.allowedUnits = [.hour, .minute]
        
        let string = formatter.string(from: self)
        guard let string = string else { return "NA" }
        return string
    }
}
