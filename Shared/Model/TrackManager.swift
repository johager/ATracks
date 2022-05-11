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
        
        // dateForHasFinalSteps: if find steps, set hasFinalSteps true when stopDate < dateForHasFinalSteps
        // dateForForceHasFinalSteps: if don't find steps, set hasFinalSteps true when stopDate < dateForForceHasFinalSteps
        
        guard let dateForHasFinalSteps = Calendar.current.date(byAdding: .day, value: -1, to: Date()),
              let dateForForceHasFinalSteps = Calendar.current.date(byAdding: .day, value: -14, to: Date())
        else { return }
        
        let fetchRequest = Track.fetchRequest
        fetchRequest.predicate = NSPredicate(format: "%K == %@ AND %K == %@", Track.hasFinalStepsKey, NSNumber(value: false), Track.isTrackingKey, NSNumber(value: false))
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            let tracks = try viewContext.fetch(fetchRequest)
            for track in tracks {
                let trackName = track.debugName
                print("--- \(file).\(#function) - trackName: \(trackName)")
                
                guard let stopDate = track.trackPoints.last?.timestamp else { continue }
                let startDate = track.date
                
                Task.init {
                    let numSteps = await HealthKitManager.shared.readSteps(beginningAt: startDate, andEndingAt: stopDate, dateOptions: .start, trackName: trackName)
                    viewContext.performAndWait {
                        if let numSteps = numSteps {
                            let hasFinalStepsToSet = stopDate < dateForHasFinalSteps
                            print("--- \(file).\(#function) - trackName: \(trackName), steps saved/new: \(track.steps)/\(numSteps), hasFinalStepsToSet: \(hasFinalStepsToSet)")
                            track.steps = numSteps
                            track.hasFinalSteps = stopDate < dateForHasFinalSteps
                            coreDataStack.saveContext()
                        } else {
                            let hasFinalStepsToSet = stopDate < dateForForceHasFinalSteps
                            print("--- \(file).\(#function) - trackName: \(trackName), hasFinalStepsToSet: \(hasFinalStepsToSet)")
                            if hasFinalStepsToSet {
                                track.hasFinalSteps = stopDate < dateForHasFinalSteps
                                coreDataStack.saveContext()
                            }
                        }
                    }
                }
            }
        } catch {
            print("--- \(file).\(#function) - error: \(error)")
            print(error.localizedDescription)
        }
        #endif
    }
    
    func stopTracking() {
        let batchUpdateRequest = NSBatchUpdateRequest(entityName: DataType.track.entityName)
        batchUpdateRequest.predicate = NSPredicate(format: "%K == %@", Track.isTrackingKey, NSNumber(value: true))
        batchUpdateRequest.propertiesToUpdate = [Track.isTrackingKey: false]
        
        viewContext.execute(batchUpdateRequest, purpose: "Set Track.isTracking false")
        
        coreDataStack.saveContext()
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
            guard let numSteps = await HealthKitManager.shared.readSteps(beginningAt: track.date, trackName: track.debugName) else { return }
            track.steps = numSteps
        }
        #endif
    }
}
