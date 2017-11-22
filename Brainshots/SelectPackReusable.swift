//
//  SelectPackReusable.swift
//  Brainshots
//
//  Created by Amrit on 31/05/17.
//  Copyright © 2017 Anuradha Sharma. All rights reserved.
//

import UIKit

class SelectPackReusable: UICollectionReusableView {
        
    @IBOutlet var leadingConstraint: NSLayoutConstraint!
    @IBOutlet var btnRestore: UIButton!

    func setupReusableView() {
    
        if !IsHost {
            leadingConstraint.constant = self.frame.size.width/2 - 23
            btnRestore.isHidden = true
        }
    }
}
