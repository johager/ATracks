//
//  Func.swift
//  ATracks
//
//  Created by James Hager on 4/23/22.
//

import SwiftUI
import os.log

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
    
    static var hasSafeAreaInsets: Bool {
        #if os(iOS)
        let insets = safeAreaInsets
        return insets.leading != 0 || insets.bottom != 0
        #else
        return false
        #endif
    }
    
    static func logError(_ error: Error, in function: String, using logger: inout Logger?, for file: String) {
        if logger == nil {
            logger = Func.logger(for: file)
        }
        
        logger!.notice("\(function) - error: \(error.localizedDescription)")
    }
    
    static func logger(for category: String) -> Logger {
        return Logger(subsystem: "com.AvantiApplications.ATracks", category: category)
    }
    
    static func memory() -> mach_vm_size_t? {
        let TASK_VM_INFO_COUNT = mach_msg_type_number_t(MemoryLayout<task_vm_info_data_t>.size / MemoryLayout<integer_t>.size)

        let TASK_VM_INFO_REV1_COUNT = mach_msg_type_number_t(MemoryLayout.offset(of: \task_vm_info_data_t.min_address)! / MemoryLayout<integer_t>.size)

        var info = task_vm_info_data_t()

        var count = TASK_VM_INFO_COUNT

        let kr = withUnsafeMutablePointer(to: &info) { infoPtr in
            infoPtr.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { intPtr in
                task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), intPtr, &count)
            }
        }

        guard kr == KERN_SUCCESS,
              count >= TASK_VM_INFO_REV1_COUNT
        else { return nil }

        return info.phys_footprint
    }
    
    static func memoryMB() -> Int? {
        guard let memory = memory() else { return nil }
        return Int(memory) / 1024 / 1024
    }
    
    static var safeAreaInsets: EdgeInsets {
        #if os(iOS)
        // based on https://developer.apple.com/forums/thread/687420
        let keyWindow = UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .map { $0 as? UIWindowScene }
            .compactMap { $0 }
            .first?.windows
            .filter { $0.isKeyWindow }
            .first
        
        guard let edgeInsets = keyWindow?.safeAreaInsets
        else { return EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0) }
        
        return EdgeInsets(top: edgeInsets.top, leading: edgeInsets.left, bottom: edgeInsets.bottom, trailing: edgeInsets.right)
        
        #else
        return EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
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
