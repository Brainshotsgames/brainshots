//
//  CommonFunctions.swift
//  Brainshots
//
//  Created by Anuradha Sharma on 18/11/16.
//  Copyright © 2016 Anuradha Sharma. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation
import MultipeerConnectivity
import AVFoundation
import GameKit


class CommonFunctions: NSObject
{
    //MARK: Shared Instance
    static let sharedInstance : CommonFunctions = {
        let instance = CommonFunctions()
        return instance
    }()
    
    //MARK:- Shared variables
    var profileImage = UIImage()
    var volume: Float?
    var hostID : MCPeerID?
    var playersArray =  [MCPeerID]()
    var shotName = String()
    var connectedPlayers = [MCPeerID]()
    var wordPlay = String()
    var scores = NSInteger()
    var scoresArray = NSMutableArray()
    var randomPlayer = [MCPeerID]()
    var gamePoints = NSInteger()
    var firstRandomElement : MCPeerID?
    var allPlayer = NSMutableArray()
    var randomWordArray = [String]()
    var randomLightningRoundWord = [String]()
    var lightningCount : NSInteger = 0
    var firstName = String()
    
    
    
    //MARK:- Shadow View
    func setupView(view : UIView) {
        
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 1.0
        view.layer.shadowRadius = 1.0
        view.layer.shadowOffset = CGSize(width: 2, height: 2)
    }
    
    //MARK:- Lightning Count 
    func fillLightningRoundCount(){
        
        lightningCount = lightningCount + 1
    }
    
    func resetLightningCount(){
    
        lightningCount = 0
    }
    
    //MARK:- Players connecting while playing the round
    //Remove Player within gameplay if connection Lost
    func removePlayer(peer:MCPeerID){
    
        if allPlayer.contains(peer){
            allPlayer.remove(peer)
        }
    }
    
    func saveFirstRandomPeer(element:MCPeerID){
        firstRandomElement = element
    }
    
    func getFirstRandomPeer()->MCPeerID {
        return firstRandomElement!
    }
    
    //MARK:- Button Borders
    func setupButtonBorder(vw : AnyObject) {
        
        vw.layer.borderWidth = 2
        vw.layer.borderColor = UIColor.white.cgColor
    }
    
    //MARK:- Button Borders + Corner Radius
    func setupButtonBorderwithRadius(vw : AnyObject) {
        
        vw.layer.borderWidth = 2
        vw.layer.borderColor = UIColor.black.cgColor
        vw.layer.cornerRadius = 20
    }
    
    //MARK:- Get Current Date
    func getCurrentDate() -> String {
        
        let date = NSDate()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, YYYY"
        let dateString = dateFormatter.string(from: date as Date)
        return dateString
    }
    
    //MARK:- IsValid Email
    func isValidEmail(_ email:String) -> Bool {
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        return emailTest.evaluate(with: email)
    }
    
    //MARK:- Center Crop Image
    func cropToBounds(image: UIImage, width: Double, height: Double) -> UIImage {
        
        let contextImage: UIImage = UIImage(cgImage: image.cgImage!)
        
        let contextSize: CGSize = contextImage.size
        
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        var cgwidth: CGFloat = CGFloat(width)
        var cgheight: CGFloat = CGFloat(height)
        
        // See what size is longer and create the center off of that
        if contextSize.width > contextSize.height {
            posX = ((contextSize.width - contextSize.height) / 2)
            posY = 0
            cgwidth = contextSize.height
            cgheight = contextSize.height
        } else {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
            cgwidth = contextSize.width
            cgheight = contextSize.width
        }
        
        let rect: CGRect = CGRect(x:posX, y:posY,width: cgwidth,height: cgheight)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImage = contextImage.cgImage!.cropping(to: rect)!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let image: UIImage = UIImage(cgImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
        
        return image
    }
    
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
    
    //MARK:- Get Profile Details
    func getProfileDetails()-> NSMutableDictionary {
    
        /*Dictionary to return Profile Details*/
        let dicDetails = NSMutableDictionary()
        
        /*Get Context*/
        let context = getContext()
        let entity =  NSEntityDescription.entity(forEntityName: "Profile", in: context)
        let request: NSFetchRequest<Profile> = Profile.fetchRequest()
        request.entity = entity
        
        do {
            /*Fetch Profile Details from CoreData*/
            let fetchResults = try getContext().fetch(request)
            for trans in fetchResults as [NSManagedObject] {
                    
                let first_name :String = trans.value(forKey: "firstName") as! String
                let last_name  :String     = trans.value(forKey: "lastName") as! String
                let gender     :String     = trans.value(forKey: "gender") as! String
                let date       :String     = trans.value(forKey: "date") as! String
                let country    :String     = trans.value(forKey: "country") as! String
                let email :String  = trans.value(forKey: "email") as! String
                
                dicDetails.setValue(first_name, forKey:"firstName")
                dicDetails.setValue(last_name, forKey:"lastName")
                dicDetails.setValue(gender, forKey:"gender")
                dicDetails.setValue(date, forKey:"date")
                dicDetails.setValue(country, forKey:"country")
                dicDetails.setValue(email, forKey:"email")
            }
            
        } catch let error as NSError {
            
            print(error.localizedDescription)
        }
        
        return dicDetails
    }
    
    func getProfileImage() -> UIImage {
    
        /*UIImage to return User Profile Image*/
        var image = UIImage()
        
        /*Get Context*/
        let context = getContext()
        let entity =  NSEntityDescription.entity(forEntityName: "Profile", in: context)
        let request: NSFetchRequest<Profile> = Profile.fetchRequest()
        request.entity = entity
        
        do {
            /*Fetch Profile Details from CoreData*/
            let fetchResults = try getContext().fetch(request)
            for trans in fetchResults as [NSManagedObject] {
               
                let imageData   = trans.value(forKey: "image") as! Data
                image = UIImage(data: imageData)!
                
                            }
            
        } catch let error as NSError {
            
            print(error.localizedDescription)
        }
        
        return image
    }
    
    //MARK:- Pop Animation
    func setPopupAnimation(target:UIView){
        
        target.transform = CGAffineTransform.init(scaleX:  0.001, y: 0.001)
        
        UIView.animate(withDuration: 0.3/1.5, animations: {
            target.transform = CGAffineTransform.init(scaleX:  1.1, y: 1.1)
        }, completion:{ (true) in
            UIView.animate(withDuration: 0.3/2, animations: {
                target.transform = CGAffineTransform.init(scaleX: 0.9, y: 0.9)
            }, completion:{ (true) in
                UIView.animate(withDuration: 0.3/2, animations: {
                    target.transform = .identity
                })
            })
        })
    }
    
    //MARK:- Shadow
    func setShadowToView(target:UIView){
    
        target.layer.shadowColor = UIColor.black.cgColor
        target.layer.shadowOpacity = 1
        target.layer.shadowRadius = 5
        target.layer.shadowOffset = CGSize(width: 0, height: 0)
    }
    
    //MARK:- Host
    /*Set Host ID */
    func setHostID(peerID:MCPeerID){
    
        hostID = peerID
    }
    
    /*Get Host ID*/
    func getHostID() -> MCPeerID {
    
        return hostID!
    }
    
    //MARK:- Add Players
    /*Add players to host*/
    func addPlayers(peer:MCPeerID) {
    
        playersArray.append(peer)
    }
    
    func removePlayers(peer:MCPeerID) {
    
        if let index = playersArray.index(of: peer) {
            playersArray.remove(at: index)
        }
    }
    
    //MARK:- Random Word
    /*Save word to be play*/
    func setWordPlay(word:String) {
        
        UserDefaults.standard.set(word, forKey: "wordPlay")
    }
    
    /*Get word to be play*/
    func getWordPlay() -> String {
    
        return UserDefaults.standard.value(forKey: "wordPlay") as! String
    }
    
    /*Save scores*/
    func setScores(score:NSInteger){
    
        scores = score
    }
    
    //MARK:- Scores Config
    /*Get scores*/
    func getScores()->NSInteger {
    
        return scores
    }
    
    /*Store players scores array*/
    func setScoresArray(array:NSMutableArray) {
        scoresArray = array
    }
    
    /*Get Players Score Array*/
    func getPlayersScore()-> NSMutableArray {
    
        return scoresArray
    }
    
    /*Remove players stats if connection lost*/
    func removePlayersScoreStats(peer:MCPeerID) {

        let displayName = peer.displayName
        var displayArray = [String]()
        
        if(scoresArray.count > 0) {
            for i in 0...scoresArray.count-1 {
                
                let dict : [String: Any] = scoresArray[i] as! [String : Any]
                let name = dict["peerName"] as! String
                displayArray.append(name)
            }
        }

        if(displayArray.contains(displayName)){
        
            let index = displayArray.index(of: displayName)
            scoresArray.removeObject(at: index!)
        }
    }
    
    //MARK:- Random Player Config for Lightning Round
    func setRandomPlayerArray(array:[MCPeerID]){
    
        randomPlayer = array
    }
    
    func getRandomPlayer()-> [MCPeerID] {
        
        return randomPlayer
    }
    
    func removeRandomPlayer(peer:MCPeerID){
        
        if randomPlayer.contains(peer){
        
            let index : NSInteger = randomPlayer.index(of: peer)!
            randomPlayer.remove(at:index)
        }
    }
    
    //MARK:- WordPack Array
    func setRandomWordArray(){
    
        let wordPackTag = UserDefaults.standard.integer(forKey: "wordPackTag")
        
        let randomNum:UInt32 = arc4random_uniform(10) // range is 0 to 99
        // convert the UInt32 to some other  types
        let someInt:Int = Int(randomNum)
        print(someInt)
        
        let randomNumber : Int = UserDefaults.standard.value(forKey: "randomNumber") as! Int
        
        if(randomNumber  == someInt) {
            setRandomWordArray()
        }
        else {
            
            var shuffelarray = [String]()
            let wordPackArray = addWordpacksArray(tag:wordPackTag)
            
            for _ in 0...randomNumber {
            
                shuffelarray = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: wordPackArray) as! [String]
            }
            
            UserDefaults.standard.set(randomNumber, forKey: "randomNumber")
            randomWordArray = shuffelarray
        }
    }
    
    //Check for Purchased Packs (It will return the total wordpacks string array)
    func addWordpacksArray(tag:NSInteger) -> [String] {
    
        var totalArray = [String]()
        var dictionary : NSDictionary?
        
        if (tag == kRegularPack) {
            
            dictionary = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "REGULAR", ofType: "plist")!)
        }
        
        if(tag == kLovePack) {
            
            dictionary = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "LOVE", ofType: "plist")!)
        }
        
        if(tag == kRock_Roll){
            
            dictionary = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "ROCK AND ROLL", ofType: "plist")!)
        }
        
        if(tag == kEarth_Space){
            
            dictionary = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "EARTH AND SPACE", ofType: "plist")!)
        }
        if(tag == kHipHop){
            
            dictionary = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "HIP HOP", ofType: "plist")!)
        }
        if(tag == kCountry_Western){
            
            dictionary = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "COUNTRY AND WESTERN", ofType: "plist")!)
        }
        if(tag == kWordStew){
            
            dictionary = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "WORD STEW", ofType: "plist")!)
        }
        
        totalArray = dictionary?["WordPack"] as! [String]
        
        return totalArray
    }
    
    func getWordArray()-> Array<String> {
        
        return randomWordArray
    }
    
    func removeWordFromArray(element:String){
    
        if(randomWordArray.contains(element)){
        
            let index = randomWordArray.index(of: element)
            randomWordArray.remove(at: index!)
            
            if(randomWordArray.count == 0){
                setRandomWordArray()
            }
        }
    }
    
    //MARK:- Lightning Round WordPack
    func setRandomLightningArray(){
        
        let wordPackTag = UserDefaults.standard.integer(forKey: "wordPackTag")
        
        let randomNum:UInt32 = arc4random_uniform(10) // range is 0 to 99
        // convert the UInt32 to some other  types
        let someInt:Int = Int(randomNum)
        print(someInt)
        
        let randomNumber : Int = UserDefaults.standard.value(forKey: "randomNumber") as! Int
        
        if(randomNumber  == someInt) {
            setRandomLightningArray()
        }
        else {
            
            var shuffelarray = [String]()
            let lightningRound = addLightningPacksArray(tag:wordPackTag)
            
            for _ in 0...randomNumber {
            
                shuffelarray = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: lightningRound) as! [String]
            }
            
            UserDefaults.standard.set(randomNumber, forKey: "randomNumber")
            randomLightningRoundWord = shuffelarray
        }
    }
    
    //Check for Purchased Packs (It will return the total wordpacks string array)
    func addLightningPacksArray(tag:NSInteger) -> [String] {
        
        var totalArray = [String]()
        var dictionary : NSDictionary?
        
        if (tag == kRegularPack) {
        
            dictionary = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "REGULAR", ofType: "plist")!)
        }
        
        if(tag == kLovePack) {
            
            dictionary = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "LOVE", ofType: "plist")!)
        }
        if(tag == kRock_Roll){
            
            dictionary = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "ROCK AND ROLL", ofType: "plist")!)
        }
        if(tag == kEarth_Space){
            
            dictionary = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "EARTH AND SPACE", ofType: "plist")!)
        }
        if(tag == kHipHop){
            
            dictionary = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "HIP HOP", ofType: "plist")!)
        }
        if(tag == kCountry_Western){
            
            dictionary = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "COUNTRY AND WESTERN", ofType: "plist")!)
        }
        if(tag == kWordStew){
            
            dictionary = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "WORD STEW", ofType: "plist")!)
        }
        
        totalArray  = dictionary?["LightningRound"] as! [String]
        return totalArray
    }

    
    func getLightningRoundWordArray()-> Array<String> {
        
        return randomLightningRoundWord
    }
    
    func removeLightningRoundWord(element:String){
        
        if(randomLightningRoundWord.contains(element)){
            
            let index = randomLightningRoundWord.index(of: element)
            randomLightningRoundWord.remove(at: index!)
            
            if(randomLightningRoundWord.count == 0){
                setRandomLightningArray()
            }
        }
    }
    
    //MARK:- Game Points Config
    func setGamePoints(points:NSInteger){
        
        gamePoints = points
    }
    
    func getGamePoints()-> NSInteger {
        
        return gamePoints
    }
    
    //MARK:- Sorting Array
    func sortDiscriptor(arrayToBeSort:NSArray) -> NSArray {
        
        let scoreDiscriptor = NSSortDescriptor.init(key: "score", ascending: false)
        let sortDiscriptor = NSArray(object:scoreDiscriptor)
        let tempArray = arrayToBeSort.sortedArray(using:sortDiscriptor as! [NSSortDescriptor])
        let sortedArray  = NSArray.init(array: tempArray)
        return sortedArray
    }
    
    //MARK:- How To Play 
    func howToPlayText(text:String) ->NSMutableAttributedString {
        
        let attributedString = NSMutableAttributedString.init(string:text)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = calculatedLineSpacing()
        paragraphStyle.alignment = .justified
        
        let font = UIFont(name:kFatFrankRegular, size: setFontSize())
        
        attributedString.addAttribute(NSFontAttributeName, value: font! ,range:NSMakeRange(0, attributedString.length))
        attributedString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
        
        return attributedString
    }
    
    /*Line Spacing for Devices*/
    func calculatedLineSpacing()->CGFloat {
        
        var value = CGFloat()
        
        if(DeviceType.IS_IPHONE_5) {
            value = 4
        }
        else if DeviceType.IS_IPHONE_6 || DeviceType.IS_IPHONE_6P {
            
            value = 7
        }
        
        return value
    }
    
    /*Set Font Size*/
    func setFontSize()-> CGFloat {
        
        var fontSize = CGFloat()
        
        if (DeviceType.IS_IPHONE_5) {
            fontSize = 16.5
        }
        else if (DeviceType.IS_IPHONE_6) {
            fontSize = 19.0
        }
        else if (DeviceType.IS_IPHONE_6P) {
            fontSize = 22.0
        }
        else if (DeviceType.IS_IPHONE_4_OR_LESS){
            fontSize = 14.0
        }
        return fontSize
    }
}
