//
//  ATracksApp.swift
//  Shared
//
//  Created by James Hager on 4/18/22.
//

import SwiftUI

@main
struct ATracksApp: App {
    @Environment(\.scenePhase) var scenePhase
    
    let coreDataStack = CoreDataStack.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, coreDataStack.context)
                .onChange(of: scenePhase) { newPhase in
                    switch newPhase {
                    case .active:
                        print("\(#function) - active")
                        LocationManager.shared.sceneDidBecomeActive()
                        //doSpecialStartUp()
                    case .inactive:
                        print("\(#function) - inactive")
                        LocationManager.shared.sceneDidBecomeInActive()
                    case .background:
                        print("\(#function) - background")
                    default:
                        print("\(#function) - newPhase: \(newPhase)")
                    }
                }
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
}
