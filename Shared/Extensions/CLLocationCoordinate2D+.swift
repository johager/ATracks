//
//  CLLocationCoordinate2D+.swift
//  ATracks
//
//  Created by James Hager on 4/24/22.
//

import Foundation
import MapKit

extension CLLocationCoordinate2D {
    
    var stringWithThreeDecimals: String {
        let latString = self.latitude.stringWithFourDecimals
        let lonString = self.longitude.stringWithFourDecimals
        return "\(latString), \(lonString)"
    }
}
