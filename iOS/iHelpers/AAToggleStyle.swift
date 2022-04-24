//
//  AAToggleStyle.swift
//  ATracks (iOS)
//
//  Created by James Hager on 4/24/22.
//
//  Based on https://stackoverflow.com/questions/56479674/set-toggle-color-in-swiftui
//  and https://stackoverflow.com/questions/56545444/how-to-remove-highlight-on-tap-of-list-with-swiftui
//

import SwiftUI

struct AAToggleStyle: ToggleStyle {
    
    var label = ""
    
    let onColor = Color.toggleOn
    let offColor = Color(UIColor.systemGray5)
    let thumbColor = Color.toggleThumb
    
    func makeBody(configuration: Self.Configuration) -> some View {
        HStack {
            Text(label)
                .foregroundColor(.text)
            Spacer()
            Button(action: { configuration.isOn.toggle() }) {
                RoundedRectangle(cornerRadius: 16, style: .circular)
                    .fill(configuration.isOn ? onColor : offColor)
                    .animation(.easeInOut(duration: 0.2), value: configuration.isOn)
                    .frame(width: 50, height: 29)
                    .overlay(
                        Circle()
                            .fill(thumbColor)
                            .shadow(radius: 1, x: 0, y: 1)
                            .padding(1.5)
                            .offset(x: configuration.isOn ? 10 : -10)
                    )
                    .animation(.easeInOut(duration: 0.2), value: configuration.isOn)
            }
            .buttonStyle(.plain)
        }
    }
}
