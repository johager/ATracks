//
//  TrackListResultsViewPhone.swift
//  ATracks (iOS)
//
//  Created by James Hager on 6/3/22.
//

import SwiftUI

struct TrackListResultsViewPhone: View {
    
    @EnvironmentObject var trackManager: TrackManager
    
    @StateObject private var device = Device.shared
    
    var delegate: TrackListResultsViewDelegate
    
//    @State private var selectedTrack: Track?
//    @State private var selectedTrackDidChangeProgramatically = false
    @State private var isShowingDeleteAlert = false
    
    @FetchRequest private var tracks: FetchedResults<Track>
    
    let file = "TrackListResultsViewPhone"
    
    // MARK: - Init
    
    init(searchText: String, delegate: TrackListResultsViewDelegate) {
        print("=== \(file).\(#function) - searchText: '\(searchText)' ===")
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
            ScrollViewReader { proxy in
                List() {
                    ForEach(tracks) { track in
                        ZStack(alignment: .leading) {
                            NavigationLink(destination: TrackDetailView(track: track, delegate: self), tag: track, selection: $trackManager.selectedTrack) { EmptyView() }
                                .opacity(0)
                            TrackRow(track: track, device: device)
                        }
                        .id(track)
//                        .listRowBackground(track === selectedTrack ? Color.listRowSelectedBackground : Color.clear)
                        
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
                    }
                }
                .listStyle(.plain)
                .onChange(of: trackManager.selectedTrack) { _ in
                    print("=== \(file).onChange(of: selectedTrack) - selectedTrackDidChangeProgramatically: \(trackManager.selectedTrackDidChangeProgramatically) ===")
                    guard trackManager.selectedTrackDidChangeProgramatically else { return }
                    proxy.scrollTo(trackManager.selectedTrack, anchor: .center)
                    trackManager.selectedTrackDidChangeProgramatically = false
                }
            }
            .padding(.bottom, 0)
        }
        .ignoresSafeArea(.keyboard)
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

// MARK: - TrackStatsViewDelegate

extension TrackListResultsViewPhone: TrackStatsViewDelegate {
    func handleSwipe(_ swipeDir: SwipeDirection) {
        //print("=== \(file).\(#function) - swipeDir: \(swipeDir) ===")
        
        guard let newTrack = SwipeHelper.newTrack(from: Array(tracks), and: trackManager.selectedTrack, for: swipeDir) else { return }
        
        trackManager.selectedTrackDidChangeProgramatically = true
        trackManager.selectedTrack = newTrack
    }
}

//struct TrackListResultsViewPhone_Previews: PreviewProvider {
//    static var previews: some View {
//        TrackListResultsViewPhone()
//    }
//}
