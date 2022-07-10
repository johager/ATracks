//
//  TrackManager.swift
//  ATracks
//
//  Created by James Hager on 4/18/22.
//

import SwiftUI
import Combine
import CoreData
import CoreLocation
import os.log

protocol TrackManagerDelegate {
    func didMakeNewTrackPoint(_ trackPoint: TrackPoint)
}

// MARK: -

class TrackManager: NSObject, ObservableObject {
    
    static let shared = TrackManager()
    
    @Published var tracks = [Track]()
    @Published var selectedTrack: Track?
    {
        didSet {
            if let selectedTrack = selectedTrack {
                //print("=== \(file).\(#function) didSet: '\(selectedTrack.debugName)' ===")
                logger?.notice("selectedTrack didSet to \(selectedTrack.debugName, privacy: .private(mask: .hash))")
            } else {
                //print("=== \(file).\(#function) didSet: nil ===")
                logger?.notice("selectedTrack didSet to nil")
            }
        }
    }
    var selectedTrackDidChangeProgramatically = false
    
    var delegate: TrackManagerDelegate?
    
    private var fetchRequest: NSFetchRequest<Track>!
    private var fetchedResultsController: NSFetchedResultsController<Track>!
    
    private var coreDataStack: CoreDataStack { CoreDataStack.shared }
    private var viewContext: NSManagedObjectContext { CoreDataStack.shared.context }
    
    private var appState: AppState!
    private var isPhone: Bool!
    
    private var shouldSetSelectedTrack: Bool {
        guard let selectedTrack = selectedTrack,
              !tracks.contains(selectedTrack)
        else { return false }
        return true
    }
    
    private var tracksThatAreTrackingOnThisDevice: [Track]? {
        let fetchRequest = Track.fetchRequest
        fetchRequest.predicate = NSPredicate(format: "%K == %@ AND %K == %@", Track.isTrackingKey, NSNumber(value: true), Track.deviceUUIDKey, deviceUUID)
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Track.date, ascending: false)]
        
        do {
            let tracks = try viewContext.fetch(fetchRequest)
            return tracks
        } catch {
            Func.logError(error, in: #function, using: &logger, for: file)
            return nil
        }
    }
    
    private var logger: Logger?
    
    lazy var deviceName = Func.deviceName
    lazy var deviceUUID = Func.deviceUUID
    
    lazy var file = Func.sourceFileNameFromFullPath(#file)
    
    // MARK: - Init
    
    private override init() {
        super.init()
//        print("=== \(file).\(#function) ===")
        logger = Func.logger(for: file)
        
        isPhone = DeviceType.current().isPhone
        
        if isPhone {
            return
        }
        
        fetchRequest = Track.fetchRequest
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Track.date, ascending: false)]
        
        fetchedResultsController = NSFetchedResultsController<Track>(
            fetchRequest: fetchRequest,
            managedObjectContext: coreDataStack.context,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        fetchTracks()
        
        setSelectedTrack()
    }
    
    // MARK: - Set Up
    
    func setUp(using appState: AppState) {
        self.appState = appState
    }
    
    // MARK: - CRUD for Tracks
    
    @discardableResult func createTrack(name: String) -> Track {
        let track = Track(name: name, deviceName: deviceName, deviceUUID: deviceUUID)
        coreDataStack.saveContext()
        return track
    }
    
    func getTracks(with searchText: String) {
        print("=== \(file).\(#function) - searchText: '\(searchText)' ===")
        
        if searchText.isEmpty {
            fetchRequest.predicate = nil
        } else {
            fetchRequest.predicate = SearchHelper().predicate(from: searchText)
        }
        
        fetchTracks()
    }
    
    func fetchTracks() {
        try? fetchedResultsController.performFetch()
        tracks = fetchedResultsController.fetchedObjects ?? []
        
        if isPhone {
            return
        }
        
        if shouldSetSelectedTrack {
            setSelectedTrack()
        }
    }
    
    func setSelectedTrack() {
        
        if isPhone {
            return
        }
        
        if tracks.count > 0 {
            self.selectedTrack = tracks[0]
        } else {
            self.selectedTrack = nil
        }
        
        #if os(macOS)
        resetSelectedTrack()
        #endif
    }
    
    #if os(macOS)
    func resetSelectedTrack() {
        let newSelectedTrack = self.selectedTrack
        Func.afterDelay(0.3) {
            self.selectedTrack = newSelectedTrack
        }
    }
    #endif
    
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
        
//        let recent = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        
        let fetchRequest = Track.fetchRequest
        fetchRequest.predicate = NSPredicate(format: "%K == %@ AND %K == %@", Track.hasFinalStepsKey, NSNumber(value: false), Track.isTrackingKey, NSNumber(value: false))
//        fetchRequest.predicate = NSPredicate(format: "%K > %@ AND %K CONTAINS %@", Track.dateKey, recent as CVarArg, Track.nameKey, "Lincoln")
//        fetchRequest.predicate = NSPredicate(format: "%K CONTAINS %@", Track.nameKey, "Lincoln")
//        fetchRequest.predicate = NSPredicate(format: "%K > %@", Track.dateKey, recent as CVarArg)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Track.dateKey, ascending: false)]
        
        do {
            let tracks = try viewContext.fetch(fetchRequest)
            for track in tracks {
                let trackName = track.debugName
                print("--- \(file).\(#function) - trackName: \(trackName)")
                
                guard let stopDate = track.trackPoints.last?.timestamp else { continue }
                let startDate = track.date
                
                Task.init {
                    let numSteps = await HealthKitManager.shared.getSteps(from: startDate, to: stopDate, trackName: trackName)
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
//                    if let numSteps = numSteps {
//                        print("--- \(file).\(#function) - trackName: \(trackName), steps saved/new: \(track.steps)/\(numSteps)")
//                    }
                }
            }
        } catch {
            Func.logError(error, in: #function, using: &logger, for: file)
        }
        #endif
    }
    
    func updateSteps(for track: Track) {
        #if os(iOS)
        Task.init {
            guard let numSteps = await HealthKitManager.shared.getSteps(from: track.date, trackName: track.debugName) else { return }
            viewContext.performAndWait {
                track.steps = numSteps
                coreDataStack.saveContext()
            }
        }
        #endif
    }
    
    func updateSummaryDataAndSteps(for track: Track) {
        track.setTrackSummaryData()
        coreDataStack.saveContext()
        updateSteps(for: track)
    }
    
    func stopTracking() {
        print("=== \(file).\(#function) ===")
        guard let tracks = tracksThatAreTrackingOnThisDevice else { return }
        
        for track in tracks {
            print("--- \(file).\(#function) - name: '\(track.debugName)'")
            track.stopTracking()
            updateSteps(for: track)
        }
        if tracks.count > 0 {
            coreDataStack.saveContext()
        }
    }
    
//    func stopTracking(_ track: Track?) {
//        
//        guard let track = track
//        else {
//            stopTracking()
//            return
//        }
//        
//        track.stopTracking()
//        coreDataStack.saveContext()
//        updateSteps(for: track)
//    }
    
    func didDelete(_ track: Track) -> Bool {
        
        if track.isTracking {
            // don't delete a track when isTracking on another device
            guard track.deviceName == deviceName else { return false }
            
            #if os(iOS)
            LocationManager.shared.stopTracking(forDelete: true)
            #endif
        }
        
        if !isPhone && track === selectedTrack {
            setSelectedTrackForDelete()
        }
        
        viewContext.delete(track)
        coreDataStack.saveContext()
        
        return true
    }
    
    func setSelectedTrackForDelete() {
        guard let selectedTrack = selectedTrack,
              tracks.count > 1,
              let index = tracks.firstIndex(of: selectedTrack)
        else {
            self.selectedTrack = nil
            return
        }
        
        if index == tracks.count - 1 {
            self.selectedTrack = tracks[index - 1]
        } else {
            self.selectedTrack = tracks[index + 1]
        }
        
        #if os(macOS)
        resetSelectedTrack()
        #endif
    }
    
    // MARK: - Handle Track Swipe
    
    #if os(iOS)
    func handleSwipe(_ swipeDir: SwipeDirection) {
        //print("=== \(file).\(#function) - swipeDir: \(swipeDir) ===")
        
        guard let newTrack = SwipeHelper.newTrack(from: tracks, and: selectedTrack, for: swipeDir) else { return }
        
        selectedTrackDidChangeProgramatically = true
        selectedTrack = newTrack
    }
    #endif
    
    // MARK: - CRUD for TrackPoints
    
    func createTrackPoint(from location: CLLocation, in track: Track) {
        //print("=== \(file).\(#function) ===")
        //print("=== \(file).\(#function) - horizontalAccuracy: \(location.horizontalAccuracy), verticalAccuracy: \(location.verticalAccuracy), altitude: \(location.altitude), appState.isActive: \(appState.isActive) ===")
        
        let trackPoint = TrackPoint(clLocation: location, track: track, shouldUpdateTrackDetails: appState.isActive)
        delegate?.didMakeNewTrackPoint(trackPoint)
        coreDataStack.saveContext()
        
        #if os(iOS)
        guard appState.isActive else { return }
        updateSteps(for: track)
        #endif
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackManager: NSFetchedResultsControllerDelegate {

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {

        let newTracks = fetchedResultsController.fetchedObjects ?? []
        
        guard newTracks.count != tracks.count else { return }
        
        tracks = newTracks
        
        if shouldSetSelectedTrack {
            setSelectedTrack()
        }
    }
}
