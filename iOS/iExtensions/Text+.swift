//
//  Text+.swift
//  ATracks (iOS)
//
//  Created by James Hager on 5/1/22.
//

import SwiftUI

extension Text {
    
    var settingsHeader: some View {
        self
            .font(.title3)
            .bold()
            .foregroundColor(.headerText)
            .kerning(1)
            .textCase(.uppercase)
    }
    
    var settingsSubHeader: some View {
        self
            .font(.title3)
            .bold()
            .foregroundColor(.headerText)
    }
}
