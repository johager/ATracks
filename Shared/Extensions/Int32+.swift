//
//  Int32+.swift
//  ATracks
//
//  Created by James Hager on 4/21/22.
//

import Foundation

extension Int32 {
    
    var stringWithNA: String {
        if self == 0 {
            return "NA"
        } else {
            return "\(self)"
        }
    }
}
