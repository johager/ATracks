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
        HStack(spacing: 0) {
            VStack(alignment: .trailing) {
                Text("Duration: ")
                Text("Ave Speed: ")
            }
            VStack(alignment: .leading) {
                Text(track.duration.stringWithUnits)
                Text("\(track.aveSpeed.stringForSpeed) mph")
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text("Distance: ")
                Text("Steps: ")
                    .foregroundColor(track.hasFinalSteps ? .text : .textInactive)
            }
            VStack(alignment: .leading) {
                Text("\(String(format: "%.2f", track.distance)) mi")
                Text(track.steps.stringWithNA)
                    .foregroundColor(track.hasFinalSteps ? .text : .textInactive)
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
