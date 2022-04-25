//
//  Func.swift
//  ATracks
//
//  Created by James Hager on 4/23/22.
//

import Foundation

enum Func {
    
    static func afterDelay(_ delaySeconds: Double, closure: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delaySeconds, execute: closure)
    }
    
    static func sourceFileNameFromFullPath(_ file: String) -> String {
        let fileComponents1 = file.components(separatedBy: "/")
        let lastComponent1 = fileComponents1.last!
        let fileComponents2 = lastComponent1.components(separatedBy: ".")
        let firstComponent2 = fileComponents2.first!
        return firstComponent2
    }
}
