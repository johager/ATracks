//
//  ContentView.swift
//  ATracks
//
//  Created by James Hager on 4/18/22.
//

import SwiftUI

struct ContentView: View {
    
    @Binding var hasSafeAreaInsets: Bool
    
    @State private var isOnboarding = false
    
    init(hasSafeAreaInsets: Binding<Bool>) {
        self._hasSafeAreaInsets = hasSafeAreaInsets
        Appearance.customizeAppearance()
    }
    
    var body: some View {
        NavigationView {
            TrackListView(hasSafeAreaInsets: $hasSafeAreaInsets)
            //SettingsView()
        }
        #if os(iOS)
        .sheet(isPresented: $isOnboarding) {
            AboutView(isOnboarding: $isOnboarding)
        }
        #endif
        .onAppear { isOnboarding = OnboardingHelper.shouldOnboard }
    }
}

// MARK: - Previews

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
