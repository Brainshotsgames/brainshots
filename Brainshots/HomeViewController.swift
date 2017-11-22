//
//  ViewController.swift
//  Brainshots
//
//  Created by Anuradha Sharma on 18/11/16.
//  Copyright © 2016 Anuradha Sharma. All rights reserved.
//

import UIKit
import MBProgressHUD
import CoreData
import AVFoundation

class HomeViewController: UIViewController {

    //MARK:- Outlets
    @IBOutlet var btnProfie: UIButton!
    @IBOutlet var btnPlayAsGuest: UIButton!
    @IBOutlet var btnFbLogin: UIButton!
    @IBOutlet var btnOptions: UIButton!
    @IBOutlet var btnHowToPlay: UIButton!
    
    //MARK:- Variables
    var btnProfileFrame = CGRect()
    var btnPlayAsGuestFrame = CGRect()
    var btnFbLoginFrame = CGRect()
    var btnOptionsFrame = CGRect()
    var isSetup = true
    
    //MARK:- View Did Load
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //changeTopButtonConstraint()
        SoundManager.sharedInstance.playBackgroundSound()
        
        /*Set Random Word from wordPack*/
        CommonFunctions.sharedInstance.setRandomWordArray()
        CommonFunctions.sharedInstance.setRandomLightningArray()
        
        btnOptions.isHidden = true
        btnFbLogin.isHidden  = true
        btnPlayAsGuest.isHidden  = true
        btnProfie.isHidden  = true
        btnHowToPlay.isHidden  = true
    }
    
    override func viewWillAppear(_ animated: Bool) {

        if (isSetup){
            perform(#selector(addButtons), with: nil, afterDelay: 0.5)
            isSetup = false
        }
    }
    
    func addButtons() {
    
        btnOptions.isHidden = false
        btnFbLogin.isHidden  = false
        btnPlayAsGuest.isHidden  = false
        btnProfie.isHidden  = false
        btnHowToPlay.isHidden  = false
        
        btnHowToPlay.bounce(into: self.view, direction: .right)
        btnProfie.bounce(into: self.view, direction: .left)
        btnPlayAsGuest.bounce(into: self.view, direction: .right)
        btnFbLogin.bounce(into: self.view, direction: .left)
        btnOptions.bounce(into: self.view, direction: .right)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:-  Facebook Login
    @IBAction func btnFacebookLogin(_ sender: AnyObject) {
        
        if(UserDefaults.standard.bool(forKey: "login")){
            navigateToPlayController()
        }
        else {
        
            if(Reachability.isConnectedToNetwork()){
                MBProgressHUD.showAdded(to: self.view, animated: true)
                let objFacebook = Facebook()
                objFacebook.getFbData(self, selector: #selector(FBDatResponse))
            }
            else {
                self.alert(title: "No Internet Connection", message: "Please check your internet connection and try again.")
            }
        }
    }

    func FBDatResponse(_ dict:AnyObject)  {

        if(dict.value(forKeyPath: "response.code") as! String == "200") {
            
            UserDefaults.standard.set(true, forKey: "login")
            
            // Delete Previous Records
            deletePreviousRecords()
            
            // Save Profile Details Method
            saveProfileDetails(response: dict.value(forKeyPath: "response.result")! as AnyObject)
            
            // Navigate to Select Play Controller
            navigateToPlayController()
        }
        else {
        
            print("Unable to Login")
        }
        
        MBProgressHUD.hide(for: self.view, animated: true)
    }

    //MARK:- Check Previous Records
    func deletePreviousRecords() {
    
        let context = getContext()
        let entity =  NSEntityDescription.entity(forEntityName: "Profile", in: context)
        let request: NSFetchRequest<Profile> = Profile.fetchRequest()
        request.entity = entity
        do {
            let results = try getContext().fetch(request)
            for trans in results as [NSManagedObject] {
                context.delete(trans)
            }
        }catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    //MARK:- Save Profile Details
    func saveProfileDetails(response:AnyObject) {
        
        let first_name      = String(describing: response.value(forKey: "first_name")!)
        let last_name       = String(describing: response.value(forKey: "last_name")!)
        let email           = String(describing: response.value(forKey: "email")!)
        let gender          = String(describing: response.value(forKey: "gender")!)
        let imageUrlString  = String(describing: response.value(forKeyPath: "picture.data.url")!)
        let date            = String(CommonFunctions.sharedInstance.getCurrentDate())
        
        // Check Location
        var country : String = "USA"
        if(!(response.value(forKeyPath: "location.name") == nil)){
            
            // Get Country Name
            let location = String(describing:response.value(forKeyPath: "location.name")!)
            let locArray = location.components(separatedBy: ",")
            if(locArray.count == 2) {
                country = locArray[1]
            } else{
                country = "USA"
            }
        }
        
        // Convert profileImage into Data
        let img_url = NSURL.init(string: imageUrlString)
        let imageData = NSData(contentsOf: img_url! as URL)
        
        // Store Data in Core Data
        let context = getContext()
        let entity =  NSEntityDescription.entity(forEntityName: "Profile", in: context)
        let profile = Profile(entity: entity!, insertInto: context)
        
        profile.setValue(first_name, forKey: "firstName")
        profile.setValue(last_name, forKey: "lastName")
        profile.setValue(email, forKey: "email")
        profile.setValue(country, forKey: "country")
        profile.setValue(gender, forKey: "gender")
        profile.setValue(imageData, forKey: "image")
        profile.setValue(date, forKey: "date")
        
        do {
            try context.save()
            print("saved!")
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        } 
    }
    
    //MARK:- Actions
    //Profile Action
    @IBAction func btnProfileSetUp(_ sender: AnyObject) {
        
        let storyBoard : UIStoryboard = UIStoryboard.init(name: "Profile", bundle: nil)
        let controller = storyBoard.instantiateViewController(withIdentifier: kProfileVC) as! ProfileViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func setRandomNumber() {
        
        let randomNum:UInt32 = arc4random_uniform(10)
        let someInt:Int = Int(randomNum)
        print(someInt)
    }
    
    //Play As Guest Action
    @IBAction func btnPlayAsGuest(_ sender: AnyObject) {
      
        let vc = self.storyboard?.instantiateViewController(withIdentifier:kIndividualPlayVC) as! IndividualPlayViewController
        vc.pushFromInApp = false
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //Options Action
    @IBAction func btnOptions(_ sender: AnyObject) {
        
        let storyBoard : UIStoryboard = UIStoryboard.init(name: "Options", bundle: nil)
        let controller = storyBoard.instantiateViewController(withIdentifier: kOptionsVC) as! OptionsViewController
        self.navigationController?.pushViewController(controller, animated: true)
        
    }
    
    //TouchDown Action
    @IBAction func touchDownAction(_ sender: Any) {
        SoundManager.sharedInstance.playButtonPressedSound()
    }
    
    //MARK:- Navigation
    func navigateToPlayController(){
        let vc = self.storyboard?.instantiateViewController(withIdentifier:kIndividualPlayVC) as! IndividualPlayViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnHowToPlay(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier:kHowToPlayVC) as! HowToPlayVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
}



extension UIViewController {
    
    func alert(title:String, message:String) {
        
        let alert = UIAlertController(title: title , message: message, preferredStyle: UIAlertControllerStyle.alert )
        let action = UIAlertAction(title: "Done", style: UIAlertActionStyle.default, handler: {Void in})
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
}

