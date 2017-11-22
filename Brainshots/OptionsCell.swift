//
//  OptionsCell.swift
//  Brainshots
//
//  Created by Amrit on 16/05/17.
//  Copyright © 2017 Anuradha Sharma. All rights reserved.
//

import UIKit

class OptionsCell: UITableViewCell {

    @IBOutlet var btnOption: UIButton!
    @IBOutlet var btnHorizontalConstraint: NSLayoutConstraint!
    
    var targetViewController = UIViewController()
    let OptionsStoryBoard = UIStoryboard.init(name: "Options", bundle: nil)
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    //MARK:- Setup Cell
    func setupCell(image:String,hightlightedImage:String,tag:NSInteger,target:UIViewController) {
    
        targetViewController = target
        btnOption.tag = tag
        btnOption.setImage(UIImage.init(named: image), for: .normal)
        btnOption.setImage(UIImage.init(named: hightlightedImage), for: .highlighted)
        btnOption.addTarget(self, action: #selector(btnOptions), for: .touchUpInside)
        btnOption.addTarget(self, action: #selector(touchDown), for: .touchDown)
    }
    
    //MARK:- Actions
    func btnOptions(sender:UIButton){
    
        switch sender.tag {
            
        //Sound Options
        case 0:
            let vc = OptionsStoryBoard.instantiateViewController(withIdentifier:kSoundOptionsVC) as! SoundViewController
            targetViewController.navigationController?.pushViewController(vc, animated: true)
            
        //More Games
        case 1:
            let vc = OptionsStoryBoard.instantiateViewController(withIdentifier:kMoreGamesVC) as! MoreGamesViewController
            targetViewController.navigationController?.pushViewController(vc, animated: true)
            
        //Legal Disclaimer
        case 2:
            let vc = OptionsStoryBoard.instantiateViewController(withIdentifier:kLegalDisclaimerVC) as! LegalDisclaimerViewController
            targetViewController.navigationController?.pushViewController(vc, animated: true)
         
        //Credits
        case 3:
            let vc = OptionsStoryBoard.instantiateViewController(withIdentifier:kCreditVC) as! CreditViewController
            targetViewController.navigationController?.pushViewController(vc, animated: true)
        
        //InApp Purchase
        case 4:
            
            let vc = OptionsStoryBoard.instantiateViewController(withIdentifier:"InAppPurchaseVC") as! InAppPurchaseVC
            vc.pushFromSelectPlay = false
            targetViewController.navigationController?.pushViewController(vc, animated: true)
            break
            
        //Default
        default:
            print("default")
        }
    }
    
    //MARK:- Touch Down
    func touchDown(){
        SoundManager.sharedInstance.playButtonPressedSound()
    }
}
