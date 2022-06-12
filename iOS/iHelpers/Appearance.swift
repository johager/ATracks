//
//  Appearance.swift
//  ATracks (iOS)
//
//  Created by James Hager on 4/19/22.
//

import SwiftUI
import UIKit

enum Appearance {
    
    //static let file = "Appearance"
    
    // MARK: - Methods
    
    static func customizeAppearance() {
        //print("=== \(file).\(#function) ===")
        
        UINavigationBar.appearance().tintColor = UIColor(.textSelectable)
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(.background)
        appearance.shadowColor = UIColor(.navigationShadow)
        appearance.titleTextAttributes = [.foregroundColor: UIColor(.text)]
        
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}
