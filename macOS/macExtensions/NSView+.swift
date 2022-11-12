//
//  NSView+.swift
//  ATracks (iOS)
//
//  Created by James Hager on 4/25/22.
//

import AppKit

extension NSView {
    
    func pin(top: NSLayoutYAxisAnchor?, trailing: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, leading: NSLayoutXAxisAnchor?, margin: [CGFloat] = [0, 0, 0, 0]) {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        if let top {
            topAnchor.constraint(equalTo: top, constant: margin[0]).isActive = true
        }
        
        if let trailing {
            trailingAnchor.constraint(equalTo: trailing, constant: -margin[1]).isActive = true
        }
        
        if let bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -margin[2]).isActive = true
        }
        
        if let leading {
            leadingAnchor.constraint(equalTo: leading, constant: margin[3]).isActive = true
        }
    }
}
