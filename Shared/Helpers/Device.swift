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
                padWentCompact = true
            }
        }
    }
    
    var isPad = false
    
    var padWentCompact = false
    
    var padShowNavigationLink: Bool { sceneHorizontalSizeClassIsCompact || padWentCompact }
    
    //lazy var file = Func.sourceFileNameFromFullPath(#file)
    
    // MARK: - Init
    
    override init() {
        super.init()
        isPad = DeviceType.isPad
    }
}
