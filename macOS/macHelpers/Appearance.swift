//
//  Appearance.swift
//  ATracks (macOS)
//
//  Created by James Hager on 4/19/22.
//

import SwiftUI
import Cocoa

enum Appearance {
    
    static var isDark: Bool {
        NSAppearance.currentDrawing().bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
    }
    
    static let file = "Appearance"
    
    // MARK: - Methods
    
    static func customizeAppearance() {
        print("=== \(file).\(#function) ===")
    }
}
