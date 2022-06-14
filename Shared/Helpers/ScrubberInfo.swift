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
    
    //lazy var file = Func.sourceFileNameFromFullPath(#file)
    
    #if os(iOS)
    private var trackID = ""
    
    func setUpFor(_ trackID: String) {
        if self.trackID == trackID {
            return
        }
        
        self.trackID = trackID
        xFraction = 2
        trackPointCLLocationCoordinate2D = nil
        trackPointCalloutLabelString = nil
    }
    #endif
}
