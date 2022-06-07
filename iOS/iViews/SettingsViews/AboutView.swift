//
//  AboutView.swift
//  ATracks (iOS)
//
//  Created by James Hager on 4/22/22.
//

import SwiftUI

struct AboutView: View {
    
    @Binding private var isOnboarding: Bool
    @Binding private var isShowingAbout: Bool
    
    let introText: [String] = [
        "ATracks records location, elevation, and step data for your outdoor activities. Data is stored locally so that you'll always have it, and data is synched to other devices with the same Apple ID so you can view your excursions on larger screens.",
        "Your data is stored in your own private iCloud account, and no one without access to your Apple ID can access that data.",
        "Step data is obtained from the Apple Health app, and is only imported into ATracks while ATracks is actively running on an iPhone or iPod Touch."
    ]
    
    // MARK: - Init
    
    init(isOnboarding: Binding<Bool> = .constant(false), isShowingAbout: Binding<Bool> = .constant(false)) {
        _isOnboarding = isOnboarding
        _isShowingAbout = isShowingAbout
        OnboardingHelper.setHasOnboarded()
    }
    
    // MARK: - View
    
    var body: some View {
        ZStack {
            List {
                if isOnboarding {
                    Text("Welcome to ATracks!")
                        .settingsSubHeader
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
                            .settingsHeader
                    }
                    .listRowSeparator(.hidden)
                } else {
                    ForEach(0..<introText.count, id: \.self) { index in
                        Text(introText[index])
                    }
                    .listRowSeparator(.hidden)
                }
                
                Section {
                    if DeviceType.current() == .phone {
                        Text("Location Set Up")
                            .settingsSubHeader
                    }
                    Text("The location and elevation data is obtained from the GPS in your device. You must allow ATracks to track your location. Providing location access \"While Using the App\" will allow ATracks to track your location only when the app is active, and \"Always\" will allow ATracks to track your location while the app is in the background.")
                    Text("The app will first ask permission to \"Allow Once\" or \"Allow While Using App\". Select \"Allow While Using App\" so that your track can be followed. This will only allow tracking while the app is active. After you grant permission for \"Allow While Using App\" and start tracking, exit the app so that you can be prompted to allow background tracking by selecting \"Change to Always Allow.\"")
                    Text("Alternatively, you can go to the device Settings > ATracks > Location and select \"Always\".")
                    
                    if DeviceType.current() == .phone {
                        Text("Steps Set Up")
                            .settingsSubHeader
                        Text("The steps data is obtained from the Apple Health app, and you must allow ATracks to read \"Steps\" on an iPhone or iPod Touch.")
                    }
                } header: {
                    Text("Set Up")
                        .settingsHeader
                }
                .listRowSeparator(.hidden)
                
                Section {
                    Text("Start Tracking")
                        .settingsSubHeader
                    Text("Tapping on the \"Start\" button is the easiest way to start tracking your activity. An alert will ask you for a track name, and you can enter a custom name or leave it blank and the default, timestamp name will be used. You can turn off the alert in settings if you like to use the default name.")
                    Text("You can also start a track by swiping on a track with the name that you would like to use for the new track, and then tapping on the \"timer\" icon.")
                    
                    Text("Stop Tracking")
                        .settingsSubHeader
                    Text("Auto-Stop will stop the tracking if you are more than 20 yds away from your starting point more than 30 seconds after starting to track, and then return within 8 yds of your starting point. The stop button will show \"[Stop]\" or \"[Stop Tracking]\" when auto-stop is turned on to indicate that tapping the stop button is unnecessary.")
                    Text("Auto-Stop can be turned on and off on the in-app Settings page.")
                } header: {
                    Text("Tracking")
                        .settingsHeader
                }
                .listRowSeparator(.hidden)
                
                Section {
                    Text("The step data is not available from the Health App immediately, so there is always a lag in the data. Final data is usually available a couple of hours after completing your activity.")
                    Text("Steps are only recorded on an iPhone, iPod Touch, or Apple Watch, and step data is only transferred into ATracks when the app is running on an iPhone or iPod Touch. So, while it's possible to create a track on an iPad and use an Apple Watch to record the steps, the step data will not appear in ATracks until after you launch ATracks on an iPhone or iPod Touch.")
                } header: {
                    Text("Steps")
                        .settingsHeader
                }
                .listRowSeparator(.hidden)
                
                Section {
                    Text("Search tracks by track name by pulling down on the track list to reveal the search bar.")
                    Text("The search is not case-sensitive, and supports partial, exact\u{00a0}(\"\"), AND\u{00a0}(+), and NOT\u{00a0}(-) searching.")
                } header: {
                    Text("Search")
                        .settingsHeader
                }
                .listRowSeparator(.hidden)
                
                Section {
                    Text("Swipe between tracks by swiping left, for next, or right, for previous, in the stats area (Duration, Avg Speed, Timestamp, Distance, Steps).")
                    Text("Tap on the map to recenter the track.")
                    Text("A green pin marker is used to indicate the beginning of a track. If the track is one-way, the end of the track has a red pin marker.")
                    Text("The average elevation is a time-weighted average.")
                    Text("Touch or swipe on the elevation plot to display that point on the map and also its latitude, longitude, and elevation.")
                } header: {
                    Text("Display")
                        .settingsHeader
                }
                .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            .padding(.top, isShowingAbout ? 40 : 6)
            
            if isOnboarding {
                VStack {
                    HStack {
                        Spacer()
                        Button {
                            isOnboarding = false
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
            
            if isShowingAbout {
                VStack {
                    ZStack {
                        Text("About")
                            .settingsSubHeader
                        HStack {
                            Spacer()
                            Button {
                                isShowingAbout = false
                            } label: {
                                Image(systemName: "xmark.circle")
                                    .font(.title)
                                    .tint(.textSelectable)
                            }
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
