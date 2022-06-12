//
//  TrackStatsView.swift
//  ATracks
//
//  Created by James Hager on 4/18/22.
//

import SwiftUI

protocol TrackStatsViewDelegate {
    #if os(iOS)
    func handleSwipe(_ swipeDir: SwipeDirection)
    #endif
}

// MARK: -

struct TrackStatsView: View {
    
    @ObservedObject private var device = Device.shared
    
    @ObservedObject private var track: Track
    private var displayOnSide: Bool
    private var delegate: TrackStatsViewDelegate?
    
    private var isCompact: Bool { device.detailHorizontalSizeClassIsCompact }
    
    //let file = "TrackStatsView"
    
    // MARK: - Init
    
    init(track: Track, displayOnSide: Bool = false, delegate: TrackStatsViewDelegate?) {
        self.track = track
        self.displayOnSide = displayOnSide
        self.delegate = delegate
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
                
            } else {  // !displayOnSide
                ZStack {
                    if !isCompact {
                        VStack(spacing: 4) {
                            Text(track.dateString)
                            Text(" ")
                        }
                    }
                    VStack(spacing: 4) {
                        if isCompact {
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
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("Distance: ")
                                Text("Steps: ")
                                    .foregroundColor(track.hasFinalSteps ? .text : .textNoData)
                            }
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(String(format: "%.2f", track.distance)) mi")
                                Text(track.steps.stringWithNA)
                                    .foregroundColor(track.hasFinalSteps ? .text : .textNoData)
                            }
                        }
                    }
                }
                .padding([.top, .bottom], 8)
                .padding(.leading, device.trackPlotStatsLeadingSpace(displayOnSide: displayOnSide))
                .padding(.trailing, device.trackPlotStatsTrailingSpace(displayOnSide: displayOnSide))
            }
        }
        #if os(iOS)
        .contentShape(Rectangle())  // so the .gesture will operate on the whole Group and not just the inner content
        .gesture(DragGesture(minimumDistance: 5)
            .onEnded { value in                
                if device.isPhone {
                    delegate?.handleSwipe(SwipeDirection.from(value))
                } else {
                    TrackManager.shared.handleSwipe(SwipeDirection.from(value))
                }
            }
        )
        #endif
        .font(device.isPhone ? .footnote : .body)
        .foregroundColor(.text)
//        #if os(iOS)
//        .task {
//            guard let endDate = track.trackPoints.last?.timestamp else { return }
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "yyyy-MM-dd, h:mm:ss a"
//            let file = "TrackStatsView"
//            print("=== \(file).task - start date: \(dateFormatter.string(from: track.date))==")
//            print("--- \(file).task -   end date: \(dateFormatter.string(from: endDate))")
//            guard let numSteps = await HealthKitManager.shared.getSteps(from: track.date, to: endDate, trackName: track.debugName) else { return }
//            print("--- \(file).task -   numSteps: \(numSteps)")
//        }
//        #endif
    }
}

//struct TrackDetailsView_Previews: PreviewProvider {
//    static var previews: some View {
//        TrackDetailsView(track: <#T##Track#>)
//    }
//}
