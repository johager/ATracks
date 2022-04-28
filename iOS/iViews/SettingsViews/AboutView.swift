//
//  AboutView.swift
//  ATracks (iOS)
//
//  Created by James Hager on 4/22/22.
//

import SwiftUI

struct AboutView: View {
    
    @Binding private var isOnboarding: Bool
    
    init(isOnboarding: Binding<Bool> = .constant(false)) {
        self._isOnboarding = isOnboarding
        OnboardingHelper.setHasOnboarded()
    }
    
    let introText: [String] = [
        "ATracks records location, elevation, and step data for your outdoor activities. Data is stored locally so that you'll always have it, and data is synched to other devices with the same Apple ID so you can view your excursions on larger screens.",
        "Your data is stored in your own private iCloud account, and no one without access to your Apple ID can access that data."
    ]
    
    var body: some View {
        ZStack {
            List() {
                if isOnboarding {
                    Text("Welcome to ATracks!")
                        .padding(.top, 24)
                        .listRowSeparator(.hidden)
                    
                    Text("This information is provided to help you get started. You can view it again later on the in-app Settings > About page.")
                        .listRowSeparator(.hidden)
                    
                    Section {
                        ForEach(0..<introText.count, id: \.self) { index in
                            Text(introText[index])
                        }
                    } header: {
                        Text("About")
                            .font(.title3)
                            .bold()
                            .foregroundColor(.headerText)
                            .kerning(1)
                            .textCase(.uppercase)
                    }
                    .listRowSeparator(.hidden)
                } else {
                    ForEach(0..<introText.count, id: \.self) { index in
                        Text(introText[index])
                    }
                    .listRowSeparator(.hidden)
                }
                
                Section {
                    Text("The location and elevation data is obtained from the GPS in your device. You must allow ATracks to use your location. The app will first ask permission to \"Allow Once\" or \"Allow While Using App\". Select \"Allow While Using App\" so that your track can be followed. This will only allow tracking while the app is active. After you grant permission for \"Allow While Using App\" and start tracking, exit the app so that you can be prompted to allow background tracking by selecting \"Change to Always Allow.\" If you don't allow background tracking, the app will not provide accurate locations while you are tracking your activity if the app is not active.")
                    Text("The steps data is obtained from the Apple Health app, and you must allow ATracks to read \"Steps.\"")
                } header: {
                    Text("Set Up")
                        .font(.title3)
                        .bold()
                        .foregroundColor(.headerText)
                        .kerning(1)
                        .textCase(.uppercase)
                }
                .listRowSeparator(.hidden)
                
                Section {
                    Text("The app can be set up to require that you \"Start\" and \"Stop\" tracking each excursion or have the app Auto-Stop the tracking.")
                    Text("Auto-Stop will stop the tracking if you are more than 20 yds away from your starting point more than 30 seconds after starting to track, and then return within 8 yds of your starting point.")
                } header: {
                    Text("Tracking - Auto Stop")
                        .font(.title3)
                        .bold()
                        .foregroundColor(.headerText)
                        .kerning(1)
                        .textCase(.uppercase)
                }
                .listRowSeparator(.hidden)
                
                Section {
                    Text("The step data is not available from the Health App immediately, so there is always a lag in the data. Final data is usually available 24 hours after completing your activity.")
                    Text("Note that this version of the app does not try to update steps after tracking stops. The app will be updated soon to do this.")
                } header: {
                    Text("Steps")
                        .font(.title3)
                        .bold()
                        .foregroundColor(.headerText)
                        .kerning(1)
                        .textCase(.uppercase)
                }
                .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            
            if isOnboarding {
                VStack() {
                    HStack() {
                        Spacer()
                        Button {
                            self.isOnboarding = false
                        } label: {
                            Image(systemName: "xmark.circle")
                                .font(.title)
                                .tint(.textSelectable)
                        }
                    }
                    Spacer()
                }
                .padding([.top, .trailing], 6)
            }
        }
        .navigationTitle("About")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
