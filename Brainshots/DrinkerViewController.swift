//
//  DrinkerViewController.swift
//  Brainshots
//
//  Created by Amritpal Singh on 02/12/16.
//  Copyright © 2016 Anuradha Sharma. All rights reserved.
//

import UIKit
import AVFoundation
import MultipeerConnectivity

class DrinkerViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,IPSessionDelegate {
    
    //MARK:- Outlets
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    //MARK:- Variables
    var drinkArray = NSArray()
    var timer = Timer()
    
    //MARK:- Subvviews
    var showAnimationImgView = UIImageView()
    
    //MARK:- Did Load
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        /*Drink Array*/
        drinkArray = ["WATER",
                      "SODA",
                      "COFFEE",
                      "JUICE",
                      "FLAVORED WATER",
                      "MILK",
                      "ICED TEA",
                      "LEMONADE",
                      "OTHER",
                      "NO SHOT"]
        
        appDelegate.IPSession.delegate = self
        //appDelegate.THSession.delegate = self
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            
            self.addImageForAnimation()
        }
      }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
    //MARK:- Add Animation
    func addImageForAnimation(){
        
        var imgSinker = UIImage()
        showAnimationImgView.frame = self.view.frame
        self.view.addSubview(showAnimationImgView)
        showAnimationImgView.isHidden = true
        
        var url = NSURL()
        var data = Data()
        url = Bundle.main.url(forResource: kDrinker, withExtension: kGif)! as NSURL
        
        do {
            data = try Data.init(contentsOf: url as URL)
        } catch {
            print(error)
        }
        
        imgSinker = UIImage.animatedImage(withAnimatedGIFData:data)!
        showAnimationImgView.animationImages = imgSinker.images
        showAnimationImgView.animationDuration = imgSinker.duration
        showAnimationImgView.animationRepeatCount = 1
        showAnimationImgView.image = imgSinker.images?.last
        
    }
    
    //MARK:- TableView Delegate & DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return drinkArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellId = "Cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        let shotsName : String = "\(String(indexPath.row + 1)). \(String(describing: drinkArray.object(at: indexPath.row)))"
        cell.textLabel?.text = shotsName
        cell.textLabel?.font = UIFont.init(name: kFatFrankRegular, size: fontSizeForShot());
        cell.textLabel?.textColor = UIColor.white
        
        let tapAction = UIButton()
        tapAction.frame = CGRect(x: 0, y: 3, width: 250, height: 40)
        cell.contentView.addSubview(tapAction)
        tapAction.tag = indexPath.row
        tapAction.addTarget(self, action: #selector(btnAction), for: .touchUpInside)
        tapAction.addTarget(self, action: #selector(touchDown), for: .touchDown)
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return tableviewCellHeight()
    }
    
    /*Table view cell tap action*/
    func btnAction(_sender:UIButton){
 
        self.view.isUserInteractionEnabled = false
        showAnimation(index:_sender.tag)
    }
    
    //MARK:- Show Animation
    /*show animation after user successfully selects the shot*/
    func showAnimation(index:NSInteger) {
        
        self.view.addSubview(showAnimationImgView)
        showAnimationImgView.isHidden = false
        showAnimationImgView.startAnimating()
        
        
        perform(#selector(stepsSound), with: nil, afterDelay: 0.1)
        perform(#selector(slurpSound), with: nil, afterDelay: 0.2)
        
        /*Block to show Popup ( Your Drink is *** )*/
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            
            let text = "\(self.drinkArray.object(at: index))"
            let popUp = PopupView.init(frame: CGRect(x: 60, y: self.view.frame.size.height - 120, width: self.view.frame.size.width - 120, height: 100))
            popUp.setLabel(text: "Your Shot is \n \(text.capitalized)")
            popUp.setTransitionToController(target:self)
            
            /*Block to hide animation*/
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5){
                
                self.showAnimationImgView.stopAnimating()
                self.showAnimationImgView.animationImages = nil
                
                if(!(UserDefaults.standard.bool(forKey: "isHost"))) {
                    
                    appDelegate.IPSession.sendMessage(message: "selected", peerID: CommonFunctions.sharedInstance.getHostID())
                }
                else {
                    self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.checkIfAllSelectDrink), userInfo: nil, repeats: true)
                }
            }
        }
    }
    
    //MARK:- Connection management by Host
    //Check by host if all players selects their shot.
    func checkIfAllSelectDrink(){

        let playerSet = Set(CommonFunctions.sharedInstance.playersArray)
        let connectedPeersSet = Set((appDelegate.IPSession.session?.connectedPeers)!)
        
        if(!(appDelegate.IPSession.session?.connectedPeers.count == 0)){
        
            if(connectedPeersSet.isSubset(of:playerSet)){
                
                timer.invalidate()
                shotChoiceEndPlay()
                perform(#selector(navigateToGame), with: nil, afterDelay: 0.3)
                appDelegate.IPSession.sendMessage(message: "true")
            }
        }
    }
    
    //MARK:- IPSession Delegate
    func receiveMessage(message: String, from peerid: MCPeerID) {
        
        DispatchQueue.main.async {
            /*Message for host*/
            if(message == "selected") {
                
                CommonFunctions.sharedInstance.addPlayers(peer:peerid)
            }
            
            /*Message for players*/
            if(message == "true") {
                
                self.shotChoiceEndPlay()
                self.navigateToGame()
            }
        }
    }

    //MARK: Navigation
    func navigateToGame() {
        
        let storyBoard = UIStoryboard.init(name: kIndividualGamePlay, bundle: nil)
        let controller = storyBoard.instantiateViewController(withIdentifier: kPartyStartedVC)
         as! PartyStartedViewController
        _ = self.navigationController?.pushViewController(controller, animated: false)
    
        showAnimationImgView.removeFromSuperview()
    }
    
    //MARK:- Sound Fx
    /*Play steps sound*/
    func stepsSound() {
        
        SoundManager.sharedInstance.playStepsInSound()
    }
    
    /*Play slurp sound*/
    func slurpSound(){
        
        SoundManager.sharedInstance.playBigSlurpSound()
    }
    
    /*Shot Choice End Sound*/
    func shotChoiceEndPlay(){
        
        SoundManager.sharedInstance.playShotChoiceEndSound()
    }

    //MARK:- Actions
    //Back Button
    @IBAction func btnBack(_ sender: AnyObject) {
        
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    //TouchDown Action
    @IBAction func touchDown(_ sender: AnyObject) {
        SoundManager.sharedInstance.playButtonPressedSound()
    }
}
