//
//  SwipeHelper.swift
//  ATracks
//
//  Created by James Hager on 6/3/22.
//

import Foundation

enum SwipeHelper {
    
    static func newTrack(from tracks: [Track], and selectedTrack: Track?, for swipeDir: SwipeDirection) -> Track? {
        
        switch swipeDir {
        case .left:
            return newTrackForSwipeLeft(from: tracks, and: selectedTrack)
        case .right:
            return newTrackForSwipeRight(from: tracks, and: selectedTrack)
        default:
            return nil
        }
    }
    
    static func newTrackForSwipeLeft(from tracks: [Track], and selectedTrack: Track?) -> Track? {

        return newTrack(from: tracks, and: selectedTrack) { index in
            let newIndex = index + 1
            if newIndex == tracks.count {
                return nil
            }
            return newIndex
        }
    }
    
    static func newTrackForSwipeRight(from tracks: [Track], and selectedTrack: Track?) -> Track? {

        return newTrack(from: tracks, and: selectedTrack) { index in
            let newIndex = index - 1
            if newIndex < 0 {
                return nil
            }
            return newIndex
        }
    }
    
    static func newTrack(from tracks: [Track], and selectedTrack: Track?, newIndexFrom: (Int) -> Int?) -> Track? {
//        print("=== \(file).\(#function) ===")
        
        guard let selectedTrack = selectedTrack,
              let index = tracks.firstIndex(of: selectedTrack)
        else { return nil }
        
//        print("=== \(file).\(#function) - current index: \(index) of count \(tracks.count) ===")
        guard let newIndex = newIndexFrom(index) else { return nil }
//        print("--- \(file).\(#function) - newIndex: \(newIndex)")
        
        return tracks[newIndex]
    }
}
