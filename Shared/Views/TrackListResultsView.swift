//
//  TrackListResultsView.swift
//  Shared
//
//  Created by James Hager on 4/18/22.
//

import SwiftUI

protocol TrackListResultsViewDelegate {
    func edit(_ track: Track)
    func startTracking(useNameOf track: Track)
}

struct TrackListResultsView: View {
    
    @Binding var hasSafeAreaInsets: Bool
    
    var delegate: TrackListResultsViewDelegate
    
    @State private var isShowingDeleteAlert = false
    
    @FetchRequest private var tracks: FetchedResults<Track>
    
    let file = "TrackListResultsView"
    
    // MARK: - Init
    
    init(hasSafeAreaInsets: Binding<Bool>, searchText: String, delegate: TrackListResultsViewDelegate) {
        //print("=== TrackListResultsView.\(#function) - searchText: '\(searchText)' ===")
        self._hasSafeAreaInsets = hasSafeAreaInsets
        self.delegate = delegate
        
        let fetchRequest = Track.fetchRequest
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Track.date, ascending: false)]
        if !searchText.isEmpty {
            fetchRequest.predicate = SearchHelper().predicate(from: searchText)
        }
        _tracks = FetchRequest(fetchRequest:fetchRequest, animation: .default)
    }
    
    // MARK: - View
    
    var body: some View {
        VStack(spacing: 0) {
            List() {
                ForEach(tracks) { track in
                    ZStack(alignment: .leading) {
                        NavigationLink(destination: TrackDetailView(track: track, hasSafeAreaInsets: $hasSafeAreaInsets)) {
                            EmptyView()
                        }
                        .opacity(0)
                        TrackRow(track: track)
                    }

                    #if os(iOS)
                    .listRowSeparatorTint(.listRowSeparator)
                    .swipeActions(allowsFullSwipe: false) {
                        Button(action: { delete(track) } ) {
                            Label("Delete", systemImage: "trash.fill")
                        }
                        .tint(.listRowSwipeDelete)
                        
                        Button(action: { delegate.edit(track) } ) {
                            Label("Edit", systemImage: "square.and.pencil")
                        }
                        .tint(.listRowSwipeEdit)
                        
                        Button(action: { delegate.startTracking(useNameOf: track) } ) {
//                            Label("Start", systemImage: "stopwatch")
                            Label("Start", systemImage: "timer")
                        }
                        .tint(.listRowSwipeStart)
                    }
                    #endif
                }
            }
            .listStyle(.plain)
            .padding(.bottom, 0)
        }
        
        #if os(iOS)
        .ignoresSafeArea(.keyboard)
        #endif
        .alert(isPresented: $isShowingDeleteAlert) {
            Alert(title: Text("Cannot Delete"), message: Text("You cannot delete a track when another device is actively tracking it."), dismissButton: .default(Text("OK")))
        }
    }
    
    // MARK: - Methods
    
    func delete(_ track: Track) {
        //print("=== \(file).\(#function) ===")
        if !TrackManager.shared.didDelete(track) {
            isShowingDeleteAlert = true
        }
    }
}

// MARK: - Previews

//struct TrackListView_Previews: PreviewProvider {
//    static var previews: some View {
//        TrackListView()
//    }
//}
