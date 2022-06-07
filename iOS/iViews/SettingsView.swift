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
    
    private var device: Device
    
    @State var isShowingAbout = false
    
    @State var isShowingCannotRecommendAlert = false
    @State var isShowingCannotSendMail = false
    
    @State var result: Result<MFMailComposeResult, Error>? = nil
    @State var isShowingMailView = false
    
    @State var isShowingMailResponseAlert = false
    @State var mailResponseTitle = ""
    @State var mailResponseMessage = ""
    
    @State var isShowingLegal = false
    
    @State var isShowingResetSettings = false
    
    //let file = "SettingsView"
    
    // MARK: - Init
    
    init(device: Device) {
        self.device = device
    }
    
    // MARK: - View
    
    var body: some View {
        List() {
            CodeVersionView()
            
            // Top Section
            
            if device.isPhone {
                NavigationLink(destination: AboutView()) {
                    Text("About")
                }
                .listRowSeparatorTint(.listRowSeparator)
            } else {
                Button(action: { isShowingAbout = true }) {
                    HStack {
                        Text("About")
                        Spacer()
                        NavigationLink.empty
                    }
                }
                .listRowSeparatorTint(.listRowSeparator)
            }
            
            Button(action: { showRecommend() }) {
                HStack {
                    Text("Recommend ATracks")
                        .foregroundColor(.text)
                    Spacer()
                    NavigationLink.empty
                }
            }
            .listRowSeparatorTint(.listRowSeparator)
            
            Button(action: { showMail() }) {
                HStack {
                    Text("Support")
                        .foregroundColor(.text)
                    Spacer()
                    NavigationLink.empty
                }
            }
            .sheet(isPresented: $isShowingMailView) {
                MailView(result: self.$result)
            }
            .listRowSeparatorTint(.listRowSeparator)
            
            if device.isPhone {
                NavigationLink(destination: LegalView()) {
                    Text("Legal")
                }
                .listRowSeparatorTint(.listRowSeparator)
            } else {
                Button(action: { isShowingLegal = true }) {
                    HStack {
                        Text("Legal")
                        Spacer()
                        NavigationLink.empty
                    }
                }
                .listRowSeparatorTint(.listRowSeparator)
            }
            
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
            } header: {
                Text("Tracking Settings")
                    .settingsHeader
            }

            // Display Settings
            
            Section {
                SwitchView(switchText: "Start/Stop On Right In Landscape", switchVal: $displaySettings.placeButtonsOnRightInLandscape)
                SwitchView(switchText: "Map Satellite View", switchVal: $displaySettings.mapViewSatellite)
                SwitchView(switchText: "Map On Right In Landscape", switchVal: $displaySettings.placeMapOnRightInLandscape)

            } header: {
                Text("Display Settings")
                    .settingsHeader
            }
        }
        .listStyle(.plain)
        .navigationTitle("Settings")
        #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
        #endif
        
        .sheet(isPresented: $isShowingAbout) {
            AboutView(isShowingAbout: $isShowingAbout)
        }
        
        .alert("Cannot Connect", isPresented: $isShowingCannotRecommendAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Sorry, we can't connect to the App Store now. Please try again later.")
        }
        
        .alert("Cannot Send Mail", isPresented: $isShowingCannotSendMail) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Sorry, your device is not set up to send mail.")
        }
        
        .onChange(of: isShowingMailView) { _ in
            handleMFMailComposeResult()
        }
        .alert(mailResponseTitle, isPresented: $isShowingMailResponseAlert) {
            Button("OK", role: .none) {}
        } message: {
            Text(mailResponseMessage)
        }
        
        .sheet(isPresented: $isShowingLegal) {
            LegalView(isShowingLegal: $isShowingLegal)
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
    }
    
    // MARK: - Methods
    
    func showRecommend() {

        guard UIApplication.shared.canOpenURL(AppInfo.appStoreURL)
        else {
            isShowingCannotRecommendAlert = true
            return
        }

        UIApplication.shared.open(AppInfo.appStoreURL)
    }
    
    func showMail() {
        
        guard MFMailComposeViewController.canSendMail()
        else {
            isShowingCannotSendMail = true
            return
        }
        
        isShowingMailView = true
    }
    
    func handleMFMailComposeResult() {
        
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

//struct SettingsView_Previews: PreviewProvider {
//    static var previews: some View {
//        SettingsView()
//    }
//}
