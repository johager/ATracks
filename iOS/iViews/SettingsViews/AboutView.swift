//
//  AboutView.swift
//  ATracks (iOS)
//
//  Created by James Hager on 4/22/22.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        List() {
            Text("ATracks records location, elevation, and step data for your outdoor activities. Data is stored locally so that you'll always have it, and data is synched to other devices with the same Apple ID so you can view your excursions on larger screens.")
                .listRowSeparator(.hidden)
            Text("Your data is stored in your own private iCloud account, and no one without access to your Apple ID can access that data.")
                .listRowSeparator(.hidden)
            
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
