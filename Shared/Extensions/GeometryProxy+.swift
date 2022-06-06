//
//  GeometryProxy+.swift
//  ATracks
//
//  Created by James Hager on 5/8/22.
//

import SwiftUI

extension GeometryProxy {
    
    var isLandscape: Bool { size.width > size.height }
    
    #if os(macOS)
    var horizontalSizeClassIsCompact: Bool { size.width < 510 }
    #endif
}
