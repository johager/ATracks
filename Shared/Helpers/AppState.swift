//
//  AppState.swift
//  ATracks
//
//  Created by James Hager on 6/26/22.
//

import Foundation
import Combine
import os.log

class AppState: ObservableObject {
    
    @Published var isActive = false
    {
        didSet {
            logger?.notice("isActive didSet \(self.isActive, privacy: .public)")
        }
    }
    
    private var logger: Logger?
    lazy var file = Func.sourceFileNameFromFullPath(#file)
    
    // MARK: - Init
    
    init() {
        logger = Func.logger(for: file)
    }
}
