//
//  TrackDetailsView.swift
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
    
    @ObservedObject var track: Track
    @Binding var hasSafeAreaInsets: Bool
    private var displayOnSide: Bool
    
    private var delegate: TrackStatsViewDelegate?
    
    private var deviceType: DeviceType { DeviceType.current() }
    private var isPhone: Bool { deviceType == .phone }
    private var onRight: Bool { DisplaySettings.shared.placeMapOnRightInLandscape }
    
    private var leadingSpace: CGFloat {
        if displayOnSide {
            if hasSafeAreaInsets {
                return onRight ? 8 : 16
            } else {
                return 16
            }
        } else {
            return 32
        }
    }

    private var trailingSpace: CGFloat {
        if displayOnSide {
            if hasSafeAreaInsets {
                return onRight ? 16 : 8
            } else {
                return 16
            }
        } else {
            return 32
        }
    }
    
    let file = "TrackStatsView"
    
    // MARK: - Init
    
    init(track: Track, hasSafeAreaInsets: Binding<Bool>, displayOnSide: Bool = false, delegate: TrackStatsViewDelegate? = nil) {
        self.track = track
        self._hasSafeAreaInsets = hasSafeAreaInsets
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
                                .foregroundColor(track.hasFinalSteps ? .text : .textNoData)
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(String(format: "%.2f", track.distance)) mi")
                            Text(track.steps.stringWithNA)
                                .foregroundColor(track.hasFinalSteps ? .text : .textNoData)
                        }
                    }
                }
                .padding([.top, .bottom], 8)
                .padding(.leading, leadingSpace)
                .padding(.trailing, trailingSpace)
            }
        }
        #if os(iOS)
        .contentShape(Rectangle())  // so the .gesture will operate on the whole Group and not just the inner content
        .gesture(DragGesture(minimumDistance: 5)
            .onEnded { value in
                delegate?.handleSwipe(SwipeDirection.from(value))
            }
        )
        #endif
        .font(isPhone ? .footnote : .body)
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
