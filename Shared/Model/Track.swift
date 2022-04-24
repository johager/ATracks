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
    
    @NSManaged var date: Date
    @NSManaged var distance: Double
    @NSManaged var duration: TimeInterval
    @NSManaged var name: String
    @NSManaged var steps: Int32
    
    @NSManaged var trackPointsSet: NSSet?
    
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
    
    var trackPoints: [TrackPoint] {
        guard let trackPointsSet = trackPointsSet as? Set<TrackPoint> else { return [] }
        return Array(trackPointsSet).sorted { $0.timestamp < $1.timestamp }
    }
    
    lazy var file = Func.sourceFileNameFromFullPath(#file)
    
    // MARK: - Init
    
    @discardableResult convenience init(name: String, date: Date = Date(), context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.init(context: context)
        self.name = name
        self.date = date
    }
    
    // MARK: - Methods
    
    func setDistanceAndDuration() {
        
        let trackPoints = self.trackPoints
        
        guard trackPoints.count > 1 else { return }
        
        let locations = trackPoints.map { $0.clLocation }
        
        // distance
        
        var distance: Double = 0
        
        for i in 0..<(locations.count - 1) {
            distance += locations[i + 1].distance(from: locations[i])
        }
        
        distance *= 0.000621371  // convert meters to miles
        
        // duration
        
        let startDate = trackPoints.first!.timestamp
        let stopDate = trackPoints.last!.timestamp
        
        print("=== \(file).\(#function) - startDate: \(startDate.stringForDebug) ===")
        print("--- \(file).\(#function) -  stopDate: \(stopDate.stringForDebug)")
        
        let duration = stopDate.timeIntervalSince(startDate)
        
        // update properties
        
        self.distance = distance
        self.duration = duration
    }
}
