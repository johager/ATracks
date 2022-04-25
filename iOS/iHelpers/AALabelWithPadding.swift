//
//  AALabelWithPadding.swift
//  ATracks (iOS)
//
//  Created by James Hager on 4/25/22.
//
//  Based on https://stackoverflow.com/questions/510382/how-do-i-create-a-round-cornered-uilabel-on-the-iphone/512402
//

import UIKit

class AALabelWithPadding: UILabel {
    
    var deltaSize: CGSize!
    
    init(horPadding: CGFloat, vertPadding: CGFloat) {
        super.init(frame: CGRect.zero)
        deltaSize = CGSize(width: 2 * horPadding, height: 2 * vertPadding)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    override var intrinsicContentSize: CGSize {
        let defaultSize = super.intrinsicContentSize
        return CGSize(width: defaultSize.width + deltaSize.width, height: defaultSize.height + deltaSize.height)
    }
}
