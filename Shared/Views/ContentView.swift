//
//  ContentView.swift
//  ATracks
//
//  Created by James Hager on 4/18/22.
//

import SwiftUI

struct ContentView: View {
    
    @Binding var hasSafeAreaInsets: Bool
    
    init(hasSafeAreaInsets: Binding<Bool>) {
        self._hasSafeAreaInsets = hasSafeAreaInsets
        Appearance.customizeAppearance()
    }
    
    // MARK: - View
    
    var body: some View {
        GeometryReader {  geometry in
            NavigationView {
                TrackListView(hasSafeAreaInsets: $hasSafeAreaInsets, isLandscape: geometry.isLandscape)
                //SettingsView()
                BlankView()
            }
        }
    }
}

// MARK: - Previews

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
