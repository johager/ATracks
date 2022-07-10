//
//  SettingsView.swift
//  ATracks (macOS)
//
//  Created by James Hager on 6/10/22.
//

import SwiftUI

struct SettingsView: View {
    
    @StateObject var displaySettings = DisplaySettings.shared
    
    // MARK: - View
    
    var body: some View {
            Form {
                Picker("Map Display:", selection: $displaySettings.mapViewSatellite) {
                    Text("Standard").tag(false)
                    Text("Satellite").tag(true)
                }
                .pickerStyle(.inline)
                Picker("Map Position In Landscape:", selection: $displaySettings.placeMapOnRightInLandscape) {
                    Text("Left").tag(false)
                    Text("Right").tag(true)
                }
                .pickerStyle(.inline)
            }
            .padding([.top, .bottom], 30)
            .padding([.leading, .trailing], 60)
    }
}

//struct SettingsView_Previews: PreviewProvider {
//    static var previews: some View {
//        SettingsView()
//    }
//}
