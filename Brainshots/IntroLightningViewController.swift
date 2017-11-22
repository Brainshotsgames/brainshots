//
//  IntroLightningViewController.swift
//  Brainshots
//
//  Created by Amritpal Singh on 10/02/17.
//  Copyright © 2017 Anuradha Sharma. All rights reserved.
//

import UIKit
import AVFoundation

class IntroLightningViewController: UIViewController {
    
    var sound : AVAudioPlayer?
    let showAnimationImgView = UIImageView()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        combinedSound()
        addAnimation()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- Add Animation Method
    func addAnimation(){
        
        showAnimationImgView.isHidden = true
        
        var imgSinker = UIImage()
        showAnimationImgView.frame = self.view.frame
        self.view.addSubview(showAnimationImgView)
        
        var url = NSURL()
        var data = Data()
        url = Bundle.main.url(forResource: "Lightning Round_Small", withExtension: "gif")! as NSURL
        
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
            self.showAnimation()
        }
    }
    
    //MARK:- Lightning Round Animation
    func showAnimation() {
        
        self.showAnimationImgView.stopAnimating()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4){
            
            self.showAnimationImgView.isHidden = false
            self.showAnimationImgView.startAnimating()
        }
        
        /*play lightning sound*/
        lightningSound()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + showAnimationImgView.animationDuration + 1.5) {
            
            self.showCurtainsOpen()
        }
    }
    
    //MARK:- Curtains Open Animation Method
    func showCurtainsOpen(){

            appDelegate.showCurtainsOpening()
        
            self.showAnimationImgView.animationImages = nil
            self.showAnimationImgView.stopAnimating()
            self.showAnimationImgView.isHidden = true
            self.showAnimationImgView.removeFromSuperview()
        
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.navigateToLightningRound()
            }
    }

    /*Navigate To Lightning Round*/
    func navigateToLightningRound(){

        let controller = self.storyboard?.instantiateViewController(withIdentifier: kLightningRoundVC) as! LightningViewController
        self.navigationController?.pushViewController(controller, animated: false)
    }
    
    func navigateToTeamLightningRound(){
    
      /*  let controller = self.storyboard?.instantiateViewController(withIdentifier: "TeamLightningRoundViewController") as! TeamLightningRoundViewController
        self.navigationController?.pushViewController(controller, animated: false)*/
    }
    
    //MARK:- Sound Fx
    /*Play sound method*/
    func lightningSound(){
        
        sound?.prepareToPlay()
        sound?.play()
    }
    
    /*Add sound to player*/
    func combinedSound() {
        
        let url = Bundle.main.url(forResource: "LIGHTNING FX COMBINED", withExtension: "wav")!
        
        do {
            sound = try AVAudioPlayer(contentsOf: url)
            guard let sound = sound else { return }
            sound.setVolume(UserDefaults.standard.float(forKey: "fxVolume"), fadeDuration: 0)
        } catch let error {
            print(error.localizedDescription)
        }
    }
}

