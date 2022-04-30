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
                    #endif
                }
                .onDelete(perform: delete)
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
                    
                    Button(action: startTracking) {
                        Text("Start")
                    }
                    .disabled(isTracking)
                    .buttonStyle(AAButtonStyle(isEnabled: !isTracking))
                    
                    Spacer()
                    
                    Button(action: stopTracking) {
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
    }
    
    // MARK: - Methods
    
    func delete(at offsets: IndexSet) {
        guard let index = offsets.first else { return }
        CoreDataStack.shared.context.delete(tracks[index])
        CoreDataStack.shared.saveContext()
    }
    
    func startTracking() {
        print("=== \(file).\(#function) ===")
        #if os(iOS)
        LocationManager.shared.startTracking()
        isTracking = true
        #endif
    }
    
    func stopTracking() {
        print("=== \(file).\(#function) ===")
        #if os(iOS)
        LocationManager.shared.stopTracking()
        isTracking = false
        #endif
    }
}

// MARK: - Previews

//struct TrackListView_Previews: PreviewProvider {
//    static var previews: some View {
//        TrackListView()
//    }
//}
