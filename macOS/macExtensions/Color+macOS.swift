//
//  Color+macOS.swift
//  ATracks (iOS)
//
//  Created by James Hager on 4/19/22.
//

import SwiftUI
import Cocoa

extension Color {
    
    // MARK: - Select Light/Dark Mode color
    
    static func color(light lightColor: Color, dark darkColor: Color) -> Color {
        if Device.shared.colorSchemeIsDark {
            return darkColor
        } else {
            return lightColor
        }
    }
}
