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
    
    @ObservedObject var displaySettings = DisplaySettings.shared
    @ObservedObject var trackManager = TrackManager.shared
    
    @State private var wasInactive = true
    
    @State private var hasOnboarded = false
    @State private var isOnboarding = false
    
    let device = Device.shared
    
    let coreDataStack = CoreDataStack.shared
    
    let file = "ATracksApp"
    
    // MARK: - Init
    
    init() {
//        UserDefaults.standard.set(false, forKey: OnboardingHelper.hasOnboardedKey)
//        UserDefaults.standard.synchronize()
        DataStateHelper.checkDataState()
//        let useAutoStop = UserDefaults.standard.bool(forKey: LocationManagerSettings.useAutoStopKey)
//        print("=== \(file).\(#function) - useAutoStop: \(useAutoStop) ===")
//        print("=== \(file).\(#function) - deviceName: \(Func.deviceName) ===")
//        print("=== \(file).\(#function) - deviceUUID: \(Func.deviceUUID) ===")
    }
    
    // MARK: - Scene
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, coreDataStack.context)
                .environmentObject(displaySettings)
                .environmentObject(trackManager)
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
                    //print("=== \(file).\(#function) - onChange - hasOnboarded: \(hasOnboarded) ===")
                    #if os(iOS)
                    handleActive()
                    #endif
                }
                .onChange(of: isOnboarding) { _ in
                    //print("=== \(file).\(#function) - onChange - isOnboarding: \(isOnboarding) ===")
                    if !isOnboarding {
                        hasOnboarded = true
                    }
                }
                .onChange(of: scenePhase) { scenePhaseChanged(to: $0) }
                .sheet(isPresented: $isOnboarding) {
                    #if os(iOS)
                    AboutView(isOnboarding: $isOnboarding)
                    #else
                    OnboardingView(isOnboarding: $isOnboarding)
                    #endif
                }
        }
        #if os(macOS)
        Settings {
            SettingsView()
        }
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("About ATracks") {
                    NSApplication.shared.orderFrontStandardAboutPanel(
                        options: [
                            NSApplication.AboutPanelOptionKey(rawValue: "Copyright"): "© \(AppInfo.copyrightYear) Avanti Applications, LLC"
                        ]
                    )
                }
            }
            SidebarCommands()
        }
        #endif
    }
    // MARK: - ScenePhase Methods
    
    func scenePhaseChanged(to phase: ScenePhase) {
        switch phase {
        case .active:
            print("=== \(file).\(#function) - active, hasOnboarded: \(hasOnboarded), wasInactive: \(wasInactive) ===")
            #if os(iOS)
            device.hasSafeAreaInsets = Func.hasSafeAreaInsets
            handleActive()
            #endif
            //doSpecialStartUp()
            NotificationCenter.default.post(name: .scenePhaseChangedToActive, object: nil, userInfo: nil)
        #if os(iOS)
        case .inactive:
            print("=== \(file).\(#function) - inactive, hasOnboarded: \(hasOnboarded) ===")
            #if os(iOS)
            if hasOnboarded {
                LocationManager.shared.sceneDidBecomeInactive()
            }
            #endif
            wasInactive = true
        #endif
        case .background:
            print("=== \(file).\(#function) - background, hasOnboarded: \(hasOnboarded) ===")
        default:
            print("=== \(file).\(#function) - phase: \(phase), hasOnboarded: \(hasOnboarded) ===")
        }
    }
    
    func handleActive() {
        print("=== \(file).\(#function) - hasOnboarded: \(hasOnboarded), wasInactive: \(wasInactive) ===")
        
        defer {
            wasInactive = false
        }
        
        #if os(iOS)
        guard hasOnboarded, wasInactive else { return }
        LocationManager.shared.sceneDidBecomeActive()
        Task { await updateSteps() }
        #endif
    }
    
//    func doSpecialStartUp() {
//        makeTrack(daysAgo: 90)
//        makeTrack(daysAgo: 3)
//        makeTrack(daysAgo: -1)
//    }
//
//    func makeTrack(daysAgo: Int) {
//        let date = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date())!
//        Track(name: "<[ \(daysAgo) Days Ago ]>", deviceName: "dummy", deviceUUID: "123", date: date, isTracking: false)
//    }
    
//    func doSpecialStartUp() {
//        let fetchRequest = Track.fetchRequest
//
//        let dateCheck = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
//        fetchRequest.predicate = NSPredicate(format: "%K > %@", Track.dateKey, dateCheck as CVarArg)
//
//        do {
//            let tracks = try coreDataStack.context.fetch(fetchRequest)
//            print("=== \(file).\(#function) - tracks.count: \(tracks.count) ===")
//
//            for track in tracks {
//                let trackName = track.debugName
//                print("--- \(file).\(#function) - trackName: \(trackName)")
//                applyAutoStop(to: track)
//            }
//
//            //coreDataStack.saveContext()
//
//        } catch {
//            print("=== \(file).\(#function) - error fetching")
//        }
//    }
//
//    func applyAutoStop(to track: Track) {
//        print("=== \(file).\(#function) - \(track.debugName) ===")
//
//        let trackPoints = track.trackPoints
//
//        guard trackPoints.count > 2 else { return }
//
//        let autoStopMinDistToStart: Double = 20
//        let autoStopMinDistToStop: Double = 8 //4 //2
//        let autoStopMinTimeIntToStart: TimeInterval = 30
//
//        var shouldCheckAutoStop = false
//
//        let firstPointIndex = 4
//        let firstLocation = trackPoints[firstPointIndex].clLocation
//
//        print("--- \(file).\(#function) - first: \(trackPoints[firstPointIndex].timestamp.stringForDebug), lat/lon \(firstLocation.coordinate.latitude), \(firstLocation.coordinate.longitude)")
//
//        for i in firstPointIndex+1..<trackPoints.count {
//            let trackPoint = trackPoints[i]
//            let dTime = trackPoint.timestamp.timeIntervalSince(trackPoints[firstPointIndex].timestamp)
//            let dLoc = trackPoint.clLocation.distance(from: firstLocation)
//            print("--- \(file).\(#function) - i: \(i), dTime: \(dTime), dLoc: \(dLoc), shouldCheckAutoStop: \(shouldCheckAutoStop)")
//            guard shouldCheckAutoStop
//            else {
//                shouldCheckAutoStop = dTime > autoStopMinTimeIntToStart && dLoc > autoStopMinDistToStart
//                continue
//            }
//            if dLoc < autoStopMinDistToStop {
//                print("--- \(file).\(#function) - i: \(i) - delete")
//                //trimTrack(track, begin: firstPointIndex, end: i + 1)
//                return
//            }
//        }
//    }
//
//    func trimTrack(_ track: Track, begin: Int, end: Int) {
//        print("=== \(file).\(#function) - begin: \(begin), end: \(end) ===")
//        let context = coreDataStack.context
//        var trackPoints = track.trackPoints
//        print("--- \(file).\(#function) - trackPoints.count: \(trackPoints.count)")
//
//        var didDelete = false
//
//        if end < trackPoints.count {
//            didDelete = true
//            for i in end..<trackPoints.count {
//                context.delete(trackPoints[i])
//                print("--- \(file).\(#function) - i: \(i) - delete")
//            }
//        }
//
//        if begin > 0 {
//            didDelete = true
//            for i in 0..<begin {
//                context.delete(trackPoints[i])
//                print("--- \(file).\(#function) - i: \(i) - delete")
//            }
//        }
//
//        guard didDelete else { return }
//
//        coreDataStack.saveContext()
//
//        trackPoints = track.trackPoints
//        print("--- \(file).\(#function) - trackPoints.count: \(trackPoints.count)")
//
//        track.date = trackPoints[0].timestamp
//        track.setTrackSummaryData()
//    }
    
    // MARK: - HealthKit Methods
    
    func updateSteps() async {
        #if os(iOS)
        print("=== \(file).\(#function) ===")
        
        guard await HealthKitManager.shared.requestPermission() == true else { return }
        
        TrackManager.shared.updateSteps()
        #endif
    }
}
