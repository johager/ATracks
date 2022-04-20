//
//  TouchLocatingView.swift
//  ATracks (iOS)
//
//  Created by James Hager on 4/20/22.
//
//  based on https://www.hackingwithswift.com/quick-start/swiftui/how-to-detect-the-location-of-a-tap-inside-a-view
//

import UIKit
import SwiftUI

struct TouchLocatingView: UIViewRepresentable {
    
    struct TouchType: OptionSet {
        let rawValue: Int
        
        static let started = TouchType(rawValue: 1 << 0)
        static let moved = TouchType(rawValue: 1 << 1)
        static let ended = TouchType(rawValue: 1 << 2)
        static let all: TouchType = [.started, .moved, .ended]
    }
    
    // A closure to call when touch data has arrived
    var onUpdate: (CGPoint) -> Void
    
    // The list of touch types to be notified of
    var types = TouchType.all
    
    // Whether touch information should continue after the user's finger has left the view
    var limitToBounds = true
    
    // MARK: - Methods
    
    func makeUIView(context: Context) -> TouchLocatingUIView {
        let view = TouchLocatingUIView()
        view.onUpdate = onUpdate
        view.touchTypes = types
        view.limitToBounds = limitToBounds
        return view
    }
    
    func updateUIView(_ uiView: TouchLocatingUIView, context: Context) {
    }
    
    //MARK: - The internal UIView responsible for catching taps
    
    class TouchLocatingUIView: UIView {
        
        var onUpdate: ((CGPoint) -> Void)?
        var touchTypes: TouchLocatingView.TouchType = .all
        var limitToBounds = true
        
        // MARK: - Init
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            isUserInteractionEnabled = true
        }
        
        // Just in case you're using storyboards!
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            isUserInteractionEnabled = true
        }
        
        // MARK: - Handle Touches

        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            guard let touch = touches.first else { return }
            let location = touch.location(in: self)
            send(location, forEvent: .started)
        }

        override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
            guard let touch = touches.first else { return }
            let location = touch.location(in: self)
            send(location, forEvent: .moved)
        }
        
        override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
            guard let touch = touches.first else { return }
            let location = touch.location(in: self)
            send(location, forEvent: .ended)
        }
        
        override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
            guard let touch = touches.first else { return }
            let location = touch.location(in: self)
            send(location, forEvent: .ended)
        }
        
        // Send a touch location only if the user asked for it
        func send(_ location: CGPoint, forEvent event: TouchLocatingView.TouchType) {
            guard touchTypes.contains(event) else { return }
            
            if limitToBounds == false || bounds.contains(location) {
                onUpdate?(CGPoint(x: round(location.x), y: round(location.y)))
            }
        }
    }
}

// MARK: - TouchLocater

struct TouchLocater: ViewModifier {
    // A custom SwiftUI view modifier that overlays a view with our UIView subclass.
    var type: TouchLocatingView.TouchType = .all
    var limitToBounds = true
    let perform: (CGPoint) -> Void
    
    func body(content: Content) -> some View {
        content
            .overlay(
                TouchLocatingView(onUpdate: perform, types: type, limitToBounds: limitToBounds)
            )
    }
}

// MARK: - View.onTouch Extension

extension View {
    
    // A new method on View that makes it easier to apply our touch locater view.
    func onTouch(type: TouchLocatingView.TouchType = .all, limitToBounds: Bool = true, perform: @escaping (CGPoint) -> Void) -> some View {
        self.modifier(TouchLocater(type: type, limitToBounds: limitToBounds, perform: perform))
    }
}
