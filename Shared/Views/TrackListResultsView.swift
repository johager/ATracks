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
    
    @Environment(\.presentationMode) var presentationMode
    
    @EnvironmentObject var trackManager: TrackManager
    
    @Binding var hasSafeAreaInsets: Bool
    private var isLandscape: Bool
    private var showNavigationLink: Bool
    
    var delegate: TrackListResultsViewDelegate
    
    @State private var isShowingDeleteAlert = false
    
//    let file = "TrackListResultsView"
    
    // MARK: - Init
    
    init(hasSafeAreaInsets: Binding<Bool>, isLandscape: Bool, delegate: TrackListResultsViewDelegate) {
        //print("=== file.\(#function) - isLandscape: \(isLandscape) ===")
        self._hasSafeAreaInsets = hasSafeAreaInsets
        self.isLandscape = isLandscape
        self.showNavigationLink = DeviceType.current() != .pad
        self.delegate = delegate
    }
    
    // MARK: - View
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                List() {
                    ForEach(trackManager.tracks) { track in
                        ZStack(alignment: .leading) {
                            #if os(iOS)
                            if showNavigationLink {
                                NavigationLink(destination: TrackDetailView(track: track, hasSafeAreaInsets: $hasSafeAreaInsets), tag: track, selection: $trackManager.selectedTrack) { EmptyView() }
                                .opacity(0)
                            } else {
                                Button(action: { trackManager.selectedTrack = track }) { EmptyView() }
                            }
                            #else
                            NavigationLink(destination: TrackDetailView(track: track, hasSafeAreaInsets: $hasSafeAreaInsets), tag: track, selection: $trackManager.selectedTrack) { EmptyView() }
                            .opacity(0)
                            #endif
                            TrackRow(track: track)
                        }
                        .id(track)
//                        #if os(iOS)
                        .listRowBackground(listRowBackgroundColor(for: track))
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
                .onChange(of: trackManager.selectedTrack) { _ in
                    //print("=== \(file).onChange(of: selectedTrack) - selectedTrackDidChangeProgramatically: \(trackManager.selectedTrackDidChangeProgramatically) ===")
                    guard trackManager.selectedTrackDidChangeProgramatically else { return }
                    withAnimation(.easeInOut(duration: 1)) {
                        proxy.scrollTo(trackManager.selectedTrack, anchor: .center)
                    }
                    Func.afterDelay(0.5) {
                        trackManager.selectedTrackDidChangeProgramatically = false
                    }
                }
                #endif
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
    
//    #if os(iOS)
    func listRowBackgroundColor(for track: Track) -> Color {
        guard let selectedTrack = trackManager.selectedTrack else { return .clear }
        return track === selectedTrack ? .listRowSelectedBackground : .clear
    }
//    #endif
}

// MARK: - Previews

//struct TrackListView_Previews: PreviewProvider {
//    static var previews: some View {
//        TrackListView()
//    }
//}
