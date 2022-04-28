//
//  BlankView.swift
//  ATracks
//
//  Created by James Hager on 4/28/22.
//

import SwiftUI

struct BlankView: View {
    var body: some View {
        EmptyView()
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
