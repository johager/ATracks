//
//  Func.swift
//  ATracks
//
//  Created by James Hager on 4/23/22.
//

import SwiftUI

enum Func {
    
    static func afterDelay(_ delaySeconds: Double, closure: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delaySeconds, execute: closure)
    }
    
    static var deviceName: String {
        #if os(OSX)
            let theDeviceName = Host.current().localizedName ?? "Mac with no name"
        #else
            let theDeviceName = UIDevice.current.name
        #endif
        
        //print("=== Syncable.deviceName: '\(theDeviceName)'")
        return theDeviceName
    }
    
    static var deviceUUID: String {
        
        #if os(OSX)
            let matchingDict = IOServiceMatching("IOPlatformExpertDevice")
            let platformExpert = IOServiceGetMatchingService(kIOMainPortDefault, matchingDict)
            
            defer{ IOObjectRelease(platformExpert) }
            
            guard platformExpert != 0 else { return "Unknown" }
            
            // UUID
            var uuidString = IORegistryEntryCreateCFProperty(platformExpert, kIOPlatformUUIDKey as CFString, kCFAllocatorDefault, 0).takeUnretainedValue() as? String ?? "Unknown"
            
            if uuidString == "Unknown" {
                // SN fallback
                let serialNumberAsCFString = IORegistryEntryCreateCFProperty(platformExpert, kIOPlatformSerialNumberKey as CFString, kCFAllocatorDefault, 0)
                uuidString = (serialNumberAsCFString?.takeUnretainedValue() as? String) ?? "Unknown"
            }
        
            return uuidString
        
        #else
            return UIDevice.current.identifierForVendor!.uuidString
            
        #endif  
    }
    
    static func sourceFileNameFromFullPath(_ file: String) -> String {
        let fileComponents1 = file.components(separatedBy: "/")
        let lastComponent1 = fileComponents1.last!
        let fileComponents2 = lastComponent1.components(separatedBy: ".")
        let firstComponent2 = fileComponents2.first!
        return firstComponent2
    }
}
