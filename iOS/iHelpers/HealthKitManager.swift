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

        let stepsCount = HKObjectType.quantityType(forIdentifier: .stepCount)!

        let res: ()? = try? await hkStore.requestAuthorization(toShare: [], read: [stepsCount])
        
        guard res != nil else { return false }

        hasAccess = true
        
        return true
    }
    
    func getSteps(from startDate: Date, to endDate: Date = Date(), trackName: String) async -> Int32? {
        let fileFunc = "\(file).getSteps(...)"
        print("=== \(fileFunc) - hasAccess: \(hasAccess)")
        
        guard hasAccess else { return nil }

        let numSteps = try! await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Int32?, Error>) in

            let stepCount = HKQuantityType.quantityType(forIdentifier: .stepCount)!

            let endDateForInterval = Calendar.current.date(byAdding: .minute, value: 1, to: endDate)!
            var interval = DateComponents()
            interval.second = Int(endDateForInterval.timeIntervalSince(startDate))
            
            let query = HKStatisticsCollectionQuery(quantityType: stepCount, quantitySamplePredicate: nil, options: [.cumulativeSum], anchorDate: startDate, intervalComponents: interval)
            
            query.initialResultsHandler = { _, result, error in
                if let error = error {
                    print("--- \(fileFunc) - \(trackName) - error retrieving steps: \(error.localizedDescription)\n---\n\(error)")
                    return continuation.resume(returning: nil)
                }

                guard let result = result
                else {
                    print("--- \(fileFunc) - \(trackName) - error retrieving steps: no result.")
                    return continuation.resume(returning: nil)
                }
                
                var sumSteps: Double = 0
                
                result.enumerateStatistics(from: startDate, to: endDate) { statistics, _ in
                    if let sum = statistics.sumQuantity() {
                        sumSteps += sum.doubleValue(for: .count())
                        //print("-- \(fileFunc) - \(trackName) - retrieved steps in enumerate - sum: \(sum), sumSteps: \(sumSteps)")
                    }
                }
                
                let numSteps = Int32(round(sumSteps))

                print("-- \(fileFunc) - \(trackName) - retrieved steps - numSteps: \(numSteps)")
                continuation.resume(returning: numSteps)
            }
            
//            query.statisticsUpdateHandler = { _, statistics, _, error in
//                if let error = error {
//                    print("--- \(fileFunc) - \(trackName) - error retrieving steps: \(error.localizedDescription)\n---\n\(error)")
//                    return continuation.resume(returning: nil)
//                }
//
//                guard let sum = statistics?.sumQuantity()
//                else {
//                    print("--- \(fileFunc) - \(trackName) - error retrieving steps: no statistics or valid sum.")
//                    return continuation.resume(returning: nil)
//                }
//
//                let numSteps = Int32(sum.doubleValue(for: .count()))
//
//                print("-- \(fileFunc) - \(trackName) - retrieved steps - numSteps: \(numSteps)")
//                continuation.resume(returning: numSteps)
//                self.hkStore.stop(query)
//            }

            hkStore.execute(query)
        }

        guard let numSteps = numSteps else { return nil }

        return numSteps
    }
}
