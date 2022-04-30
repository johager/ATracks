//
//  TrackDetailsView.swift
//  ATracks
//
//  Created by James Hager on 4/18/22.
//

import SwiftUI

struct TrackStatsView: View {
    
    @ObservedObject var track: Track
    var displayTall: Bool
    
    // MARK: - Init
    
    init(track: Track, displayTall: Bool = false) {
        self.track = track
        self.displayTall = displayTall
    }
    
    // MARK: - View
    
    var body: some View {
        Group {
            if displayTall {
                HStack(spacing: 0) {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Distance: ")
                        Text("Duration: ")
                        Text("Avg Speed: ")
                        Text("Steps: ")
                            .foregroundColor(track.hasFinalSteps ? .text : .textInactive)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(String(format: "%.2f", track.distance)) mi")
                        Text(track.duration.stringWithUnits)
                        Text("\(track.aveSpeed.stringForSpeed) mph")
                        Text(track.steps.stringWithNA)
                            .foregroundColor(track.hasFinalSteps ? .text : .textInactive)
                    }

                }
                
            } else {
                HStack(spacing: 0) {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Duration: ")
                        Text("Avg Speed: ")
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text(track.duration.stringWithUnits)
                        Text("\(track.aveSpeed.stringForSpeed) mph")
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Distance: ")
                        Text("Steps: ")
                            .foregroundColor(track.hasFinalSteps ? .text : .textInactive)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(String(format: "%.2f", track.distance)) mi")
                        Text(track.steps.stringWithNA)
                            .foregroundColor(track.hasFinalSteps ? .text : .textInactive)
                    }
                }
                .padding([.top, .bottom], 8)
                .padding(.leading, displayTall ? 16 : 32)
                .padding(.trailing, displayTall ? 8 : 32)
            }
        }
        .font(.footnote)
        .foregroundColor(.text)
        #if os(iOS)
        .task {
            guard let endDate = track.trackPoints.last?.timestamp else { return }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd, h:mm:ss a"
            let file = "TrackStatsView"
            print("=== \(file).task - start date: \(dateFormatter.string(from: track.date))==")
            print("--- \(file).task -   end date: \(dateFormatter.string(from: endDate))")
            guard let numSteps = await HealthKitManager.shared.readSteps(beginningAt: track.date, andEndingAt: endDate, dateOptions: .start) else { return }
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
