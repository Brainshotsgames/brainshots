//
//  CurtainViewController.swift
//  Brainshots
//
//  Created by Amritpal Singh on 18/01/17.
//  Copyright © 2017 Anuradha Sharma. All rights reserved.
//

import UIKit
import AVFoundation

protocol hideCurtainDelegate {
    func hideCurtains()
}

class CurtainViewController: UIViewController {

    var delegate:hideCurtainDelegate?
    var curtainsSound : AVAudioPlayer? = nil
    var curtainsOpenSound : AVAudioPlayer? = nil
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        curtainShound()
        openCurtainsSound()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func closeCurtains() {
        
        let closeCurtainImgView = FLAnimatedImageView(frame: self.view.frame)
        self.view.addSubview(closeCurtainImgView)

        var url = NSURL()
        
        if(DeviceType.IS_IPHONE_6P){
        
           url = Bundle.main.url(forResource: "CurtainClose640", withExtension: "gif")! as NSURL
        }
        else{
        
            url = Bundle.main.url(forResource: "CurtainClose320", withExtension: "gif")! as NSURL
        }
        
        let data = NSData(contentsOf: url as URL)
        let animatedImage = FLAnimatedImage(animatedGIFData: data as Data!)
        animatedImage?.loopCount = 1
        closeCurtainImgView.animatedImage = animatedImage
        
        curtainsSound?.prepareToPlay()
        curtainsSound?.play()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            
            closeCurtainImgView.removeFromSuperview()
            self.openCurtains()
        }
    }
    
    func openCurtains() {
        
        let openCurtainImgView = FLAnimatedImageView(frame: self.view.frame)
        self.view.addSubview(openCurtainImgView)
        
        var url = NSURL()
        
        if(DeviceType.IS_IPHONE_6P){
            
            url = Bundle.main.url(forResource: "CurtainOpen640", withExtension: "gif")! as NSURL
        }
        else{
            
            url = Bundle.main.url(forResource: "CurtainOpen320", withExtension: "gif")! as NSURL
        }
        
        let data = NSData(contentsOf: url as URL)
        let animatedImage = FLAnimatedImage(animatedGIFData: data as Data!)
        animatedImage?.loopCount = 1
        openCurtainImgView.animatedImage = animatedImage

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            
            openCurtainImgView.removeFromSuperview()
            self.hideCurtains()
        }
    }
    
    func openCurtainsOnlyAnimation(){
    
        let openCurtainImgView = FLAnimatedImageView(frame: self.view.frame)
        self.view.addSubview(openCurtainImgView)
        
        var url = NSURL()
        
        if(DeviceType.IS_IPHONE_6P){
            
            url = Bundle.main.url(forResource: "CurtainOpen640", withExtension: "gif")! as NSURL
        }
        else{
            
            url = Bundle.main.url(forResource: "CurtainOpen320", withExtension: "gif")! as NSURL
        }
        
        let data = NSData(contentsOf: url as URL)
        let animatedImage = FLAnimatedImage(animatedGIFData: data as Data!)
        animatedImage?.loopCount = 1
        openCurtainImgView.animatedImage = animatedImage
        
        curtainsOpenSound?.prepareToPlay()
        curtainsOpenSound?.play()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            
            openCurtainImgView.removeFromSuperview()
            self.hideCurtains()
        }
    }
    
    /*Add Bottle On Counter Sound*/
    func curtainShound(){
        
        let url = Bundle.main.url(forResource: "CURTAINS CLOSE_OPEN", withExtension: "wav")!
        
        do {
            curtainsSound = try AVAudioPlayer(contentsOf: url)
            guard let curtainsSound = curtainsSound else { return }
            curtainsSound.setVolume(UserDefaults.standard.float(forKey: "fxVolume"), fadeDuration: 0)
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func openCurtainsSound(){
    
        let url = Bundle.main.url(forResource: "CURTAINS OPEN", withExtension: "wav")!
        
        do {
            curtainsOpenSound = try AVAudioPlayer(contentsOf: url)
            guard let curtainsOpenSound = curtainsOpenSound else { return }
            curtainsOpenSound.setVolume(UserDefaults.standard.float(forKey: "fxVolume"), fadeDuration: 0)
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func hideCurtains() {
        
        delegate?.hideCurtains()
    }
}
