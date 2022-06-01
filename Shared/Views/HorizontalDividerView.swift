//
//  HorizontalDividerView.swift
//  ATracks
//
//  Created by James Hager on 5/31/22.
//

import SwiftUI

struct HorizontalDividerView: View {
    var body: some View {
        Rectangle()
            .edgesIgnoringSafeArea([.trailing, .leading])
            .foregroundColor(.border)
            .frame(height: 0.5)
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        HorizontalDividerView()
    }
}
