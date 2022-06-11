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
    private var device: Device
    private var isSelected: Bool
    private var isEditing: Bool
    private var delegate: TrackRowDelegate? = nil
    
    @FocusState private var isFocused: Bool // = true
    
    var listRowTextColor: Color { isSelected ? .listRowSelectedText : .text }
    var listRowTextSecondaryColor: Color { isSelected ? .listRowSelectedTextSecondary : .textSecondary }
    var backgroundColor: Color {
        if device.isPhone {
            return .clear
        } else {
            return isSelected ? Color.listRowSelectedBackground : .listBackground
        }
    }
    
    //let file = "TrackRow"
    
    // MARK: - Init
    
    init(track: Track, device: Device, isSelected: Bool = false, isEditing: Bool = false, delegate: TrackRowDelegate? = nil) {
        self.track = track
        self.device = device
        self.isSelected = isSelected
        self.isEditing = isEditing
        self.delegate = delegate
    }
    
    // MARK: - View
    
    var body: some View {
        HStack {
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
                } else {
                    Text(track.name)
                        .font(.body.monospacedDigit())
                        .foregroundColor(listRowTextColor)
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
        #if os(iOS)
        .padding([.top, .bottom], device.isPad ? 8 : 0)
        .padding([.leading, .trailing], device.isPad ? 16 : 0)
        #else
        .padding([.top, .bottom], 4)
        .padding([.leading, .trailing], 24)
        #endif
        .background(backgroundColor)
        .font(.footnote.monospacedDigit())
        .foregroundColor(listRowTextSecondaryColor)
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
