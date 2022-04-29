//
//  HealthKitDateOptions.swift
//  ATracks (iOS)
//
//  Created by James Hager on 4/28/22.
//

import Foundation
import HealthKit

enum HealthKitDateOptions {
    
    case none
    case start
    case startAndStop
    
    var queryOptions: HKQueryOptions {
        switch self {
        case .none:
            return []
        case .start:
            return .strictStartDate
        case .startAndStop:
            return [.strictStartDate, .strictEndDate]
        }
    }
}
