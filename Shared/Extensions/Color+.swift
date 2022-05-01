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
        return color(light: medium2Green, dark: dark2Green)
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
    
    static var listRowSelectedBackground: Color {
        return color(light: light2Green, dark: Color(white: 0.11))
    }
    
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
        let darkColor = Color(red: 0.75, green: 0, blue: 0)
        return color(light: lightColor, dark: darkColor)
    }
    
    // MARK: - Track Point Callout Colors
    
    static var trackPointCalloutText: Color {
        return color(light: .text, dark: .white)
    }
    
    static var trackPointCalloutBackground: Color {
        return color(light: Color(white: 1.0), dark: Color(white: 0.10))
    }
    
    static var trackPointCalloutBorder: Color {
        return color(light: Color(white: 0.60), dark: Color(white: 0.70))
    }
    
    // MARK: - Plot Colors
    
    static var plotAxis: Color {
        return color(light: Color(white: 0.10), dark: Color(white: 0.75))
    }
    
    static var plotAltitude: Color {
        return color(light: Color(white: 0.30), dark: Color(white: 0.70))
    }
    
    static var plotGrid: Color {
        return color(light: Color(white: 0.77), dark: Color(white: 0.23))
    }
    
//    static var plotSpeed: Color {
//        let lightColor = Color(red: 0.9, green: 0, blue: 0)
//        let darkColor = Color(red: 0.85, green: 0, blue: 0)
//        return color(light: lightColor, dark: darkColor)
//    }
    
    static var plotVertical: Color {
        let lightColor = Color(white: 0.0, opacity: 0.3)
        let darkColor = Color(white: 1.0, opacity: 0.3)
        return color(light: lightColor, dark: darkColor)
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
