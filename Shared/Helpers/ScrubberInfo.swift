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
//    {
//        didSet {
//            #if os(iOS)
//            print("=== \(file).\(#function) didSet \(xFraction) - trackID: \(trackID) ===")
//            #else
//            print("=== \(file).\(#function) didSet \(xFraction) ===")
//            #endif
//        }
//    }
    @Published var trackPointCLLocationCoordinate2D: CLLocationCoordinate2D?
    @Published var trackPointCalloutLabelString: String?
    
    lazy var file = Func.sourceFileNameFromFullPath(#file)
    
    #if os(iOS)
    var trackID = ""
    
    func setUpFor(_ trackID: String) {
//        print("=== \(file).\(#function) - trackID: \(trackID) ===")
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
