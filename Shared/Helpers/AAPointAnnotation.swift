//
//  AAPointAnnotation.swift
//  ATracks
//
//  Created by James Hager on 4/20/22.
//

import SwiftUI
#if os(iOS)
    import UIKit
#elseif os(macOS)
    import Cocoa
#endif

import MapKit

class AAPointAnnotation: MKPointAnnotation {
    
    var imageNameBase: String!
    var imageNameBackgroundBase: String?
    var forStart = true
    var imageOffsetY: CGFloat!
    
    // MARK: - Init
    
    convenience init(coordinate: CLLocationCoordinate2D, imageNameBase: String, imageOffsetY: CGFloat = 0) {
        self.init()
        self.coordinate = coordinate
        self.imageNameBase = imageNameBase
        self.imageOffsetY = imageOffsetY
    }
    
    convenience init(coordinate: CLLocationCoordinate2D, imageNameBase: String, imageNameBackgroundBase: String, forStart: Bool, imageOffsetY: CGFloat = 0) {
        self.init()
        self.coordinate = coordinate
        self.imageNameBase = imageNameBase
        self.imageNameBackgroundBase = imageNameBackgroundBase
        self.forStart = forStart
        self.imageOffsetY = imageOffsetY
    }
    
    // MARK: - Methods
    
    #if os(iOS)
    func image(forMapType mapType: MKMapType) -> UIImage? {
        guard let topImage = UIImage(named: imageNameBase)?.colored(UIColor(mainColor(forMapType: mapType)))
        else { return nil }
        
        guard let imageNameBackgroundBase = imageNameBackgroundBase,
              let backgroundImage = UIImage(named: imageNameBackgroundBase)?.colored(UIColor(backgroundColor(forMapType: mapType)))
        else { return topImage }

        return backgroundImage.overlay(topImage)
    }
    
    #elseif os(macOS)
    func image(forMapType mapType: MKMapType) -> NSImage? {
        guard let topImage = NSImage(named: imageNameBase)?.colored(NSColor(mainColor(forMapType: mapType)))
        else { return nil }
        
        guard let imageNameBackgroundBase = imageNameBackgroundBase,
              let backgroundImage = NSImage(named: imageNameBackgroundBase)?.colored(NSColor(backgroundColor(forMapType: mapType)))
        else { return topImage }
        
        return backgroundImage.overlay(topImage)
    }
    #endif
    
    func backgroundColor(forMapType mapType: MKMapType) -> Color {
        
        if forStart {
            return mapType == .standard ? .markerStartFill : .markerStartFillSat
        } else {
            return mapType == .standard ? .markerEndFill : .markerEndFillSat
        }
    }
    
    func mainColor(forMapType mapType: MKMapType) -> Color {
        
        if forStart {
            return mapType == .standard ? .markerStartShape : .markerStartShapeSat
        } else {
            return mapType == .standard ? .markerEndShape : .markerEndShapeSat
        }
    }
}
