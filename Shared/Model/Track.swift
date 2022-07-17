//
//  Track.swift
//  ATracks
//
//  Created by James Hager on 4/18/22.
//

import CoreData

@objc(Track)
class Track: NSManagedObject, Identifiable {
    
    // MARK: - CoreData Properties
    
    @NSManaged var altitudeMin: Double
    @NSManaged var altitudeMax: Double
    @NSManaged var altitudeAve: Double
    @NSManaged var altitudeGain: Double
    @NSManaged var altitudeIsValid: Bool
    @NSManaged var date: Date
    @NSManaged var deviceName: String
    @NSManaged var deviceUUID: String
    @NSManaged var distance: Double
    @NSManaged var duration: TimeInterval
    @NSManaged var hasFinalSteps: Bool
    @NSManaged var isTracking: Bool
    @NSManaged var name: String
    @NSManaged var steps: Int32
    @NSManaged var timezone: String
    
    @NSManaged var trackPointsSet: NSSet?
    
    // MARK: - Static Properties
    
    static let altitudeIsValidKey = "altitudeIsValid"
    static let dateKey = "date"
    static let deviceUUIDKey = "deviceUUID"
    static let hasFinalStepsKey = "hasFinalSteps"
    static let isTrackingKey = "isTracking"
    static let nameKey = "name"
    
    // MARK: - Properties

    static var fetchRequest: NSFetchRequest<Track> { NSFetchRequest<Track>(entityName: DataType.track.entityName) }
    
    var id: String { objectID.uriRepresentation().absoluteString }
    
    var aveSpeed: Double {
        if duration > 0 {
            return distance / duration * 3600  // convert seconds to hours
        } else {
            return 0
        }
    }
    
    var dateString: String {
        if isFault {
            return ""
        }
        return date.stringForTrack(timezone: timezone)
    }
    
    var debugName: String { "\(name) (\(defaultName))" }
    var defaultName: String { date.stringForTrackName(timezone: timezone) }
    
    var trackPoints: [TrackPoint] {
        guard !isFault,
              let trackPointsSet = trackPointsSet as? Set<TrackPoint>
        else { return [] }
        return Array(trackPointsSet).sorted { $0.timestamp < $1.timestamp }
    }
    
    lazy var file = Func.sourceFileNameFromFullPath(#file)
    
    // MARK: - Init
    
    @discardableResult convenience init(name: String, deviceName: String = "", deviceUUID: String = "", date: Date = Date(), isTracking: Bool = true, context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.init(context: context)
        self.name = name
        self.deviceName = deviceName
        self.deviceUUID = deviceUUID
        self.date = date
        self.isTracking = isTracking
        self.timezone = TimeZone.current.abbreviation() ?? "GMT"
    }
    
    // MARK: - Methods
    
    func stopTracking() {
        isTracking = false
        setTrackSummaryData()
    }
    
    func setTrackSummaryData(verticalAccuracy: Double = 1, shouldUpdateTrackDetails: Bool = true) {
//        print("=== \(file).\(#function) - shouldUpdateTrackDetails: \(shouldUpdateTrackDetails) ===")
        
        if verticalAccuracy <= 0 {
            altitudeIsValid = false
        }
        
        guard shouldUpdateTrackDetails else { return }
        
        let trackPoints = self.trackPoints
        
        guard trackPoints.count > 1 else { return }
        
        setDistanceAndDuration(from: trackPoints)
        setAltitudeData()
    }
    
    func setAltitudeData() {
//        print("=== \(file).\(#function) - altitudeIsValid: \(altitudeIsValid) ===")
        guard altitudeIsValid else { return }
        
        let trackHelper = TrackHelper(track: self)
        
        guard trackHelper.altitudes.count > 1 else { return }
        
        altitudeMin = trackHelper.altitudeMin
        altitudeMax = trackHelper.altitudeMax
        altitudeAve = trackHelper.altitudeAve
        altitudeGain = trackHelper.altitudeGain
        
        let userInfo = [
            TrackHelper.timeKey: trackHelper.time,
            TrackHelper.altitudesKey: trackHelper.altitudes
//            TrackHelper.altitudesRawKey: trackHelper.altitudesRaw
        ]
        
        NotificationCenter.default.post(name: Notification.Name.altitudeChanged(for: self), object: nil, userInfo: userInfo)
    }
    
    func setDistanceAndDuration(from trackPoints: [TrackPoint]) {
        
        let locations = trackPoints.map { $0.clLocation }
        
        // distance
        
        var distance: Double = 0
        
        for i in 1..<locations.count {
            distance += locations[i].distance(from: locations[i - 1])
        }
        
        distance *= 0.000621371  // convert meters to miles
        
        // duration
        
        let startDate = trackPoints.first!.timestamp
        let stopDate = trackPoints.last!.timestamp
        
//        print("=== \(file).\(#function) - startDate: \(startDate.stringForDebug) ===")
//        print("--- \(file).\(#function) -  stopDate: \(stopDate.stringForDebug)")
        
        let duration = stopDate.timeIntervalSince(startDate)
        
        // update properties
        
        self.distance = distance
        self.duration = duration
    }
}
