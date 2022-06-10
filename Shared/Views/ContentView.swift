//
//  ContentView.swift
//  ATracks
//
//  Created by James Hager on 4/18/22.
//

import SwiftUI

struct ContentView: View {
    
    #if os(iOS)
    @Environment(\.horizontalSizeClass) var hSizeClass
    #endif
    
    @EnvironmentObject var trackManager: TrackManager
    
    private var device: Device
    
    private var horizontalSizeClassIsCompact: Bool {
        #if os(iOS)
        guard let hSizeClass = hSizeClass else { return true }
        return hSizeClass == .compact ? true : false
        #else
        return false
        #endif
    }
    
//    let file = "ContentView"
    
    // MARK: - Init
    
    init(device: Device) {
        self.device = device
        Appearance.customizeAppearance()
    }
    
    // MARK: - View
    
    var body: some View {
        GeometryReader {  geometry in
            NavigationView {
                TrackListView(device: device, horizontalSizeClassIsCompact: horizontalSizeClassIsCompact, isLandscape: geometry.isLandscape)
                    .id(horizontalSizeClassIsCompact)
                //SettingsView()
                #if os(iOS)
                if let selectedTrack = trackManager.selectedTrack {
                    TrackDetailView(track: selectedTrack, device: device)
                } else {
                    BlankView()
                }
                #else
                BlankView()
                #endif
            }
            #if os(macOS)
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Button(action: toggleSidebar, label: {
                        Image(systemName: "sidebar.leading")
                    })
                }
            }
            #endif
        }
    }
    
    // MARK: - Methods
    
    #if os(macOS)
    func toggleSidebar() {
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
    }
    #endif
}

// MARK: - Previews

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
