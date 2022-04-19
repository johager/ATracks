//
//  TrackListView.swift
//  Shared
//
//  Created by James Hager on 4/18/22.
//

import SwiftUI

struct TrackListView: View {
    
    @State private var isTracking = false
//    @State private var selectedTrack: Track?
    
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(
                keyPath: \Track.date,
                ascending: false)
        ],
        predicate: nil,
        animation: .default)
    
    private var tracks: FetchedResults<Track>
    
    var body: some View {
        
        VStack {
            List() {
                ForEach(tracks) { track in
                    ZStack(alignment: .leading) {
                        NavigationLink(destination: TrackDetailView(track: track)) {
                            EmptyView()
                        }
                        .opacity(0)
                        TrackRow(track: track)
                    }
//                    .onTapGesture {
//                        print("tapped in list")
//                        selectedTrack = track
//                    }
//                    .listRowBackground(track == selectedTrack ? Color.tableViewSelectedBackgroundColor : .white)
                }
                .onDelete(perform: delete)
//                .listRowBackground(Color.tableViewSelectedBackgroundColor)
                
            }
            .listStyle(.plain)
            
            #if os(iOS)
            HStack {
                Spacer()
                
                Button(action: startTrack) {
                    Text("Start")
                }
                .disabled(isTracking)
                .buttonStyle(AAButtonStyle(isEnabled: !isTracking))
                
                Spacer()
                
                Button(action: stopTrack) {
                    Text("Stop")
                }
                .disabled(!isTracking)
                .buttonStyle(AAButtonStyle(isEnabled: isTracking))
                
                Spacer()
            }
            #endif
        }
        .navigationTitle("Tracks")
        #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
        #endif
        .frame(minWidth: 250)
    }
    
    // MARK: - Methods
    
    func delete(at offsets: IndexSet) {
        guard let index = offsets.first else { return }
        CoreDataStack.shared.context.delete(tracks[index])
        CoreDataStack.shared.saveContext()
    }
    
    func startTrack() {
        print("\(#function)")
        #if os(iOS)
        LocationManager.shared.startTracking()
        isTracking = true
        #endif
    }
    
    func stopTrack() {
        print("\(#function)")
        #if os(iOS)
        LocationManager.shared.stopTracking()
        isTracking = false
        #endif
    }
}

// MARK: - Previews

struct TrackListView_Previews: PreviewProvider {
    static var previews: some View {
        TrackListView()
    }
}
