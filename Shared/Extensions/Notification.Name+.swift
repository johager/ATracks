//
//  Notification.Name+.swift
//  ATracks
//
//  Created by James Hager on 4/20/22.
//

import Foundation

extension Notification.Name {
    public static let didStartTracking = Notification.Name(rawValue: "didStartTracking")
    public static let didStopTracking = Notification.Name(rawValue: "didStopTracking")
    public static let scenePhaseChangedToActive = Notification.Name(rawValue: "scenePhaseChangedToActive")
}
