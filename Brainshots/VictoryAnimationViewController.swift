//
//  VictoryAnimationViewController.swift
//  Brainshots
//
//  Created by Amritpal Singh on 03/03/17.
//  Copyright © 2017 Anuradha Sharma. All rights reserved.
//

import UIKit
import AVFoundation

class VictoryAnimationViewController: UIViewController {

    @IBOutlet weak var imgVictory: UIImageView!
    var strWinner = String()

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
//        let imageBoy : UIImage = UIImage.init(named: "Victory.png")!
//        imgVictory.image = imageBoy
        
        addAnimation()
        self.showAnimation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    /*Victory animation addon before the actual animation takes place*/
    func addAnimation() {
    
        var imgSinker = UIImage()
        
        var url = NSURL()
        var data = Data()
        url = Bundle.main.url(forResource: "Victory", withExtension: "gif")! as NSURL
        
        do {
            data = try Data.init(contentsOf: url as URL)
        } catch {
            print(error)
        }
        
        imgSinker = UIImage.animatedImage(withAnimatedGIFData:data)!
        imgVictory.animationImages = imgSinker.images
        imgVictory.animationDuration = imgSinker.duration
        imgVictory.animationRepeatCount = -1
        imgVictory.image = imgSinker.images?.last

    }
    
    /*Method to show victory animation*/
    func showAnimation() {
        
        imgVictory.startAnimating()
        perform(#selector(playSound), with: nil, afterDelay: 0.1)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            
            self.imgVictory.stopAnimating()
            self.imgVictory.removeFromSuperview()
            self.navigateToVictoryPage()
        }
    }
    
    /*Play Victory Music*/
    func playSound() {
    
        SoundManager.sharedInstance.playVictorySound()
    }
    
    /*Method to play Victory Music end sound*/
    func playVictoryEnd(){
    
        SoundManager.sharedInstance.playVictoryEndSound()
    }
    
    /*Navigate to Victory Page*/
    func navigateToVictoryPage(){
    
        SoundManager.sharedInstance.stopVictoryMusic()
        playVictoryEnd() // Plays Victory End Sound
        
        let controller = self.storyboard?.instantiateViewController(withIdentifier: kVictoryVC) as! VictoryViewController
        _ = self.navigationController?.pushViewController(controller, animated: false)
        
        controller.strWinner = strWinner
    }
}
