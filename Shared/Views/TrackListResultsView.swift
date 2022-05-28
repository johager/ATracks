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

// MARK: -

struct TrackListResultsView: View {
    
    @Binding var hasSafeAreaInsets: Bool
    
    var delegate: TrackListResultsViewDelegate
    
    @State private var selectedTrack: Track?
    @State private var selectedTrackDidChangeProgramatically = false
    @State private var isShowingDeleteAlert = false
    
    @FetchRequest private var tracks: FetchedResults<Track>
    
    private var isNotPhone: Bool { DeviceType.current() != .phone }
    
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
            ScrollViewReader { proxy in
                List() {
                    ForEach(tracks) { track in
                        ZStack(alignment: .leading) {
                            NavigationLink(destination: TrackDetailView(track: track, hasSafeAreaInsets: $hasSafeAreaInsets, delegate: self), tag: track, selection: $selectedTrack) {
                                EmptyView()
                            }
                            .opacity(0)
                            TrackRow(track: track)
                                
                        }
                        .id(track)
//                        #if os(iOS)
//                        .listRowBackground(track === selectedTrack ? Color.listRowSelectedBackground : Color.clear)
//                        #endif
                        
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
                #if os(iOS)
                .onChange(of: selectedTrack) { _ in
                    print("=== \(file).onChange(of: selectedTrack) - selectedTrackDidChangeProgramatically: \(selectedTrackDidChangeProgramatically) ===")
                    guard selectedTrackDidChangeProgramatically else { return }
                    proxy.scrollTo(selectedTrack, anchor: .center)
                    self.selectedTrackDidChangeProgramatically = false
                }
                #endif
            }
            .onAppear {
                if isNotPhone && selectedTrack == nil && tracks.count > 0 {
                    selectedTrack = tracks[0]
                }
            }
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
    
    func handleSwipeLeft() {
        print("=== \(file).\(#function) ===")
        
        doSwipe() { index in
            let newIndex = index + 1
            if newIndex == tracks.count {
//                newIndex = 0
                return nil
            }
            return newIndex
        }
    }
    
    func handleSwipeRight() {
        print("=== \(file).\(#function) ===")
        
        doSwipe() { index in
            let newIndex = index - 1
            if newIndex < 0 {
//                newIndex = tracks.count - 1
                return nil
            }
            return newIndex
        }
    }
    
    func doSwipe(newIndexFrom: (Int) -> Int?) {
        print("=== \(file).\(#function) ===")
        
        guard let selectedTrack = selectedTrack,
              let index = tracks.firstIndex(of: selectedTrack)
        else { return }
        
        print("--- \(file).\(#function) - current index: \(index) of count \(tracks.count)")
        guard let newIndex = newIndexFrom(index) else { return }
        print("--- \(file).\(#function) - newIndex: \(newIndex)")
        
        selectedTrackDidChangeProgramatically = true
        self.selectedTrack = tracks[newIndex]
    }
}

// MARK: - TrackStatsViewDelegate

extension TrackListResultsView: TrackStatsViewDelegate {
    #if os(iOS)
    func handleSwipe(_ swipeDir: SwipeDirection) {
        print("=== \(file).\(#function) - swipeDir: \(swipeDir) ===")
        switch swipeDir {
        case .left:
            handleSwipeLeft()
        case .right:
            handleSwipeRight()
        default:
            break
        }
    }
    #endif
}

// MARK: - Previews

//struct TrackListView_Previews: PreviewProvider {
//    static var previews: some View {
//        TrackListView()
//    }
//}
