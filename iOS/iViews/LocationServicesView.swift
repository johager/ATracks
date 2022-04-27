//
//  LocationServicesView.swift
//  ATracks (iOS)
//
//  Created by James Hager on 4/27/22.
//

import SwiftUI
import CoreLocation

struct LocationServicesView: View {
    
//    @Environment(\.horizontalSizeClass) var horizontalSizeClass
//    @Environment(\.verticalSizeClass) var verticalSizeClass
//    var isiPad: Bool { verticalSizeClass == .regular && horizontalSizeClass == .regular }
    @State private var locationServicesEnabled = "false"
    @State private var significantLocationChangeMonitoringAvailable = "false"
    @State private var headingAvailable = "false"
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("locationServicesEnabled: \(locationServicesEnabled)")
            Text("significantLocationChangeMonitoringAvailable: \(significantLocationChangeMonitoringAvailable)")
            Text("headingAvailable: \(headingAvailable)")
        }
        .onAppear() {
            locationServicesEnabled = "\(CLLocationManager.locationServicesEnabled())"
            significantLocationChangeMonitoringAvailable = "\(CLLocationManager.significantLocationChangeMonitoringAvailable())"
            headingAvailable = "\(CLLocationManager.headingAvailable())"
        }
    }
}

struct LocationServicesView_Previews: PreviewProvider {
    static var previews: some View {
        LocationServicesView()
    }
}
