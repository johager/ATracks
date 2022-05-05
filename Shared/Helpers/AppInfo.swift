//
//  AppInfo.swift
//  ATracks (iOS)
//
//  Created by James Hager on 4/18/22.
//

import Foundation

enum AppInfo {
    
    // MARK: - About
    
    static let appName = "ATracks"
    
    static var appNameWithFullVersion: String { "\(appName) \(version) (\(bundle))" }
    
    static var appNameWithVersion: String { "\(appName) \(version)" }
    
    static var codeVersionAndBundle: String { "\(version)_\(bundle)" }
    
    static let appStoreURL = URL(string: "itms-apps://itunes.apple.com/us/app/atracks/id1619330372")!
    
    static let copyrightYear = "2022"
    
    // MARK: - Version & Bundle
    
    static var version: String { Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String }
    
    static var bundle: String { Bundle.main.infoDictionary!["CFBundleVersion"] as! String }
    
    static var bundleLowercase: String { bundle.lowercased() }
}
