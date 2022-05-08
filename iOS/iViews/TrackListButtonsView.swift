//
//  TrackListButtonsView.swift
//  ATracks (iOS)
//
//  Created by James Hager on 5/7/22.
//

import SwiftUI

protocol TrackListButtonsViewDelegate {
    func startButtonTapped()
    func stopButtonTapped()
}

// MARK: -

struct TrackListButtonsView: View {
    
    @ObservedObject var locationManagerSettings = LocationManagerSettings.shared
    
    let hOrVStack: HOrVStack
    @Binding var hasSafeAreaInsets: Bool
    @Binding var isTracking: Bool
    
    var delegate: TrackListButtonsViewDelegate
    
    private var startTrackingText: String {
        if locationManagerSettings.useDefaultTrackName {
            return "Start"
        } else {
            return "Start\u{2026}"
        }
    }
    
    private var stopTrackingText: String {
        if locationManagerSettings.useAutoStop {
            return "[Stop]"
        } else {
            return "Stop"
        }
    }
    
    let file = "TrackListButtonsView"
    
    // MARK: - View
    
    var body: some View {
        HOrVStackView(hOrVStack: hOrVStack) {
            Spacer()
            
            Button(action: delegate.startButtonTapped) {
                Text(startTrackingText)
            }
            .disabled(isTracking)
            .buttonStyle(AAButtonStyle(isEnabled: !isTracking))
            
            Spacer()
            
            Button(action: delegate.stopButtonTapped) {
                Text(stopTrackingText)
            }
            .disabled(!isTracking)
            .buttonStyle(AAButtonStyle(isEnabled: isTracking))
            
            Spacer()
        }
    }
}

//struct TrackListButtonsView_Previews: PreviewProvider {
//    static var previews: some View {
//        TrackListButtonsView()
//    }
//}
