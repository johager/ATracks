//
//  Color+.swift
//  ATracks (macOS)
//
//  Created by James Hager on 4/19/22.
//

import SwiftUI
extension Color {
    
    static var background: Color {
        return color(light: .white, dark: .black)
    }
    
    static var border: Color {
        return color(light: medium2Green, dark: darkGreen)
    }
    
    static var headerBackground: Color {
        return color(light: light1HGreen, dark: dark3HGreen)
    }
    
    static var headerBorder: Color {
        return color(light: medium2Green, dark: dark3HGreen)
    }
    
    static var headerText: Color {
        return color(light: dark2Green, dark: lightGreen)
    }
    
    #if os(iOS)
    static var listBackground: Color {
        return background
    }
    #else
    static var listBackground: Color {
        return color(light: Color(white: 0.96), dark: Color(white: 0.22))
    }
    #endif
    
    #if os(iOS)
    static var listCoverForInactive: Color {
        let lightColor = Color(white: 0.9, opacity: 0.6)
        let darkColor = Color(white: 0.1, opacity: 0.6)
        return color(light: lightColor, dark: darkColor)
    }
    #endif
    
    #if os(iOS)
    static var listRowSelectedBackground: Color {
        return color(light: light1HGreen, dark: dark3HGreen)
    }
    #else
    static var listRowSelectedBackground: Color {
        return color(light: mediumGreen, dark: avantiGreen)
    }
    #endif
    
    #if os(iOS)
    static var listRowSelectedText: Color {
        return text
    }
    #else
    static var listRowSelectedText: Color {
//        return color(light: .white, dark: Color(white: 0.22))
//        return color(light: .white, dark: .black)
        return .white
    }
    #endif
    
    #if os(iOS)
    static var listRowSelectedTextSecondary: Color {
        return textSecondary
    }
    #else
    static var listRowSelectedTextSecondary: Color {
//        return color(light: light1HGreen, dark: Color(white: 0.22))
//        return color(light: light1HGreen, dark: Color(white: 0.2))
        return light1HGreen
    }
    #endif
    
    static var listRowSeparator: Color {
        return color(light: medium3Green, dark: darkGreen)
    }
    
    static var listRowSwipeDelete: Color {
        let lightColor = Color(red: 0.9, green: 0, blue: 0)
        let darkColor = Color(red: 0.75, green: 0, blue: 0)
        return color(light: lightColor, dark: darkColor)
    }
    
    static var listRowSwipeEdit: Color {
        return color(light: avantiOrange, dark: darkOrange)
    }
    
    static var listRowSwipeStart: Color {
        return color(light: mediumGreen, dark: darkGreen)
    }
    
    static var navigationShadow: Color {
        return color(light: avantiGreen, dark: dark2Green)
    }
    
    static var tabBarBackground: Color {
        return color(light: light2Green, dark: dark6Green)
    }
    
    static var text: Color {
        return color(light: .black, dark: Color(white: 0.9))
    }
    
    static var textInactive: Color {
        return color(light: Color(white: 0.3), dark: Color(white: 0.6))
    }
    
    static var textNoData: Color {
        return color(light: Color(white: 0.5), dark: Color(white: 0.6))
    }
    
    static var textSecondary: Color {
        return color(light: Color(white: 0.2), dark: Color(white: 0.8))
    }
    
    static var textSelectable: Color {
        return color(light: avantiGreen, dark: avantiOrange)
    }
    
    // MARK: - AAButtonStyle
    
    static var aaButtonBackgroundNormal: Color {
        return color(light: lightGreen, dark: dark2Green)
    }
    
    static var aaButtonBackgroundDisabled: Color {
        let darkColor = Color(white: 0.08)
        return color(light: lightGray, dark: darkColor)
    }
    
    static var aaButtonBackgroundHighlighted: Color {
        return color(light: lightishGreen, dark: avantiGreen)
    }
    
    static var aaButtonBorder: Color {
        return color(light: avantiGreen, dark: lightGreen)
    }
    
    static var aaButtonBorderDisabled: Color {
        let lightColor = Color(white: 0.75)
        let darkColor = Color(white: 0.3)
        return color(light: lightColor, dark: darkColor)
    }
    
    static var aaButtonText: Color {
        return color(light: avantiGreen, dark: lightGreen)
    }
    
    static var aaButtonTextDisabled: Color {
        let lightColor = Color(white: 0.65)
        let darkColor = Color(white: 0.35)
        return color(light: lightColor, dark: darkColor)
    }
    
    // MARK: - Toggle Colors
    
    static var toggleOn: Color {
        let lightColor = Color(red: 0.49, green: 0.63, blue: 0.60)
        return color(light: lightColor, dark: mediumGreen)
    }
    
    static var toggleThumb: Color {
        return color(light: .white, dark: lightishGreen)
    }
    
    // MARK: - Track Colors
    
    static var track: Color {
        let lightColor = Color(red: 0.9, green: 0, blue: 0)
        return colorStatic(light: lightColor, dark: avantiOrange)
    }
    
    static var trackSat: Color {
        return avantiOrange
    }
    
    static var markerEndFill: Color {
        return color(light: lightGreen, dark: Color(white: 0.65))
    }
    
    static var markerEndFillSat: Color {
        #if os(iOS)
        let lightColor = medium3Green
        #else
        let lightColor = medium2Green
        #endif
        return color(light: lightColor, dark: medium3Green)
    }
    
    static var markerEndShape: Color {
        let lightColor = Color(red: 0.9, green: 0, blue: 0)
        #if os(iOS)
        let darkColor = Color(red: 0.85, green: 0, blue: 0)
        #else
        let darkColor = Color(red: 0.8, green: 0, blue: 0)
        #endif
        return color(light: lightColor, dark: darkColor)
    }
    
    static var markerEndShapeSat: Color {
        return Color(red: 0.9, green: 0, blue: 0)
    }
    
    static var markerStartFill: Color {
        return color(light: lightGreen, dark: avantiGreen)
    }
    
    static var markerStartFillSat: Color {
        return avantiGreen
    }
    
    static var markerStartShape: Color {
        return colorStatic(light: avantiGreen, dark: medium2Green)
    }
    
    static var markerStartShapeSat: Color {
        return color(light: medium3Green, dark: medium3Green)
    }
    
    // MARK: - Track Point Callout Colors
    
    static var trackPointCalloutText: Color {
        return colorStatic(light: .text, dark: .white)
    }
    
    static var trackPointCalloutBackground: Color {
        return colorStatic(light: Color(white: 1.0), dark: Color(white: 0.10))
    }
    
    static var trackPointCalloutBorder: Color {
        return colorStatic(light: Color(white: 0.60), dark: Color(white: 0.70))
    }
    
    // MARK: - Plot Colors
    
    static var plotAxis: Color {
        return color(light: Color(white: 0.10), dark: Color(white: 0.75))
    }
    
    static var plotAltitude: Color {
        return color(light: Color(white: 0.30), dark: Color(white: 0.70))
    }
    
//    static var plotAltitudeRaw: Color {
//        return .red
//    }
    
    static var plotGrid: Color {
        return color(light: Color(white: 0.77), dark: Color(white: 0.23))
    }
    
    static var plotVertical: Color {
        let lightColor = Color(white: 0.0, opacity: 0.3)
        let darkColor = Color(white: 1.0, opacity: 0.3)
        return color(light: lightColor, dark: darkColor)
    }
    
    // MARK: - Static Color
    
    static func colorStatic(light lightColor: Color, dark darkColor: Color) -> Color {
        if Device.shared.colorSchemeIsDark {
            return darkColor
        } else {
            return lightColor
        }
    }
    
    // MARK: - Reference Colors
    
    static let avantiGreen = Color(red: 0, green: 84/255.0, blue: 73/255.0)
    static let darkGreen = Color(red: 0, green: 0.22, blue: 0.19)  // 35% black
    static let dark2Green = Color(red: 0, green: 0.18, blue: 0.16)  // 45% black
    static let dark3HGreen = Color(red: 0, green: 0.13, blue: 0.11)  // 60% black
    static let dark6Green = Color(red: 0, green: 0.05, blue: 0.04)  // 85% black
    static let mediumGreen = Color(red: 56/255.0, green: 119/255.0, blue: 109/255.0)  // approx 22% white
    static let medium2Green = Color(red: 128/255.0, green: 170/255.0, blue: 164/255.0)  // 50% white
    static let medium3Green = Color(red: 179/255.0, green: 204/255.0, blue: 201/255.0)  // 70% white
    static let lightishGreen = Color(red: 191/255.0, green: 212/255.0, blue: 209/255.0)  // 75% white
    static let lightGreen = Color(red: 215/255.0, green: 229/255.0, blue: 227/255.0)  // 84% white
    static let light1HGreen = Color(red: 230/255.0, green: 238/255.0, blue: 237/255.0)  // 90% white
    static let light2Green = Color(red: 242/255.0, green: 246/255.0, blue: 246/255.0)  // 95% white

    static let avantiOrange = Color(red: 230/255.0, green: 160/255.0, blue: 12/255.0)
    static let darkOrange = Color(red: 150/255.0, green: 104/255.0, blue: 9/255.0)  // 35% black
    
    static let lightGray = Color(white: 245/255.0)
}
