//
//  TrackListView.swift
//  ATracks
//
//  Created by James Hager on 5/2/22.
//

import SwiftUI

struct TrackListView: View {
    
    @EnvironmentObject var trackManager: TrackManager
        
    #if os(iOS)
    @ObservedObject var displaySettings = DisplaySettings.shared
    @ObservedObject var locationManagerSettings = LocationManagerSettings.shared
    #endif

//    @ObservedObject private var device: Device
    @ObservedObject private var device = Device.shared
    
    private var horizontalSizeClassIsCompact: Bool
    private var isLandscape: Bool
    
    @State private var isTracking = false
    
    @State private var searchText = ""
    
    #if os(iOS)
    @State private var isShowingSettingsView = false
    
    @State private var isShowingAddEditTrackName = false
    
    @State private var trackBeingEdited: Track?
    
    @State private var trackName: String? = nil
    @State private var trackNameAlertTitle = ""
    @State private var trackNameAlertMessage: String?
    @State private var trackNameAlertDoneTitle = ""
    @State private var trackNameAlertForAdd = true
    
    var defaultTrackName: String { Date().stringForTrackName }
    
    var interfaceOrientation: UIInterfaceOrientation {
        guard
            let scene = UIApplication.shared.connectedScenes.first,
            let sceneDelegate = scene as? UIWindowScene else { return .unknown }
        return sceneDelegate.interfaceOrientation
    }
    var isLandscapeLeft: Bool { return interfaceOrientation == .landscapeLeft }
    var isLandscapeRight: Bool { return interfaceOrientation == .landscapeRight }
    #endif
    
    let file = "TrackListView"
    
    // MARK: - Init
    
    init(horizontalSizeClassIsCompact: Bool, isLandscape: Bool) {
        self.horizontalSizeClassIsCompact = horizontalSizeClassIsCompact
        self.isLandscape = isLandscape
    }
    
    // MARK: - View
    
    var body: some View {
        GeometryReader {  geometry in
            if shouldShowSideBySide(for: geometry) {
                HStack(spacing: 0) {
                    #if os(iOS)
                    if !displaySettings.placeButtonsOnRightInLandscape {
                        Group {
                            TrackListButtonsView(in: .vstack, isTracking: $isTracking, delegate: self)
                                .padding(.leading, device.hasSafeAreaInsets ? (isLandscapeLeft ? -30 : 0) : 16)
                                .padding(.trailing, 16)
                            VerticalDividerView()
                        }
                        .background(Color.tabBarBackground)
                    }
                    #endif
                    
                    #if os(iOS)
                    if device.isPhone {
                        TrackListResultsViewPhone(searchText: searchText, delegate: self)
                    } else {
                        TrackListResultsView(delegate: self)
                    }
                    #else
                    TrackListResultsView(delegate: self)
                    #endif
                    
                    #if os(iOS)
                    if displaySettings.placeButtonsOnRightInLandscape {
                        Group {
                            VerticalDividerView()
                            TrackListButtonsView(in: .vstack, isTracking: $isTracking, delegate: self)
                                .padding(.leading, 16)
                                .padding(.trailing, device.hasSafeAreaInsets ? (isLandscapeRight ? -30 : 0) : 16)
                        }
                        .background(Color.tabBarBackground)
                    }
                    #endif
                }
            } else {  // not side by side
                VStack(spacing: 0) {
                    #if os(iOS)
                    if device.isPhone {
                        TrackListResultsViewPhone(searchText: searchText, delegate: self)
                    } else {
                        TrackListResultsView(delegate: self)
                    }
                    #else
                    TrackListResultsView(delegate: self)
                    #endif
                    #if os(iOS)
                    VStack(spacing: 0) {
                        Rectangle()
                            .fill(Color.border)
                            .frame(height: 0.7)
                            .edgesIgnoringSafeArea(.all)
                        
                        TrackListButtonsView(in: .hstack, isTracking: $isTracking, delegate: self)
                            .padding(.top, 16)
                            .padding(.bottom, device.hasSafeAreaInsets ? 0 : 16)
                    }
                    .background(Color.tabBarBackground)
                    #endif
                }
            }
        }
        .navigationTitle("Tracks")
        #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .ignoresSafeArea(.keyboard)
            .onReceive(NotificationCenter.default.publisher(for: .didStartTracking)) { _ in
                isTracking = true
            }
            .onReceive(NotificationCenter.default.publisher(for: .didStopTracking)) { _ in
                isTracking = false
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { isShowingSettingsView = true }) {
                        Image(systemName: "gearshape")
                            .tint(.textSelectable)
                    }
                }
            }
            .trackNameAlert(isPresented: $isShowingAddEditTrackName) {
                return TrackNameAlert(title: $trackNameAlertTitle, message: $trackNameAlertMessage, text: $trackName, doneTitle: $trackNameAlertDoneTitle) { trackName in
                    handleAddEditTrackName(trackName)
                }
            }
        #endif
        .frame(minWidth: 250)
//            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: Text("Track name..."))
        .searchable(text: $searchText, prompt: Text("Track name..."))
        .onChange(of: searchText) { _ in
            #if os(iOS)
            if device.isPhone {
                return
            }
            #endif
            trackManager.getTracks(with: searchText)
        }
        .onAppear {
            device.sceneHorizontalSizeClassIsCompact = horizontalSizeClassIsCompact
        }
        #if os(iOS)
        NavigationLink(destination: SettingsView(device: device), isActive: $isShowingSettingsView) {  }
            .isDetailLink(false)
        #endif
    }
    
    // MARK: - Methods
    
    func shouldShowSideBySide(for geometry: GeometryProxy) -> Bool {
        #if os(iOS)
        return geometry.isLandscape
        #else
        return false
        #endif
    }
    
    func startTracking(name: String) {
        //print("=== \(file).\(#function) - name: '\(name)' ===")
        #if os(iOS)
        LocationManager.shared.startTracking(name: name)
        #endif
    }
    
    func handleAddEditTrackName(_ trackName: String?) {
        // trackName == nil  : cancel was tapped
        // trackName == ""   : use default
        
        #if os(iOS)
        
        defer {
            trackBeingEdited = nil
        }
        
        guard let trackName else { return }
        
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

// MARK: - TrackListButtonsViewDelegate

#if os(iOS)
extension TrackListView: TrackListButtonsViewDelegate {
    
    func startButtonTapped() {
        //print("=== \(file).\(#function) ===")
        #if os(iOS)
        if locationManagerSettings.useDefaultTrackName {
            startTracking(name: defaultTrackName)
            return
        }
        trackName = nil
        trackNameAlertTitle = "Add Track"
        trackNameAlertMessage = "Leave blank for the default, timestamp track name."
        trackNameAlertDoneTitle = "Start"
        trackNameAlertForAdd = true
        isShowingAddEditTrackName = true
        #endif
    }
    
    func stopButtonTapped() {
        //print("=== \(file).\(#function) ===")
        #if os(iOS)
        LocationManager.shared.stopTracking()
        #endif
    }
}
#endif

// MARK: - TrackListResultsViewDelegate

extension TrackListView: TrackListResultsViewDelegate {
    
    func edit(_ track: Track) {
        //print("=== \(file).\(#function) - \(track.debugName) ===")
        #if os(iOS)
        trackBeingEdited = track
        trackName = track.name
        trackNameAlertTitle = "Edit Track Name"
        trackNameAlertMessage = "Set it blank to use the default, timestamp track name."
        trackNameAlertDoneTitle = "Save"
        trackNameAlertForAdd = false
        isShowingAddEditTrackName = true
        #endif
    }
    
    func startTracking(useNameOf track: Track) {
        //print("=== \(file).\(#function) ===")
        startTracking(name: track.name)
    }
}

//struct TrackListSearchWrapper_Previews: PreviewProvider {
//    static var previews: some View {
//        TrackListSearchWrapper()
//    }
//}
