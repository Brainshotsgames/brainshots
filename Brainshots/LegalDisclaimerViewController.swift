//
//  LegalDisclaimerViewController.swift
//  Brainshots
//
//  Created by Amritpal Singh on 01/12/16.
//  Copyright © 2016 Anuradha Sharma. All rights reserved.
//

import UIKit

class LegalDisclaimerViewController: UIViewController {
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- Actions
    @IBAction func btnBack(_ sender: AnyObject) {
    
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func termsOfUse(_ sender: AnyObject) {
        
        let htmlFile = Bundle.main.path(forResource: "terms-and-conditions", ofType: "html")
        let html = try? String(contentsOfFile: htmlFile!, encoding: String.Encoding.utf8)
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "LegalVC") as? LegalVC
        controller?.html = html
        self.navigationController?.pushViewController(controller!, animated: true)
    }
    
    @IBAction func PrivacyPolicy(_ sender: AnyObject) {
        
        let htmlFile = Bundle.main.path(forResource: "privacy-policy", ofType: "html")
        let html = try? String(contentsOfFile: htmlFile!, encoding: String.Encoding.utf8)
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "LegalVC") as? LegalVC
        controller?.html = html
        self.navigationController?.pushViewController(controller!, animated: true)
    }
    
    @IBAction func btnBackTouchDown(_ sender: Any) {
        SoundManager.sharedInstance.playButtonPressedSound()
    }
}
