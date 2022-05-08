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
            print("=== \(file).\(#function): \(hasAccess) ===")
        }
    }
    
    private var hkStore: HKHealthStore!
    
    lazy var file = Func.sourceFileNameFromFullPath(#file)
    
    // MARK: - Init
    
    private init() {
        hkStore = HKHealthStore()
    }
    
    // MARK: - Methods
    
    func requestPermission() async -> Bool {
        
        #if targetEnvironment(simulator)
        return false
        #endif
        
        guard HKHealthStore.isHealthDataAvailable() else { return false }

        let stepsCount = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!

        let res: ()? = try? await hkStore.requestAuthorization(toShare: [], read: [stepsCount])
        
        guard res != nil else { return false }

        hasAccess = true
        
        return true
    }
    
    func readSteps(beginningAt startDate: Date, andEndingAt endDate: Date = Date(), dateOptions: HealthKitDateOptions = .start) async -> Int32? {
        print("=== \(file).\(#function) - hasAccess: \(hasAccess)")
        
        guard hasAccess else { return nil }

        let numSteps = try! await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Int32?, Error>) in

            let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!
            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: dateOptions.queryOptions)

            let query = HKStatisticsQuery(quantityType: stepsQuantityType, quantitySamplePredicate: predicate, options: [.cumulativeSum]) { _, result, error in
                if let error = error {
                    print("=== \(self.file).\(#function) - error retrieving steps: \(error.localizedDescription)\n---\n\(error)")
                    return continuation.resume(returning: nil)
                }

                guard let sum = result?.sumQuantity()
                else {
                    print("=== \(self.file).\(#function) - error retrieving steps: no result or valid sum.")
                    return continuation.resume(returning: nil)
                }
                
                let numSteps = Int32(sum.doubleValue(for: .count()))

                print("=== \(self.file).\(#function) - retrieved steps - numSteps: \(numSteps)")
                continuation.resume(returning: numSteps)
            }

            hkStore.execute(query)
        }

        guard let numSteps = numSteps else { return nil }

        return numSteps
    }
}
