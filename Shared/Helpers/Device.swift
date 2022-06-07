//
//  Device.swift
//  ATracks
//
//  Created by James Hager on 6/5/22.
//

import Foundation

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
    
    //lazy var file = Func.sourceFileNameFromFullPath(#file)
    
    // MARK: - Init
    
    override init() {
        super.init()
        deviceType = DeviceType.current()
    }    
}
