//
//  LegalVC.swift
//  Brainshots
//
//  Created by Amrit on 03/08/17.
//  Copyright © 2017 Anuradha Sharma. All rights reserved.
//

import UIKit

class LegalVC: UIViewController,UIWebViewDelegate {
    
    @IBOutlet weak var webView: UIWebView!
    var html : String? = nil
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        activityIndicator.color = .white
        activityIndicator.hidesWhenStopped = true
        webView.backgroundColor = UIColor.clear
        webView.isOpaque = false
        webView.delegate = self
        webView.loadHTMLString(html!, baseURL: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK:- Actions
    @IBAction func btnBack(_ sender: AnyObject) {
        
        _ = self.navigationController?.popViewController(animated: true)
    }
    @IBAction func btnBackTouchDown(_ sender: Any) {
        SoundManager.sharedInstance.playButtonPressedSound()
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        if(request.url?.absoluteString.contains("terms"))! {
            
            let htmlFile = Bundle.main.path(forResource: "terms-and-conditions", ofType: "html")
            let html = try? String(contentsOfFile: htmlFile!, encoding: String.Encoding.utf8)
            webView.loadHTMLString(html!, baseURL: nil)
            return false
            
        } else if(request.url?.absoluteString.contains("privacy"))! {
        
        
            let htmlFile = Bundle.main.path(forResource: "privacy-policy", ofType: "html")
            let html = try? String(contentsOfFile: htmlFile!, encoding: String.Encoding.utf8)
            webView.loadHTMLString(html!, baseURL: nil)
        }
        
        return true
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        activityIndicator.startAnimating()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        activityIndicator.stopAnimating()
    }
}

