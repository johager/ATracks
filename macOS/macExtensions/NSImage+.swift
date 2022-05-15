//
//  NSImage+.swift
//  ATracks (macOS)
//
//  Created by James Hager on 5/14/22.
//

import AppKit

extension NSImage {
    
    func colored(_ color: NSColor) -> NSImage? {
        let image = self.copy() as! NSImage
        image.lockFocus()
        color.set()
        CGRect(origin: .zero, size: size).fill(using: .sourceAtop)
        image.unlockFocus()
        return image
    }
    
    func overlay(_ topImage: NSImage) -> NSImage {
        
        let newImage = NSImage(size: size)
        newImage.lockFocus()
        
        let rect = CGRect(origin: .zero, size: size)
        
        self.draw(in: rect)
        topImage.draw(in: rect)
        newImage.unlockFocus()
        
        return newImage
    }
}
