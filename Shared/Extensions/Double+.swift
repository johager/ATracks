//
//  Double+.swift
//  ATracks
//
//  Created by James Hager on 4/20/22.
//

import Foundation

extension Double {
    
    var stringAsInt: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(for: self)!
    }
    
    var stringForSpeed: String {
        if self > 10 {
            return String(format: "%.0f", self)
        } else {
            return String(format: "%.1f", self)
        }
    }
    
    var stringWithFourDecimals: String { String(format: "%.4f", self) }
}
