//
//  SoundViewController.swift
//  Brainshots
//
//  Created by Amritpal Singh on 01/12/16.
//  Copyright © 2016 Anuradha Sharma. All rights reserved.
//

import UIKit
import AVFoundation

class SoundViewController: UIViewController {

    @IBOutlet weak var insideView: UIView!
    @IBOutlet weak var pointValueSegment: UISegmentedControl!
    @IBOutlet weak var sliderMusic: UISlider!
    @IBOutlet weak var sliderFx: UISlider!
    @IBOutlet var pointValueTopConstraint: NSLayoutConstraint!
    
    var fxVolumeCheck : AVAudioPlayer?
    var count : Float = 0.5
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        /*Set Initial values for sliders*/
        setSliderValue()
        
        /*Set Slider Actions*/
        setSliderAction()
        
        /*addFxVolumeCheckPlayer*/
        addFxVolumeCheckPlayer()
        
        /*Set segment control value*/
        setSegmentValue()
  
        if DeviceType.IS_IPHONE_4_OR_LESS {
            pointValueTopConstraint.constant = 80
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*Method to set slider value*/
    func setSliderValue(){
    
        sliderMusic.value = (UserDefaults.standard.float(forKey: "musicVolume"))
        sliderFx.value = (UserDefaults.standard.float(forKey: "fxVolume"))
    }
    
    /*Set Sliders Actions*/
    func setSliderAction(){
        
        sliderMusic.addTarget(self, action: #selector(musicVolume), for: .valueChanged)
        sliderFx.addTarget(self, action: #selector(fxVolume), for: .valueChanged)
    }
    
    /*Music Slider Action*/
    func musicVolume(sender:UISlider){
        
        print(sender.value)
        self.count = sender.value
        let value : Float = sender.value
        SoundManager.sharedInstance.setMusicVolume(value: value)
    }
    
    /* Set Segment Value (POint Value)*/
    func setSegmentValue(){
        
        if(UserDefaults.standard.float(forKey: "pointsLevel")) == 25 {
            
            pointValueSegment.selectedSegmentIndex = 0
        }
        else{
            pointValueSegment.selectedSegmentIndex = 1
        }
    }
    
    /*FX Slider Action*/
    func fxVolume(sender:UISlider) {

        fxVolumeCheck?.setVolume(sender.value, fadeDuration: 0)
        let value : Float = sender.value
        SoundManager.sharedInstance.setFxVolume(value: value)
    }
    
    
    
    /*Segment Control Action */
    @IBAction func segmentControl(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            UserDefaults.standard.set(25, forKey: "pointsLevel")
            break
        case 1:
            UserDefaults.standard.set(50, forKey: "pointsLevel")
            break
        default:
            break
        }
    }
    /*Back Action*/
    @IBAction func btnBack(_ sender: AnyObject) {

        _ = self.navigationController?.popViewController(animated: true)
    }
    
    /*TouchDown Action*/
    @IBAction func backTouchDown(_ sender: Any) {
        SoundManager.sharedInstance.playButtonPressedSound()
    }
    
    @IBAction func fxSliderDragAction(_ sender: Any) {
        
        fxVolumeCheck?.pause()
        fxVolumeCheck?.currentTime = 0.0
        fxVolumeCheck?.play()
    }
    
    /*Add fx volume check sound*/
    func addFxVolumeCheckPlayer(){
        
        let url = Bundle.main.url(forResource: kGoodGuessBell, withExtension: kWav)!
    
        do {
            fxVolumeCheck = try AVAudioPlayer(contentsOf: url)
            guard let fxVolumeCheck = fxVolumeCheck else { return }
            fxVolumeCheck.setVolume(UserDefaults.standard.float(forKey: "fxVolume"), fadeDuration: 0)
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
}


