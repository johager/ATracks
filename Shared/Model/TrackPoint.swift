//
//  TrackPoint.swift
//  ATracks
//
//  Created by James Hager on 4/18/22.
//

import CoreData
import CoreLocation

@objc(TrackPoint)
class TrackPoint: NSManagedObject {
    
    // MARK: - CoreData Properties
    
    @NSManaged var altitude: Double
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var speed: Double
    @NSManaged var timestamp: Date
    
    @NSManaged var track: Track?
    
    // MARK: - Properties
    
    var clLocation: CLLocation { CLLocation(latitude: latitude, longitude: longitude)}
    
    var clLocationCoordinate2D: CLLocationCoordinate2D { CLLocationCoordinate2D(latitude: latitude, longitude: longitude) }
    
    static var fetchRequest: NSFetchRequest<TrackPoint> { NSFetchRequest<TrackPoint>(entityName: DataType.trackPoint.entityName) }
    
    // MARK: - Init
    
    @discardableResult convenience init(clLocation: CLLocation, track: Track, context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.init(context: context)
        altitude = clLocation.altitude
        latitude = clLocation.coordinate.latitude
        longitude = clLocation.coordinate.longitude
        speed = clLocation.speed
        timestamp = clLocation.timestamp
        
        self.track = track
        track.setDistanceAndDuration()
    }
}
