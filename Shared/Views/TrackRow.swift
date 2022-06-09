//
//  TrackRow.swift
//  ATracks
//
//  Created by James Hager on 4/18/22.
//

import SwiftUI

protocol TrackRowDelegate {
    func didFinishEditing()
}

// MARK: -

struct TrackRow: View {
    
    @ObservedObject var track: Track
    private var isEditing: Bool
    private var delegate: TrackRowDelegate? = nil
    
    @FocusState private var isFocused: Bool // = true
    
    //let file = "TrackRow"
    
    // MARK: - Init
    
    init(track: Track, isEditing: Bool = false, delegate: TrackRowDelegate? = nil) {
        self.track = track
        self.isEditing = isEditing
        self.delegate = delegate
    }
    
    // MARK: - View
    
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                if isEditing {
                    TextField("Name", text: $track.name)
                        .background(Color.background)
                        .disableAutocorrection(true)
                        .font(.body.monospacedDigit())
                        .foregroundColor(.text)
                        .focused($isFocused)
                        .onSubmit {
                            CoreDataStack.shared.saveContext()
                            isFocused = false
                            delegate?.didFinishEditing()
                        }
                        #if os(macOS)
                        .textFieldStyle(.squareBorder)
                        #endif
                } else {
                    Text(track.name)
                        .font(.body.monospacedDigit())
                        .foregroundColor(.text)
                }
                Text(track.dateString)
                    .offset(x: 16)
            }
            Spacer()
            VStack(alignment: .leading, spacing: 4) {
                Text(String(format: "%.2f", track.distance) + " mi")
                Text(track.duration.stringWithUnits)
            }
        }
        .font(.footnote.monospacedDigit())
        .foregroundColor(.textSecondary)
        #if os(macOS)
        .onAppear {
            if isEditing {
                Func.afterDelay(0.1) {
                    self.isFocused = true
                }
            }
        }
        #endif
    }
}

// MARK: - Previews

//struct TrackRow_Previews: PreviewProvider {
//    static var previews: some View {
//        TrackRow()
//    }
//}
