//
//  ProgressIndicatorPE.swift
//  PhotoEditorFilterEffects
//
//  Created by Sonjoy Borkakoty on 29/12/22.
//

import UIKit

class ProgressIndicatorPE: UIView {

    var indicatorColor:UIColor
    var loadingViewColor:UIColor
    var loadingMessage:String
    var messageFrame = UIView()
    var activityIndicator = UIActivityIndicatorView()

    init(inview: UIView, loadingViewColor: UIColor, indicatorColor: UIColor, msg:String){

        let contentWidth = widthForViewPE(text: NSLocalizedString("indicatorTitleBackgroundRemovalVC", comment: ""), font: UIFont.preferredFont(forTextStyle: .body), height: 40)
        self.indicatorColor = indicatorColor
        self.loadingViewColor = loadingViewColor
        self.loadingMessage = msg
        super.init(frame: CGRect(x: 0, y: 0, width: contentWidth+20, height: 65))
        initalizeCustomIndicator()
    }
    convenience init(inview:UIView) {

        self.init(inview: inview,loadingViewColor: UIColor.brown,indicatorColor:UIColor.black, msg: "Loading..")
    }
    convenience init(inview:UIView,messsage:String) {

        self.init(inview: inview,loadingViewColor: UIColor.brown,indicatorColor:UIColor.black, msg: messsage)
    }

    required init?(coder aDecoder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }
    
    func initalizeCustomIndicator(){

        messageFrame.frame = self.bounds
        activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
        activityIndicator.color = indicatorColor
        activityIndicator.hidesWhenStopped = true
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        let strLabel = UILabel(frame:CGRect(x: 0, y: 25, width: self.bounds.width , height: 40))
        strLabel.text = loadingMessage
        strLabel.font = UIFont.preferredFont(forTextStyle: .body)
        strLabel.adjustsFontSizeToFitWidth = true
        strLabel.textColor = UIColor.white
        strLabel.textAlignment = .center
        
        messageFrame.layer.cornerRadius = 7.5
        messageFrame.backgroundColor = loadingViewColor
        //messageFrame.alpha = 0.8
        messageFrame.addSubview(activityIndicator)
        messageFrame.addSubview(strLabel)
    }

    func  start(){
        //check if view is already there or not..if again started
        if !self.subviews.contains(messageFrame){

            activityIndicator.startAnimating()
            self.addSubview(messageFrame)
        }
    }

    func stop(){

        if self.subviews.contains(messageFrame){

            activityIndicator.stopAnimating()
            messageFrame.removeFromSuperview()
        }
    }
}

