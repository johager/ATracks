//
//  Device.swift
//  ATracks
//
//  Created by James Hager on 6/5/22.
//

import SwiftUI

class Device: NSObject, ObservableObject {
    
    @Published var hasSafeAreaInsets = false
    
    @Published var detailHorizontalSizeClassIsCompact = false
    
    @Published var sceneHorizontalSizeClassIsCompact = false {  // the main scene
        didSet {
            guard isPad else { return }
            if sceneHorizontalSizeClassIsCompact {
                padShowNavigationLink = true
            }
        }
    }
    
    @Published var padShowNavigationLink = false
    
    var deviceType: DeviceType!
    
    // MARK: - Calculated
    
    var isPhone: Bool { deviceType.isPhone }
    var isPad: Bool { deviceType.isPad }
    var isMac: Bool { deviceType.isMac }
    
    var useSafeAreaInsets: Bool { isPhone && hasSafeAreaInsets }
    
    //lazy var file = Func.sourceFileNameFromFullPath(#file)
    
    // MARK: - Init
    
    override init() {
        super.init()
        deviceType = DeviceType.current()
    }
    
    // MARK: - Methods
    
    func trackPlotStatsLeadingSpace(displayOnSide: Bool) -> CGFloat {
        return trackPlotStatsSpace(displayOnSide: displayOnSide, safeOnRight: 8, safeNotOnRight: 16)
    }
    
    func trackPlotStatsTrailingSpace(displayOnSide: Bool) -> CGFloat {
        return trackPlotStatsSpace(displayOnSide: displayOnSide, safeOnRight: 16, safeNotOnRight: 8)
    }
    
    func trackPlotStatsSpace(displayOnSide: Bool, safeOnRight: CGFloat, safeNotOnRight: CGFloat) -> CGFloat {
        if displayOnSide {
            if useSafeAreaInsets {
                let placeMapOnRightInLandscape = DisplaySettings.shared.placeMapOnRightInLandscape
                return placeMapOnRightInLandscape ? safeOnRight : safeNotOnRight
            } else {
                return 16
            }
        } else {
            return 32
        }
    }
}
