//
//  SettingsView.swift
//  ATracks (iOS)
//
//  Created by James Hager on 4/19/22.
//

import SwiftUI

struct SettingsView: View {
    
    let rows = [
        CodeVersionView()
    ]
    
    var body: some View {
        List() {
            ForEach(rows) { row in
                row
            }
        }
        .listStyle(.plain)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
