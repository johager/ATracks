//
//  LegalView.swift
//  ATracks (iOS)
//
//  Created by James Hager on 4/22/22.
//

import SwiftUI

struct LegalView: View {
    var body: some View {
        List {
            Text("Legal...")
        }
        .listStyle(.plain)
        .navigationTitle("Legal")
        #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

struct LegalView_Previews: PreviewProvider {
    static var previews: some View {
        LegalView()
    }
}
