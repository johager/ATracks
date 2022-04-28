//
//  OnboardingHelper.swift
//  ATracks
//
//  Created by James Hager on 4/28/22.
//

import Foundation

enum OnboardingHelper {
    
    static let hasOnboardedKey = "hasOnboarded"
    
    // MARK: - Methods
    
    static var shouldOnboard: Bool {
        !UserDefaults.standard.bool(forKey: hasOnboardedKey)
    }
    
    static func setHasOnboarded() {
        UserDefaults.standard.set(true, forKey: hasOnboardedKey)
        UserDefaults.standard.synchronize()
    }
}
