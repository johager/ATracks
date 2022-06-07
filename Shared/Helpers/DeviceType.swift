//
//  DeviceType.swift
//  ATracks
//
//  Created by James Hager on 4/29/22.
//

import SwiftUI

enum DeviceType {
    
    case phone
    case pad
    case mac
    
    var isPhone: Bool { self == .phone }
    var isPad: Bool { self == .pad }
    var isMac: Bool { self == .mac }
    
    static func current() -> DeviceType {
        #if os(iOS)
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .phone
        } else {
            return .pad
        }
        #else
        return .mac
        #endif
    }
}
