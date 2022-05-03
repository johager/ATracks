//
//  SettingsView.swift
//  ATracks (iOS)
//
//  Created by James Hager on 4/19/22.
//

import SwiftUI
import MessageUI

struct SettingsView: View {
    
    @ObservedObject var displaySettings = DisplaySettings.shared
    @ObservedObject var locationManagerSettings = LocationManagerSettings.shared
    
//    @State var isShowingCannotRecommendAlert = false
    
    @State var result: Result<MFMailComposeResult, Error>? = nil
    @State var isShowingMailView = false
    
    @State var isShowingMailResponseAlert = false
    @State var mailResponseTitle = ""
    @State var mailResponseMessage = ""
    
    @State var isShowingResetSettings = false
    
//    @State var mapDisplayOption = "Regular"
//    let mapDisplayOptions = ["Regular", "Satellite"]
    
    let file = "SettingsView"
    
    // MARK: - View
    
    var body: some View {
//        Form {
        List() {
            CodeVersionView()
            
            // Top Section
            
            NavigationLink(destination: AboutView()) {
                Text("About")
            }
            .listRowSeparatorTint(.listRowSeparator)
            
//            Button(action: { showRecommend() }) {
//                HStack {
//                    Text("Recommend ATracks")
//                        .foregroundColor(recommendColor())
//                    Spacer()
//                    NavigationLink.empty
//                }
//            }
//            .disabled(!UIApplication.shared.canOpenURL(AppInfo.appStoreURL))
//            .listRowSeparatorTint(.listRowSeparator)
            
            Button(action: { isShowingMailView = true }) {
                HStack {
                    Text("Support")
                        .foregroundColor(supportColor())
                    Spacer()
                    NavigationLink.empty
                }
            }
            .sheet(isPresented: $isShowingMailView) {
                MailView(result: self.$result)
            }
            .disabled(!MFMailComposeViewController.canSendMail())
            .listRowSeparatorTint(.listRowSeparator)
            
            NavigationLink(destination: LegalView()) {
                Text("Legal")
            }
            .listRowSeparatorTint(.listRowSeparator)
            
            Button(action: { isShowingResetSettings = true }) {
                HStack {
                    Text("Reset Settings")
                    Spacer()
                    NavigationLink.empty
                }
            }
            .listRowSeparatorTint(.listRowSeparator)
            
            // Tracking Settings
            
            Section {
                SwitchView(switchText: "Use Default Track Name", switchVal: $locationManagerSettings.useDefaultTrackName)
                SwitchView(switchText: "Use Auto-Stop", switchVal: $locationManagerSettings.useAutoStop)
//                Text("Setting2")
//                    .ignoresSafeArea()
//                    .listRowBackground(Color.headerBackground)
//                    .listRowInsets(EdgeInsets(top: 0, leading: 64, bottom: 0, trailing: 16))

            } header: {
                Text("Tracking Settings")
                    .settingsHeader
            }
////            .listRowBackground(Color.red.edgesIgnoringSafeArea(.all))
            ///

            // Display Settings
            
            Section {
                SwitchView(switchText: "Map Satellite View", switchVal: $displaySettings.mapViewSatellite)
                SwitchView(switchText: "Map On Right In Landscape", switchVal: $displaySettings.placeMapOnRightInLandscape)
//                Text("Setting2")
//                    .ignoresSafeArea()
//                    .listRowBackground(Color.headerBackground)
//                    .listRowInsets(EdgeInsets(top: 0, leading: 64, bottom: 0, trailing: 16))

            } header: {
                Text("Display Settings")
                    .settingsHeader
            }
            
//            SettingsSectionView(title: "Tracking Settings")
//            
//            SwitchView(switchText: "Use Auto-Stop", switchVal: $locationManagerSettings.useAutoStop)
            
//            // Map Settings
//
//            Section {
//
//                Picker(selection: $mapDisplayOption, label: Text("Map Display Option")) {
//                    ForEach(mapDisplayOptions, id: \.self) { option in
//                        Text(option)
//                    }
//                }
//
//
////                Text("Setting2")
////                    .ignoresSafeArea()
////                    .listRowBackground(Color.headerBackground)
////                    .listRowInsets(EdgeInsets(top: 0, leading: 64, bottom: 0, trailing: 16))
//
//
//            } header: {
//                Text("Map Settings")
////                    .font(.headline)
//                    .font(.title3)
//                    .bold()
//                    .foregroundColor(.headerText)
//                    .kerning(1)
//                    .textCase(.uppercase)
//
////                    .listRowInsets(EdgeInsets(top: -8, leading: 0, bottom: 0, trailing: 0))
//            }
////            .listRowBackground(Color.headerBackground)
////            .headerProminence(.increased)
////            .background(Color.red)
        }
        
//        .ignoresSafeArea()
        .listStyle(.plain)
        .navigationTitle("Settings")
        #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
        #endif
        
//        .alert("Cannot Connect", isPresented: $isShowingCannotRecommendAlert) {
//            Button("OK", role: .cancel) { }
//        } message: {
//            Text("Sorry, we can't connect to the App Store now. Please try again later.")
//        }
        
        .onChange(of: isShowingMailView) { _ in
            handleMFMailComposeResult()
        }
        .alert(mailResponseTitle, isPresented: $isShowingMailResponseAlert) {
            Button("OK", role: .none) {}
        } message: {
            Text(mailResponseMessage)
        }
        
        .alert("Reset All Settings", isPresented: $isShowingResetSettings) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                displaySettings.setDefaults()
                locationManagerSettings.setDefaults()
            }
        } message: {
            Text("Reset all settings to the default values?")
        }
//        }
//        .background(Color.listRowSelectedBackground)
    }
    
    // MARK: - Methods
    
//    func recommendColor() -> Color {
//        if UIApplication.shared.canOpenURL(AppInfo.appStoreURL) {
//            return .text
//        } else {
//            return .textInactive
//        }
//    }
    
    func supportColor() -> Color {
        if MFMailComposeViewController.canSendMail() {
            return .text
        } else {
            return .textInactive
        }
    }
    
//    func showRecommend() {
//        if UIApplication.shared.canOpenURL(AppInfo.appStoreURL) {
//            UIApplication.shared.open(AppInfo.appStoreURL)
//            return
//        }
//
//        isShowingCannotRecommendAlert = true
//    }
    
    func handleMFMailComposeResult() {
        //print("=== \(file).\(#function) ===")
        
        guard !isShowingMailView,
              let result = result
        else { return }
        
        mailResponseTitle = ""
        
        switch result {
        case .success(let mcResult):
            switch mcResult {
            case .saved:
                mailResponseTitle = "Message Saved"
                mailResponseMessage = "The message was saved in your Drafts folder."
            case .sent:
                mailResponseTitle = "Message Sent"
                mailResponseMessage = "The message was queued to your Outbox and will be sent as soon as possible."
            case .failed:
                mailResponseTitle = "Message Failed"
                mailResponseMessage = "There was an unknown error."
            default:  // .cancelled
                break
            }
        case .failure(let error):
            mailResponseTitle = "Message Failed"
            mailResponseMessage = error.localizedDescription
        }
        
        if mailResponseTitle.isEmpty {
            return
        }
        
        Func.afterDelay(0.3) {
            isShowingMailResponseAlert = true
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
