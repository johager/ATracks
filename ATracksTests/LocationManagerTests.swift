//
//  LocationManagerTests.swift
//  ATracksTests
//
//  Created by James Hager on 4/22/22.
//

import XCTest
@testable import ATracks
import CoreLocation

class LocationManagerTests: XCTestCase, LocationManagerSettingsProvider {
    
    var useAutoStop = false
    
    struct AutoStopTestCase {
        let deltaLocMax: Double  // meters
        let deltaLocEnd: Double  // meters
        let deltaT: TimeInterval
        let shouldFail: Bool
        
        var desc: String {
            "deltaLoc Max/End: \(deltaLocMax)/\(deltaLocEnd), deltaT: \(deltaT), shouldFail: \(shouldFail)"
        }
        
        init(deltaLocMax: Double, deltaLocEnd: Double, deltaT: TimeInterval, shouldFail: Bool = false) {
            self.deltaLocMax = deltaLocMax
            self.deltaLocEnd = deltaLocEnd
            self.deltaT = deltaT
            self.shouldFail = shouldFail
        }
    }
    
    // MARK: - SetUp & TearDown
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        
    }
    
    // MARK: - Helper Methods
    
    func runAutoStopTestCases(_ testCases: [AutoStopTestCase], function: String) {
        
        LocationManager.shared.settingsProvider = self
        
        var failedCases = [AutoStopTestCase]()
        
        let startLocation = CLLocationCoordinate2D(latitude: 37.33, longitude: -122.01)
        
        for testCase in testCases {
            print(">>> \(function) - testCase: \(testCase.desc)")
            LocationManager.shared.stopTracking()
            LocationManager.shared.isTracking = true
            LocationManager.shared.location = makeLocation(from: startLocation, deltaT: 2 * testCase.deltaT)
            LocationManager.shared.checkAutoStop()
            
            var newLocation = location(from: startLocation, heading: 0, distanceInMeters: testCase.deltaLocMax)
            LocationManager.shared.location = makeLocation(from: newLocation, deltaT: testCase.deltaT)
            LocationManager.shared.checkAutoStop()
            
            newLocation = location(from: startLocation, heading: 0, distanceInMeters: testCase.deltaLocEnd)
            LocationManager.shared.location = makeLocation(from: newLocation, deltaT: 0)
            LocationManager.shared.checkAutoStop()
            
            if LocationManager.shared.isTracking != testCase.shouldFail {
                print(">>> \(function) - testCase: \(testCase.desc)  >>>  failed")
                failedCases.append(testCase)
                XCTFail("failed \(testCase.desc)")
            }
        }
        
        reportFailedAutoStopTestCases(failedCases, function: function)
    }
    
    func makeLocation(from loc2D: CLLocationCoordinate2D, deltaT: TimeInterval) -> CLLocation {
        let date = Date(timeIntervalSinceNow: -deltaT)
        return CLLocation(coordinate: loc2D, altitude: 100, horizontalAccuracy: 10, verticalAccuracy: 10, timestamp: date)
    }
    
    func location(from origin: CLLocationCoordinate2D, heading: Double, distanceInMeters: Double) -> CLLocationCoordinate2D {
        // based on https://stackoverflow.com/questions/7278094/moving-a-cllocation-by-x-meters
        // heading is in radians (N: 0, W: pi/2, E: -pi/2)
        
        let distRadians = distanceInMeters / 6372797.6
        
        let lat1 = origin.latitude * Double.pi / 180
        let lon1 = origin.longitude * Double.pi / 180

        let lat2 = asin(sin(lat1) * cos(distRadians) + cos(lat1) * sin(distRadians) * cos(heading))
        let lon2 = lon1 + atan2(sin(heading) * sin(distRadians) * cos(lat1), cos(distRadians) - sin(lat1) * sin(lat2))
        return CLLocationCoordinate2D(latitude: lat2 * 180 / Double.pi, longitude: lon2 * 180 / Double.pi)
    }
    
    func reportFailedAutoStopTestCases(_ failedCases: [AutoStopTestCase], function: String) {
        
        guard failedCases.count > 0 else { return }
        
        print("=== \(function) ===")
        
        for failedCase in failedCases {
            print("--- \(function) - failed testCase: \(failedCase.desc)")
        }
    }

    // MARK: - Test autoStop
    
    func testAutoStop() {
        // autoStop() should set isTracking to false, ie an automatic stop
        
        useAutoStop = true
        LocationManager.shared.shouldTrack = false
        
        let minDStart = LocationManager.shared.autoStopMinDistToStart
        let minDStop = LocationManager.shared.autoStopMinDistToStop
        let minT = LocationManager.shared.autoStopMinTimeIntToStart
        
        let testCases = [
            AutoStopTestCase(deltaLocMax: minDStart + 1, deltaLocEnd: minDStop - 1, deltaT: minT + 1)
        ]
        
        runAutoStopTestCases(testCases, function: #function)
    }
    
    func testAutoStopShouldFail() {
        // autoStop() should leave isTracking true, ie a failed automatic stop
        
        useAutoStop = true
        LocationManager.shared.shouldTrack = false
        
        let minDStart = LocationManager.shared.autoStopMinDistToStart
        let minDStop = LocationManager.shared.autoStopMinDistToStop
        let minT = LocationManager.shared.autoStopMinTimeIntToStart
        
        let dDBeg: Double = 1
        let dDEnd: Double = -1
        let dT: Double = 10
        
        // apply +dDBeg, +dDEnd, and +dT to satisfy the constraint (to pass)
        
        let testCases = [
            AutoStopTestCase(deltaLocMax: minDStart - dDBeg, deltaLocEnd: minDStop + dDEnd, deltaT: minT + dT, shouldFail: true),
            AutoStopTestCase(deltaLocMax: minDStart + dDBeg, deltaLocEnd: minDStop - dDEnd, deltaT: minT + dT, shouldFail: true),
            AutoStopTestCase(deltaLocMax: minDStart + dDBeg, deltaLocEnd: minDStop + dDEnd, deltaT: minT - dT, shouldFail: true)
        ]
        
        runAutoStopTestCases(testCases, function: #function)
    }
}
