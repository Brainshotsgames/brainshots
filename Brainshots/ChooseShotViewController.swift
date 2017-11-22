//
//  ChooseShotViewController.swift
//  Brainshots
//
//  Created by Amritpal Singh on 02/12/16.
//  Copyright © 2016 Anuradha Sharma. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ChooseShotViewController: UIViewController,IPSessionDelegate {

    //MARK:------------ CHanges \\//----------------------//
    @IBOutlet var lblInfo: ActiveLabel!
    @IBOutlet var noticeView: UIView!
    @IBOutlet var btnAccept: UIButton!
    @IBOutlet var btnDontShow: UIButton!
    @IBOutlet var check1: UIImageView!
    @IBOutlet var check2: UIImageView!
    
    @IBOutlet var topLblConst: NSLayoutConstraint!
    @IBAction func btnAcceptBox(_ sender: UIButton) {
        
        sender.tag = sender.tag == 0 ? 1 : 0
        check1.image = sender.tag == 1 ? UIImage.init(named: "redcheck.png") : UIImage.init(named: "")
        btnAccept.isUserInteractionEnabled = sender.tag == 1 ? true : false
        btnAccept.alpha = sender.tag == 1 ? 1.0: 0.7
    }
    
    @IBAction func btnDontShowBox(_ sender: UIButton) {
        
        sender.tag = sender.tag == 0 ? 1 : 0
        check2.image = sender.tag == 1 ? UIImage.init(named: "redcheck.png") : UIImage.init(named: "")
        UserDefaults.standard.set(sender.tag == 1 ? true : false, forKey: "showDialouge")
    }
    
    @IBAction func btnAccept(_ sender: UIButton) {
        
        UIView.transition(with: self.noticeView, duration: 0.5, options: .transitionCrossDissolve, animations: { 
            self.noticeView.isHidden = true
        }, completion: nil)
    }
    
    @IBAction func btnDecline(_ sender: UIButton) {
    
        self.btnBack(sender)
    }
    
    func checkForNotice(){
        
        btnAccept.isUserInteractionEnabled =  false
        btnAccept.alpha =  0.7
        noticeView.isHidden = UserDefaults.standard.bool(forKey: "showDialouge")
    }
    
    func addNotice() {
    
        let customType = ActiveType.custom(pattern: "\\sTerms of Use\\b")
        let customType2 = ActiveType.custom(pattern: "\\sPrivacy Policy\\b")
        lblInfo.enabledTypes.append(customType)
        lblInfo.enabledTypes.append(customType2)
        lblInfo.urlMaximumLength = 31
        
        lblInfo.customize { label in
            
            label.text = "You must be age of majority or have your parent’s permission to play.  Play the game responsibly, and be aware of your and your opponents’ limits.  We do not monitor or moderate what or how much players consume. Do not use the game with foods that may present allergy risks, choking hazards, or with alcohol or other intoxicants.  You are solely responsible for your and your opponents’ gameplay, and play the game at your own risk.  The user is responsible for maintaining the security of his/her device and account, and if the user allows someone else to play the game on their device, they are responsible for that use and the monitoring of same.\nFor full details, please review the Terms of Use and Privacy Policy."
            
            if (DeviceType.IS_IPHONE_4_OR_LESS){
                
                lblInfo.font = UIFont(name: kFatFrankRegular, size: 13)
            }
            else if (DeviceType.IS_IPHONE_5) {
                
                lblInfo.font = UIFont(name: kFatFrankRegular, size: 15)
            }
            else if (DeviceType.IS_IPHONE_6) {
                
               topLblConst.constant = 50
               lblInfo.font = UIFont(name: kFatFrankRegular, size: 16)
            }
            else if (DeviceType.IS_IPHONE_6P) {
                
               topLblConst.constant = 60
               lblInfo.font = UIFont(name: kFatFrankRegular, size: 17)
            }
            
            lblInfo.lineSpacing = 2
            lblInfo.numberOfLines = 0
            lblInfo.textColor = .white
    
            //Custom types
            lblInfo.customColor[customType] = .yellow
            lblInfo.customSelectedColor[customType] = UIColor.yellow.withAlphaComponent(0.5)
            lblInfo.customColor[customType2] = .yellow
            lblInfo.customSelectedColor[customType2] = UIColor.yellow.withAlphaComponent(0.5)
            
            let storyBoard = UIStoryboard(name: "Options", bundle: nil)
            
            lblInfo.handleCustomTap(for: customType) { _ in

                let htmlFile = Bundle.main.path(forResource: "terms-and-conditions", ofType: "html")
                let html = try? String(contentsOfFile: htmlFile!, encoding: String.Encoding.utf8)
                let controller = storyBoard.instantiateViewController(withIdentifier: "LegalVC") as? LegalVC
                controller?.html = html
                self.navigationController?.pushViewController(controller!, animated: true)
            }
            
            lblInfo.handleCustomTap(for: customType2) { _ in
                
                let htmlFile = Bundle.main.path(forResource: "privacy-policy", ofType: "html")
                let html = try? String(contentsOfFile: htmlFile!, encoding: String.Encoding.utf8)
                let controller = storyBoard.instantiateViewController(withIdentifier: "LegalVC") as? LegalVC
                controller?.html = html
                self.navigationController?.pushViewController(controller!, animated: true)
            }
        }
    }
    
    //MARK:- Outlets
    @IBOutlet weak var btnDrinker: UIButton!
    @IBOutlet weak var btnThinker: UIButton!
    @IBOutlet weak var btnSinker: UIButton!
    @IBOutlet weak var backViewShot: UIView!
    @IBOutlet weak var backViewDrinker: UIView!
    
    //MARK:- Variables
    var timer = Timer()
    
    //MARK:- Did Load
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        /*Add Notice*/
        addNotice()
        
        /*Check For Notice*/
        checkForNotice()
        
        /*initialize IP session delegate to self*/
        appDelegate.IPSession.delegate = self
        
        /*set game starts boolean*/
        UserDefaults.standard.set(true, forKey: "GameStarts")
        
        /*Set connection lost notification*/
        NotificationCenter.default.addObserver(self, selector: #selector(checkIfPlayerLostConnection), name: NSNotification.Name(rawValue: "connectionLost"), object: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- Notification Selector
    /*Regular Check for Lost Connection*/
    func checkIfPlayerLostConnection(){
    
        DispatchQueue.main.async {
            self.showAlert()
        }
    }
    
    //MARK:- Alert
    /*Show Alert if connection losts*/
    func showAlert() {
        
        let controller = UIAlertController.init(title: kConnectionLost, message:kStartAgain, preferredStyle: .alert)
        
        let okAction = UIAlertAction.init(title: "OK", style: .default) { (action:UIAlertAction!) in
            
            let array = self.navigationController?.viewControllers
            
            for obj in array! {
                print(obj)
                if obj.isKind(of: IndividualPlayViewController.self)  {
                    _ =  self.navigationController?.popToViewController(obj, animated: false)
                    NotificationCenter.default.removeObserver(self, name:NSNotification.Name(rawValue: "connectionLost"), object: nil)
                }
            }
        }
        
        controller.addAction(okAction)
        present(controller, animated: true, completion: nil)
    }

    //MARK:- Session Delegate
    /*IPSession Delegate*/
    func receiveMessage(message: String, from peerid: MCPeerID) {
        
        DispatchQueue.main.async {
            
            if(message == "selected") {
                CommonFunctions.sharedInstance.addPlayers(peer:peerid)
            }
        }
    }
    
    //MARK:- Actions
    //Drinker Action
    @IBAction func btnDrinker(_ sender: AnyObject) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier:kDrinkerVC) as! DrinkerViewController
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    //Thinker Action
    @IBAction func btnThinker(_ sender: AnyObject) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier:kThinkerVC) as! ThinkerViewController
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    //Kitchen Sinker Action
    @IBAction func btnKitchenSinker(_ sender: AnyObject) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier:kSinkerVC) as! SinkerViewController
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    //BAck Button Action
    @IBAction func btnBack(_ sender: AnyObject) {
        
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name(rawValue: "connectionLost"), object: nil)
        
        if(UserDefaults.standard.bool(forKey: "isHost")) {
            appDelegate.IPSession.advertiserAssistant?.startAdvertisingPeer()
        }
        else{
            appDelegate.IPSession.session?.disconnect()
        }
        
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    //TouchDown Action
    @IBAction func touchDown(_ sender: AnyObject) {
        SoundManager.sharedInstance.playButtonPressedSound()
    }
}
