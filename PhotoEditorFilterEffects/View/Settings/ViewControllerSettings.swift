//
//  ViewControllerSettings.swift
//  PhotoEditorFilterEffects
//
//  Created by Sonjoy Borkakoty on 21/11/22.
//

import UIKit
import WebKit

class ViewControllerSettings: UIViewController {
    
    var window: UIWindow?
    
    private var compactConstraints: [NSLayoutConstraint] = []
    private var regularConstraints: [NSLayoutConstraint] = []
    private var sharedConstraints: [NSLayoutConstraint] = []
    
    private lazy var masterView: UIView = {
        let view = UINib(nibName: "MasterViewSettings", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
        view.frame = UIScreen.main.bounds
        view.backgroundColor = UIColor(hexaRGB: getBackgroundColor())!
        view.translatesAutoresizingMaskIntoConstraints = false
        view.tag = 1
        return view
    }()
    
    private lazy var buttonRateApp: UIButton = {
        let view = UIButton(type: .system)
        view.setTitle(NSLocalizedString("buttonLabelRateApp", comment: ""), for: .normal)
        view.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title2)
        view.tintColor = UIColor(hexaRGB: getContentColor())
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(buttonRateAppPressed), for: .touchUpInside)
        let rightImage = UIImageView(frame: CGRect(x: masterView.bounds.width-27, y: 10, width: 7, height: 14))
        rightImage.image = UIImage(named: "img_arrowright")?.withRenderingMode(.alwaysTemplate)
        rightImage.tintColor = UIColor(hexaRGB: getContentColor())
        view.addSubviews(rightImage)
        return view
    }()
    
    private lazy var buttonPrivacy: UIButton = {
        let view = UIButton(type: .system)
        view.setTitle(NSLocalizedString("buttonLabelPrivacyPolicy", comment: ""), for: .normal)
        view.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title2)
        view.tintColor = UIColor(hexaRGB: getContentColor())
        view.translatesAutoresizingMaskIntoConstraints = false
        let rightImage = UIImageView(frame: CGRect(x: masterView.bounds.width-27, y: 10, width: 7, height: 14))
        rightImage.image = UIImage(named: "img_arrowright")?.withRenderingMode(.alwaysTemplate)
        rightImage.tintColor = UIColor(hexaRGB: getContentColor())
        view.addSubviews(rightImage)
        view.addTarget(self, action: #selector(buttonPrivacyPressed), for: .touchUpInside)
        return view
    }()
    
    private lazy var buttonTerms: UIButton = {
        let view = UIButton(type: .system)
        view.setTitle(NSLocalizedString("buttonLabelTermsOfUse", comment: ""), for: .normal)
        view.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title2)
        view.tintColor = UIColor(hexaRGB: getContentColor())
        view.translatesAutoresizingMaskIntoConstraints = false
        let rightImage = UIImageView(frame: CGRect(x: masterView.bounds.width-27, y: 10, width: 7, height: 14))
        rightImage.image = UIImage(named: "img_arrowright")?.withRenderingMode(.alwaysTemplate)
        rightImage.tintColor = UIColor(hexaRGB: getContentColor())
        view.addSubviews(rightImage)
        view.addTarget(self, action: #selector(buttonTermsPressed), for: .touchUpInside)
        return view
    }()
    
    /*private lazy var buttonHowItWorks: UIButton = {
        let view = UIButton(type: .system)
        view.setTitle(NSLocalizedString("buttonLabelHowItWorks", comment: ""), for: .normal)
        view.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title2)
        view.tintColor = UIColor(hexaRGB: getContentColor())
        view.translatesAutoresizingMaskIntoConstraints = false
        let rightImage = UIImageView(frame: CGRect(x: masterView.bounds.width-27, y: 10, width: 7, height: 14))
        rightImage.image = UIImage(named: "img_arrowright")?.withRenderingMode(.alwaysTemplate)
        rightImage.tintColor = UIColor(hexaRGB: getContentColor())
        view.addSubviews(rightImage)
        view.addTarget(self, action: #selector(buttonHowItWorksPressed), for: .touchUpInside)
        return view
    }()*/
    
    private lazy var labelDarkMode: UILabel = {
        let view = UILabel()
        view.text = NSLocalizedString("buttonLabelDarkMode", comment: "")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = UIColor(hexaRGB: getContentColor())
        view.textAlignment = .left
        view.font = UIFont.preferredFont(forTextStyle: .title2)
        view.adjustsFontForContentSizeCategory = false
        return view
    }()
    
    private lazy var switchDarkMode: UISwitch = {
        let view = UISwitch(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 35, height: 35)))
        view.addTarget(self, action: #selector(setDarkMode), for: .valueChanged)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setOn(true, animated: false)
        return view
    }()
    
    private lazy var viewDevider1: UIView = {
        let view = UIView()
        view.layer.backgroundColor = UIColor(hexaRGB: getContentColor(), alpha: 0.4)?.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var viewDevider2: UIView = {
        let view = UIView()
        view.layer.backgroundColor = UIColor(hexaRGB: getContentColor(), alpha: 0.4)?.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var viewDevider3: UIView = {
        let view = UIView()
        view.layer.backgroundColor = UIColor(hexaRGB: getContentColor(), alpha: 0.4)?.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var viewDevider4: UIView = {
        let view = UIView()
        view.layer.backgroundColor = UIColor(hexaRGB: getContentColor(), alpha: 0.4)?.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //handle dark mode
        if #available(iOS 13.0, *) {
            view.overrideUserInterfaceStyle = .light
        }
        
        setUpUISettings()
        
        setUpConstraintsSettings()
        NSLayoutConstraint.activate(sharedConstraints)
        layoutTraitSettings(traitCollection: UIScreen.main.traitCollection)
    }
    
    func setNavBarSettings() {
        
        self.navigationItem.setHidesBackButton(true, animated: false)
        let navTitle = UILabel()
        navTitle.text = NSLocalizedString("actionSheetSettings", comment: "")
        navTitle.font = UIFont.preferredFont(forTextStyle: .title1)
        navTitle.textColor = UIColor(hexaRGB: getContentColor())!
        navTitle.numberOfLines = 2
        navTitle.lineBreakMode = .byTruncatingTail
        navTitle.sizeToFit()
        navTitle.textAlignment = .center
        self.navigationItem.titleView = navTitle
        
        let leftButton = UIBarButtonItem()
        let leftButtonView = UIImageView(frame: CGRect(x: 0, y: 2, width: 12, height: 20))
        leftButtonView.image = UIImage(named: "img_arrowleft")?.withRenderingMode(.alwaysTemplate)
        leftButtonView.tintColor = UIColor(hexaRGB: getContentColor())!
        let leftLabel = UILabel(frame: CGRect(x: 20, y: 0, width: 90, height: 25))
        leftLabel.text = NSLocalizedString("navBarButtonBack", comment: "")
        leftLabel.textAlignment = .left
        leftLabel.font = UIFont.preferredFont(forTextStyle: .title3)
        leftLabel.minimumScaleFactor = 1
        leftLabel.textColor = UIColor(hexaRGB: getContentColor())!
        
        let leftView = UIButton(frame: CGRect(x: 0, y: 0, width: 102, height: 25))
        leftView.addSubview(leftButtonView)
        leftView.addSubview(leftLabel)
        leftView.addTarget(self, action: #selector(backButtonTapSettings), for: .allTouchEvents)
        leftButton.customView = leftView
        
        self.navigationItem.leftBarButtonItem  = leftButton
        
        self.navigationController?.navigationBar.semanticContentAttribute = .forceLeftToRight
    }
    
    func setUpUISettings() {
        
        setNavBarSettings()
        
        self.view.backgroundColor = UIColor(hexaRGB: getBackgroundColor())
        masterView.addSubviews(buttonRateApp)
        masterView.addSubviews(viewDevider1)
        masterView.addSubviews(buttonPrivacy)
        masterView.addSubviews(viewDevider2)
        masterView.addSubviews(buttonTerms)
        masterView.addSubviews(viewDevider3)
        //masterView.addSubviews(buttonHowItWorks)
        masterView.addSubviews(viewDevider4)
        masterView.addSubviews(labelDarkMode)
        masterView.addSubviews(switchDarkMode)
        self.view.addSubview(masterView)
        
        if getBackgroundColor().range(of: "#000000") != nil {
            switchDarkMode.setOn(true, animated: false)
        } else {
            switchDarkMode.setOn(false, animated: false)
        }
    }
    
    func setUpConstraintsSettings() {
        let safeArea = view.safeAreaLayoutGuide
        
        sharedConstraints.append(contentsOf: [
            masterView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            masterView.leftAnchor.constraint(equalTo: safeArea.leftAnchor),
            masterView.rightAnchor.constraint(equalTo: safeArea.rightAnchor),
            masterView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            
            buttonRateApp.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 30),
            buttonRateApp.leftAnchor.constraint(equalTo: masterView.leftAnchor, constant: 10),
            buttonRateApp.heightAnchor.constraint(equalToConstant: 35),
            
            viewDevider1.topAnchor.constraint(equalTo: buttonRateApp.bottomAnchor, constant: 10),
            viewDevider1.widthAnchor.constraint(equalToConstant: masterView.bounds.width-20),
            viewDevider1.heightAnchor.constraint(equalToConstant: 1),
            viewDevider1.centerXAnchor.constraint(equalTo: masterView.centerXAnchor),
            
            buttonPrivacy.topAnchor.constraint(equalTo: viewDevider1.bottomAnchor, constant: 30),
            buttonPrivacy.leftAnchor.constraint(equalTo: masterView.leftAnchor, constant: 10),
            buttonPrivacy.heightAnchor.constraint(equalToConstant: 35),
            
            viewDevider2.topAnchor.constraint(equalTo: buttonPrivacy.bottomAnchor, constant: 10),
            viewDevider2.widthAnchor.constraint(equalToConstant: masterView.bounds.width-20),
            viewDevider2.heightAnchor.constraint(equalToConstant: 1),
            viewDevider2.centerXAnchor.constraint(equalTo: masterView.centerXAnchor),
            
            buttonTerms.topAnchor.constraint(equalTo: viewDevider2.bottomAnchor, constant: 30),
            buttonTerms.leftAnchor.constraint(equalTo: masterView.leftAnchor, constant: 10),
            buttonTerms.heightAnchor.constraint(equalToConstant: 35),
            
            viewDevider3.topAnchor.constraint(equalTo: buttonTerms.bottomAnchor, constant: 10),
            viewDevider3.widthAnchor.constraint(equalToConstant: masterView.bounds.width-20),
            viewDevider3.heightAnchor.constraint(equalToConstant: 1),
            viewDevider3.centerXAnchor.constraint(equalTo: masterView.centerXAnchor),
            
            //buttonHowItWorks.topAnchor.constraint(equalTo: viewDevider3.bottomAnchor, constant: 30),
            //buttonHowItWorks.leftAnchor.constraint(equalTo: masterView.leftAnchor, constant: 10),
            //buttonHowItWorks.heightAnchor.constraint(equalToConstant: 35),
            
            //viewDevider4.topAnchor.constraint(equalTo: buttonHowItWorks.bottomAnchor, constant: 10),
            //viewDevider4.widthAnchor.constraint(equalToConstant: masterView.bounds.width-20),
            //viewDevider4.heightAnchor.constraint(equalToConstant: 1),
            //viewDevider4.centerXAnchor.constraint(equalTo: masterView.centerXAnchor),
            
            labelDarkMode.topAnchor.constraint(equalTo: viewDevider3.bottomAnchor, constant: 30),
            labelDarkMode.leftAnchor.constraint(equalTo: masterView.leftAnchor, constant: 10),
            labelDarkMode.heightAnchor.constraint(equalToConstant: 35),
            
            switchDarkMode.topAnchor.constraint(equalTo: viewDevider3.bottomAnchor, constant: 30),
            switchDarkMode.widthAnchor.constraint(equalToConstant: 55),
            switchDarkMode.heightAnchor.constraint(equalToConstant: 55),
            switchDarkMode.rightAnchor.constraint(equalTo: masterView.rightAnchor, constant: -10),
        ])
        
        regularConstraints.append(contentsOf: [
            masterView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            masterView.leftAnchor.constraint(equalTo: safeArea.leftAnchor),
            masterView.rightAnchor.constraint(equalTo: safeArea.rightAnchor),
            masterView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            
            buttonRateApp.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 30),
            buttonRateApp.leftAnchor.constraint(equalTo: masterView.leftAnchor, constant: 10),
            buttonRateApp.heightAnchor.constraint(equalToConstant: 35),
            
            viewDevider1.topAnchor.constraint(equalTo: buttonRateApp.bottomAnchor, constant: 10),
            viewDevider1.widthAnchor.constraint(equalToConstant: masterView.bounds.width-20),
            viewDevider1.heightAnchor.constraint(equalToConstant: 1),
            viewDevider1.centerXAnchor.constraint(equalTo: masterView.centerXAnchor),
            
            buttonPrivacy.topAnchor.constraint(equalTo: viewDevider1.bottomAnchor, constant: 30),
            buttonPrivacy.leftAnchor.constraint(equalTo: masterView.leftAnchor, constant: 10),
            buttonPrivacy.heightAnchor.constraint(equalToConstant: 35),
            
            viewDevider2.topAnchor.constraint(equalTo: buttonPrivacy.bottomAnchor, constant: 10),
            viewDevider2.widthAnchor.constraint(equalToConstant: masterView.bounds.width-20),
            viewDevider2.heightAnchor.constraint(equalToConstant: 1),
            viewDevider2.centerXAnchor.constraint(equalTo: masterView.centerXAnchor),
            
            buttonTerms.topAnchor.constraint(equalTo: viewDevider2.bottomAnchor, constant: 30),
            buttonTerms.leftAnchor.constraint(equalTo: masterView.leftAnchor, constant: 10),
            buttonTerms.heightAnchor.constraint(equalToConstant: 35),
            
            viewDevider3.topAnchor.constraint(equalTo: buttonTerms.bottomAnchor, constant: 10),
            viewDevider3.widthAnchor.constraint(equalToConstant: masterView.bounds.width-20),
            viewDevider3.heightAnchor.constraint(equalToConstant: 1),
            viewDevider3.centerXAnchor.constraint(equalTo: masterView.centerXAnchor),
            
            //buttonHowItWorks.topAnchor.constraint(equalTo: viewDevider3.bottomAnchor, constant: 30),
            //buttonHowItWorks.leftAnchor.constraint(equalTo: masterView.leftAnchor, constant: 10),
            //buttonHowItWorks.heightAnchor.constraint(equalToConstant: 35),
            
            //viewDevider4.topAnchor.constraint(equalTo: buttonHowItWorks.bottomAnchor, constant: 10),
            //viewDevider4.widthAnchor.constraint(equalToConstant: masterView.bounds.width-20),
            //viewDevider4.heightAnchor.constraint(equalToConstant: 1),
            //viewDevider4.centerXAnchor.constraint(equalTo: masterView.centerXAnchor),
            
            labelDarkMode.topAnchor.constraint(equalTo: viewDevider3.bottomAnchor, constant: 30),
            labelDarkMode.leftAnchor.constraint(equalTo: masterView.leftAnchor, constant: 10),
            labelDarkMode.heightAnchor.constraint(equalToConstant: 35),
            
            switchDarkMode.topAnchor.constraint(equalTo: viewDevider3.bottomAnchor, constant: 30),
            switchDarkMode.widthAnchor.constraint(equalToConstant: 55),
            switchDarkMode.heightAnchor.constraint(equalToConstant: 55),
            switchDarkMode.rightAnchor.constraint(equalTo: masterView.rightAnchor, constant: -10),
        ])
        
        compactConstraints.append(contentsOf: [
            masterView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            masterView.leftAnchor.constraint(equalTo: safeArea.leftAnchor),
            masterView.rightAnchor.constraint(equalTo: safeArea.rightAnchor),
            masterView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            
            buttonRateApp.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 30),
            buttonRateApp.leftAnchor.constraint(equalTo: masterView.leftAnchor, constant: 10),
            buttonRateApp.heightAnchor.constraint(equalToConstant: 35),
            
            viewDevider1.topAnchor.constraint(equalTo: buttonRateApp.bottomAnchor, constant: 10),
            viewDevider1.widthAnchor.constraint(equalToConstant: masterView.bounds.width-20),
            viewDevider1.heightAnchor.constraint(equalToConstant: 1),
            viewDevider1.centerXAnchor.constraint(equalTo: masterView.centerXAnchor),
            
            buttonPrivacy.topAnchor.constraint(equalTo: viewDevider1.bottomAnchor, constant: 30),
            buttonPrivacy.leftAnchor.constraint(equalTo: masterView.leftAnchor, constant: 10),
            buttonPrivacy.heightAnchor.constraint(equalToConstant: 35),
            
            viewDevider2.topAnchor.constraint(equalTo: buttonPrivacy.bottomAnchor, constant: 10),
            viewDevider2.widthAnchor.constraint(equalToConstant: masterView.bounds.width-20),
            viewDevider2.heightAnchor.constraint(equalToConstant: 1),
            viewDevider2.centerXAnchor.constraint(equalTo: masterView.centerXAnchor),
            
            buttonTerms.topAnchor.constraint(equalTo: viewDevider2.bottomAnchor, constant: 30),
            buttonTerms.leftAnchor.constraint(equalTo: masterView.leftAnchor, constant: 10),
            buttonTerms.heightAnchor.constraint(equalToConstant: 35),
            
            viewDevider3.topAnchor.constraint(equalTo: buttonTerms.bottomAnchor, constant: 10),
            viewDevider3.widthAnchor.constraint(equalToConstant: masterView.bounds.width-20),
            viewDevider3.heightAnchor.constraint(equalToConstant: 1),
            viewDevider3.centerXAnchor.constraint(equalTo: masterView.centerXAnchor),
            
            //buttonHowItWorks.topAnchor.constraint(equalTo: viewDevider3.bottomAnchor, constant: 30),
            //buttonHowItWorks.leftAnchor.constraint(equalTo: masterView.leftAnchor, constant: 10),
            //buttonHowItWorks.heightAnchor.constraint(equalToConstant: 35),
            
            //viewDevider4.topAnchor.constraint(equalTo: buttonHowItWorks.bottomAnchor, constant: 10),
            //viewDevider4.widthAnchor.constraint(equalToConstant: masterView.bounds.width-20),
            //viewDevider4.heightAnchor.constraint(equalToConstant: 1),
            //viewDevider4.centerXAnchor.constraint(equalTo: masterView.centerXAnchor),
            
            labelDarkMode.topAnchor.constraint(equalTo: viewDevider3.bottomAnchor, constant: 30),
            labelDarkMode.leftAnchor.constraint(equalTo: masterView.leftAnchor, constant: 10),
            labelDarkMode.heightAnchor.constraint(equalToConstant: 35),
            
            switchDarkMode.topAnchor.constraint(equalTo: viewDevider3.bottomAnchor, constant: 30),
            switchDarkMode.widthAnchor.constraint(equalToConstant: 55),
            switchDarkMode.heightAnchor.constraint(equalToConstant: 55),
            switchDarkMode.rightAnchor.constraint(equalTo: masterView.rightAnchor, constant: -10),
        ])
    }
    
    func layoutTraitSettings(traitCollection:UITraitCollection) {
        if (!sharedConstraints[0].isActive) {
           NSLayoutConstraint.activate(sharedConstraints)
        }
        if traitCollection.horizontalSizeClass == .compact && traitCollection.verticalSizeClass == .regular {
            if regularConstraints.count > 0 && regularConstraints[0].isActive {
                NSLayoutConstraint.deactivate(regularConstraints)
            }
            NSLayoutConstraint.activate(compactConstraints)
        } else {
            if compactConstraints.count > 0 && compactConstraints[0].isActive {
                NSLayoutConstraint.deactivate(compactConstraints)
            }
            NSLayoutConstraint.activate(regularConstraints)
        }
    }
    
    @objc func backButtonTapSettings(sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func buttonRateAppPressed(sender: AnyObject) {
        UIApplication.shared.open(NSURL(string: "http://www.google.com")! as URL)
    }
    
    @objc func buttonPrivacyPressed(sender: AnyObject) {
        UIApplication.shared.open(NSURL(string: "http://www.google.com")! as URL)
    }
    
    @objc func buttonTermsPressed(sender: AnyObject) {
        UIApplication.shared.open(NSURL(string: "http://www.google.com")! as URL)
    }
    
    @objc func buttonHowItWorksPressed(sender: AnyObject) {
        UIApplication.shared.open(NSURL(string: "http://www.google.com")! as URL)
    }
    
    @objc func setDarkMode(_ sender: UISwitch) {
        
        if sender.isOn {
            setBackgroundColor(themeColor: "#000000")
            setMenuBackColor(menuBackColor: "#474747")
            setContentColor(contentColor: "#C6E7FF")
        } else {
            setBackgroundColor(themeColor: "#E5E5E5")
            setMenuBackColor(menuBackColor: "#DDDDDD")
            setContentColor(contentColor: "#252525")
        }
        
        self.navigationController?.popToRootViewController(animated: true)
    }
}

