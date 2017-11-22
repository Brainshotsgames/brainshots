//
//  InAppPurchaseVC.swift
//  Brainshots
//
//  Created by Amrit on 07/09/17.
//  Copyright © 2017 Anuradha Sharma. All rights reserved.
//

import UIKit
import MBProgressHUD
import StoreKit

class InAppPurchaseVC: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    let frontImages = ["free_word_pack","boy_with_love","boy_rock_roll","boy_with_earth","hip_hop_boy","boy_with_piano","boy_word_stew"]
    let backImages = ["FreeWordsDVD","loveDVD","rockandrollDVD","earthandspaceDVD","hiphopDVD","countrywesternDVD","wordstewDVD"]
    
    let wordPackMessage = ["Love","Rock & Roll","Earth & Space","Hip Hop","Country & Western","Word Stew"]
    
    @IBOutlet var collectionView: UICollectionView!
    
    // @IBOutlet var lblHeading: UILabel!
    var pushFromSelectPlay = Bool()
    
    var OriginalFrames = CGRect()
    var index_view = NSInteger()
    var blurEffectView = UIVisualEffectView()
    
    let animatedView = UIView()
    let frontView = UIImageView()
    let backView = UIImageView()
    
    //@IBOutlet var headingHeight: NSLayoutConstraint!
    //MARK:- Buttons
    let backButton = UIButton()
    var purchaseButton = UIButton()
    var is_pack_purchased = Bool()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        /*inApp Purchase Notification*/
        NotificationCenter.default.addObserver(self, selector: #selector(handlePurchaseNotification), name: NSNotification.Name(rawValue: IAPHelper.IAPHelperPurchaseNotification), object: nil)
        
        index_view = -1
        addBlurEffect()
        
        view.addSubview(animatedView)
        
        animatedView.backgroundColor = UIColor.clear
        animatedView.frame = view.frame
        
        frontView.frame = animatedView.frame
        backView.frame = animatedView.frame
        
        frontView.autoresizingMask = [.flexibleWidth, .flexibleHeight,.flexibleTopMargin, .flexibleLeftMargin, .flexibleRightMargin, .flexibleBottomMargin]
        backView.autoresizingMask = [.flexibleWidth, .flexibleHeight,.flexibleTopMargin, .flexibleLeftMargin, .flexibleRightMargin, .flexibleBottomMargin]
        
        frontView.contentMode = .scaleAspectFit
        backView.contentMode = .scaleAspectFit
        
        animatedView.addSubview(frontView)
        animatedView.addSubview(backView)
        addBackButton()
        
        animatedView.isHidden = true
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK:-Add Blur Effect
    func addBlurEffect() {
        
        let effect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        blurEffectView = UIVisualEffectView(effect: effect)
        blurEffectView.frame = self.view.frame
        view.addSubview(blurEffectView)
        blurEffectView.alpha = 0
    }
    
    //MARK:- Add Back & Purchase Button
    func addBackButton() {
        
        backView.addSubview(backButton)
        backView.addSubview(purchaseButton)
        
        backView.isUserInteractionEnabled = true
        
        (backButton.frame,purchaseButton.frame) = getBackButtonFrame()
        backButton.addTarget(self, action: #selector(backButtonAction), for: .touchUpInside)
        backButton.setBackgroundImage(UIImage.init(named: "arrow_left_normal"), for: .normal)
        backButton.setBackgroundImage(UIImage.init(named: "arrow_left_hover"), for: .highlighted)
    }
    
    func getBackButtonFrame() ->(CGRect,CGRect) {
        
        let (x1,x2) = setXForButtons()
        
        var backButtonframe = CGRect()
        backButtonframe = CGRect.init(x:x1, y: self.view.frame.size.height - 100, width: 45, height: 45)
        
        var purchaseButtonframe = CGRect()
        purchaseButtonframe = CGRect.init(x:self.view.frame.size.width-x2, y: self.view.frame.size.height - 97, width: 149, height: 39)
        
        return (backButtonframe,purchaseButtonframe)
    }
    
    func setXForButtons()-> (CGFloat,CGFloat) {
        
        var x1 = CGFloat()
        var x2 = CGFloat()
        
        if DeviceType.IS_IPHONE_4_OR_LESS {
            
            x1 = 50
            x2 = 200
        }
        else if DeviceType.IS_IPHONE_5 {
            
            x1 = 55
            x2 = 200
        }
        else if DeviceType.IS_IPHONE_6 {
            
            x1 = 70
            x2 = 230
        }
            
        else if DeviceType.IS_IPHONE_6P {
            
            x1 = 80
            x2 = 240
        }
        
        return (x1,x2)
    }
    
    //MARK:- Collection View Delegates
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return frontImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell : InAppCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! InAppCell
        cell.img.image = UIImage.init(named:frontImages[indexPath.row])
        
        if(index_view == indexPath.row) {
            
            cell.img.isHidden = true
        }
        else{
            
            cell.img.isHidden = false
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        index_view = indexPath.row
        
        let cell : InAppCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! InAppCell
        
        let attributes : UICollectionViewLayoutAttributes = collectionView.layoutAttributesForItem(at: indexPath)!
        let cellRect : CGRect = attributes.frame
        let cellFrameInSuperview = collectionView.convert(cellRect, to: self.view)
        
        collectionView.reloadData()
        
        OriginalFrames = CGRect.init(x: cellFrameInSuperview.origin.x + cell.img.frame.origin.x + 10.5, y: cellFrameInSuperview.origin.y + cell.img.frame.origin.y - 1.5, width: cell.img.frame.size.width, height: cell.img.frame.size.height)
        
        if( indexPath.row == 0) {
            is_pack_purchased = true
        }
        else {
            is_pack_purchased = UserDefaults.standard.bool(forKey: wordPackProducts[indexPath.row-1])
        }
        
        purchaseButton(isPurchased:is_pack_purchased,tagValue:indexPath.row)
        
        animateView(tag: indexPath.row,frames: OriginalFrames)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = Int((collectionView.frame.size.width/2)-10)
        var height = Int()
        height = Int((collectionView.frame.height/3) - 10)
        
        let size = CGSize.init(width:width , height: height)
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionElementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath)
            return header
            
        } else {
            print("footer")
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "footer", for: indexPath)
            return footer
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        var size = CGSize()
        
        if(pushFromSelectPlay){
            
            size.height = 50
            size.width = collectionView.frame.size.width
        }
        else{
            
            size.height = 0
            size.width = collectionView.frame.size.width
        }
        
        return size
    }
    
    
    //MARK:- Animate Pack
    func animateView(tag:NSInteger,frames:CGRect) {
        
        SoundManager.sharedInstance.playGrownFlip()
        
        backView.isHidden = true
        
        animatedView.frame = frames
        animatedView.isHidden = false
        
        frontView.image = UIImage.init(named:frontImages[tag])
        backView.image = UIImage.init(named:backImages[tag])
        
        view.bringSubview(toFront: blurEffectView)
        view.bringSubview(toFront: animatedView)
        
        UIView.transition(with: self.view, duration:0.6, options: .allowAnimatedContent, animations: {
            
            self.animatedView.frame = self.view.frame
            self.blurEffectView.alpha = 0.6
            
        }) { (Bool) in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                
                self.backView.isHidden = false
                
                UIView.transition(from:self.frontView,
                                  to:self.backView ,
                                  duration: 0.5,
                                  options: [.transitionFlipFromLeft,.showHideTransitionViews] ,
                                  completion:{(true) in })
            }
        }
    }
    
    //MARK:- Purchase Check & Target Setting Method
    func purchaseButton(isPurchased:Bool,tagValue:NSInteger) {
        
        purchaseButton.tag = tagValue
        
        if(isPurchased) {
            
            purchaseButton.removeTarget(self, action: #selector(purchaseButtonAction), for: .touchUpInside)
            purchaseButton.addTarget(self, action: #selector(playButtonAction), for: .touchUpInside)
            purchaseButton.setBackgroundImage(UIImage.init(named: "play_normal"), for: .normal)
            purchaseButton.setBackgroundImage(UIImage.init(named: "play_hover"), for: .highlighted)
        }
        else {
            
            purchaseButton.removeTarget(self, action:  #selector(playButtonAction), for: .touchUpInside)
            purchaseButton.addTarget(self, action: #selector(purchaseButtonAction), for: .touchUpInside)
            purchaseButton.setBackgroundImage(UIImage.init(named: "purchase_normal"), for: .normal)
            purchaseButton.setBackgroundImage(UIImage.init(named: "purchase_hover"), for: .highlighted)
        }
    }
    
    
    //MARK:- Play Button Action
    func playButtonAction() {
        
        switch purchaseButton.tag {
            
        case kRegularPack:
            UserDefaults.standard.set(kRegularPack, forKey: "wordPackTag")
            break
        case kLovePack:
            UserDefaults.standard.set(kLovePack, forKey: "wordPackTag")
            break
        case kRock_Roll:
            UserDefaults.standard.set(kRock_Roll, forKey: "wordPackTag")
            break
        case kEarth_Space:
            UserDefaults.standard.set(kEarth_Space, forKey: "wordPackTag")
            break
        case kHipHop:
            UserDefaults.standard.set(kHipHop, forKey: "wordPackTag")
            break
        case kCountry_Western:
            UserDefaults.standard.set(kCountry_Western, forKey: "wordPackTag")
            break
        case kWordStew:
            UserDefaults.standard.set(kWordStew, forKey: "wordPackTag")
            break
        default:
            break
        }
        
        flipBack()
        
        print(CommonFunctions.sharedInstance.randomWordArray)
        print(CommonFunctions.sharedInstance.randomLightningRoundWord)
        
        self.perform(#selector(navigateToPlay), with: nil, afterDelay: 1.5)
    }
    
    //MARK:- Navigate to Individual Play
    func navigateToPlay() {
        
        /*Set Random Word from wordPack*/
        CommonFunctions.sharedInstance.setRandomWordArray()
        CommonFunctions.sharedInstance.setRandomLightningArray()
        
        let storyBoard = UIStoryboard.init(name: "Home", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier:kIndividualPlayVC) as! IndividualPlayViewController
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK:- Purchase Action
    func purchaseButtonAction(){
        
        print(purchaseButton.tag)
        
        if (appDelegate.products.count > 0) {
            for product in appDelegate.products {
                if (product.productIdentifier == wordPackProducts[purchaseButton.tag-1]) {
                    self.purchaseWordPAck(product, message: wordPackMessage[purchaseButton.tag])
                    break
                }
            }
        } else {
            self.alert(title: "", message: "Unable to connect, Please try again later.")
            appDelegate.reload()
        }
    }
    
    func purchaseWordPAck(_ product: SKProduct, message: String) {
        
        let alert = UIAlertController(title: "", message: "Do you want to purchase \(message) word pack?", preferredStyle: UIAlertControllerStyle.alert )
        let purchseAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: {Void in
            
            //Activity indicator
            MBProgressHUD.showAdded(to: self.view, animated: true)
            RageProducts.store.buyProduct(product)
        })
        let action = UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: {Void in})
        alert.addAction(purchseAction)
        alert.addAction(action)
        self.navigationController!.present(alert, animated: true, completion:nil)
    }
    
    //MARK:- Back Button (Animated View) Action
    func backButtonAction(sender:UIButton){
        
        flipBack()
    }
    
    func flipBack() {
        
        SoundManager.sharedInstance.playFlipBack()
        
        frontView.isHidden = false
        
        UIView.transition(from:self.backView,
                          to: self.frontView,
                          duration: 0.5,
                          options: [.transitionFlipFromRight,.showHideTransitionViews] ,
                          completion:{(true) in
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                UIView.transition(with: self.view, duration:0.5, options: .allowAnimatedContent, animations: {
                                    
                                    self.animatedView.frame = self.OriginalFrames
                                    self.blurEffectView.alpha = 0
                                    
                                }) { (Bool) in
                                    
                                    self.animatedView.isHidden = true
                                    self.index_view = -1
                                    self.collectionView.reloadData()
                                }
                            }
        })
    }
    
    //MARK:- BackButton
    @IBAction func restoreButtonAction(_ sender: AnyObject) {
        
        if Reachability.isConnectedToNetwork() {
            if (appDelegate.products.count > 0) {
                MBProgressHUD.showAdded(to: self.view, animated: true)
                RageProducts.store.restorePurchases()
            } else {
                let alert = UIAlertController(title: title, message: "Unable to connect, Please try again later.", preferredStyle: UIAlertControllerStyle.alert )
                let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {Void in})
                alert.addAction(action)
                self.navigationController!.present(alert, animated: true, completion:nil)
                appDelegate.reload()
            }
        } else {
            
            let alert = UIAlertController(title: title, message: "Please check Internet Connection", preferredStyle: UIAlertControllerStyle.alert )
            let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {Void in})
            alert.addAction(action)
            self.navigationController!.present(alert, animated: true, completion:nil)
        }
    }
    
    
    //MARK:- InAppPurchase Handler
    /*Notification handler*/
    func handlePurchaseNotification(_ notification: Notification) {
        
        MBProgressHUD.hide(for: self.view, animated: true)
        
        guard let dict = notification.object as? [String:String] else { return }
        
        print(dict)
        
        let status = dict["status"]!
        
        if(status == "fail") {
            
            let message = dict["message"]!
            self.alert(title: "Transaction failed!", message: message)
        }
            
        else if (status == "success"){
            
            let productID = dict["message"]!
            
            for (_, product) in appDelegate.products.enumerated() {
                
                guard product.productIdentifier == productID else { continue }
                UserDefaults.standard.synchronize()
                
                let index = wordPackProducts.index(of:product.productIdentifier)
                purchaseButton(isPurchased: true, tagValue: index!)
                
                do {
                    let receiptURL = Bundle.main.appStoreReceiptURL
                    let data = try Data.init(contentsOf: receiptURL!)
                    let str = String.init(data: data, encoding: .utf8)!
                    print(str)
                    
                    let alert = UIAlertController(title: "", message: str, preferredStyle: UIAlertControllerStyle.alert )
                    let action = UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: {Void in})
                    alert.addAction(action)
                    self.navigationController!.present(alert, animated: true, completion:nil)
                    
                } catch { print("Error") }
            }
        }
        else if (status == "restorationCancel"){
            
            print("Cancel")
        }
    }
    
    //MARK:- BackButton
    @IBAction func btnBack(_ sender: UIButton) {
        
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    /*TouchDown Action*/
    @IBAction func touchDown(_ sender: Any) {
        SoundManager.sharedInstance.playButtonPressedSound()
    }
}
