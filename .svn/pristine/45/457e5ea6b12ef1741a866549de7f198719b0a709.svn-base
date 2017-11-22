//
//  InstructionsTextView.swift
//  Brainshots
//
//  Created by Amritpal Singh on 08/12/16.
//  Copyright © 2016 Anuradha Sharma. All rights reserved.
//

import UIKit

class InstructionsTextView: UITextView {

    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        
        // Drawing code
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
        if DeviceType.IS_IPHONE_5  || DeviceType.IS_IPHONE_4_OR_LESS {
            
            self.font = UIFont.systemFont(ofSize: 16)
        }
        if  DeviceType.IS_IPHONE_6 {
            
            self.font = UIFont.systemFont(ofSize: 20)
        }
        if DeviceType.IS_IPHONE_6P {
            
            self.font = UIFont.systemFont(ofSize: 22)
        }
    }
}
