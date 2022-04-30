//
//  ContentView.swift
//  ATracks
//
//  Created by James Hager on 4/18/22.
//

import SwiftUI

struct ContentView: View {
    
    @Binding var hasSafeAreaInsets: Bool
    var deviceType: DeviceType
    
    init(hasSafeAreaInsets: Binding<Bool>, deviceType: DeviceType) {
        self._hasSafeAreaInsets = hasSafeAreaInsets
        self.deviceType = deviceType
        Appearance.customizeAppearance()
    }
    
    var body: some View {
        NavigationView {
            TrackListView(hasSafeAreaInsets: $hasSafeAreaInsets, deviceType: deviceType)
            //SettingsView()
            BlankView()
        }
    }
}

// MARK: - Previews

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
