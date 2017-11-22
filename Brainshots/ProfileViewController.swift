//
//  ProfileViewController.swift
//  Brainshots
//
//  Created by Anuradha Sharma on 18/11/16.
//  Copyright © 2016 Anuradha Sharma. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit
import CoreData

class ProfileViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet var lblUserName: UILabel!
    @IBOutlet var lblName: UILabel!
    @IBOutlet var lblCountry: UILabel!
    @IBOutlet var lblGender: UILabel!
    @IBOutlet var lblDate: UILabel!
    @IBOutlet var lblGamesPlayed: UILabel!
    @IBOutlet var lblBestGame: UILabel!
    @IBOutlet weak var statsConsraint: NSLayoutConstraint!
    @IBOutlet var btnEditProfile: UIButton!
    @IBOutlet var btnLogout: UIButton!
    
    //MARK: Sub Views
    @IBOutlet var vwGameStats: UIView!
    @IBOutlet var imgProfile: UIImageView!
    
    //MARK: Variables
    var first_name = String()
    var last_name = String()
    var email = String()
    var gender = String()
    var date = String()
    var country = String()
    
    //MARK: View Did Load
    override func viewDidLoad() {
        
        super.viewDidLoad()
        addBestGames()
        checkLoginStatus()
        CommonFunctions.sharedInstance.setupButtonBorder(vw: imgProfile)
        CommonFunctions.sharedInstance.setupButtonBorder(vw: vwGameStats)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(true)
        getProfileDetails()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: Check Login Status
    func checkLoginStatus() {
       
        btnLogout.isHidden = !(UserDefaults.standard.bool(forKey: "login"))
    }
    
    //MARK: Get Profile Details
    func getProfileDetails() {
    
        let details : NSMutableDictionary = CommonFunctions.sharedInstance.getProfileDetails()
        
            first_name      = (details.value(forKey: "firstName") as! String?)!
            last_name       = (details.value(forKey: "lastName") as! String?)!
            gender          = (details.value(forKey: "gender") as! String?)!
            date            = (details.value(forKey: "date") as! String?)!
            country         = (details.value(forKey: "country") as! String?)!
            email           = (details.value(forKey: "email") as! String?)!

            lblName.text = ("\(first_name) \(last_name)")
            lblUserName.text = email
            lblGender.text = gender
            lblCountry.text = country
            lblDate.text = "Joined Brainshots: \(date)"
        
            let profileImage : UIImage = CommonFunctions.sharedInstance.getProfileImage()
        
            imgProfile.image = CommonFunctions.sharedInstance.cropToBounds(image: profileImage, width: Double(imgProfile.frame.size.width), height: Double(imgProfile.frame.size.height))
    }
    
    //MARK: Logout Action Sheet
    func showSheet () {
        
        let actionSheetController: UIAlertController = UIAlertController(title:kLogoutMessage, message: nil, preferredStyle: .actionSheet)
        let cancelActionButton: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
        }
        actionSheetController.addAction(cancelActionButton)
        let logoutActionButton: UIAlertAction = UIAlertAction(title: "Logout", style: .destructive)
        { action -> Void in
            
            UserDefaults.standard.set(false, forKey: "login")
            fbLoginManager.logOut()
            FBSDKAccessToken.setCurrent(nil)
            FBSDKProfile.setCurrent(nil)
            self.restoreGuest()
            
            _ = self.navigationController?.popViewController(animated: true)
        }
        actionSheetController.addAction(logoutActionButton)
        self.present(actionSheetController, animated: true, completion: nil)
    }
    
    func restoreGuest(){
    
        /// Store Data in Core Data
        let context = getContext()
        let entity =  NSEntityDescription.entity(forEntityName: "Profile", in: context)
        let profile = Profile(entity: entity!, insertInto: context)
        profile.setValue(UIDevice.current.name, forKey: "firstName")
        profile.setValue("", forKey: "lastName")
        profile.setValue("", forKey: "email")
        profile.setValue("USA", forKey: "country")
        profile.setValue("Male", forKey: "gender")
        
        let image = UIImage.init(named: "ProfilePlaceHolder")
        let data : NSData = UIImagePNGRepresentation(image!)! as NSData
        
        profile.setValue(data, forKey: "image")
        profile.setValue("\(CommonFunctions.sharedInstance.getCurrentDate())", forKey: "date")
        do {
            try context.save()
            print("saved!")
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    
    }
    
    //MARK:- Actions
    //MARK: Button Actions
    @IBAction func btnEditProfile(_ sender: AnyObject){
        
        let controller = self.storyboard?.instantiateViewController(withIdentifier:kEditProfileVC) as! EditProfileViewController
        
        controller.first_name   = first_name
        controller.last_name    = last_name
        controller.email        = email
        controller.gender       = gender
        controller.country      = country
        
        self.navigationController?.pushViewController(controller, animated: true)
        
    }
    
    //Back Button Action
    @IBAction func backBtn(_ sender: AnyObject){
        
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    //Logout Action
    @IBAction func btnLogout(_ sender: AnyObject) {
        
        showSheet()
    }
    
    //TouchDown Action
    @IBAction func touchDownAction(_ sender: Any) {
        SoundManager.sharedInstance.playButtonPressedSound()
    }
    
    //MARK:- Scores Stats
    func addBestGames(){
    
        let bestGames = UserDefaults.standard.value(forKey: "bestGame")
        lblBestGame.text = "\(bestGames!)"
        let gamesPlayed = UserDefaults.standard.value(forKey: "gamePlayed")
        lblGamesPlayed.text = "\(gamesPlayed!)"
    }
    
    deinit {
        
        print("Deinit")
    }
}
