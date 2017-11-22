//
//  CustomSlider.swift
//  Brainshots
//
//  Created by Amritpal Singh on 06/02/17.
//  Copyright © 2017 Anuradha Sharma. All rights reserved.
//

import UIKit

class CustomSlider: UISlider {
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        //keeps original origin and width, changes height, you get the idea
        let customBounds = CGRect(origin: bounds.origin, size: CGSize(width: bounds.size.width, height: 10.0))
        super.trackRect(forBounds: customBounds)
        return customBounds
    }
    
    //while we are here, why not change the image here as well? (bonus material)
    override func awakeFromNib() {
        
        self.setThumbImage(UIImage(named: "SoundButton"), for: .normal)
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = 5
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        super.awakeFromNib()
    }
}
