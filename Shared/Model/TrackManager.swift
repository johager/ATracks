//
//  TrackManager.swift
//  ATracks
//
//  Created by James Hager on 4/18/22.
//

import CoreData
import CoreLocation

protocol TrackManagerDelegate {
    func didMakeNewTrackPoint(_ trackPoint: TrackPoint)
}

// MARK: -

class TrackManager {
    
    static let shared = TrackManager()
    
    var track: Track!
    var tracks = [Track]()
    var trackPoints = [TrackPoint]()
    
    var delegate: TrackManagerDelegate?
    
    private let trackFetchRequest = Track.fetchRequest
    
    var coreDataStack: CoreDataStack { CoreDataStack.shared }
    
    var viewContext: NSManagedObjectContext { CoreDataStack.shared.context }
    
    // MARK: - Init
    
    private init() {
//        print("\(#function)")
        trackFetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        //fetchTracks()
        //describeTrackPoints()
    }
    
    func describeTrackPoints() {
        for trackPoint in trackPoints {
            print("\(trackPoint.timestamp.stringForTrack), \(trackPoint.speed * 2.23694) mph")
        }
    }
    
    // MARK: - CRUD for Tracks
    
    func createTrack(name: String) {
        tracks.insert(Track(name: name), at: 0)
        coreDataStack.saveContext()
    }
    
    func fetchTracks() {
        print("\(#function)")
        do {
            tracks = try viewContext.fetch(trackFetchRequest)
        } catch {
            print("error fetching tracks: \(error)")
            print(error.localizedDescription)
        }
    }
    
    // MARK: - CRUD for TrackPoints
    
    func createTrackPoint(from location: CLLocation, in track: Track) {
        print("--- \(#function)")
        let trackPoint = TrackPoint(clLocation: location, track: track)
        trackPoints.append(trackPoint)
        coreDataStack.saveContext()
        delegate?.didMakeNewTrackPoint(trackPoint)
        #if os(iOS)
        Task.init {
            guard let numSteps = await HealthKitManager.shared.readSteps(beginningAt: track.date) else { return }
            track.steps = numSteps
        }
        #endif
    }
    
    func fetchTrackPoints(for track: Track? = nil) {
        
        if let track = track {
            trackPoints = track.trackPoints
            return
        }
        
        let trackPointFetchRequest = TrackPoint.fetchRequest
        trackPointFetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]
        
        do {
            trackPoints = try viewContext.fetch(trackPointFetchRequest)
            trackPoints.sort { $0.timestamp < $1.timestamp }
        } catch {
            print("error fetching trackPoints: \(error)")
            print(error.localizedDescription)
        }
    }
}
