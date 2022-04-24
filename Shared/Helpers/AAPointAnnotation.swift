//
//  AAPointAnnotation.swift
//  ATracks
//
//  Created by James Hager on 4/20/22.
//

#if os(iOS)
    import UIKit
#elseif os(macOS)
    import Cocoa
#endif

import MapKit

class AAPointAnnotation: MKPointAnnotation {
    
    var imageNameBase: String!
    var imageOffsetY: CGFloat!
    
    // MARK: - Init
    
    convenience init(coordinate: CLLocationCoordinate2D, imageNameBase: String, imageOffsetY: CGFloat = 0) {
        self.init()
        self.coordinate = coordinate
        self.imageNameBase = imageNameBase
        self.imageOffsetY = imageOffsetY
    }
    
    // MARK: - Methods
    
    #if os(iOS)
        func image(mapType: MKMapType, isDark: Bool) -> UIImage? {
            return UIImage(named: imageName(mapType: mapType, isDark: isDark))
        }
    
    #elseif os(macOS)
        func image(mapType: MKMapType, isDark: Bool) -> NSImage? {
            return NSImage(named: imageName(mapType: mapType, isDark: isDark))
        }
    #endif
    
    func imageName(mapType: MKMapType, isDark: Bool) -> String {
        
        let type: String
        if isDark {
            type = "Sat"
        } else {
            if mapType == .standard {
                type = "Std"
            } else {
                type = "Sat"
            }
        }
        
        return imageNameBase + type
    }
}
