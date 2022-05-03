//
//  TrackListView.swift
//  ATracks
//
//  Created by James Hager on 5/2/22.
//

import SwiftUI

struct TrackListView: View {
    
    @Binding var hasSafeAreaInsets: Bool
    
    @State private var searchText = ""
    #if os(iOS)
    @State private var isShowingSettingsView = false
    #endif
    
    let file = "TrackListView"
    
    // MARK: - View
    
    var body: some View {
        TrackListResultsView(hasSafeAreaInsets: $hasSafeAreaInsets, searchText: searchText)
            .navigationTitle("Tracks")
            #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: { isShowingSettingsView = true }) {
                            Image(systemName: "gearshape")
                                .tint(.textSelectable)
                        }
                    }
                }
            #endif
            .frame(minWidth: 250)
//            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: Text("Track name..."))
            .searchable(text: $searchText, prompt: Text("Track name..."))
        #if os(iOS)
        NavigationLink(destination: SettingsView(), isActive: $isShowingSettingsView) { EmptyView() }
        #endif
    }
}

//struct TrackListSearchWrapper_Previews: PreviewProvider {
//    static var previews: some View {
//        TrackListSearchWrapper()
//    }
//}
