//
//  BlankView.swift
//  ATracks
//
//  Created by James Hager on 4/28/22.
//

import SwiftUI

struct BlankView: View {
    var body: some View {
        GeometryReader { geometry in
            HStack {
                Spacer()
                Text("Select a track...")
                Spacer()
            }
            #if os(iOS)
            .padding(.top, geometry.size.height * 0.2)
            #else
            .padding(.top, geometry.size.height / 3)
            #endif
        }
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

struct BlankView_Previews: PreviewProvider {
    static var previews: some View {
        BlankView()
    }
}
