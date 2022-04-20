//
//  ATracksApp.swift
//  Shared
//
//  Created by James Hager on 4/18/22.
//

import SwiftUI
#if os(iOS)
import HealthKit
#endif

@main
struct ATracksApp: App {
    @Environment(\.scenePhase) var scenePhase
    
    let coreDataStack = CoreDataStack.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, coreDataStack.context)
                .onChange(of: scenePhase) { scenePhaseChanged(to: $0) }
                .task { await checkHealthKit() }
        }
        
    }
    
    // MARK: - ScenePhase Methods
    
    func scenePhaseChanged(to phase: ScenePhase) {
        switch phase {
        case .active:
            print("\(#function) - active")
            #if os(iOS)
            //LocationManager.shared.sceneDidBecomeActive()
            #endif
            //doSpecialStartUp()
        #if os(iOS)
        case .inactive:
            print("\(#function) - inactive")
            //LocationManager.shared.sceneDidBecomeInActive()
        #endif
        case .background:
            print("\(#function) - background")
        default:
            print("\(#function) - phase: \(phase)")
        }
    }
    
    func doSpecialStartUp() {
        let coreDataStack = CoreDataStack.shared
        let context = coreDataStack.context
        
        let fetchRequest = Track.fetchRequest
        
        do {
            let tracks = try context.fetch(fetchRequest)
            print("\(#function) - tracks.count: \(tracks.count)")
            
            for track in tracks {
                track.duration /= 3600
            }
            
            coreDataStack.saveContext()
            
        } catch {
            print("\(#function) - error fetching")
        }
    }
    
    // MARK: - HealthKit Methods
    
    func checkHealthKit() async {
        #if os(iOS)
        print("\(#function)")
        
        guard HKHealthStore.isHealthDataAvailable() else { return }
        
        guard await HealthKitManager.shared.requestPermission() == true else { return }
        #endif
    }
}
