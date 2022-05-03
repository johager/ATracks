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
    
    @State private var hasOnboarded = false
    @State private var isOnboarding = false
    
    @State var hasSafeAreaInsets = false
    
    let coreDataStack = CoreDataStack.shared
    
    let file = "ATracksApp"
    
    // MARK: - Init
    
    init() {
        DataStateHelper.checkDataState()
//        let useAutoStop = UserDefaults.standard.bool(forKey: LocationManagerSettings.useAutoStopKey)
//        print("=== \(file).\(#function) - useAutoStop: \(useAutoStop) ===")
//        print("=== \(file).\(#function) - deviceName: \(Func.deviceName) ===")
//        print("=== \(file).\(#function) - deviceUUID: \(Func.deviceUUID) ===")
    }
    
    // MARK: - Scene
    
    var body: some Scene {
        WindowGroup {
            ContentView(hasSafeAreaInsets: $hasSafeAreaInsets)
                .environment(\.managedObjectContext, coreDataStack.context)
                .onAppear {
                    if OnboardingHelper.shouldOnboard {
                        //print("=== \(file).\(#function) - onAppear - shouldOnboard ===")
                        isOnboarding = true
                    } else {
                        //print("=== \(file).\(#function) - onAppear - shouldOnboard not ===")
                        hasOnboarded = true
                    }
                }
                .onChange(of: hasOnboarded) { _ in
                    print("=== \(file).\(#function) - onChange - hasOnboarded: \(hasOnboarded) ===")
                    #if os(iOS)
                    LocationManager.shared.sceneDidBecomeActive()
                    #endif
                    Task { await checkHealthKit() }
                }
                .onChange(of: isOnboarding) { _ in
                    //print("=== \(file).\(#function) - onChange - isOnboarding: \(isOnboarding) ===")
                    if !isOnboarding {
                        hasOnboarded = true
                    }
                }
                .onChange(of: scenePhase) { scenePhaseChanged(to: $0) }
                #if os(iOS)
                .sheet(isPresented: $isOnboarding) {
                    AboutView(isOnboarding: $isOnboarding)
                }
                #endif
        }
    }
    // MARK: - ScenePhase Methods
    
    func scenePhaseChanged(to phase: ScenePhase) {
        switch phase {
        case .active:
            print("=== \(file).\(#function) - active, hasOnboarded: \(hasOnboarded) ===")
            #if os(iOS)
            hasSafeAreaInsets = Func.hasSafeAreaInsets
            if hasOnboarded {
                LocationManager.shared.sceneDidBecomeActive()
            }
            #endif
            //doSpecialStartUp()
        #if os(iOS)
        case .inactive:
            print("=== \(file).\(#function) - inactive, hasOnboarded: \(hasOnboarded) ===")
            #if os(iOS)
            if hasOnboarded {
                LocationManager.shared.sceneDidBecomeInActive()
            }
            #endif
        #endif
        case .background:
            print("=== \(file).\(#function) - background, hasOnboarded: \(hasOnboarded) ===")
        default:
            print("=== \(file).\(#function) - phase: \(phase), hasOnboarded: \(hasOnboarded) ===")
        }
    }
    
    func doSpecialStartUp() {
        let coreDataStack = CoreDataStack.shared
        let context = coreDataStack.context
        
        let fetchRequest = Track.fetchRequest
        
        do {
            let tracks = try context.fetch(fetchRequest)
            print("=== \(file).\(#function) - tracks.count: \(tracks.count) ===")
            
            for track in tracks {
                track.duration /= 3600
            }
            
            coreDataStack.saveContext()
            
        } catch {
            print("=== \(file).\(#function) - error fetching")
        }
    }
    
    // MARK: - HealthKit Methods
    
    func checkHealthKit() async {
        #if os(iOS)
        print("=== \(file).\(#function) ===")
        
        guard await HealthKitManager.shared.requestPermission() == true else { return }
        
        TrackManager.shared.updateSteps()
        #endif
    }
}
