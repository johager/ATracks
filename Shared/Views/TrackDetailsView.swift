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
            ZStack {
                MapView(track: track, shouldTrackPoint: true, delegate: self)
                    .edgesIgnoringSafeArea([.trailing, .leading])
                VStack {
                    Spacer()
                    Text(latLonText)
                        .font(.footnote.monospacedDigit())
                        .foregroundColor(.latLonCalloutText)
                        .padding([.top, .bottom], 4)
                        .padding([.leading, .trailing], 8)
                        .background(
                            ZStack {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.latLonCalloutBackground)
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.latLonCalloutBorder, lineWidth: 1)
                            }
                        )
                        .padding(.bottom, 8)
                        .hidden(latLonTextIsHidden)
                }
            }
            TrackPlotView(track: track)
                .frame(height: 150)
        }
        .navigationTitle(track.name)
    }
}

// MARK: - MapViewDelegate

extension TrackDetailsView: MapViewDelegate {
    
    func showLatLonFor(_ clLocationCoordinate2D: CLLocationCoordinate2D) {
//        let file = "TrackDetailsView"
//        print("=== \(file).\(#function) ===")
        
        latLonText = clLocationCoordinate2D.stringWithThreeDecimals
        
        if latLonTextIsHidden {
            latLonTextIsHidden = false
        }
    }
}

//struct TrackDetailsView_Previews: PreviewProvider {
//    static var previews: some View {
//        TrackDetailsView()
//    }
//}
