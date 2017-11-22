//
//  LeaderBoardViewController.swift
//  Brainshots
//
//  Created by Amritpal Singh on 02/12/16.
//  Copyright © 2016 Anuradha Sharma. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class LeaderBoardViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,IPSessionDelegate {

    @IBOutlet weak var tableView: UITableView!
    var scoresArray = NSArray()
    var navigation = Bool()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        tableView.separatorColor = UIColor.clear
        
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        
        navigation = true
        
        appDelegate.IPSession.delegate = self
        
        /*Sorting Scores Array*/
        let tempArr : NSArray = CommonFunctions.sharedInstance.getPlayersScore().copy() as! NSArray
        scoresArray = CommonFunctions.sharedInstance.sortDiscriptor(arrayToBeSort: tempArr)
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
 
    //MARK:- TableView Delegates & Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return scoresArray.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellId = "Cell"
        
        let cell : LeaderBoardCell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! LeaderBoardCell
        
        if(!((indexPath.row % 2) == 0)) {
        
            cell.backgroundColor = UIColor.lightGray
        }
        else {
        
            cell.backgroundColor = UIColor.init(red: 235.0/255.0, green: 235.0/255.0, blue: 235.0/255.0, alpha: 1)
        }
        
        let dict : [String:Any] = scoresArray.object(at:indexPath.row) as! [String : Any]
        cell.lblPlayer.text = String(describing: dict["peerName"]!)
        cell.lblScore.text = String(describing: dict["score"]!)
        
        return cell
    }
    
    //MARK:- Actions
    @IBAction func btnContinue(_ sender: AnyObject) {
        
        if(UserDefaults.standard.bool(forKey: "navigateToLightning")){
        
            if(UserDefaults.standard.bool(forKey:"lightningRoundOver")) {
                
                if(navigation){
                    navigation = false
                    appDelegate.IPSession.sendMessage(message: "navigateToSingVC")
                    showCurtains()
                }
            }
            else{
                
                if(navigation){
                    navigation = false
                    appDelegate.IPSession.sendMessage(message: "navigateToLightning")
                    perform(#selector(navigateToNext), with: nil, afterDelay: 0.2)
                }
            }
        }
        else {
            
            if(navigation){
                navigation = false
                appDelegate.IPSession.sendMessage(message: "navigateToSingVC")
                showCurtains()
            }
        }
    }
    
    //MARK:- Show Curtains Animation
    func showCurtains() {
        
        appDelegate.showCurtains()
        perform(#selector(navigateToSingVC), with: nil, afterDelay: 1.5)
    }

    
    func navigateToSingVC(){
        
        let array = self.navigationController?.viewControllers
        
        for obj in array! {
            print(obj)
            if obj.isKind(of: SingViewController.self)  {
                
                _ =  self.navigationController?.popToViewController(obj, animated: false)
            }
        }
    }
    
    func navigateToNext(){
    
        let controller = self.storyboard?.instantiateViewController(withIdentifier: kLightningAnimationVC) as! IntroLightningViewController
        _ = self.navigationController?.pushViewController(controller, animated: false)
    }
    
    // Container Delegates
    func receiveMessage(message: String, from peerid: MCPeerID) {
        
        DispatchQueue.main.async {
            
            if(message == "navigateToLightning") {
                
                if(self.navigation) {
                    self.navigation = false
                    self.navigateToNext()
                }
            }
            else if (message == "navigateToSingVC") {
                
                if(self.navigation) {
                    self.navigation = false
                    self.showCurtains()
                }
            }
        }
        
    }
}
