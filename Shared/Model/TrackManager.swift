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
    
    var delegate: TrackManagerDelegate?
    
    private var tracks = [Track]()
    
    private var coreDataStack: CoreDataStack { CoreDataStack.shared }
    private var viewContext: NSManagedObjectContext { CoreDataStack.shared.context }
    
    lazy var deviceName = Func.deviceName
    lazy var deviceUUID = Func.deviceUUID
    
    lazy var file = Func.sourceFileNameFromFullPath(#file)
    
    // MARK: - Init
    
    private init() {
//        print("=== TrackManager.\(#function) ===")
        
    }
    
    // MARK: - CRUD for Tracks
    
    @discardableResult func createTrack(name: String) -> Track {
        let track = Track(name: name, deviceName: deviceName, deviceUUID: deviceUUID)
        coreDataStack.saveContext()
        return track
    }
    
    func update(_ track: Track, with name: String) {
        if name == track.name {
            return
        }
        track.name = name
        coreDataStack.saveContext()
    }
    
    func updateSteps() {
        #if os(iOS)
        CoreDataStack.shared.context.perform {
            self.doUpdateSteps()
        }
        #endif
    }
    
    func doUpdateSteps() {
        print("=== \(file).\(#function) ===")
        #if os(iOS)
        
        let fetchRequest = Track.fetchRequest
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            let tracks = try viewContext.fetch(fetchRequest)
            for track in tracks {
                print("--- \(file).\(#function) - name: \(track.name), isTracking: \(track.isTracking)")
                if track.isTracking {
                    continue
                }
                guard let stopDate = track.trackPoints.last?.timestamp else { continue }
                let startDate = track.date
                
                Task.init {
                    guard let numSteps = await HealthKitManager.shared.readSteps(beginningAt: startDate, andEndingAt: stopDate, dateOptions: .start) else { return }
                    viewContext.performAndWait {
                        print("--- \(file).\(#function) - name: \(track.name), steps saved/new: \(track.steps)/\(numSteps)")
                        track.steps = numSteps
                        track.hasFinalSteps = true
                        coreDataStack.saveContext()
                    }
                }
            }
        } catch {
            print("--- \(file).\(#function) - error: \(error)")
            print(error.localizedDescription)
        }
        #endif
    }
    
    func stopTracking(_ track: Track) {
        track.isTracking = false
        coreDataStack.saveContext()
    }
    
    func didDelete(_ track: Track) -> Bool {
        
        if track.isTracking {
            // don't delete a track when isTracking on another device
            guard track.deviceName == deviceName else { return false }
            
            #if os(iOS)
            LocationManager.shared.stopTracking(forDelete: true)
            #endif
        }
        
        viewContext.delete(track)
        coreDataStack.saveContext()
        
        return true
    }
    
    // MARK: - CRUD for TrackPoints
    
    func createTrackPoint(from location: CLLocation, in track: Track) {
        //print("=== \(file).\(#function) ===")
        print("=== \(file).\(#function) - horizontalAccuracy: \(location.horizontalAccuracy), verticalAccuracy: \(location.verticalAccuracy), altitude: \(location.altitude) ===")
        
        let trackPoint = TrackPoint(clLocation: location, track: track)
        coreDataStack.saveContext()
        delegate?.didMakeNewTrackPoint(trackPoint)
        #if os(iOS)
        Task.init {
            guard let numSteps = await HealthKitManager.shared.readSteps(beginningAt: track.date) else { return }
            track.steps = numSteps
        }
        #endif
    }
}
