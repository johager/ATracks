//
//  VerticalDividerView.swift
//  ATracks
//
//  Created by James Hager on 5/7/22.
//

import SwiftUI

struct VerticalDividerView: View {
    
    var body: some View {
        Rectangle()
            .edgesIgnoringSafeArea([.top, .bottom])
            .foregroundColor(.border)
            .frame(width: 0.7)
    }
}

struct VerticalRectangleDivider_Previews: PreviewProvider {
    static var previews: some View {
        VerticalDividerView()
    }
}
