//
//  HowToPlayVC.swift
//  Brainshots
//
//  Created by Amrit on 15/06/17.
//  Copyright © 2017 Anuradha Sharma. All rights reserved.
//

import UIKit
import AVFoundation

class HowToPlayVC: UIViewController,SSTTapSliderDelegate {

    //MARK:- Outlet
    @IBOutlet var slideImageView: UIImageView!
    @IBOutlet var slider: SSTTapSlider!
    @IBOutlet var sliderView: UIView!
    
    //MARK:- Variables
    var slideImage : UIImage?
    var player : AVAudioPlayer?
    var timer : Timer?
    var duration = NSInteger()
    var timeInterval = NSInteger()
    
    //MARK:- Didload
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black
        
        //Hide Slider View
        self.sliderView.isHidden = !self.sliderView.isHidden
        
        //Pause Background Music
        SoundManager.sharedInstance.pauseBackgroundSound()
        
        //Tap Gesture Instance
        let gesture =  UITapGestureRecognizer(target: self, action:#selector(tapGesture))
        slideImageView.addGestureRecognizer(gesture)
        slideImageView.isUserInteractionEnabled = true
        
        //Set Timer Initial Value
        timeInterval = -1

        //Play Method
        howToPlay()
    }
    
    //MARK:- Tap Gesture
    func tapGesture() {
    
        UIView.transition(with: sliderView, duration: 0.5, options: .transitionCrossDissolve, animations: { _ in
            self.sliderView.isHidden = !self.sliderView.isHidden
        }, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- Set Player Sound
    /*Play How To Play Sound*/
    func howToPlay() {
        
        let url = Bundle.main.url(forResource: "HowToPlay", withExtension: "wav")!
        
        do {
            
            player = try AVAudioPlayer(contentsOf: url)
            guard let player = player else { return }
            
            player.setVolume(1,fadeDuration: 0)
            duration =  NSInteger(player.duration)
            slider.minimumValue = 0
            slider.maximumValue = Float(duration - 3)
            slider.value = 0
            
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(playSlides), userInfo: nil, repeats: true)
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    //MARK:- Timer method
    /*Timer Method for playing Slides*/
    func playSlides(timer:Timer) {
    
        timeInterval = timeInterval + 1
        
        slider.value = Float(timeInterval)
        
        if(timeInterval == duration - 3) {
            
            self.btnBack("")
        }
        else {
            switchImages()
        }
    }

    //MARK:- Switch Images Timer Action
    func switchImages() {
    
        switch timeInterval {
            
        case 0:
            player?.prepareToPlay()
            player?.play()
            slideImage = UIImage.init(named: "Home.png")
            slideImageView.image = slideImage
            break
        case 4:
            slideImage = UIImage.init(named: "Play.png")
            slideImageView.image = slideImage
            animate()
            break
        case 12:
            slideImage = UIImage.init(named: "Success.png")
            slideImageView.image = slideImage
            animate()
            break
        case 17:
            slideImage = UIImage.init(named: "Fail.png")
            slideImageView.image = slideImage
            animate()
            break
        case 27:
            slideImage = UIImage.init(named: "RoundWinner2.png")
            slideImageView.image = slideImage
            animate()
            break
        case 35:
            slideImage = UIImage.init(named: "LightningRound.png")
            slideImageView.image = slideImage
            animate()
            break
        case 37:
            slideImage = UIImage.init(named: "Host_Join.png")
            slideImageView.image = slideImage
            animate()
            break
        case 41:
            slideImage = UIImage.init(named: "Pack.png")
            slideImageView.image = slideImage
            animate()
            break
        case 45:
            slideImage = UIImage.init(named: "Drinks.png")
            slideImageView.image = slideImage
            animate()
            break
        case 54:
            slideImage = UIImage.init(named: "Victory.png")
            slideImageView.image = slideImage
            animate()
            break
        default:
            break
        }
    }
    
    //MARK:- Switch Images Slider Action
    func switchImagesFromSlider() {
        
        if(timeInterval >= 0 && timeInterval < 4 ){
            slideImage = UIImage.init(named: "Home.png")
        }
        else if(timeInterval >= 4 && timeInterval < 12 ){
            slideImage = UIImage.init(named: "Play.png")
        }
        else if(timeInterval >= 12 && timeInterval < 17 ){
            slideImage = UIImage.init(named: "Success.png")
        }
        else if(timeInterval >= 17 && timeInterval < 27 ){
            slideImage = UIImage.init(named: "Fail.png")
        }
        else if(timeInterval >= 27 && timeInterval < 35 ){
            slideImage = UIImage.init(named: "RoundWinner2.png")
        }
        else if(timeInterval >= 35 && timeInterval < 37 ){
            slideImage = UIImage.init(named: "LightningRound.png")
        }
        else if(timeInterval >= 37 && timeInterval < 41 ){
            slideImage = UIImage.init(named: "Host_Join.png")
        }
        else if(timeInterval >= 41 && timeInterval < 45 ){
            slideImage = UIImage.init(named: "Pack.png")
        }
        else if(timeInterval >= 45 && timeInterval < 54 ){
            slideImage = UIImage.init(named: "Drinks.png")
        }
        else if(timeInterval >= 54 && timeInterval <= 60 ){
            slideImage = UIImage.init(named: "Victory.png")
        }
        
        slideImageView.image = slideImage
    }
    
    //MARK:- SSTTapSliderDelegate Methods
    func tapSlider(_ tapSlider: SSTTapSlider!, valueDidChange value: Float) {
        
        timeInterval = NSInteger(value)
        player?.currentTime = TimeInterval(value)
 
        if(!(timer?.isValid)!) {
            
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(playSlides), userInfo: nil, repeats: true)
        }
        if(!(player?.isPlaying)!){
            
            player?.prepareToPlay()
            player?.play()
        }
        
        switchImagesFromSlider()
    }
    
    //MARK:- Animation
    func animate() {
    
        let transition = CATransition()
        transition.duration = 1.0
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        transition.type = "cube"
        transition.subtype = kCATransitionFromRight
        transition.fillMode = kCAFillModeForwards
        slideImageView.layer.add(transition, forKey: nil)
        
    }
    
    //MARK:- Back Button Action
    @IBAction func btnBack(_ sender: Any) {
        
        if(timer?.isValid)!{
            timer?.invalidate()
        }
        
        player?.stop()
        SoundManager.sharedInstance.playBackgroundSound()
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    //MARK:- Touch Down Action
    @IBAction func btnBackTouchDown(_ sender: Any) {
        SoundManager.sharedInstance.playButtonPressedSound()
    }
    
    /*kCATransitionFade
     kCATransitionMoveIn
     kCATransitionPush
     kCATransitionReveal
     @"cameraIris"
     @"cameraIrisHollowOpen"
     @"cameraIrisHollowClose"
     @"cube"
     @"alignedCube"
     @"flip"
     @"alignedFlip"
     @"oglFlip"
     @"rotate"
     @"pageCurl"
     @"pageUnCurl"
     @"rippleEffect"
     @"suckEffect"*/
}
