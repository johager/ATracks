//
//  HOrVStackView.swift
//  ATracks (iOS)
//
//  Created by James Hager on 5/7/22.
//
//  Inspired by https://www.hackingwithswift.com/quick-start/swiftui/how-to-automatically-switch-between-hstack-and-vstack-based-on-size-class
//

import SwiftUI

enum HOrVStack {
    case hstack
    case vstack
}

struct HOrVStackView<Content: View>: View {
    
    let hOrVStack: HOrVStack
    let horizontalAlignment: HorizontalAlignment
    let verticalAlignment: VerticalAlignment
    let spacing: CGFloat?
    let content: () -> Content
    
    init(hOrVStack: HOrVStack, horizontalAlignment: HorizontalAlignment = .center, verticalAlignment: VerticalAlignment = .center, spacing: CGFloat? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.hOrVStack = hOrVStack
        self.horizontalAlignment = horizontalAlignment
        self.verticalAlignment = verticalAlignment
        self.spacing = spacing
        self.content = content
    }
    
    // MARK: - View
    
    var body: some View {
        if hOrVStack == .hstack {
            HStack(alignment: verticalAlignment, spacing: spacing, content: content)
        } else {
            VStack(alignment: horizontalAlignment, spacing: spacing, content: content)
        }
    }
}

//struct HOrVStackView_Previews: PreviewProvider {
//    static var previews: some View {
//        HOrVStackView()
//    }
//}
