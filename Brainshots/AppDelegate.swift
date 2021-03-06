//
//  AppDelegate.swift
//  Brainshots
//
//  Created by Anuradha Sharma on 18/11/16.
//  Copyright © 2016 Anuradha Sharma. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import CoreData
import MultipeerConnectivity
import StoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,hideCurtainDelegate {

    var backgroundUpdateTask: UIBackgroundTaskIdentifier = 0
    var checkTimer = Timer()
    var window: UIWindow?
    var curtainsVC :CurtainViewController!
    var IPSession = IndividualSession()  //Global Session Variable
    var products = [SKProduct]()
    
    //DID FINISH LOADING
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
        setDefaults()
        reload()
        fillDefaultData()
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    //MARK:- Reload Products
    func reload() {
        
        products = []
        RageProducts.store.requestProducts{success, products in
            
            if success {
                self.products.removeAll()
                self.products = products!
            }
        }
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(
            app,
            open: url as URL!,
            sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String,
            annotation: options[UIApplicationOpenURLOptionsKey.annotation]
        )
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        let facebookDidHandle = FBSDKApplicationDelegate.sharedInstance().application(
            application,
            open: url,
            sourceApplication: sourceApplication,
            annotation: annotation)
        
        return facebookDidHandle
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
       
        self.backgroundUpdateTask = UIApplication.shared.beginBackgroundTask(expirationHandler: {
            self.endBackgroundUpdateTask()
        })
    }
    
    func endBackgroundUpdateTask() {
        
        UIApplication.shared.endBackgroundTask(self.backgroundUpdateTask)
        self.backgroundUpdateTask = UIBackgroundTaskInvalid
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        checkTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(expireSession), userInfo: nil, repeats: false)
        
    }
    
    func expireSession() {
        appDelegate.IPSession.session?.disconnect()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        self.endBackgroundUpdateTask()
        checkTimer.invalidate()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        self.saveContext()
        appDelegate.IPSession.session?.disconnect()
        
        if(UserDefaults.standard.bool(forKey: "isHost")){
            
            UserDefaults.standard.set(false, forKey: "isHost")
            appDelegate.IPSession.advertiserAssistant?.stopAdvertisingPeer()
        }
    }
    
    //MARK:- Additions
    /*Add Curtains Opening & Closing handler VC to window*/
    func addCurtainsVC() {
        
        curtainsVC = CurtainViewController()
        curtainsVC.view.frame = (self.window?.frame)!
        curtainsVC.delegate = self
        self.window?.addSubview(curtainsVC.view)
    }
    
    /*Calling Curtains VC for curtains opening & closing animation*/
    func showCurtains() {
        
        addCurtainsVC()
        self.window?.bringSubview(toFront: curtainsVC.view)
        curtainsVC.closeCurtains()
    }
    
    /*Remove the Curtains View from window after comlpetion of animation*/
    func hideCurtains() {
        
        self.window?.sendSubview(toBack:curtainsVC.view)
        self.window?.willRemoveSubview(curtainsVC.view)
        curtainsVC.delegate = nil
        curtainsVC = nil
    }
    
    /*method calling from Curtains VC for showing only curtains opening animation*/
    func showCurtainsOpening(){
        
        addCurtainsVC()
        self.window?.bringSubview(toFront: curtainsVC.view)
        curtainsVC.openCurtainsOnlyAnimation()
    }
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "CoreData")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    func saveContext () {
        print("treminate")
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    //MARK:- Set Defaults
    func setDefaults(){
    
        /*store joining date*/
        if(!(CommonFunctions.sharedInstance.isKeyPresentInUserDefaults(key:"JoiningDate"))){
            
            let date = Date()
            let format = DateFormatter()
            format.dateFormat = "yyyy-MM-dd hh:mm:ss"
            let dateString = format.string(from: date)
            UserDefaults.standard.set(dateString, forKey: "JoiningDate")
        }
        /*store music volume value*/
        if(!(CommonFunctions.sharedInstance.isKeyPresentInUserDefaults(key:"musicVolume"))){
        
             UserDefaults.standard.set(0.30, forKey: "musicVolume")
        }
        /*store fx volume value*/
        if(!(CommonFunctions.sharedInstance.isKeyPresentInUserDefaults(key:"fxVolume"))){
            
            UserDefaults.standard.set(0.5, forKey: "fxVolume")
        }
        /*store points level for gameplay*/
        if(!(CommonFunctions.sharedInstance.isKeyPresentInUserDefaults(key:"pointsLevel"))){
            
            UserDefaults.standard.set(25, forKey: "pointsLevel")
        }
        if(!(CommonFunctions.sharedInstance.isKeyPresentInUserDefaults(key:"gamePlayed"))){
            
            UserDefaults.standard.set(0, forKey: "gamePlayed")
        }
        if(!(CommonFunctions.sharedInstance.isKeyPresentInUserDefaults(key:"bestGame"))){
            
            UserDefaults.standard.set(0, forKey: "bestGame")
        }
        if(!(CommonFunctions.sharedInstance.isKeyPresentInUserDefaults(key:"randomNumber"))){
            
            let randomNum:UInt32 = arc4random_uniform(10) // range is 0 to 9
            // convert the UInt32 to some other  types
            let someInt:Int = Int(randomNum)
            UserDefaults.standard.set(someInt, forKey: "randomNumber")
        }
        if(!(CommonFunctions.sharedInstance.isKeyPresentInUserDefaults(key:"LaunchFirstTime"))){
        
             UserDefaults.standard.set(true, forKey: "LaunchFirstTime")
        }
        if(!(CommonFunctions.sharedInstance.isKeyPresentInUserDefaults(key:"wordPackTag"))){
            
            
            UserDefaults.standard.set(0, forKey: "wordPackTag")
        }
        if(!(CommonFunctions.sharedInstance.isKeyPresentInUserDefaults(key:"showDialouge"))){
            UserDefaults.standard.set(false, forKey: "showDialouge")
        }
        
        UserDefaults.standard.set(false, forKey: "GameStarts")
    }
    
    //MARK:- Default Data
    /*Fill Default Data in CoreData*/
    func fillDefaultData(){
        
        if((UserDefaults.standard.bool(forKey: "LaunchFirstTime"))){
            
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
            
              UserDefaults.standard.set(false, forKey: "LaunchFirstTime")
        }
    }
}

extension NSNumber {
    
    var asLocaleCurrency:String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        //formatter.locale = NSLocale.current
        return formatter.string(from: self)!
    }
}

