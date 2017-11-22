//
//  ExtraPointViewController.swift
//  Brainshots
//
//  Created by Amritpal Singh on 28/02/17.
//  Copyright © 2017 Anuradha Sharma. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ExtraPointViewController: UIViewController {

    //MARK:- Outlets
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var lblPoint: UILabel!
    @IBOutlet weak var lblNiceGoing: UILabel!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var topLabelConstraint: NSLayoutConstraint!
    @IBOutlet weak var imgBottomConstraint: NSLayoutConstraint!
    
    //MARK:- Variables
    var scoresArray = NSMutableArray()
    var roundWinner = String()
    var strMessage = String()
    var totalScores = NSInteger()
    
    //MARK:- Constants
    let kAwardedText    = "YOU ARE AWARDED AN EXTRA POINT"
    let kNiceGoing      = "NICE GOING!!!"
   
    
    //MARK:- Did Load
    override func viewDidLoad(){
        
        // strMessage = "Paul Wins the Round"
        
        super.viewDidLoad()
        
        backView.isHidden = true
        
        lblMessage.text = ""
        lblPoint.text = ""
        lblNiceGoing.text = ""

        /*Add scores to last player*/
        addScoreToLastPlayer()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- Add Scores for Winnner
    func addScoreToLastPlayer(){
    
        scoresArray = CommonFunctions.sharedInstance.getPlayersScore()
        
        var array = [String]()
         
         for i in 0...scoresArray.count-1 {
         
            var dict = [String:Any]()
            dict = scoresArray.object(at: i) as! [String : Any]
            array.insert(dict["peerName"] as! String, at: i)
         }
         
         let index = array.index(of:roundWinner)
         let dict : NSDictionary = scoresArray.object(at:index!) as! NSDictionary
         
         let mutDict : NSMutableDictionary = dict.mutableCopy() as! NSMutableDictionary
         
         var score : NSInteger = dict.value(forKey:"score")! as! NSInteger
         score = score + 1
         totalScores = score
         mutDict.setValue(score, forKey:"score")
         scoresArray.replaceObject(at: index!, with: mutDict)
         CommonFunctions.sharedInstance.setScoresArray(array:scoresArray)
        
         perform(#selector(showPopUpMessage), with: nil, afterDelay: 0.5)

    }
    
    //MARK:- Popup Message
    func showPopUpMessage() {
        
        let attributes = [NSStrokeWidthAttributeName: -2.0,
                          NSStrokeColorAttributeName: UIColor.black,
                          NSForegroundColorAttributeName: UIColor.white] as [String : Any];

        lblMessage.attributedText = NSAttributedString(string: strMessage , attributes: attributes)
        lblPoint.attributedText = NSAttributedString(string: kAwardedText, attributes: attributes)
        lblNiceGoing.attributedText = NSAttributedString(string: kNiceGoing, attributes: attributes)
        
        backView.isHidden = false
        CommonFunctions.sharedInstance.setPopupAnimation(target: backView)
        
        checkIfPlayerWins()
    }
    
    //MARK:- Player Winning Check
    func checkIfPlayerWins() {
        
        let gamePoints = CommonFunctions.sharedInstance.getGamePoints()
        
        if(totalScores > gamePoints || totalScores == gamePoints){
            
            perform(#selector(navigateToVictory), with: nil, afterDelay: 2)
        }
        else{
            perform(#selector(navigateToLeaderBoard), with: nil, afterDelay: 2)
        }
    }
    
    //MARK:- Navigate
    func navigateToLeaderBoard(){
    
        let controller = self.storyboard?.instantiateViewController(withIdentifier: kLeaderBoardVC) as! LeaderBoardViewController
        _ = self.navigationController?.pushViewController(controller, animated: false)
        
    }
    
    /*Navigation to Victory View Controller*/
    func navigateToVictory(){
        
        let controller = self.storyboard?.instantiateViewController(withIdentifier: kVictoryAnimationVC) as! VictoryAnimationViewController
        _ = self.navigationController?.pushViewController(controller, animated: false)
        controller.strWinner = roundWinner
    }
}
