//
//  AboutHelper.swift
//  ATracks
//
//  Created by James Hager on 6/15/22.
//

import Foundation

enum AboutHelper {
    
    static let introText: [String] = [
        "ATracks records location, elevation, and step data for your outdoor activities. Data is stored locally so that you'll always have it, and data is synched to other devices with the same Apple ID so you can view your excursions on larger screens.",
        "Your data is stored in your own private iCloud account, and no one without access to your Apple ID can access that data.",
        "Tracks can only be recorded using an iDevice (iPhone, iPad, or iPod Touch).",
        "Step data is obtained from the Apple Health app, and is only imported into ATracks while ATracks is actively running on an iPhone or iPod Touch."
    ]
    
    static let searchText: [String] = [
        "The search is not case-sensitive, and supports partial, exact\u{00a0}(\"\"), AND\u{00a0}(+), and NOT\u{00a0}(-) searching."
        ]
    
    static let displayText: [String] = [
        "Tap on the map to recenter the track.",
        "A green pin marker is used to indicate the beginning of a track. If the track is one-way, the end of the track has a red pin marker.",
        "The average elevation is a time-weighted average.",
        "Touch or swipe on the elevation plot to display that point on the map and also its latitude, longitude, and elevation."
        ]
}
