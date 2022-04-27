//
//  ContentView.swift
//  ATracks
//
//  Created by James Hager on 4/18/22.
//

import SwiftUI

struct ContentView: View {
    
    init() {
        Appearance.customizeAppearance()
    }
    
    var body: some View {
        NavigationView {
            TrackListView()
            //SettingsView()
            #if os(iOS)
            LocationServicesView()
            #endif
        }
    }
}

// MARK: - Previews

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
