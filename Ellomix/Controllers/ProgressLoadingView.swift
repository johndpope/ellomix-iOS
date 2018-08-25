//
//  ProgressLoadingView.swift
//  National Driver Training
//
//  Created by Abelardo Torres on 7/16/18.
//  Copyright © 2018 National Driver Training. All rights reserved.
//

import UIKit

class ProgressLoadingView: UIView {

    var indicatorColor:UIColor = UIColor.brown
    var loadingViewColor: UIColor = UIColor.black
    var loadingMessage: String = "Loading..."
    var messageFrame = UIView()
    var activityIndicator = UIActivityIndicatorView()
    
    init(inview:UIView, loadingViewColor: UIColor, indicatorColor: UIColor, msg: String) {
        
        self.indicatorColor = indicatorColor
        self.loadingViewColor = loadingViewColor
        self.loadingMessage = msg
        super.init(frame: CGRect(x: inview.frame.midX - 150, y: inview.frame.midY - 25, width: 300, height: 50))
        initalizeProgressIndicator()
        
    }
    convenience init(inview: UIView) {
        
        self.init(inview: inview, loadingViewColor: UIColor.brown, indicatorColor:UIColor.black, msg: "Loading..")
    }
    convenience init(inview: UIView, messsage: String) {
        
        self.init(inview: inview, loadingViewColor: UIColor.brown, indicatorColor:UIColor.black, msg: messsage)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func initalizeProgressIndicator(){
        
        messageFrame.frame = self.bounds
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityIndicator.tintColor = indicatorColor
        activityIndicator.hidesWhenStopped = true
        activityIndicator.frame = CGRect(x: self.bounds.origin.x + 6, y: 0, width: 20, height: 50)
        print(activityIndicator.frame)
        let strLabel = UILabel(frame:CGRect(x: self.bounds.origin.x + 30, y: 0, width: self.bounds.width - (self.bounds.origin.x + 30) , height: 50))
        strLabel.text = loadingMessage
        strLabel.adjustsFontSizeToFitWidth = true
        strLabel.textColor = UIColor.white
        messageFrame.layer.cornerRadius = 15
        messageFrame.backgroundColor = loadingViewColor
        messageFrame.alpha = 0.8
        messageFrame.addSubview(activityIndicator)
        messageFrame.addSubview(strLabel)
        
    }
    
    func startAnimation() {
        //check if view is already there or not..if again started
        if !self.subviews.contains(messageFrame){
            
            activityIndicator.startAnimating()
            self.addSubview(messageFrame)
            
        }
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
