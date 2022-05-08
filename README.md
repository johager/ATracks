# ATracks

This is my capstone project for the Devmountain iOS App Developer Bootcamp.

The app tracks a user's activity. It maps the location using GPS coordinates from CoreLocation, and tracks a user's steps using HealthKit to access the Apple Health app.

Track data is persisted locally using CoreData and in the cloud using CloudKit via an NSPersistentCloudKitContainer. Track data is synched between all devices with the same Apple ID.

User settings are stored locally using UserDefaults.

The app is designed to work on iOS, iPadOS, and macOS.

### Development

The app was developed using Swift and SwiftUI. Some features required bridging to AppKit and UIKit:

- Alert with a text field
- MKMapView with an MKOverlay
- Detect tap on MKMapView
- Detect touch position on View
- Present MFMailComposeViewController

### Technology

Swift, SwiftUI, AppKit, UIKit, CoreData, CoreLocation, HealthKit, MapKit, XCTest

### iOS App Screen Shots

![Track List](https://avantiapplications.com/images/at_ss1_tracks_01_iphone13prographite_portrait_half.png)

![Track Detail](https://avantiapplications.com/images/at_ss2_track_01_iphone13prographite_portrait_half.png)

### App Store

The iOS version was released to the App Store on May 5, 2022. Get it at https://itunes.apple.com/us/app/atracks/id1619330372
