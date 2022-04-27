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
    
    lazy var deviceName = Func.deviceName
    lazy var deviceUUID = Func.deviceUUID
    
    lazy var file = Func.sourceFileNameFromFullPath(#file)
    
    // MARK: - Init
    
    private init() {
//        print("=== TrackManager.\(#function) ===")
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
    
    @discardableResult func createTrack(name: String) -> Track {
        let track = Track(name: name, deviceName: deviceName, deviceUUID: deviceUUID)
        tracks.insert(track, at: 0)
        coreDataStack.saveContext()
        return track
    }
    
    func fetchTracks() {
        print("=== \(file).\(#function) ===")
        do {
            tracks = try viewContext.fetch(trackFetchRequest)
        } catch {
            print("--- \(file).\(#function) - error: \(error)")
            print(error.localizedDescription)
        }
    }
    
    // MARK: - CRUD for TrackPoints
    
    func createTrackPoint(from location: CLLocation, in track: Track) {
        //print("=== \(file).\(#function) ===")
        print("=== \(file).\(#function) - horizontalAccuracy: \(location.horizontalAccuracy), verticalAccuracy: \(location.verticalAccuracy), altitude: \(location.altitude) ===")
        
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
            print("=== \(file).\(#function) - error: \(error)")
            print(error.localizedDescription)
        }
    }
    
    func stopTracking(_ track: Track) {
        track.isTracking = false
        coreDataStack.saveContext()
    }
}
