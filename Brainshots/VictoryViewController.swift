//
//  VictoryViewController.swift
//  Brainshots
//
//  Created by Amritpal Singh on 02/12/16.
//  Copyright © 2016 Anuradha Sharma. All rights reserved.
//

import UIKit

class VictoryViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var btnQuit: UIButton!
    @IBOutlet weak var btnNewGame: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var lblResult: UILabel!
    
    var strResult = String()
    var strWinner = String()
    var scoresArray = NSArray()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        /*Message*/
        strResult = "CONGRATS \(strWinner.uppercased()) \n YOU ARE A ROCKSTAR !"
        
        /*Update Games Played and Best Games*/
        updateGamesPlayed_BestGames()

        /*Set all default values to false when the game is over*/
        UserDefaults.standard.set(false, forKey: "navigateToLightning")
        UserDefaults.standard.set(false, forKey: "lightningRoundOver")
        UserDefaults.standard.set(false, forKey: "navigateToSingVC")
        UserDefaults.standard.set(false, forKey: "GameStarts")
        
        /*Removing Notifications*/
         NotificationCenter.default.removeObserver(self, name:NSNotification.Name(rawValue: "connectionLostWithHost"), object: nil)
        
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name(rawValue: "connectionLost"), object: nil)
        
        /*PopUp Result Method*/
        perform(#selector(popResults), with: nil, afterDelay: 0.5)
        
        /*Add Actions for buttons*/
        btnQuit.addTarget(self, action: #selector(quitAction), for: .touchUpInside)
        btnNewGame.addTarget(self, action: #selector(newGameAction), for: .touchUpInside)
        
        /*Sorting Scores Array*/
        let tempArr : NSArray = CommonFunctions.sharedInstance.getPlayersScore().copy() as! NSArray
        scoresArray = CommonFunctions.sharedInstance.sortDiscriptor(arrayToBeSort: tempArr)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*Pop Result Method*/
    func popResults() {
        
        lblResult.text = strResult
        CommonFunctions.sharedInstance.setPopupAnimation(target: lblResult)
    }

    /*Quit Button Action*/
    func quitAction() {
        
        /*Set Random Word from wordPack*/
        CommonFunctions.sharedInstance.setRandomWordArray()
        CommonFunctions.sharedInstance.setRandomLightningArray()
        
        SoundManager.sharedInstance.playBackgroundSound()
        disconnectSession()
        
        /*Navigation Stack Array*/
        let array = self.navigationController?.viewControllers
        
        for obj in array! {
            print(obj)
            if obj.isKind(of: HomeViewController.self)  {
                _ =  self.navigationController?.popToViewController(obj, animated: true)
            }
        }
    }
    
    /*New Game Button Action*/
    func newGameAction(){
        
        SoundManager.sharedInstance.playBackgroundSound()
        disconnectSession()
        
        let array = self.navigationController?.viewControllers
        
        for obj in array! {
            print(obj)
            if obj.isKind(of: IndividualPlayViewController.self)  {
                
                _ =  self.navigationController?.popToViewController(obj, animated: true)
            }
        }
    }
    
    
    //MARK:- Disconnect Individual Play Session
    func disconnectSession(){
        
        /*disconnect the session instance*/
        appDelegate.IPSession.session?.disconnect()
        
        /*If user is a host then stop advertising the peers of host for avoiding another game play intruption of same peer*/
        if(UserDefaults.standard.bool(forKey: "isHost")){
            
            UserDefaults.standard.set(false, forKey: "isHost")
            appDelegate.IPSession.advertiserAssistant?.stopAdvertisingPeer()
        }
    }
    
    //MARK:- TableView Delegates & DataSource
    /*Table View DataSource*/
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scoresArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellId  = "Cell"
        
        let cell : VictoryCell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! VictoryCell

        if(indexPath.row == 0) {
        
            cell.lblPlayer.font = UIFont.init(name: kFatFrankRegular, size: 25)
            cell.lblPoints.font = UIFont.init(name: kFatFrankRegular, size: 25)
        }
        
        let dict : [String:Any] = scoresArray.object(at:indexPath.row) as! [String : Any]
        cell.lblPlayer.text = String(describing: dict["peerName"]!)
        cell.lblPoints.text = String(describing: dict["score"]!)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 30
    }
    
    //MARK:- GamesPlayed Updation
    func updateGamesPlayed_BestGames() {
        
        if(strWinner == appDelegate.IPSession.session?.myPeerID.displayName){
            
            updateGamesPlayed()
            updateBestGames()
        }
        else {
            
            updateGamesPlayed()
        }
    }
    
    func updateGamesPlayed (){
    
        let gamesPlayed : NSInteger = UserDefaults.standard.value(forKey: "gamePlayed") as! NSInteger
        let gamePlayed = gamesPlayed + 1
        UserDefaults.standard.set(gamePlayed, forKey: "gamePlayed")
        
    }
    
    func updateBestGames(){
    
        let bestGamesPlayed : NSInteger = UserDefaults.standard.value(forKey: "bestGame") as! NSInteger
        let bestGame = bestGamesPlayed + 1
        UserDefaults.standard.set(bestGame, forKey: "bestGame")
    }
    
    //MARK:- TouchDown Actions
    @IBAction func touchDown(_ sender: AnyObject) {
        SoundManager.sharedInstance.playButtonPressedSound()
    }    
}
