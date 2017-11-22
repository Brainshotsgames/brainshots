//
//  SingViewController.swift
//  Brainshots
//
//  Created by Amritpal Singh on 09/02/17.
//  Copyright © 2017 Anuradha Sharma. All rights reserved.
//

import UIKit
import AVFoundation
import MultipeerConnectivity
import GameKit

class SingViewController: UIViewController,IPSessionDelegate {
    
    //MARK:- Labels
    @IBOutlet weak var lblTimer: UILabel!
    @IBOutlet weak var lblPlayer: UILabel!
    @IBOutlet weak var lblWord: UILabel!
    
    //MARK:- Variables
    var index = NSInteger()
    var timer = Timer()
    var count = NSInteger()
    var display_name = String()
    var myPeerName = String()
    var randomWord = String()
    var checkTimer = Timer()
    
    /*Swipe gesture*/
    let swipeGesture = UISwipeGestureRecognizer()

    //Score
    var scores = NSInteger()
    
    //Scores Array
    var scoresArray = NSMutableArray()
    var totalScores = NSInteger()
    
    //myTurn Bool
    var myTurn = Bool()
    var winner = String()
    
    //Array to store peers who make good guess in the round
    var goodGuessPeers = [MCPeerID]()
    
    //set Bool if no last player wins the round
    var roundComplete = Bool()
    var winnerOfRound = String()
    var allPlayer = NSArray()
    
    var playerOver = [MCPeerID]()
    

    //MARK:- View Did Load
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        /*Add Shadow to Views*/
        CommonFunctions.sharedInstance.setShadowToView(target:lblTimer)
        CommonFunctions.sharedInstance.setShadowToView(target:lblPlayer)
        CommonFunctions.sharedInstance.setShadowToView(target:lblWord)
        
        /*Set bool after players completed one round*/
        UserDefaults.standard.set(false, forKey: "firstRoundOver")
        UserDefaults.standard.set(false, forKey: "lightningRoundOver")
        
        /*Add swipe gesture*/
        addSwipe()
        
        /*Set Lightning Round Count*/
        if(UserDefaults.standard.bool(forKey: "isHost")){
            
            CommonFunctions.sharedInstance.resetLightningCount()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- Connection Lost Notifications
    /*Called when connection lost(for 2 players)*/
    func connectionLost() {
        
        DispatchQueue.main.async {
            
            if(self.timer.isValid){
                
                self.timer.invalidate()
                SoundManager.sharedInstance.stopFx()
                self.lblWord.text = ""
                self.lblPlayer.text = ""
                self.lblTimer.text = ""
            }
            else {
                self.checkWhenTimerStarts()
            }
            
            NotificationCenter.default.removeObserver(self, name:NSNotification.Name(rawValue: "invalidateTimerSound"), object: nil)
        }
    }
    
    func checkWhenTimerStarts(){
        
        checkTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(stopTimer), userInfo: nil, repeats: true)
    }
    
    func stopTimer(){
        
        if(timer.isValid){
            
            timer.invalidate()
            checkTimer.invalidate()
            SoundManager.sharedInstance.stopFx()
            
            self.lblWord.text = ""
            self.lblPlayer.text = ""
            self.lblTimer.text = ""
        }
    }
    
    
    /*Check if Player lost connection (for multiple players)*/
    func checkIfPeerLostConnection(notification:Notification) {
        
        DispatchQueue.main.async {
        
            let dict : [String:Any] = notification.userInfo as! [String:Any]
            let peerID : MCPeerID = dict["peer"] as! MCPeerID
            print(peerID)
            
            if(self.playerOver.contains(peerID)){
                
                self.removePeerFromScoreBoard(peer:peerID)
                
                if(self.goodGuessPeers.contains(peerID)){
                    let index = self.goodGuessPeers.index(of: peerID)
                    self.goodGuessPeers.remove(at:index!)
                }
                
                if(peerID.displayName == self.display_name){
                    
                    if(self.timer.isValid){
                        
                        self.timer.invalidate()
                        SoundManager.sharedInstance.stopFx()
                        self.lblWord.text = ""
                        self.lblPlayer.text = ""
                        self.lblTimer.text = ""
                    }
                    else {
                        self.checkWhenTimerStarts()
                    }
                    
                    self.lblWord.text = ""
                    self.lblTimer.text = ""
                    self.lblPlayer.text = ""
                    
                    let jsonObject = ["message":"connectionLost"]
                    let str : String = getJsonString(dict: jsonObject)
                    appDelegate.IPSession.sendMessage(message: str)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.setTurn()
                    }
                }
            }
            else{
                self.index = self.index-1
            }
        }
    }
    
    func removePeerFromScoreBoard(peer:MCPeerID){
    
        let name = peer.displayName
        var array = [String]()
        
        if(scoresArray.count > 0){
        
            for i in 0...scoresArray.count-1 {
                
                var dict = [String:Any]()
                dict = scoresArray.object(at: i) as! [String : Any]
                array.insert(dict["peerName"] as! String, at: i)
            }

            if(array.contains(name)){
                
                 let index = array.index(of: name)
                 self.scoresArray.removeObject(at: index!)
            }
        }
    }
    
    //MARK:- View Will Appear
    override func viewWillAppear(_ animated: Bool) {
        
        print(CommonFunctions.sharedInstance.getWordArray())
        
        super.viewWillAppear(animated)
        myTurn = false
        
        /*set bool for navigate to lightning round*/
        UserDefaults.standard.set(true, forKey: "navigateToLightning")
        
        appDelegate.IPSession.delegate = self
        myPeerName = (appDelegate.IPSession.session?.myPeerID.displayName)!
        //scores = 0
        
        /*Notification to invalidate timer and sound if connection lost*/
        NotificationCenter.default.addObserver(self, selector: #selector(connectionLost), name: NSNotification.Name(rawValue: "invalidateTimerSound"), object: nil)
        
        /*Notification fire if player lost conection in between*/
        NotificationCenter.default.addObserver(self, selector: #selector(checkIfPeerLostConnection), name: NSNotification.Name(rawValue: "connectionLostForPeer"), object: nil)
        
        if(UserDefaults.standard.bool(forKey: "isHost")) {
            
            roundComplete = false
            winnerOfRound = "failure"
            totalScores = 0
            index = 0
            
            shuffelPlayers()
            print("Players Order ==> \(allPlayer)")
            randomWord = getRandomWord().capitalized
            print("Random Word ==> \(randomWord)")
            
            perform(#selector(setTurn), with: nil, afterDelay: 2)
        }
        
       // perform(#selector(addCounterAnimation), with: nil, afterDelay: 2)
        //addSuccesssss()
        //addFailureeee()
        
    }

    func addSuccesssss(){
        
        let okView : UIView = UIView.init(frame: self.view.frame)
        self.view.addSubview(okView)
        
        let imageView : UIImageView = UIImageView.init(frame:self.view.frame)
        let image : UIImage = UIImage.init(named: "Round_OpenCurtain_NoMic_BG")!
        imageView.image = image
        okView.addSubview(imageView)
        
        let imageViewBoy : UIImageView = UIImageView.init(frame:self.view.frame)
        let imageBoy : UIImage = UIImage.init(named: "boy_ok")!
        imageViewBoy.image = imageBoy
        okView.addSubview(imageViewBoy)
        
    }
    
    func addFailureeee(){
    
        let okView : UIView = UIView.init(frame: self.view.frame)
        self.view.addSubview(okView)
        
        let imageView : UIImageView = UIImageView.init(frame: self.view.frame)
        let image : UIImage = UIImage.init(named: "Round_OpenCurtain_NoMic_BG")!
        imageView.image = image
        okView.addSubview(imageView)
        
        let imageViewBoy : UIImageView = UIImageView.init(frame:self.view.frame)
        let imageBoy : UIImage = UIImage.init(named: "TakeShot")!
        imageViewBoy.image = imageBoy
        okView.addSubview(imageViewBoy)

    }
    
    //MARK:- Players Shuffling
    func shuffelPlayers() {
        
        if(!(UserDefaults.standard.bool(forKey: "firstRoundOver"))){
            
            var arr = appDelegate.IPSession.session?.connectedPeers
            arr?.append((appDelegate.IPSession.session?.myPeerID)!)
            let shuffled : [MCPeerID] = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: arr!) as![MCPeerID]
            let element : MCPeerID = shuffled[0]
            
            CommonFunctions.sharedInstance.saveFirstRandomPeer(element: element)
            allPlayer = shuffled as NSArray
        }
        else {
            checkShuffelArray()
        }
    }
    
    /*Shuffel players after first round over*/
    func checkShuffelArray(){
        
        var arr = appDelegate.IPSession.session?.connectedPeers
        arr?.append((appDelegate.IPSession.session?.myPeerID)!)
        let shuffled : [MCPeerID] = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: arr!) as![MCPeerID]
        let element : MCPeerID = shuffled[0]
        
        if(element == CommonFunctions.sharedInstance.firstRandomElement) {
            self.checkShuffelArray()
        }
        else{
            CommonFunctions.sharedInstance.saveFirstRandomPeer(element: element)
            allPlayer = shuffled as NSArray
        }
    }
    
    //MARK:- Turn Setup (by Host)
    func setTurn() {
        
        if(index < allPlayer.count) {
            
            let peerID : MCPeerID?
            peerID = allPlayer.object(at: index) as? MCPeerID
            playerOver.append(peerID!)
            display_name = (peerID?.displayName)!
            
            print("\(display_name) turns")
            print("Random Word ==> \(randomWord)")
            
            var countAnimation = Bool()
            
            if index == 0 {
                
                countAnimation = true
                UserDefaults.standard.set(true, forKey: "showCountAnimation")
            }
            else {
                
                countAnimation = false
                UserDefaults.standard.set(false, forKey: "showCountAnimation")
            }
            
            
            if(display_name == myPeerName) {
                
                myTurn = true
                
                let gamePoints = UserDefaults.standard.integer(forKey: "pointsLevel")
                
                if(!(UserDefaults.standard.bool(forKey:"firstRoundOver"))) {
                    CommonFunctions.sharedInstance.setGamePoints(points:gamePoints)
                }
             
                let jsonObject = ["message":"HostTurn","word":randomWord,"peer_name":myPeerName,"gamePoints":gamePoints,"firstAttempt":true,"countAnimation":countAnimation] as [String : Any]
                
                let str : String = getJsonString(dict: jsonObject)
                appDelegate.IPSession.sendMessage(message: str)
                
                display_name = myPeerName
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.updateHost()
                }
                
               // perform(#selector(partyStarted), with: nil, afterDelay: 0.4)
            }
            else {
                
                myTurn = false
                
                let jsonObject = ["message":"PlayerTurn","word":randomWord,"peer_name":(peerID?.displayName)!,"countAnimation":countAnimation,"firstAttempt":true] as [String : Any]
                
                let str = getJsonString(dict: jsonObject)
                appDelegate.IPSession.sendMessage(message: str)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.updateHost()
                }
            }
            
            index = index + 1
        }
            
        else {
            
            print("Round One Complete")
            print("Good Guess Peeers --> \(goodGuessPeers)")
            
            self.lblTimer.text = ""
            self.lblWord.text = ""
            self.lblPlayer.text = ""
            self.timer.invalidate()
            
            UserDefaults.standard.set(true, forKey: "GoodGuessPlay")
            UserDefaults.standard.set(true, forKey: "firstRoundOver")
            
            setupForGoodGuess()
            
        }
    }
    
    //MARK:- Swipe Gesture
    func addSwipe() {
        
        swipeGesture.direction = .right
        swipeGesture.addTarget(self, action: #selector(swipeAction))
        self.view.removeGestureRecognizer(self.swipeGesture)
    }
    
    //MARK:- Scores Calculation
    func calculatePlayersScore(peerName:MCPeerID,scores:NSInteger) {
        
        /*Creating scores array when the game starts */
        if(!(UserDefaults.standard.bool(forKey:"firstRoundOver"))) {
          
            let scoresDict = NSMutableDictionary()
            scoresDict.setValue(peerName.displayName,forKey: "peerName")
            scoresDict.setValue(scores, forKey:"score")
            scoresArray.add(scoresDict)
            
            print("Scores Array ===> \(scoresArray)")
            
            setTurn()
        }
        
        /*Adding scores for good guess*/
        else if(UserDefaults.standard.bool(forKey:"GoodGuessPlay")){
        
            let name = peerName.displayName
            var array = [String]()
            
            for i in 0...scoresArray.count-1 {
                
                var dict = [String:Any]()
                dict = scoresArray.object(at: i) as! [String : Any]
                array.insert(dict["peerName"] as! String, at: i)
            }
            
            let index = array.index(of:name)
            let dict : NSDictionary = scoresArray.object(at:index!) as! NSDictionary
            
            let mutDict : NSMutableDictionary = dict.mutableCopy() as! NSMutableDictionary
            
            let score : NSInteger = dict.value(forKey:"score")! as! NSInteger
            totalScores = score + scores
            
            mutDict.setValue(totalScores, forKey:"score")
            scoresArray.replaceObject(at: index!, with: mutDict)
            
            print("Score Array ===> \(scoresArray)")
            
            checkIfPlayerWin(dict:dict)
        
        }
            
        else {
            
            let arr : NSMutableArray = CommonFunctions.sharedInstance.getPlayersScore()
            print(arr)
            let name = peerName.displayName
            var array = [String]()
            
            for i in 0...arr.count-1{
                
                var dict = [String:Any]()
                dict = arr.object(at: i) as! [String : Any]
                array.insert(dict["peerName"] as! String, at: i)
            }
            
            let index = array.index(of:name)
            let dict : NSDictionary = arr.object(at:index!) as! NSDictionary
            
            let mutDict : NSMutableDictionary = dict.mutableCopy() as! NSMutableDictionary
            
            let score : NSInteger = dict.value(forKey:"score")! as! NSInteger
            totalScores = score + scores

            mutDict.setValue(totalScores, forKey:"score")
            arr.replaceObject(at: index!, with: mutDict)
            scoresArray = arr
            
            print("Score Array ===> \(scoresArray)")
            
            checkIfPlayerWin(dict:dict)
        }
    }
    
    //Check if player wins the game
    func checkIfPlayerWin(dict:NSDictionary){
    
        let gamePoint = CommonFunctions.sharedInstance.getGamePoints()
        
        if(totalScores > gamePoint || totalScores == gamePoint ) {
            
            winner = dict["peerName"] as! String
            print("Winner --> \(winner)")
            
            let jsonObject = ["message":"playOver","peer_name":winner,"score":totalScores,"scoreboard":scoresArray] as [String : Any]
            
            let str : String = getJsonString(dict: jsonObject)
            appDelegate.IPSession.sendMessage(message: str)
            
            CommonFunctions.sharedInstance.setScoresArray(array:scoresArray)
            perform(#selector(navigateToVictory), with: nil, afterDelay: 0.2)
            
        }
        else {
            setTurn()
        }
    }
    
    //MARK:- Random word
    func getRandomWord()-> String {
        
        let array : [String] = CommonFunctions.sharedInstance.getWordArray()
        let element = array.randomElement
        CommonFunctions.sharedInstance.removeWordFromArray(element: element)
        return element
    }
    
    //MARK:- Setup by Host for Good Guess Players
    func setupForGoodGuess() {
        
        if(goodGuessPeers.count == 0) {
        
            UserDefaults.standard.set(false, forKey: "GoodGuessPlay")
            
            let jsonObject = ["message":"Over","message2":"\(winnerOfRound)","scoreboard":scoresArray,"winnerOfRound":winnerOfRound] as [String : Any]
            let str : String = getJsonString(dict: jsonObject)
            appDelegate.IPSession.sendMessage(message: str)
            
            CommonFunctions.sharedInstance.setScoresArray(array:scoresArray)
            
            if(!(winnerOfRound == "failure")){
                self.navigateToNextController(message:"\(winnerOfRound)")
            }
            else {
                self.NavigateToScoreBoard()
            }
        }
        
        if(goodGuessPeers.count == 1) {

            let peerID : MCPeerID?
            peerID = goodGuessPeers[0]
            winnerOfRound = (peerID?.displayName)!
            goodGuessPeers.removeAll()
            
            UserDefaults.standard.set(false, forKey: "GoodGuessPlay")
            
            let jsonObject = ["message":"Over","message2":"\(winnerOfRound)","scoreboard":scoresArray,"winnerOfRound":winnerOfRound] as [String : Any]
            let str : String = getJsonString(dict: jsonObject)
            appDelegate.IPSession.sendMessage(message: str)
            CommonFunctions.sharedInstance.setScoresArray(array:scoresArray)
            self.navigateToNextController(message:"\(winnerOfRound)")
           
        }
            
        else if(goodGuessPeers.count > 1) {
           
            let peerID : MCPeerID?
            peerID = goodGuessPeers[0]
            display_name = (peerID?.displayName)!
            
            if(peerID == (appDelegate.IPSession.session?.myPeerID)!){
                
                print("Good Guess Peers is Host")
                
                myTurn = true
                let jsonObject = ["message":"HostTurn","peer_name":myPeerName,"firstAttempt":false] as [String : Any]
                let str : String = getJsonString(dict: jsonObject)
                appDelegate.IPSession.sendMessage(message: str)
                display_name = myPeerName
                perform(#selector(partyStarted), with: nil, afterDelay: 0.4)
                
            }
            else {
                
                myTurn = false
                display_name = (peerID?.displayName)!
                var jsonObject = ["message":"PlayerTurn","peer_name":(peerID?.displayName)! ,"firstAttempt":false] as [String : Any]
                var str = getJsonString(dict: jsonObject)
                appDelegate.IPSession.sendMessage(message: str, peerID: peerID!)
                jsonObject  = ["message":"PlayerTurn","peer_name":(peerID?.displayName)!,"firstAttempt":false] as [String : Any]
                str = getJsonString(dict: jsonObject)
                var arr = CommonFunctions.sharedInstance.connectedPlayers
                let index = arr.index(of: peerID!)
                arr.remove(at: index!)
                if(arr.count > 0){
                    appDelegate.IPSession.sendMessage(message: str, peerIDs: arr)
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    self.updateHost()
                }
            }
            
            goodGuessPeers.remove(at: 0)
            
            print("Good Guess Peeers left --> \(goodGuessPeers)")
        }
    }
    
    // MArk:- Update host view
    func updateHost() {
        
        timer.invalidate()
        self.lblPlayer.text = ""
        self.lblWord.text = ""
        self.lblTimer.text = ""
        
        self.partyStarted()
    }
    
    //MARK:- Session Container Delegates
    func receiveMessage(message: String, from peerid: MCPeerID) {
        
        let dict : [String: Any] =  convertJsonToDictionary(json: message)!
        let str : String = dict["message"] as! String
        
        DispatchQueue.main.async {
            
            if(str == "HostTurn") {
                
                self.lblTimer.text = ""
                self.lblWord.text = ""
                self.lblPlayer.text = ""
                
                let firstAttempt : Bool = (dict["firstAttempt"])! as! Bool
                
                if(firstAttempt == true) {
                
                    self.randomWord = dict["word"] as! String
                    let element : String = self.randomWord.lowercased()
                    CommonFunctions.sharedInstance.removeWordFromArray(element: element)
                    let countAnimation : Bool = (dict["countAnimation"])! as! Bool
                    
                    if countAnimation == true {
                        UserDefaults.standard.set(true, forKey: "showCountAnimation")
                    }
                    else{
                        UserDefaults.standard.set(false, forKey: "showCountAnimation")
                    }
                    
                    if(!(UserDefaults.standard.bool(forKey:"firstRoundOver"))) {
                        let gamePoints = dict["gamePoints"]! as! NSInteger
                        CommonFunctions.sharedInstance.setGamePoints(points:gamePoints)
                    }
                }
                
                self.display_name  = CommonFunctions.sharedInstance.getHostID().displayName
                
                self.partyStarted()
            }
                
            else if (str == "hostSuccess") {
                
                self.lblTimer.text = ""
                self.lblWord.text = ""
                self.lblPlayer.text = ""
                self.timer.invalidate()
                
            }
            else if(str == "playerSuccess") {
                
                self.goodGuessPeers.append(peerid)
                self.calculatePlayersScore(peerName: peerid, scores: 1)
            }
                
            else if(str == "playerFailure"){
                
                self.calculatePlayersScore(peerName: peerid, scores: 0)
            }
                
            else if(str == "hostFailure"){
                
                self.lblTimer.text = ""
                self.lblWord.text = ""
                self.lblPlayer.text = ""
            }
                
            else if(str == "timerInvalidate"){
                
                self.timer.invalidate()
                SoundManager.sharedInstance.stopCountDown()
            }
            else if(str == "Over") {
                
                self.lblTimer.text = ""
                self.lblWord.text = ""
                self.lblPlayer.text = ""
                self.timer.invalidate()
                
                self.winnerOfRound = dict["winnerOfRound"] as! String
                
                let array : NSArray = dict["scoreboard"] as! NSArray
                let arr = array.mutableCopy()
                CommonFunctions.sharedInstance.setScoresArray(array:arr as! NSMutableArray)
                
                if(!(self.winnerOfRound == "failure")){
                
                    self.navigateToNextController(message:dict["message2"] as! String)
                }
                else{
                
                    self.NavigateToScoreBoard()
                }
            }
                
            else if(str == "playOver"){
                
                let array : NSArray = dict["scoreboard"] as! NSArray
                let arr = array.mutableCopy()
                CommonFunctions.sharedInstance.setScoresArray(array:arr as! NSMutableArray)
                self.winner = dict["peer_name"] as! String
                self.navigateToVictory()
            }
            else if (str == "connectionLost"){
            
                if(self.timer.isValid){
                    
                    self.timer.invalidate()
                    SoundManager.sharedInstance.stopFx()
                    self.lblWord.text = ""
                    self.lblPlayer.text = ""
                    self.lblTimer.text = ""
                }
                else {
                    self.checkWhenTimerStarts()
                }
            }
            else {
                
                self.lblTimer.text = ""
                self.lblWord.text = ""
                self.lblPlayer.text = ""
                self.timer.invalidate()
                
                let firstAttempt : Bool = (dict["firstAttempt"])! as! Bool
                
                if(firstAttempt == true) {
                
                    self.randomWord = dict["word"] as! String
                    
                    let element : String = self.randomWord.lowercased()
                    CommonFunctions.sharedInstance.removeWordFromArray(element: element)
                    
                    let countAnimation : Bool = (dict["countAnimation"])! as! Bool
                    if countAnimation == true {
                        UserDefaults.standard.set(true, forKey: "showCountAnimation")
                    }
                    else{
                        UserDefaults.standard.set(false, forKey: "showCountAnimation")
                    }
                }

                let player : String = (dict["peer_name"] as! String?)!
                self.display_name = player
                
                if(self.display_name == self.myPeerName){
                
                    self.myTurn = true
                }
                else{
                
                    self.myTurn = false
                }
                
                self.partyStarted()
            }
        }
    }
    
    // MARK:- Start Game
    func partyStarted(){
        
        if(UserDefaults.standard.bool(forKey: "showCountAnimation")){
        
            lblPlayer.text = "\(display_name.capitalized)'s turn"
            setPopupAnimation(target:lblPlayer)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                
                self.lblWord.text = self.randomWord
                setPopupAnimation(target:self.lblWord)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                
                self.addCounterAnimation()
            }
            
        }
        else {
        
            lblPlayer.text = "\(display_name.capitalized)'s turn"
            setPopupAnimation(target:lblPlayer)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8){
                    
                    self.lblWord.text = self.randomWord
                    setPopupAnimation(target:self.lblWord)
                }
                
                /*Start Timer after words appear*/
                self.count = 10
                self.startTimer()
            }
        }
//        lblPlayer.text = "\(display_name.capitalized)'s turn"
//        setPopupAnimation(target:lblPlayer)
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//        
//             self.lblWord.text = self.randomWord
//             setPopupAnimation(target:self.lblWord)
//        }
//        
//        /*Check is the turn is first*/
//        /*Only in the first turn counting animation will pop*/
//        if(UserDefaults.standard.bool(forKey: "showCountAnimation")){
//        
//            /*Add counting animation after 0.2 second delay*/
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                
//                self.addCounterAnimation()
//            }
//        }
//        else {
//        
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//            
//                /*Start Timer after words appear*/
//                self.count = 10
//                self.startTimer()
//            }
//        }
    }
    
    //MARK: Count Animation
    /*Start Counting Animation at startup*/
    func addCounterAnimation(){
        
        var imgSinker = UIImage()
        let showAnimationImgView = UIImageView()
        showAnimationImgView.frame = self.view.frame
        self.view.addSubview(showAnimationImgView)
        
        var url = NSURL()
        var data = Data()
        url = Bundle.main.url(forResource: kCountDown, withExtension: kGif)! as NSURL
        
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
        showAnimationImgView.startAnimating()
        
        /*Play Count Sound after loading count animation*/
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            
            SoundManager.sharedInstance.playCountSound()
        }
        
        /*Start Time immediatley after countdown animation finish*/
        DispatchQueue.main.asyncAfter(deadline: .now() +  2.6) {
            
            /*Start Timer after words appear*/
            self.count = 10
            self.startTimer()
        }
        
        /*Remove image from memory*/
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            
            /*Remove timer image animation from self*/
            showAnimationImgView.removeFromSuperview()
            showAnimationImgView.animationImages = nil
        }
    }
    
    //MARK:- Swipe Action
    func swipeAction() {
        
        myTurn = false
        scores = 1;
        sendTimerInvalidateMessage()
        self.view.removeGestureRecognizer(self.swipeGesture)
       // CommonFunctions.sharedInstance.setScores(score: scores)
        addSuccessView()
    }
    
    //MARK:- Success Methods
    func addSuccessView() {
        
        self.lblPlayer.text = ""
        self.lblWord.text = ""
        self.lblTimer.text = ""
        timer.invalidate()
        
        SoundManager.sharedInstance.playGoodGuess()
        
        let okView : UIView = UIView.init(frame: self.view.frame)
        self.view.addSubview(okView)
        
        let imageView : UIImageView = UIImageView.init(frame:self.view.frame)
        let image : UIImage = UIImage.init(named: "Round_OpenCurtain_NoMic_BG")!
        imageView.image = image
        okView.addSubview(imageView)
        
        let imageViewBoy : UIImageView = UIImageView.init(frame:self.view.frame)
        let imageBoy : UIImage = UIImage.init(named: "boy_ok")!
        imageViewBoy.image = imageBoy
        okView.addSubview(imageViewBoy)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            
            self.sendSuccessMessage()
            okView.removeFromSuperview()
        }
    }
    
    func sendSuccessMessage() {
        
        if(UserDefaults.standard.bool(forKey: "isHost")) {
            
            if(!(self.roundComplete)){
                self.goodGuessPeers.append((appDelegate.IPSession.session?.myPeerID)!)
            }
            
            let jsonObject = ["message":"hostSuccess"]
            let str : String = getJsonString(dict: jsonObject)
            appDelegate.IPSession.sendMessage(message: str)
            
            let score : NSInteger = 1
            calculatePlayersScore(peerName:(appDelegate.IPSession.session?.myPeerID)!,scores:score)
        }
        else {
            
            let jsonObject = ["message":"playerSuccess"] as [String : Any]
            let str : String = getJsonString(dict: jsonObject)
            appDelegate.IPSession.sendMessage(message: str, peerID: CommonFunctions.sharedInstance.getHostID())
        }
    }

    //MARK:- Timer Invalidate
    func sendTimerInvalidateMessage() {
        
        let jsonObject = ["message":"timerInvalidate"]
        let str : String = getJsonString(dict: jsonObject)
        appDelegate.IPSession.sendMessage(message:str)
    }
    
    //MARK:- Enable Swipe Gesture
    func enableSwipe() {
        
        if(self.myTurn == true) {
            
            self.view.addGestureRecognizer(self.swipeGesture)
        }
        else{
            self.view.removeGestureRecognizer(self.swipeGesture)
        }
    }
    
    //MARK:- Timer
    /*Start timer method*/
    func startTimer() {

        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: true)
        setPopupAnimation2(target:lblTimer)
    }
    
    /*Call method to run timer for 10 seconds*/
    func runTimedCode(){
        
        if(count == 0) {
            
            self.view.removeGestureRecognizer(self.swipeGesture)
            myTurn = false
            
            lblTimer.text = "\(count)"
            timer.invalidate()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                
                if self.display_name == self.myPeerName {
                    
                    self.addFailureView()
                }
            }
        }
        else {
            
            if(count == 9){
                self.enableSwipe()
            }
            
            if(count == 3) {
                SoundManager.sharedInstance.playLast3SecCountDown()
            }
            
            lblTimer.text = "\(count)"
            count = count - 1
        }
    }
    
    //MARK:- Failure View
    func addFailureView()  {
        
        self.lblWord.text = ""
        self.lblTimer.text = ""
        self.lblPlayer.text = ""
        
        SoundManager.sharedInstance.playMissGuess()
        
        let okView : UIView = UIView.init(frame: self.view.frame)
        self.view.addSubview(okView)
        
        let imageView : UIImageView = UIImageView.init(frame: self.view.frame)
        let image : UIImage = UIImage.init(named: "Round_OpenCurtain_NoMic_BG")!
        imageView.image = image
        okView.addSubview(imageView)
        
        let imageViewBoy : UIImageView = UIImageView.init(frame:self.view.frame)
        let imageBoy : UIImage = UIImage.init(named: "TakeShot")!
        imageViewBoy.image = imageBoy
        okView.addSubview(imageViewBoy)

        DispatchQueue.main.asyncAfter(deadline: .now() + 3){
            
            self.sendFailureMessage()
            okView.removeFromSuperview()
        }
    }
    
    func sendFailureMessage(){
    
        if(UserDefaults.standard.bool(forKey: "isHost")){
        
            let jsonObject = ["message":"hostFailure"]
            let str : String = getJsonString(dict: jsonObject)
            appDelegate.IPSession.sendMessage(message: str)
            
            if(self.winnerOfRound == ((appDelegate.IPSession.session?.myPeerID.displayName)!)){
                self.winnerOfRound = "failure"
            }
            
            let score : NSInteger = 0
            calculatePlayersScore(peerName:(appDelegate.IPSession.session?.myPeerID)!,scores:score)
        }
        else {
        
            let jsonObject = ["message":"playerFailure","score":scores] as [String : Any]
            let str : String = getJsonString(dict: jsonObject)
            appDelegate.IPSession.sendMessage(message: str, peerID: CommonFunctions.sharedInstance.getHostID())
        }
    }
    
    //MARK:- Navigation
    
    /*Navigation to Victory View Controller*/
    func navigateToVictory(){
        
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name(rawValue: "invalidateTimerSound"), object: nil)
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name(rawValue: "connectionLostForPeer"), object: nil)
        
        let controller = self.storyboard?.instantiateViewController(withIdentifier: kVictoryAnimationVC) as! VictoryAnimationViewController
        _ = self.navigationController?.pushViewController(controller, animated: false)
        controller.strWinner = winner
    }
    
    /*Navigate to Extra Point Controller*/
    func navigateToNextController(message:String) {
        
        let str = "\(message) Wins the Round"
        
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name(rawValue: "invalidateTimerSound"), object: nil)
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name(rawValue: "connectionLostForPeer"), object: nil)
        
        let controller = self.storyboard?.instantiateViewController(withIdentifier: kExtraPointVC) as! ExtraPointViewController
        _ = self.navigationController?.pushViewController(controller, animated: false)
        controller.strMessage = str
        controller.roundWinner = winnerOfRound
        
    }
    
    /*Navigate to scoreboard*/
    func NavigateToScoreBoard(){
        
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name(rawValue: "invalidateTimerSound"), object: nil)
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name(rawValue: "connectionLostForPeer"), object: nil)
        
        let controller = self.storyboard?.instantiateViewController(withIdentifier: kLeaderBoardVC) as! LeaderBoardViewController
        _ = self.navigationController?.pushViewController(controller, animated: false)
    }
}
