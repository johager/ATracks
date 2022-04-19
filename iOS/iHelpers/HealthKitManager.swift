//
//  HealthKitManager.swift
//  ATracks (iOS)
//
//  Created by James Hager on 4/19/22.
//

import Foundation
import HealthKit

class HealthKitManager {
    
    static let shared = HealthKitManager()
    
    var hasAccess = false {
        didSet {
            print("=== HealthKitManager.hasAccess: \(hasAccess)")
        }
    }
    
    private var hkStore: HKHealthStore!
    
    // MARK: - Init
    
    private init() {
        hkStore = HKHealthStore()
    }
    
    // MARK: - Methods
    
    func requestPermission () async -> Bool {

        let stepsCount = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!

        let res: ()? = try? await hkStore.requestAuthorization(toShare: [], read: [stepsCount])
        
        guard res != nil else { return false }

        hasAccess = true
        
        return true
    }
    
    func readSteps(beginningAt startDate: Date, andEndingAt endDate: Date = Date()) async -> Int32? {
        
        guard hasAccess else { return nil }

        let numSteps = try! await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Int32?, Error>) in

            let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!
            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
//            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
//            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [.strictStartDate, .strictEndDate])

            var interval = DateComponents()
            interval.day = 1

            let query = HKStatisticsQuery(quantityType: stepsQuantityType, quantitySamplePredicate: predicate, options: [.cumulativeSum]) { _, result, error in
                if let error = error {
                    print("Error retrieving steps: \(error.localizedDescription)\n---\n\(error)")
                    return continuation.resume(returning: nil)
                }

                guard let sum = result?.sumQuantity()
                else {
                    print("Error retrieving steps: no result or valid sum.")
                    return continuation.resume(returning: nil)
                }
                
                let sumDouble = sum.doubleValue(for: HKUnit.count())
                let sumInt = Int32(sumDouble)

                print("Retrieved steps - sumInt: \(sumInt)")
                continuation.resume(returning: sumInt)
            }

            hkStore.execute(query)
        }

        guard let numSteps = numSteps else { return nil }

        return numSteps
    }
}
