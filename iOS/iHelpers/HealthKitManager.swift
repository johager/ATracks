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
    
    func readSteps(beginningAt startDate: Date, andEndingAt endDate: Date = Date(), dateOptions: HealthKitDateOptions = .start, trackName: String) async -> Int32? {
        let fileFunc = "\(file).readSteps(...)"
        print("=== \(fileFunc) - hasAccess: \(hasAccess)")

        guard hasAccess else { return nil }

        let numSteps = try! await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Int32?, Error>) in

            let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: dateOptions.queryOptions)

            let query = HKStatisticsQuery(quantityType: stepsQuantityType, quantitySamplePredicate: predicate, options: [.cumulativeSum]) { _, result, error in
                if let error = error {
                    print("--- \(fileFunc) - \(trackName) - error retrieving steps: \(error.localizedDescription)\n---\n\(error)")
                    return continuation.resume(returning: nil)
                }

                guard let sum = result?.sumQuantity()
                else {
                    print("--- \(fileFunc) - \(trackName) - error retrieving steps: no result or valid sum.")
                    return continuation.resume(returning: nil)
                }

                let numSteps = Int32(round(sum.doubleValue(for: .count())))

                print("-- \(fileFunc) - \(trackName) - retrieved steps - numSteps: \(numSteps)")
                continuation.resume(returning: numSteps)
            }

            hkStore.execute(query)
        }

        guard let numSteps = numSteps else { return nil }

        return numSteps
    }
    
    /*
    func readSteps(beginningAt startDate: Date, andEndingAt endDate: Date = Date(), dateOptions: HealthKitDateOptions = .start, trackName: String) async -> Int32? {
        let fileFunc = "\(file).readSteps(...)"
        print("=== \(fileFunc) - hasAccess: \(hasAccess)")
        
        guard hasAccess else { return nil }

        let numSteps = try! await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Int32?, Error>) in

            let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!

            let endDateUse = Calendar.current.date(byAdding: .minute, value: 1, to: endDate)!
            var interval = DateComponents()
            interval.second = Int(endDateUse.timeIntervalSince(startDate))
            
            let query = HKStatisticsCollectionQuery(quantityType: stepsQuantityType, quantitySamplePredicate: nil, options: [.cumulativeSum], anchorDate: startDate, intervalComponents: interval)
            
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
                        print("-- \(fileFunc) - \(trackName) - retrieved steps in enumerate - sum: \(sum), sumSteps: \(sumSteps)")
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
    */
    
    func readCurrentSteps(trackName: String = "") async -> Int32? {
        let fileFunc = "\(file).readCurrentSteps(...)"
        print("=== \(fileFunc) - hasAccess: \(hasAccess)")
        
        guard hasAccess else { return nil }
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        var interval = DateComponents()
        interval.day = 1
        
        let numSteps = try! await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Int32?, Error>) in

            let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!

            let query = HKStatisticsCollectionQuery(quantityType: stepsQuantityType, quantitySamplePredicate: nil, options: [.cumulativeSum], anchorDate: startOfDay, intervalComponents: interval)
            
            query.initialResultsHandler = { _, result, error in
                if let error = error {
                    print("--- \(fileFunc) - \(trackName) - error retrieving steps in initialResultsHandler: \(error.localizedDescription)\n---\n\(error)")
                    return continuation.resume(returning: nil)
                }

                guard let result = result
                else {
                    print("--- \(fileFunc) - \(trackName) - error retrieving steps in initialResultsHandler: no result.")
                    return continuation.resume(returning: nil)
                }
                
                var numSteps: Int32 = 0
                
                result.enumerateStatistics(from: startOfDay, to: now) { statistics, _ in
                    if let sum = statistics.sumQuantity() {
                        numSteps = Int32(round(sum.doubleValue(for: .count())))
                        print("-- \(fileFunc) - \(trackName) - retrieved steps in enumerate - numSteps: \(numSteps)")
                    }
                }

                print("-- \(fileFunc) - \(trackName) - retrieved steps in initialResultsHandler - numSteps: \(numSteps)")
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
