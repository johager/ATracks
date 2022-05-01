//
//  TrackListView.swift
//  Shared
//
//  Created by James Hager on 4/18/22.
//

import SwiftUI

struct TrackListView: View {
    
    @Binding var hasSafeAreaInsets: Bool
    
    @State private var isTracking = false
//    @State private var selectedTrack: Track?
    
    #if os(iOS)
    @ObservedObject var locationManagerSettings = LocationManagerSettings.shared
    @State private var isShowingSettingsView = false
    
    @State private var isShowingAddEditTrackName = false
    
    @State private var trackBeingEdited: Track?
    
    @State private var trackName: String? = nil {
        didSet {
            if let trackName = trackName {
                print("=== \(file).\(#function) didSet: '\(trackName)' ===")
            } else {
                print("=== \(file).\(#function) didSet: nil ===")
            }
        }
    }
    @State private var trackNameAlertTitle = ""
    @State private var trackNameAlertMessage: String?
    @State private var trackNameAlertDoneTitle = ""
    @State private var trackNameAlertForAdd = true
    
    var defaultTrackName: String { Date().stringForTrackName }
    
    private var stopTrackingText: String {
        if locationManagerSettings.useAutoStop {
            return "[Stop]"
        } else {
            return "Stop"
        }
    }
    #endif
    
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(
                keyPath: \Track.date,
                ascending: false)
        ],
        predicate: nil,
        animation: .default)
    
    private var tracks: FetchedResults<Track>
    
    let file = "TrackListView"
    
    // MARK: - View
    
    var body: some View {
        VStack {
            List() {
                ForEach(tracks) { track in
                    ZStack(alignment: .leading) {
                        NavigationLink(destination: TrackDetailView(track: track, hasSafeAreaInsets: $hasSafeAreaInsets)) {
                            EmptyView()
                        }
                        .opacity(0)
                        TrackRow(track: track)
                    }
//                    .onTapGesture {
//                        print("tapped in list")
//                        selectedTrack = track
//                    }
//                    .listRowBackground(track == selectedTrack ? Color.listRowSelectedBackground : .white)
                    #if os(iOS)
                    .listRowSeparatorTint(.listRowSeparator)
                    .swipeActions(allowsFullSwipe: false) {
                        Button(action: { delete(track) } ) {
                            Label("Delete", systemImage: "trash.fill")
                        }
                        .tint(.listRowSwipeDelete)
                        
                        Button(action: { edit(track) } ) {
                            Label("Edit", systemImage: "square.and.pencil")
                        }
                        .tint(.listRowSwipeEdit)
                        
                        Button(action: { startTracking(useNameOf: track) } ) {
//                            Label("Start", systemImage: "stopwatch")
                            Label("Start", systemImage: "timer")
                        }
                        .tint(.listRowSwipeStart)
                    }
                    #endif
                }
//                .listRowBackground(Color.listRowSelectedBackground)
                
            }
            .listStyle(.plain)
            
            #if os(iOS)
            VStack(spacing: 0) {
                Rectangle()
                    .fill(Color.border)
                    .frame(height: 1)
                    .edgesIgnoringSafeArea(.all)
                
                HStack {
                    Spacer()
                    
                    Button(action: startButtonTapped) {
                        Text("Start")
                    }
                    .disabled(isTracking)
                    .buttonStyle(AAButtonStyle(isEnabled: !isTracking))
                    
                    Spacer()
                    
                    Button(action: stopButtonTapped) {
                        Text(stopTrackingText)
                    }
                    .disabled(!isTracking)
                    .buttonStyle(AAButtonStyle(isEnabled: isTracking))
                    
                    Spacer()
                }
                .padding(.top, 16)
                .padding(.bottom, hasSafeAreaInsets ? 0 : 16)
            }
//            .background() {
//                Rectangle()
//                    .fill(Color.border)
//                    .frame(height: 1)
//                Color.tabBarBackground
//                    .edgesIgnoringSafeArea(.all)
//            }
            .background(Color.tabBarBackground)
            
            
            NavigationLink(destination: SettingsView(), isActive: $isShowingSettingsView) { EmptyView() }
            #endif
        }
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
        .onReceive(NotificationCenter.default.publisher(for: .didStartTracking)) { _ in
            isTracking = true
        }
        .onReceive(NotificationCenter.default.publisher(for: .didStopTracking)) { _ in
            isTracking = false
        }
        #if os(iOS)
        .trackNameAlert(isPresented: $isShowingAddEditTrackName) {
            return TrackNameAlert(title: $trackNameAlertTitle, message: $trackNameAlertMessage, text: $trackName, doneTitle: $trackNameAlertDoneTitle) { trackName in
                handleAddEditTrackName(trackName)
            }
        }
        #endif
    }
    
    // MARK: - Methods
    
    func delete(_ track: Track) {
        //print("=== \(file).\(#function) ===")
        CoreDataStack.shared.context.delete(track)
        CoreDataStack.shared.saveContext()
    }
    
    func edit(_ track: Track) {
        //print("=== \(file).\(#function) - name: \(track.name) ===")
        #if os(iOS)
        trackBeingEdited = track
        trackName = track.name
        trackNameAlertTitle = "Edit Track Name"
        trackNameAlertMessage = "Set it blank to use the default track name."
        trackNameAlertDoneTitle = "Save"
        trackNameAlertForAdd = false
        isShowingAddEditTrackName = true
        #endif
    }
    
    func startTracking(useNameOf track: Track) {
        //print("=== \(file).\(#function) ===")
        startTracking(name: track.name)
    }
    
    func startButtonTapped() {
        //print("=== \(file).\(#function) ===")
        #if os(iOS)
        if locationManagerSettings.useDefaultTrackName {
            startTracking(name: defaultTrackName)
            return
        }
        trackName = nil
        trackNameAlertTitle = "Add Track"
        trackNameAlertMessage = "Leave blank for the default track name."
        trackNameAlertDoneTitle = "Start Tracking"
        trackNameAlertForAdd = true
        isShowingAddEditTrackName = true
        #endif
    }
    
    func startTracking(name: String) {
        //print("=== \(file).\(#function) - name: '\(name)' ===")
        #if os(iOS)
        LocationManager.shared.startTracking(name: name)
        isTracking = true
        #endif
    }
    
    func stopButtonTapped() {
        //print("=== \(file).\(#function) ===")
        #if os(iOS)
        LocationManager.shared.stopTracking()
        isTracking = false
        #endif
    }
    
    func handleAddEditTrackName(_ trackName: String?) {
        // trackName == nil  : cancel was tapped
        // trackName == ""   : use default
        
        #if os(iOS)
        
        defer {
            trackBeingEdited = nil
        }
        
        guard let trackName = trackName else { return }
        
        var name = trackName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trackNameAlertForAdd {
            if name.isEmpty {
                name = defaultTrackName
            }
            startTracking(name: name)
        } else {
            guard let track = trackBeingEdited else { return }
            if name.isEmpty {
                name = track.defaultName
            }
            TrackManager.shared.update(track, with: name)
        }
        #endif
    }
}

// MARK: - Previews

//struct TrackListView_Previews: PreviewProvider {
//    static var previews: some View {
//        TrackListView()
//    }
//}
