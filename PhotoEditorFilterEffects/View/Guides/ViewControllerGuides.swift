//
//  ViewControllerGuides.swift
//  PhotoEditorFilterEffects
//
//  Created by Sonjoy Borkakoty on 15/11/22.
//

import UIKit
import WebKit

class ViewControllerGuides: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //handle dark mode
        if #available(iOS 13.0, *) {
            view.overrideUserInterfaceStyle = .light
        }
        
        self.title = NSLocalizedString("actionSheetGuides", comment: "")
        
        let masterView = UINib(nibName: "MasterViewGuides", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
        masterView.backgroundColor = UIColor(hexaRGB: getBackgroundColor())!
        masterView.translatesAutoresizingMaskIntoConstraints = false
        
        let webView: WKWebView = WKWebView(frame: CGRect(x: 0, y: 0,   width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        webView.load(URLRequest(url: URL(string: "https://www.google.com/")!))
        masterView.addSubview(webView)
        view.addSubviews(masterView)
    }
}
