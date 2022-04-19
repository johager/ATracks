//
//  TrackListView.swift
//  Shared
//
//  Created by James Hager on 4/18/22.
//

import SwiftUI

struct TrackListView: View {
    
    @State private var isTracking = false
    
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
                }
                .onDelete(perform: delete)
//                .listRowBackground(Color.white)
            }
            .listStyle(.plain)
            
            HStack {
                Spacer()
                
                Button(action: startTrack) {
                    Text("Start")
                }
                .disabled(isTracking)
                
                Spacer()
                
                Button(action: stopTrack) {
                    Text("Stop")
                }
                .disabled(!isTracking)
                
                Spacer()
            }
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
        LocationManager.shared.startTracking()
        isTracking = true
    }
    
    func stopTrack() {
        print("\(#function)")
        LocationManager.shared.stopTracking()
        isTracking = false
    }
}

// MARK: - Previews

struct TrackListView_Previews: PreviewProvider {
    static var previews: some View {
        TrackListView()
    }
}
