//
//  VictoryCell.swift
//  Brainshots
//
//  Created by Amritpal Singh on 02/12/16.
//  Copyright © 2016 Anuradha Sharma. All rights reserved.
//

import UIKit

class VictoryCell: UITableViewCell {

    @IBOutlet weak var lblPlayer: UILabel!
    @IBOutlet weak var lblPoints: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
