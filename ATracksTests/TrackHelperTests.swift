//
//  TrackHelperTests.swift
//  TrackHelperTests
//
//  Created by James Hager on 4/21/22.
//

import XCTest
import CoreData
@testable import ATracks

class TrackHelperTests: XCTestCase {

    var track: Track!
    
    var trackHelper: TrackHelper!
    
    struct SetGridValsTestCase {
        let min: Double
        let max: Double
    }
    
    var coreDataStack: CoreDataStack { CoreDataStack .shared }
    var viewContext: NSManagedObjectContext { CoreDataStack.shared.context }
    
    class
    
    // MARK: - SetUp & TearDown
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        
        if trackHelper != nil {
            trackHelper = nil
        }
        
        if track != nil {
            for trackPoint in track.trackPoints {
                viewContext.delete(trackPoint)
            }
            
            viewContext.delete(track)
        }
    }
    
    // MARK: - Helper Methods
    
    func runSetGridValsTestCases(_ testCases: [SetGridValsTestCase], function: String) {
        
        track = Track(name: "_test_")
        trackHelper = TrackHelper(track: track)
        
        var failedCases = [SetGridValsTestCase]()
        
        for testCase in testCases {
            trackHelper.setGridVals(for: [testCase.min, testCase.max])
            if trackHelper.yAxisNumGridLines > 5 {
                failedCases.append(testCase)
                XCTFail("yAxisNumGridLines > 5 for  min/max: \(testCase.min) / \(testCase.max)")
            }
        }
    }
    
    func reportFailedSetGridValsTestCases(_ failedCases: [SetGridValsTestCase], function: String) {
        
        guard failedCases.count > 0 else { return }
        
        print("=== \(function) ===")
        
        for failedCase in failedCases {
            print("--- \(function) - failed testCase: min/max : \(failedCase.min) / \(failedCase.max)")
        }
    }
    
    // MARK: - Test setGridVals
    
    func testSetGridVals() {
        let testCases = [
            SetGridValsTestCase(min: 5434, max: 5546),
            SetGridValsTestCase(min: 5433, max: 5550),
            SetGridValsTestCase(min: 5433, max: 5554)
        ]
        
        runSetGridValsTestCases(testCases, function: #function)
    }
}
