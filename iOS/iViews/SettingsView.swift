//
//  SettingsView.swift
//  ATracks (iOS)
//
//  Created by James Hager on 4/19/22.
//

import SwiftUI
import MessageUI

struct SettingsView: View {
    
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
                Text("Setting1")
//                    .ignoresSafeArea()
//                    .listRowBackground(Color.headerBackground)
//                    .listRowInsets(EdgeInsets(top: 0, leading: 64, bottom: 0, trailing: 16))
                Text("Setting2")
            } header: {
                Text("Settings")
//                    .font(.headline)
                    .font(.title)
                    .bold()
                    .foregroundColor(.headerText)
                    .kerning(3)
//                    .textCase(.uppercase)
                    
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
