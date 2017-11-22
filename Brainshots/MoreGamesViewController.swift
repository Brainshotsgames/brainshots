//
//  MoreGamesViewController.swift
//  Brainshots
//
//  Created by Amritpal Singh on 01/12/16.
//  Copyright © 2016 Anuradha Sharma. All rights reserved.
//

import UIKit
import SafariServices
import MessageUI

class MoreGamesViewController: UIViewController,MFMailComposeViewControllerDelegate {
    
    //MARK:- Outlets
    @IBOutlet weak var lblTrivia: UILabel!
    @IBOutlet var lblInfo: ActiveLabel!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        CommonFunctions.sharedInstance.setupButtonBorder(vw: lblTrivia)
        customLabel()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- Add Custom Label
    func customLabel(){
        
        let customType = ActiveType.custom(pattern: "\\s\(email)\\b")
        lblInfo.enabledTypes.append(customType)
        lblInfo.urlMaximumLength = 31
        
        lblInfo.customize { label in
            
            label.text = "For more information about our games or our company, please visit us at \(link) or contact us at info@brainshotsgames.com"
            
            lblInfo.font = UIFont(name: kFatFrankRegular, size: 16)
            lblInfo.lineSpacing = 1
            lblInfo.numberOfLines = 0
            lblInfo.textColor = kBaseRed
            lblInfo.URLColor = UIColor.blue
            lblInfo.URLSelectedColor = kBaseRed
            lblInfo.handleURLTap { _ in
            
                if let url = URL.init(string: link){
                let svc = SFSafariViewController(url: url)
                    self.present(svc, animated: true, completion: nil)
                }
            }
            
            //Custom types
            lblInfo.customColor[customType] = UIColor.blue
            lblInfo.customSelectedColor[customType] = kBaseRed
            lblInfo.handleCustomTap(for: customType) { _ in
                
                self.openEmail(email)
            }
        }
    }
    
    //MARK:- Mail Composer
    func openEmail(_ emailAddress: String) {
        
        // If user has not setup any email account in the iOS Mail app
        if !MFMailComposeViewController.canSendMail() {
            print("Mail services are not available")
            if let url = URL(string: "mailto:" + emailAddress){
                UIApplication.shared.canOpenURL(url)
            }
            return
        }
        
        // Use the iOS Mail app
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        composeVC.setToRecipients([emailAddress])
        composeVC.setSubject("")
        composeVC.setMessageBody("", isHTML: false)
        
        // Present the view controller modally.
        self.present(composeVC, animated: true, completion: nil)
    }
    
    // MARK: MailComposeViewControllerDelegate
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        // Dismiss the mail compose view controller.
        controller.dismiss(animated: true, completion: nil)
    }
    
    //MARK:- Actions
    @IBAction func btnBack(_ sender: AnyObject) {
        
         _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnBackTouchDown(_ sender: Any) {
        SoundManager.sharedInstance.playButtonPressedSound()
    }
}
