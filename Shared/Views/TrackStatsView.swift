//
//  TrackDetailsView.swift
//  ATracks
//
//  Created by James Hager on 4/18/22.
//

import SwiftUI

struct TrackStatsView: View {
    
    @ObservedObject var track: Track
    @Binding var hasSafeAreaInsets: Bool
    var displayOnSide: Bool
    
    private var deviceType: DeviceType { DeviceType.current() }
    private var isPhone: Bool { deviceType == .phone }
    
    // MARK: - Init
    
    init(track: Track, hasSafeAreaInsets: Binding<Bool>, displayOnSide: Bool = false) {
        self.track = track
        self._hasSafeAreaInsets = hasSafeAreaInsets
        self.displayOnSide = displayOnSide
    }
    
    // MARK: - View
    
    var body: some View {
        Group {
            if displayOnSide {
                VStack {
                    Text(track.dateString)
                    Spacer()
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
                    Spacer()
                }
                .padding(.top, 8)
                
            } else {
                VStack(spacing: 4) {
                    if isPhone {
                        Text(track.dateString)
                    }
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
                        if !isPhone {
                            VStack(spacing: 4) {
                                Text(track.dateString)
                                Text("")
                            }
                            Spacer()
                        }
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
                }
                .padding([.top, .bottom], 8)
                .padding(.leading, displayOnSide ? 16 : 32)
                .padding(.trailing, displayOnSide ? 8 : 32)
                .padding(.trailing, displayOnSide ? (hasSafeAreaInsets ? 8 : 16) : 32)
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
