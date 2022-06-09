//
//  TouchLocatingView.swift
//  ATracks (macOS)
//
//  Created by James Hager on 5/9/22.
//

import AppKit
import SwiftUI

struct TouchLocatingView: NSViewRepresentable {
    
    var onUpdate: (CGPoint) -> Void
    
    // MARK: - Methods
    
    func makeNSView(context: Context) -> TouchLocatingNSView {
        let view = TouchLocatingNSView()
        view.onUpdate = onUpdate
        return view
    }
    
    func updateNSView(_ uiView: TouchLocatingNSView, context: Context) {
    }
    
    //MARK: - The internal UIView responsible for catching taps
    
    class TouchLocatingNSView: NSView {
        
        var onUpdate: ((CGPoint) -> Void)?
        
        // MARK: - Init
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDown, .leftMouseDragged]) {
                self.handleEvent($0)
                return $0
            }
        }
        
        required init?(coder: NSCoder) {
            fatalError("TouchLocatingView.init(coder:) has not been implemented")
        }
        
        // MARK: - Handle Touches
        
        func handleEvent(_ event: NSEvent) {
            
            guard let eventWindow = event.window,
                  let viewWindow = self.window,
                  eventWindow === viewWindow
            else { return }
                  
            let locationInView = convert(event.locationInWindow, from: nil)
            if bounds.contains(locationInView) {
                onUpdate?(CGPoint(x: round(locationInView.x), y: round(locationInView.y)))
            }
        }
    }
}

// MARK: - TouchLocater

struct TouchLocater: ViewModifier {
    // A custom SwiftNS view modifier that overlays a view with our NSView subclass.
    let perform: (CGPoint) -> Void
    
    func body(content: Content) -> some View {
        content
            .overlay(
                TouchLocatingView(onUpdate: perform)
            )
    }
}

// MARK: - View.onTouch Extension

extension View {
    
    // A new method on View that makes it easier to apply our touch locater view.
    func onTouch(perform: @escaping (CGPoint) -> Void) -> some View {
        self.modifier(TouchLocater(perform: perform))
    }
}
