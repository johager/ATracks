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
    
    // MARK: - Init
    
    init(in hOrVStack: HOrVStack, isTracking: Binding<Bool>, delegate: TrackListButtonsViewDelegate) {
        self.hOrVStack = hOrVStack
        self._isTracking = isTracking
        self.delegate = delegate
    }
    
    // MARK: - View
    
    var body: some View {
        HOrVStackView(hOrVStack) {
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
