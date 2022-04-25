//
//  TrackDetailsView.swift
//  ATracks
//
//  Created by James Hager on 4/20/22.
//

import SwiftUI
import MapKit

struct TrackDetailsView: View {
    
    @ObservedObject var track: Track
    
    @State private var latLonText = ""
    @State private var latLonTextIsHidden = true
    
    // MARK: - View
    
    var body: some View {
        VStack(spacing: 0) {
            TrackStatsView(track: track)
//            ZStack {
                MapView(track: track, shouldTrackPoint: true)
                    .edgesIgnoringSafeArea([.trailing, .leading])
//                VStack {
//                    Spacer()
//                    Text(latLonText)
//                        .font(.footnote.monospacedDigit())
//                        .foregroundColor(.latLonCalloutText)
//                        .padding([.top, .bottom], 4)
//                        .padding([.leading, .trailing], 8)
//                        .background(
//                            ZStack {
//                                RoundedRectangle(cornerRadius: 6)
//                                    .fill(Color.latLonCalloutBackground)
//                                RoundedRectangle(cornerRadius: 6)
//                                    .stroke(Color.latLonCalloutBorder, lineWidth: 1)
//                            }
//                        )
//                        .padding(.bottom, 8)
//                        .hidden(latLonTextIsHidden)
//                        .onReceive(NotificationCenter.default.publisher(for: .showInfoForLocation)) { notification in
//                            guard let userInfo = notification.userInfo as? Dictionary<String,Any>,
//                                  let clLocationCoordinate2D = userInfo[Key.clLocationCoordinate2D] as? CLLocationCoordinate2D
//                            else { return }
//                            latLonText = clLocationCoordinate2D.stringWithThreeDecimals
//
//                            if latLonTextIsHidden {
//                                latLonTextIsHidden = false
//                            }
//                        }
//                }
//            }
            TrackPlotView(track: track)
                .frame(height: 150)
        }
        .navigationTitle(track.name)
    }
}

//struct TrackDetailsView_Previews: PreviewProvider {
//    static var previews: some View {
//        TrackDetailsView()
//    }
//}
