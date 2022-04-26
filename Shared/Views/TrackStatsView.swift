//
//  TrackDetailsView.swift
//  ATracks
//
//  Created by James Hager on 4/18/22.
//

import SwiftUI

struct TrackStatsView: View {
    
    @ObservedObject var track: Track
    
    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Text("Duration: \(track.duration.stringWithUnits)")
                Spacer()
                Text("Distance: \(String(format: "%.2f", track.distance)) mi")
            }
            HStack {
                Text("Ave Speed: \(track.aveSpeed.stringForSpeed) mph")
                Spacer()
                Text("Steps: \(track.steps.stringWithNA)")
            }
        }
        .font(.footnote)
        .foregroundColor(.text)
        .padding([.top, .bottom], 8)
        .padding([.trailing, .leading], 32)
        #if os(iOS)
        .task {
            guard let endDate = track.trackPoints.last?.timestamp else { return }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd, h:mm:ss a"
            let file = "TrackStatsView"
            print("=== \(file).task - start date: \(dateFormatter.string(from: track.date))==")
            print("--- \(file).task -   end date: \(dateFormatter.string(from: endDate))")
            guard let numSteps = await HealthKitManager.shared.readSteps(beginningAt: track.date, andEndingAt: endDate) else { return }
            print("--- \(file).task -   numSteps: \(numSteps)")
        }
        #endif
    }
}

//struct TrackDetailsView_Previews: PreviewProvider {
//    static var previews: some View {
//        TrackDetailsView(track: <#T##Track#>)
//    }
//}
