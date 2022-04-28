//
//  AAButtonStyle.swift
//  ATracks (macOS)
//
//  Created by James Hager on 4/19/22.
//
//  based on https://stackoverflow.com/questions/66809095/how-can-i-make-these-swiftui-text-buttons-change-color-on-tap
//

import SwiftUI

struct AAButtonStyle: ButtonStyle {
    
    var isEnabled: Bool
    
    init(isEnabled: Bool = true) {
        self.isEnabled = isEnabled
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding([.top, .bottom], 8)
            .padding([.leading, .trailing], 16)
            .font(.headline)
            .foregroundColor(isEnabled ? .aaButtonText : .aaButtonTextDisabled)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isEnabled ? Color.aaButtonBackgroundNormal : Color.aaButtonBackgroundDisabled)
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isEnabled ? Color.aaButtonBorder : Color.aaButtonBorderDisabled, lineWidth: 1)
                }
            )
    }
}
