   
//
//  IndividualPlayViewController.swift
//  Brainshots
//
//  Created by Amritpal Singh on 27/02/17.
//  Copyright © 2017 Anuradha Sharma. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import MBProgressHUD

class IndividualPlayViewController: UIViewController,MCNearbyServiceBrowserDelegate,IPSessionDelegate {

    //MARK:- Variables
    var browser: MCNearbyServiceBrowser!
    var hostName = NSMutableArray()
    var displayName = String()
    var pushFromInApp = Bool()
    var timer = Timer()
    var isNameExist = false
    
    @IBOutlet var bottomView: UIView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- Back Button
    @IBAction func btnBack(_ sender: Any) {
        
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    //MARK:-Button Host
    @IBAction func btnHostGame(_ sender: Any) {
        
        UserDefaults.standard.set(true, forKey: "isHost")
       
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "WordPackViewController") as! WordPackViewController
        _ = self.navigationController?.pushViewController(controller, animated: false)
    }      
    
    //MARK:-Button Join Game
    @IBAction func btnJoinGame(_ sender: Any) {
        
        UserDefaults.standard.set(false, forKey: "isHost")
        
        timer = Timer.scheduledTimer(timeInterval: 15, target: self, selector: #selector(timeOut), userInfo: nil, repeats: false)
        
        self.view.isUserInteractionEnabled = false
        
        showProgressHud(text: "Finding Host")
        createIPSessionWithHost()
        
    }
    
    //Mark:- Timeout Method
    func timeOut() {
    
        removeObserver()
        
        MBProgressHUD.hide(for: self.bottomView, animated: false)
        
        self.view.isUserInteractionEnabled = true
        
        browser.stopBrowsingForPeers()
        browser.delegate = nil
        
        let controller = UIAlertController.init(title:"Connection time out!", message:"Please try again!", preferredStyle: .alert)
        
        let okAction = UIAlertAction.init(title: "OK", style: .cancel) { (action:UIAlertAction!) in
        }
        
        controller.addAction(okAction)
        present(controller, animated: true, completion: nil)
    }
    
    //MARK:- Add Progress
    /*Add Customize Progress View with Message*/
    func showProgressHud(text:String){
        
        let progress = MBProgressHUD.showAdded(to:self.bottomView, animated: true)
        progress.bezelView.color = .white
        progress.activityIndicatorColor = kBaseRed
        progress.animationType = .zoomIn
        progress.label.font = UIFont.init(name: kFatFrankRegular, size: 20)
        progress.label.text = text
        progress.label.textColor = kBaseRed
    }
    
    //MARK:- Session
    /*Create Session*/
    func createIPSessionWithHost(){
        
        //Setup display name
        displayName = getPlayerName()
        
        //Create the Session for managing session related functionality.
        appDelegate.IPSession = IndividualSession.init(displayName: displayName, serviceType: "connect", ifAdvertise: false)
        appDelegate.IPSession.delegate = self
        browser = MCNearbyServiceBrowser.init(peer:(appDelegate.IPSession.session?.myPeerID)!, serviceType: "connect")
        browser.delegate = self
        browser.startBrowsingForPeers()
    }
    
    //MARK:- Fetch Player Name
    func getPlayerName()-> String {
        
        let dict : NSMutableDictionary =  CommonFunctions.sharedInstance.getProfileDetails()
        let name: String  = (dict.value(forKey: "firstName") as! String?)!
        return name.capitalized
    }
    
    
    //MARK:- Connection Monitoring
    /*Checking connection with Host*/
    func setConnectionWithHost(notification:Notification) {
        
        DispatchQueue.main.async {
            
            self.removeObserver()
            
            /*Store user info of notification*/
            let dict : [String:Any] = notification.userInfo as! [String:Any]
            let status : String = dict["status"] as! String
            
            /*Check for connection*/
            if status == "connected" {
                    print("connecting")
            }
            else if status == "not-connected" {
                
                MBProgressHUD.hide(for: self.bottomView, animated: true)
                self.timer.invalidate()
                self.view.isUserInteractionEnabled = true
                self.showNotConnectedAlert()
            }
        }
    }
    
    //MARK:- Browser Delegates
    /*MCNearbyServiceBrowser Delegates*/
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        
        /*Inviting Peer*/
        browser.invitePeer(peerID , to:(appDelegate.IPSession.session)! , withContext: nil, timeout: 10)
        
        /*Add Observer for connection*/
        addObserver()
        
        /*Save PeerID Instance*/
        CommonFunctions.sharedInstance.setHostID(peerID:peerID)
    
        MBProgressHUD.hide(for: self.bottomView, animated: false)
        showProgressHud(text: "Connecting Host")
        
        timer.invalidate()
        self.view.isUserInteractionEnabled = false
        browser.stopBrowsingForPeers()
        browser.delegate = nil
        
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID){
        
        removeObserver()
        timer.invalidate()
        showErrorALert()
        MBProgressHUD.hide(for: self.bottomView, animated: true)
        self.view.isUserInteractionEnabled = true
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error){
        
        removeObserver()
        timer.invalidate()
        showErrorALert()
        MBProgressHUD.hide(for: self.bottomView, animated: true)
        self.view.isUserInteractionEnabled = true
        
    }
    
    func showErrorALert() {
    
        let controller = UIAlertController.init(title:"Unable to Connect.Try Again!", message:kPlayerAlreadyExists, preferredStyle: .alert)
        
        let okAction = UIAlertAction.init(title: "OK", style: .cancel) { (action:UIAlertAction!) in }
        
        controller.addAction(okAction)
        present(controller, animated: true, completion: nil)
    }
    
    //MARK:- IPSession Delegates
    func receiveMessage(message: String, from peerid: MCPeerID){
        
        let dict : [String: Any] =  convertJsonToDictionary(json: message)!
        let str : String = dict["message"] as! String
            
        DispatchQueue.main.async {
            
            if(str == "getPeersInfo") {
                
                let arrayDisplayName = dict["peersNameList"] as! NSArray
                
                let myPeerName : String = (appDelegate.IPSession.session?.myPeerID.displayName.capitalized)!
                
                if arrayDisplayName.contains(myPeerName){
                    
                    self.isNameExist = true
                    appDelegate.IPSession.session?.disconnect()
                    self.reconnectWithPeernameChange()
                }
                else {
                    
                    if(self.isNameExist) {
                        self.showNameChangeAlert()
                    } else {
                        
                        MBProgressHUD.hide(for: self.bottomView, animated: true)
                        self.view.isUserInteractionEnabled = true
                        
                        let controller = self.storyboard?.instantiateViewController(withIdentifier: "WordPackViewController") as! WordPackViewController
                        _ = self.navigationController?.pushViewController(controller, animated: true)
                    }
                }
            }
        }
    }
    
    //MARK:- Name Change Alert
    func showNameChangeAlert() {
    
        let alert = UIAlertController(title: "\(getPlayerName().capitalized) is already exists. So your name changes to \(displayName).Lets get started", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Done", style: .cancel) { (_) in
        
            MBProgressHUD.hide(for: self.bottomView, animated: true)
            self.view.isUserInteractionEnabled = true
            
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "WordPackViewController") as! WordPackViewController
            _ = self.navigationController?.pushViewController(controller, animated: true)
        }
        
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func reconnectWithPeernameChange() {
        
        let arr = displayName.components(separatedBy: " ")
        
        if let last = arr.last {
            if let last1 = Int(last) {
                displayName =  arr.first! + "\(last1+1)"
            }
            else {
                displayName =  displayName + " 1"
            }
        }
        
        //Create the Session for managing session related functionality.
        appDelegate.IPSession = IndividualSession.init(displayName: displayName, serviceType: "connect", ifAdvertise: false)
        appDelegate.IPSession.delegate = self
        browser = MCNearbyServiceBrowser.init(peer:(appDelegate.IPSession.session?.myPeerID)!, serviceType: "connect")
        browser.delegate = self
        browser.startBrowsingForPeers()
    }
    
    //MARK:- Alert
    /*show alert if player name already exists in game*/
    func showAlert() {
        
        let controller = UIAlertController.init(title:kPlayerAlreadyExistsTitle, message:kPlayerAlreadyExists, preferredStyle: .alert)
        
        let okAction = UIAlertAction.init(title: "OK", style: .cancel) { (action:UIAlertAction!) in
        }
        
        controller.addAction(okAction)
        present(controller, animated: true, completion: nil)
    }
    
    /*If User is unsuccessfull in connecting with Host*/
    func showNotConnectedAlert(){
        
        let alert = UIAlertController.init(title: kConnectionLostTitle, message: kConnectionLostMessage, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "OK", style: .cancel) { (action:UIAlertAction!) in
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: TouchDown Actions
    @IBAction func touchDown(_ sender: AnyObject) {
        SoundManager.sharedInstance.playButtonPressedSound()
    }
    
    func removeObserver(){
        /*Remove observer*/
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name(rawValue: "connectingHost"), object: nil)
    }
    func addObserver(){
    
        /*Add Observer for checking connectivity*/
        NotificationCenter.default.addObserver(self, selector: #selector(setConnectionWithHost), name: NSNotification.Name(rawValue: "connectingHost"), object: nil)
    }
}
