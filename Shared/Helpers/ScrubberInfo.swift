//
//  ScrubberInfo.swift
//  ATracks
//
//  Created by James Hager on 6/14/22.
//

import SwiftUI
import CoreLocation

class ScrubberInfo: ObservableObject {
    
    @Published var xFraction: CGFloat = 2
    @Published var trackPointCLLocationCoordinate2D: CLLocationCoordinate2D?
    @Published var trackPointCalloutLabelString: String?
}
