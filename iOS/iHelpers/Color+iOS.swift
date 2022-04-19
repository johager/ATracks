//
//  Color+iOS.swift
//  ATracks (iOS)
//
//  Created by James Hager on 4/19/22.
//

import SwiftUI
import UIKit

extension Color {
    
    // MARK: - Select Light/Dark Mode color
    
    static func color(light lightColor: Color, dark darkColor: Color) -> Color {
        let uiColor = UIColor { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                return UIColor(darkColor)
            } else {
                return UIColor(lightColor)
            }
        }
        return Color(uiColor)
    }
}
