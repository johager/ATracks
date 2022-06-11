//
//  NSTableView+.swift
//  ATracks (macOS)
//
//  Created by James Hager on 5/31/22.
//

import AppKit

extension NSTableView {
    
    open override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        
        backgroundColor = .clear
        enclosingScrollView?.drawsBackground = false
        intercellSpacing = NSMakeSize(0, -8)
        selectionHighlightStyle = .none
    }
}
