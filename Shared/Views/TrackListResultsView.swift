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
    
    @EnvironmentObject var trackManager: TrackManager
    
    @ObservedObject private var device = Device.shared
    
    private var delegate: TrackListResultsViewDelegate
    
    @State private var isShowingDeleteAlert = false
    
    #if os(macOS)
    @State private var trackBeingEdited: Track? = nil
    #endif
    
    let file = "TrackListResultsView"
    
    // MARK: - Init
    
    init(delegate: TrackListResultsViewDelegate) {
        //print("=== file.\(#function) ===")
        self.delegate = delegate
    }
    
    // MARK: - View
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                #if os(macOS)
                HorizontalDividerView()
                #endif
                ScrollViewReader { proxy in
                    List() {
                        ForEach(trackManager.tracks) { track in
                            ZStack(alignment: .leading) {
                                #if os(iOS)
                                if device.padShowNavigationLink {
                                    NavigationLink(destination: TrackDetailView(track: track), tag: track, selection: $trackManager.selectedTrack) { EmptyView() }
                                        .opacity(0)
                                } else {
                                    Button(action: { trackManager.selectedTrack = track }) { EmptyView() }
                                }
                                #else
                                NavigationLink(destination: TrackDetailView(track: track), tag: track, selection: $trackManager.selectedTrack) { EmptyView() }
                                .opacity(0)
                                #endif
                                let isEditing = isEditing(track)
                                TrackRow(track: track, device: device, isSelected: isSelected(track), isEditing: isEditing, delegate: self)
                                    #if os(macOS)
                                    .id(isEditing)
                                    #endif
                            }
                            .id(track)
                            #if os(iOS)
                            .padding([.top, .bottom], -6)
                            #endif
                            .padding([.leading, .trailing], -16)
                            
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
                            #else
                            .contextMenu {
                                Button(action: { trackBeingEdited = track }) { Text("Edit") }
                                Button(action: { delete(track) }) { Text("Delete") }
                            }
                            #endif
                        }
                    }
                    .listStyle(.plain)
                    .animation(.linear, value: trackManager.tracks)
                    .background(Color.listBackground)
                    .onChange(of: trackManager.selectedTrack) { _ in
                        //print("=== \(file).onChange(of: selectedTrack) - selectedTrackDidChangeProgramatically: \(trackManager.selectedTrackDidChangeProgramatically) ===")
                        #if os(iOS)
                        guard trackManager.selectedTrackDidChangeProgramatically else { return }
                        withAnimation(.easeInOut(duration: 1)) {
                            proxy.scrollTo(trackManager.selectedTrack, anchor: .center)
                        }
                        Func.afterDelay(0.5) {
                            trackManager.selectedTrackDidChangeProgramatically = false
                        }
                        #else
                        trackBeingEdited = nil
                        #endif
                    }
                }
                .padding(.bottom, 0)
            }
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
        //print("=== \(file).\(#function) - \(track.debugName) ===")
        if !TrackManager.shared.didDelete(track) {
            isShowingDeleteAlert = true
        }
    }
    
    func isEditing(_ track: Track) -> Bool {
        #if os(iOS)
        return false
        #else
        guard let trackBeingEdited = trackBeingEdited else { return false }
        return track === trackBeingEdited
        #endif
    }
    
    func isSelected(_ track: Track) -> Bool {
        guard let selectedTrack = trackManager.selectedTrack else { return false }
        return track === selectedTrack
    }
}

// MARK: - TrackRowDelegate

extension TrackListResultsView: TrackRowDelegate {
    
    func didFinishEditing() {
        //print("=== file.\(#function) ===")
        #if os(macOS)
        trackBeingEdited = nil
        #endif
    }
}

// MARK: - Previews

//struct TrackListView_Previews: PreviewProvider {
//    static var previews: some View {
//        TrackListView()
//    }
//}
