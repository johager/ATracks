//
//  SettingsView.swift
//  ATracks (iOS)
//
//  Created by James Hager on 4/19/22.
//

import SwiftUI
import MessageUI

struct SettingsView: View {
    
    @ObservedObject var locationManagerSettings = LocationManagerSettings.shared
    
    @State var result: Result<MFMailComposeResult, Error>? = nil
    @State var isShowingMailView = false
    
    var body: some View {
        List() {
            CodeVersionView()
            
            NavigationLink(destination: AboutView()) {
                Text("About")
            }
            
            Button(action: showMailView) {
                HStack {
                    Text("Support")
                    Spacer()
                    NavigationLink.empty
                }
            }
            .sheet(isPresented: $isShowingMailView) {
                MailView(result: self.$result)
            }
            
            NavigationLink(destination: LegalView()) {
                Text("Legal")
            }
            
            Section {
                SwitchView(switchText: "Use Auto-Stop", switchVal: $locationManagerSettings.useAutoStop)
//                Text("Setting2")
//                    .ignoresSafeArea()
//                    .listRowBackground(Color.headerBackground)
//                    .listRowInsets(EdgeInsets(top: 0, leading: 64, bottom: 0, trailing: 16))
            } header: {
                Text("Tracking Settings")
//                    .font(.headline)
                    .font(.title3)
                    .bold()
                    .foregroundColor(.headerText)
                    .kerning(1)
                    .textCase(.uppercase)
                    
//                    .listRowInsets(EdgeInsets(top: -8, leading: 0, bottom: 0, trailing: 0))
            }
//            .listRowBackground(Color.headerBackground)
//            .headerProminence(.increased)
//            .background(Color.red)
        }
        
//        .ignoresSafeArea()
        .listStyle(.plain)
        .navigationTitle("Settings")
        #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
        #endif
    }
    
    func showMailView() {
        isShowingMailView = true
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
