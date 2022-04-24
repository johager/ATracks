//
//  View+.swift
//  ATracks
//
//  Created by James Hager on 4/24/22.
//

import SwiftUI

extension View {
    
    func hidden(_ shouldHide: Bool) -> some View {
        opacity(shouldHide ? 0 : 1)
    }
}
