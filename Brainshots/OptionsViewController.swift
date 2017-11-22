//
//  OptionsViewController.swift
//  Brainshots
//
//  Created by Anuradha Sharma on 18/11/16.
//  Copyright © 2016 Anuradha Sharma. All rights reserved.
//

import UIKit


class OptionsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    //MARK:- Declare Properties
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet var tblOptions: UITableView!
    @IBOutlet var topConstraint: NSLayoutConstraint!
    
    //MARK:- Image Names
    let buttonImages = ["option_sound_normal","more_games_normal","legal_disclaimer_normal","credits_normal","in_app_purchase_normal"]
    let highlightImages = ["option_sound_hover","more_games_hover","legal_disclaimer_hover","credits_hover","in_app_purchase_hover"]
    
    //MARK:- View Did Load
    override func viewDidLoad() {
        
        super.viewDidLoad()
    
        tblOptions.separatorStyle = .none
        tblOptions.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin, .flexibleWidth]
        tblOptions.isOpaque = false
        tblOptions.backgroundColor = UIColor.clear
        tblOptions.backgroundView = nil
        tblOptions.bounces = false
        
        if DeviceType.IS_IPHONE_4_OR_LESS {
            topConstraint.constant = 40
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- TableView Delegates & DatSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return buttonImages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! OptionsCell
        cell.backgroundColor = UIColor.clear
        cell.setupCell(image: buttonImages[indexPath.row], hightlightedImage: highlightImages[indexPath.row], tag: indexPath.row,target:self)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return heightForCell()
    }
    
    func heightForCell() -> CGFloat {
    
        var height = CGFloat()
        
        if DeviceType.IS_IPHONE_4_OR_LESS {
            
            height = 60
        }
        
        if DeviceType.IS_IPHONE_5 {
        
            height = 70
        }
        
        if DeviceType.IS_IPHONE_6 {
        
            height = 80
        }
        
        if DeviceType.IS_IPHONE_6P {
        
            height = 90
        }
    
        return height
    }

    //MARK:- Back Action
    @IBAction func btnBack(_ sender: AnyObject) {
        
         _ = self.navigationController?.popViewController(animated: true)
    }
    
    //MARK:- TouchDown Action
    @IBAction func touchDownAction(_ sender: Any) {
        SoundManager.sharedInstance.playButtonPressedSound()
    }
}
