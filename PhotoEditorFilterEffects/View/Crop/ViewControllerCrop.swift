//
//  CropViewController.swift
//  PhotoEditorFilterEffects
//
//  Created by MacBook on 10/22/22.
//

import UIKit
import Mantis

class ViewControllerCrop: UIViewController, CropViewControllerDelegate {
    
    var receivedImage: UIImage?
    var croppedImage: UIImage?
    
    private var compactConstraints: [NSLayoutConstraint] = []
    private var regularConstraints: [NSLayoutConstraint] = []
    private var sharedConstraints: [NSLayoutConstraint] = []
    
    private lazy var masterView: UIView = {
        let view = UINib(nibName: "MasterViewCrop", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
        view.frame = UIScreen.main.bounds
        view.backgroundColor = UIColor(hexaRGB: getBackgroundColor())!
        view.translatesAutoresizingMaskIntoConstraints = false
        view.tag = 1
        return view
    }()
    
    private lazy var uiImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = receivedImage!
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private lazy var bottomActionPanel: UIScrollView = {
        let customView = UIScrollView()
        customView.isScrollEnabled = true
        customView.contentSize.width = 900.0
        customView.contentSize.height = 85.0
        customView.showsVerticalScrollIndicator = false
        customView.showsHorizontalScrollIndicator = false
        customView.translatesAutoresizingMaskIntoConstraints = false
        customView.backgroundColor = UIColor(hexaRGB: getMenuBackColor())!
        return customView
    }()
    
    lazy private var buttonAsShot: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "img_group26")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setButtonActiveColor(hex: getContentColor(), alpha: 0.6)
        button.tag = 2
        button.addTarget(self, action: #selector(buttonCropStyleTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var labelAsShot: UILabel = {
        let view = UILabel()
        view.text = NSLocalizedString("buttonLabelAsShot", comment: "")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 2
        view.lineBreakMode = .byWordWrapping
        view.textColor = UIColor(hexaRGB: getContentColor(), alpha: 1)
        view.textAlignment = .center
        view.font = UIFont.preferredFont(forTextStyle: .body)
        view.adjustsFontForContentSizeCategory = true
        view.tag = 12
        return view
    }()
    
    lazy private var buttonFree: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "img_group27")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setButtonActiveColor(hex: getContentColor(), alpha: 0.6)
        button.tag = 3
        button.addTarget(self, action: #selector(buttonCropStyleTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var labelFree: UILabel = {
        let view = UILabel()
        view.text = NSLocalizedString("buttonLabelFree", comment: "")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 2
        view.lineBreakMode = .byWordWrapping
        view.textColor = UIColor(hexaRGB: getContentColor(), alpha: 0.6)
        view.textAlignment = .center
        view.font = UIFont.preferredFont(forTextStyle: .body)
        view.adjustsFontForContentSizeCategory = true
        view.tag = 13
        return view
    }()
    
    lazy private var button11: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "img_rectangle47_34X42")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setButtonActiveColor(hex: getContentColor(), alpha: 0.6)
        button.tag = 4
        button.addTarget(self, action: #selector(buttonCropStyleTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var label11: UILabel = {
        let view = UILabel()
        view.text = "1:1"
        view.translatesAutoresizingMaskIntoConstraints = false
        //view.backgroundColor = hexStringToUIColor(hex: "#33DDFF")
        view.textColor = UIColor(hexaRGB: getContentColor(), alpha: 0.6)
        view.textAlignment = .center
        view.font = UIFont.preferredFont(forTextStyle: .body)
        view.adjustsFontForContentSizeCategory = true
        view.tag = 14
        return view
    }()
    
    lazy private var button45: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "img_rectangle46")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setButtonActiveColor(hex: getContentColor(), alpha: 0.6)
        button.tag = 5
        button.addTarget(self, action: #selector(buttonCropStyleTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var label45: UILabel = {
        let view = UILabel()
        view.text = "4:5"
        view.translatesAutoresizingMaskIntoConstraints = false
        //view.backgroundColor = hexStringToUIColor(hex: "#33DDFF")
        view.textColor = UIColor(hexaRGB: getContentColor(), alpha: 0.6)
        view.textAlignment = .center
        view.font = UIFont.preferredFont(forTextStyle: .body)
        view.adjustsFontForContentSizeCategory = true
        view.tag = 15
        return view
    }()
    
    lazy private var button54: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "img_rectangle47_34X42")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setButtonActiveColor(hex: getContentColor(), alpha: 0.6)
        button.tag = 6
        button.addTarget(self, action: #selector(buttonCropStyleTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var label54: UILabel = {
        let view = UILabel()
        view.text = "5:4"
        view.translatesAutoresizingMaskIntoConstraints = false
        //view.backgroundColor = hexStringToUIColor(hex: "#33DDFF")
        view.textColor = UIColor(hexaRGB: getContentColor(), alpha: 0.6)
        view.textAlignment = .center
        view.font = UIFont.preferredFont(forTextStyle: .body)
        view.adjustsFontForContentSizeCategory = true
        view.tag = 16
        return view
    }()
    
    lazy private var button34: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "img_rectangle46")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setButtonActiveColor(hex: getContentColor(), alpha: 0.6)
        button.tag = 7
        button.addTarget(self, action: #selector(buttonCropStyleTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var label34: UILabel = {
        let view = UILabel()
        view.text = "3:4"
        view.translatesAutoresizingMaskIntoConstraints = false
        //view.backgroundColor = hexStringToUIColor(hex: "#33DDFF")
        view.textColor = UIColor(hexaRGB: getContentColor(), alpha: 0.6)
        view.textAlignment = .center
        view.font = UIFont.preferredFont(forTextStyle: .body)
        view.adjustsFontForContentSizeCategory = true
        view.tag = 17
        return view
    }()
    
    lazy private var button43: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "img_rectangle47_34X42")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setButtonActiveColor(hex: getContentColor(), alpha: 0.6)
        button.tag = 8
        button.addTarget(self, action: #selector(buttonCropStyleTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var label43: UILabel = {
        let view = UILabel()
        view.text = "4:3"
        
        view.translatesAutoresizingMaskIntoConstraints = false
        //view.backgroundColor = hexStringToUIColor(hex: "#33DDFF")
        view.textColor = UIColor(hexaRGB: getContentColor(), alpha: 0.6)
        view.textAlignment = .center
        view.font = UIFont.preferredFont(forTextStyle: .body)
        view.adjustsFontForContentSizeCategory = true
        view.tag = 18
        return view
    }()
    
    lazy private var button23: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "img_rectangle46")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setButtonActiveColor(hex: getContentColor(), alpha: 0.6)
        button.tag = 9
        button.addTarget(self, action: #selector(buttonCropStyleTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var label23: UILabel = {
        let view = UILabel()
        view.text = "2:3"
        
        view.translatesAutoresizingMaskIntoConstraints = false
        //view.backgroundColor = hexStringToUIColor(hex: "#33DDFF")
        view.textColor = UIColor(hexaRGB: getContentColor(), alpha: 0.6)
        view.textAlignment = .center
        view.font = UIFont.preferredFont(forTextStyle: .body)
        view.adjustsFontForContentSizeCategory = true
        view.tag = 19
        return view
    }()
    
    lazy private var button32: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "img_rectangle47_34X42")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setButtonActiveColor(hex: getContentColor(), alpha: 0.6)
        button.tag = 10
        button.addTarget(self, action: #selector(buttonCropStyleTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var label32: UILabel = {
        let view = UILabel()
        view.text = "3:2"
        
        view.translatesAutoresizingMaskIntoConstraints = false
        //view.backgroundColor = hexStringToUIColor(hex: "#33DDFF")
        view.textColor = UIColor(hexaRGB: getContentColor(), alpha: 0.6)
        view.textAlignment = .center
        view.font = UIFont.preferredFont(forTextStyle: .body)
        view.adjustsFontForContentSizeCategory = true
        view.tag = 110
        return view
    }()
    
    lazy private var button169: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "img_rectangle48")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setButtonActiveColor(hex: getContentColor(), alpha: 0.6)
        button.tag = 11
        button.addTarget(self, action: #selector(buttonCropStyleTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var label169: UILabel = {
        let view = UILabel()
        view.text = "16:9"
        
        view.translatesAutoresizingMaskIntoConstraints = false
        //view.backgroundColor = hexStringToUIColor(hex: "#33DDFF")
        view.textColor = UIColor(hexaRGB: getContentColor(), alpha: 0.6)
        view.textAlignment = .center
        view.font = UIFont.preferredFont(forTextStyle: .body)
        view.adjustsFontForContentSizeCategory = true
        view.tag = 111
        return view
    }()
    
    lazy private var buttonFacebook: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "img_rectangle49")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setButtonActiveColor(hex: getContentColor(), alpha: 0.6)
        button.tag = 12
        button.addTarget(self, action: #selector(buttonCropStyleTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var labelFacebook: UILabel = {
        let view = UILabel()
        view.text = NSLocalizedString("buttonLabelFacebook", comment: "")
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 2
        view.lineBreakMode = .byWordWrapping
        view.textColor = UIColor(hexaRGB: getContentColor(), alpha: 0.6)
        view.textAlignment = .center
        view.font = UIFont.preferredFont(forTextStyle: .body)
        view.adjustsFontForContentSizeCategory = true
        view.tag = 112
        return view
    }()
    
    lazy private var buttoniPhone: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "img_rectangle52")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setButtonActiveColor(hex: getContentColor(), alpha: 0.6)
        button.tag = 13
        button.addTarget(self, action: #selector(buttonCropStyleTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var labeliPhone: UILabel = {
        let view = UILabel()
        view.text = NSLocalizedString("buttonLabeliPhone", comment: "")
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 2
        view.lineBreakMode = .byWordWrapping
        view.textColor = UIColor(hexaRGB: getContentColor(), alpha: 0.6)
        view.textAlignment = .center
        view.font = UIFont.preferredFont(forTextStyle: .body)
        view.adjustsFontForContentSizeCategory = true
        view.tag = 113
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //handle dark mode
        if #available(iOS 13.0, *) {
            view.overrideUserInterfaceStyle = .light
        }
        
        croppedImage = receivedImage!
        setUpUICrop()
        
        setUpConstraintsCrop()
        NSLayoutConstraint.activate(sharedConstraints)
        layoutTraitCrop(traitCollection: UIScreen.main.traitCollection)
    }
    
    func setUpUICrop() {
        
        setNavBarCrop()
        self.view.backgroundColor = UIColor(hexaRGB: getBackgroundColor())
        masterView.addSubview(uiImageView)
        view.addSubview(masterView)
        setUpBottomActionPanelCrop()
    }
    
    func setNavBarCrop() {
        self.navigationItem.setHidesBackButton(true, animated: false)
        let navTitle = UILabel()
        navTitle.text = NSLocalizedString("navBarTitleCropVC", comment: "")
        navTitle.font = UIFont.preferredFont(forTextStyle: .title1)
        navTitle.textColor = UIColor(hexaRGB: getContentColor())!
        navTitle.numberOfLines = 2
        navTitle.lineBreakMode = .byTruncatingTail
        navTitle.sizeToFit()
        navTitle.textAlignment = .center
        self.navigationItem.titleView = navTitle
        
        let navBarButtonTitleAttributes = [NSAttributedString.Key.foregroundColor: UIColor(hexaRGB: getContentColor())!,  NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .title3)]
        
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
        leftView.addTarget(self, action: #selector(backButtonTapCrop), for: .allTouchEvents)
        leftButton.customView = leftView
            
        let rightButton = UIBarButtonItem(title: NSLocalizedString("navBarButtonDone", comment: ""), style: .done, target: self, action: #selector(doneButtonTapCrop))
        rightButton.tintColor = UIColor(hexaRGB: getContentColor())!
        rightButton.setTitleTextAttributes(navBarButtonTitleAttributes, for: .normal)
        
        self.navigationItem.leftBarButtonItem  = leftButton
        self.navigationItem.rightBarButtonItem  = rightButton
        
        self.navigationController?.navigationBar.semanticContentAttribute = .forceLeftToRight
    }
    
    func setUpBottomActionPanelCrop() {
        masterView.addSubview(bottomActionPanel)
        bottomActionPanel.addSubview(buttonAsShot)
        bottomActionPanel.addSubview(labelAsShot)
        bottomActionPanel.addSubview(buttonFree)
        bottomActionPanel.addSubview(labelFree)
        bottomActionPanel.addSubview(button11)
        bottomActionPanel.addSubview(label11)
        bottomActionPanel.addSubview(button45)
        bottomActionPanel.addSubview(label45)
        bottomActionPanel.addSubview(button54)
        bottomActionPanel.addSubview(label54)
        bottomActionPanel.addSubview(button34)
        bottomActionPanel.addSubview(label34)
        bottomActionPanel.addSubview(button43)
        bottomActionPanel.addSubview(label43)
        bottomActionPanel.addSubview(button23)
        bottomActionPanel.addSubview(label23)
        bottomActionPanel.addSubview(button32)
        bottomActionPanel.addSubview(label32)
        bottomActionPanel.addSubview(button169)
        bottomActionPanel.addSubview(label169)
        bottomActionPanel.addSubview(buttonFacebook)
        bottomActionPanel.addSubview(labelFacebook)
        bottomActionPanel.addSubview(buttoniPhone)
        bottomActionPanel.addSubview(labeliPhone)
        
        NSLayoutConstraint.activate([
            
            bottomActionPanel.heightAnchor.constraint(equalToConstant: 120),
            bottomActionPanel.bottomAnchor.constraint(equalTo: masterView.bottomAnchor),
            bottomActionPanel.widthAnchor.constraint(equalTo: masterView.widthAnchor),
            bottomActionPanel.centerXAnchor.constraint(equalTo: masterView.centerXAnchor),
            
            buttonAsShot.leftAnchor.constraint(equalTo: bottomActionPanel.leftAnchor, constant: 45.0),
            buttonAsShot.topAnchor.constraint(equalTo: bottomActionPanel.topAnchor, constant: 15.0),
            buttonAsShot.heightAnchor.constraint(equalToConstant: 55),
            labelAsShot.topAnchor.constraint(equalTo: buttonAsShot.bottomAnchor, constant: 5),
            labelAsShot.centerXAnchor.constraint(equalTo: buttonAsShot.centerXAnchor),
            
            buttonFree.leftAnchor.constraint(equalTo: buttonAsShot.rightAnchor, constant: 45.0),
            buttonFree.topAnchor.constraint(equalTo: bottomActionPanel.topAnchor, constant: 15.0),
            buttonFree.heightAnchor.constraint(equalToConstant: 55),
            labelFree.topAnchor.constraint(equalTo: buttonFree.bottomAnchor, constant: 5),
            labelFree.centerXAnchor.constraint(equalTo: buttonFree.centerXAnchor),
            
            button11.leftAnchor.constraint(equalTo: buttonFree.rightAnchor, constant: 40.0),
            button11.topAnchor.constraint(equalTo: bottomActionPanel.topAnchor, constant: 15.0),
            button11.heightAnchor.constraint(equalToConstant: 55),
            label11.topAnchor.constraint(equalTo: button11.bottomAnchor, constant: 5),
            label11.centerXAnchor.constraint(equalTo: button11.centerXAnchor),
            
            button45.leftAnchor.constraint(equalTo: button11.rightAnchor, constant: 25.0),
            button45.topAnchor.constraint(equalTo: bottomActionPanel.topAnchor, constant: 15.0),
            button45.heightAnchor.constraint(equalToConstant: 55),
            label45.topAnchor.constraint(equalTo: button45.bottomAnchor, constant: 5),
            label45.centerXAnchor.constraint(equalTo: button45.centerXAnchor),
            
            button54.leftAnchor.constraint(equalTo: button45.rightAnchor, constant: 25.0),
            button54.topAnchor.constraint(equalTo: bottomActionPanel.topAnchor, constant: 15.0),
            button54.heightAnchor.constraint(equalToConstant: 55),
            label54.topAnchor.constraint(equalTo: button54.bottomAnchor, constant: 5),
            label54.centerXAnchor.constraint(equalTo: button54.centerXAnchor),
            
            button34.leftAnchor.constraint(equalTo: button54.rightAnchor, constant: 25.0),
            button34.topAnchor.constraint(equalTo: bottomActionPanel.topAnchor, constant: 15.0),
            button34.heightAnchor.constraint(equalToConstant: 55),
            label34.topAnchor.constraint(equalTo: button34.bottomAnchor, constant: 5),
            label34.centerXAnchor.constraint(equalTo: button34.centerXAnchor),
            
            button43.leftAnchor.constraint(equalTo: button34.rightAnchor, constant: 25.0),
            button43.topAnchor.constraint(equalTo: bottomActionPanel.topAnchor, constant: 15.0),
            button43.heightAnchor.constraint(equalToConstant: 55),
            label43.topAnchor.constraint(equalTo: button43.bottomAnchor, constant: 5),
            label43.centerXAnchor.constraint(equalTo: button43.centerXAnchor),
            
            button23.leftAnchor.constraint(equalTo: button43.rightAnchor, constant: 25.0),
            button23.topAnchor.constraint(equalTo: bottomActionPanel.topAnchor, constant: 15.0),
            button23.heightAnchor.constraint(equalToConstant: 55),
            label23.topAnchor.constraint(equalTo: button23.bottomAnchor, constant: 5),
            label23.centerXAnchor.constraint(equalTo: button23.centerXAnchor),
            
            button32.leftAnchor.constraint(equalTo: button23.rightAnchor, constant: 25.0),
            button32.topAnchor.constraint(equalTo: bottomActionPanel.topAnchor, constant: 15.0),
            button32.heightAnchor.constraint(equalToConstant: 55),
            label32.topAnchor.constraint(equalTo: button32.bottomAnchor, constant: 5),
            label32.centerXAnchor.constraint(equalTo: button32.centerXAnchor),
            
            button169.leftAnchor.constraint(equalTo: button32.rightAnchor, constant: 25.0),
            button169.topAnchor.constraint(equalTo: bottomActionPanel.topAnchor, constant: 15.0),
            button169.heightAnchor.constraint(equalToConstant: 55),
            label169.topAnchor.constraint(equalTo: button169.bottomAnchor, constant: 5),
            label169.centerXAnchor.constraint(equalTo: button169.centerXAnchor),
            
            buttonFacebook.leftAnchor.constraint(equalTo: button169.rightAnchor, constant: 25.0),
            buttonFacebook.topAnchor.constraint(equalTo: bottomActionPanel.topAnchor, constant: 15.0),
            buttonFacebook.heightAnchor.constraint(equalToConstant: 55),
            labelFacebook.topAnchor.constraint(equalTo: buttonFacebook.bottomAnchor, constant: 5),
            labelFacebook.centerXAnchor.constraint(equalTo: buttonFacebook.centerXAnchor),
            
            buttoniPhone.leftAnchor.constraint(equalTo: buttonFacebook.rightAnchor, constant: 25.0),
            buttoniPhone.topAnchor.constraint(equalTo: bottomActionPanel.topAnchor, constant: 15.0),
            buttoniPhone.heightAnchor.constraint(equalToConstant: 55),
            labeliPhone.topAnchor.constraint(equalTo: buttoniPhone.bottomAnchor, constant: 5),
            labeliPhone.centerXAnchor.constraint(equalTo: buttoniPhone.centerXAnchor),
        ])
    }
    
    @objc func backButtonTapCrop(sender: Any) {
        if let viewController = navigationController?.viewControllers.first(where: {$0 is ViewControllerStyleRedactor}) {
              navigationController?.popToViewController(viewController, animated: false)
        }
    }
    
    @objc func doneButtonTapCrop(sender: Any) {
        if let viewController = navigationController?.viewControllers.first(where: {$0 is ViewControllerStyleRedactor}) {
            
            //NotificationCenter.default.removeObserver(self, name: Notification.Name("com.cropphoto.success"), object: nil)
            NotificationCenter.default.removeObserver(self)
            let imageDataDict:[String: UIImage] = ["croppedImage": croppedImage!]
            NotificationCenter.default.post(name: Notification.Name("com.cropphoto.success"), object: nil, userInfo: imageDataDict)
              navigationController?.popToViewController(viewController, animated: false)
        }
    }
    
    func setUpConstraintsCrop() {
        let safeArea = view.safeAreaLayoutGuide
        let scaledSize = calculateImageViewScale(viewSize: self.view.bounds.size, imageSize: receivedImage!.size, leftRightAnchorConstant: 20, topBottomAnchorConstant: 135)
        
        sharedConstraints.append(contentsOf: [
            masterView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            masterView.leftAnchor.constraint(equalTo: safeArea.leftAnchor),
            masterView.rightAnchor.constraint(equalTo: safeArea.rightAnchor),
            masterView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            uiImageView.topAnchor.constraint(equalTo: masterView.topAnchor, constant: 5),
            uiImageView.widthAnchor.constraint(equalToConstant: masterView.bounds.width-20),
            uiImageView.centerXAnchor.constraint(equalTo: masterView.centerXAnchor),
            uiImageView.heightAnchor.constraint(equalToConstant: scaledSize.height),
        ])
        
        regularConstraints.append(contentsOf: [
            masterView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            masterView.leftAnchor.constraint(equalTo: safeArea.leftAnchor),
            masterView.rightAnchor.constraint(equalTo: safeArea.rightAnchor),
            masterView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            uiImageView.topAnchor.constraint(equalTo: masterView.topAnchor, constant: 5),
            uiImageView.widthAnchor.constraint(equalToConstant: masterView.bounds.width-20),
            uiImageView.centerXAnchor.constraint(equalTo: masterView.centerXAnchor),
            uiImageView.heightAnchor.constraint(equalToConstant: scaledSize.height),
        ])
        
        compactConstraints.append(contentsOf: [
            masterView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            masterView.leftAnchor.constraint(equalTo: safeArea.leftAnchor),
            masterView.rightAnchor.constraint(equalTo: safeArea.rightAnchor),
            masterView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            uiImageView.topAnchor.constraint(equalTo: masterView.topAnchor, constant: 5),
            uiImageView.widthAnchor.constraint(equalToConstant: masterView.bounds.width-20),
            uiImageView.centerXAnchor.constraint(equalTo: masterView.centerXAnchor),
            uiImageView.heightAnchor.constraint(equalToConstant: scaledSize.height),
        ])
    }
    
    func layoutTraitCrop(traitCollection:UITraitCollection) {
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
    
    func setButtonColorCrop(selectedButtonTag: Int?, selectedLabelTag: Int?) {
        
        for i in 2...13 {
            if i != selectedButtonTag {
                if let foundView = view.viewWithTag(i) as? UIButton {
                    foundView.setButtonActiveColor(hex: getContentColor(), alpha: 0.6)
                }
            }
        }
        
        for i in 12...113 {
            if i != selectedLabelTag {
                if let foundView = view.viewWithTag(i) as? UILabel {
                    foundView.textColor = UIColor(hexaRGB: getContentColor(), alpha: 0.6)
                }
            }
        }
    }
    
    @objc func buttonCropStyleTap(sender: UIButton) {
        
        let selectedTag = sender.tag
        var config = Mantis.Config()
        config.cropViewConfig.showRotationDial = false
        
        switch sender.tag {
        case 2:
            uiImageView.image = receivedImage!
        case 3:
            config.ratioOptions = [.custom]
            let cropViewController = Mantis.cropViewController(image: receivedImage!, config: config)
            cropViewController.modalPresentationStyle = .fullScreen
            cropViewController.delegate = self
            self.present(cropViewController, animated: true)
        case 4:
            config.ratioOptions = [.custom]
            config.addCustomRatio(byVerticalWidth: 1, andVerticalHeight: 1)
            let cropViewController = Mantis.cropViewController(image: receivedImage!, config: config)
            cropViewController.delegate = self
            self.present(cropViewController, animated: true)
        case 5:
            config.ratioOptions = [.custom]
            config.addCustomRatio(byVerticalWidth: 4, andVerticalHeight: 5)
            let cropViewController = Mantis.cropViewController(image: receivedImage!, config: config)
            cropViewController.delegate = self
            self.present(cropViewController, animated: true)
        case 6:
            config.ratioOptions = [.custom]
            config.addCustomRatio(byVerticalWidth: 5, andVerticalHeight: 4)
            let cropViewController = Mantis.cropViewController(image: receivedImage!, config: config)
            cropViewController.delegate = self
            self.present(cropViewController, animated: true)
        case 7:
            config.ratioOptions = [.custom]
            config.addCustomRatio(byVerticalWidth: 4, andVerticalHeight: 3)
            let cropViewController = Mantis.cropViewController(image: receivedImage!, config: config)
            cropViewController.delegate = self
            self.present(cropViewController, animated: true)
        case 8:
            config.ratioOptions = [.custom]
            config.addCustomRatio(byVerticalWidth: 3, andVerticalHeight: 4)
            let cropViewController = Mantis.cropViewController(image: receivedImage!, config: config)
            cropViewController.delegate = self
            self.present(cropViewController, animated: true)
        case 9:
            config.ratioOptions = [.custom]
            config.addCustomRatio(byVerticalWidth: 3, andVerticalHeight: 2)
            let cropViewController = Mantis.cropViewController(image: receivedImage!, config: config)
            cropViewController.delegate = self
            self.present(cropViewController, animated: true)
        case 10:
            config.ratioOptions = [.custom]
            config.addCustomRatio(byVerticalWidth: 2, andVerticalHeight: 3)
            let cropViewController = Mantis.cropViewController(image: receivedImage!, config: config)
            cropViewController.delegate = self
            self.present(cropViewController, animated: true)
        case 11:
            config.ratioOptions = [.custom]
            config.addCustomRatio(byVerticalWidth: 9, andVerticalHeight: 16)
            let cropViewController = Mantis.cropViewController(image: receivedImage!, config: config)
            cropViewController.delegate = self
            self.present(cropViewController, animated: true)
        case 12:
            config.ratioOptions = [.custom]
            config.addCustomRatio(byVerticalWidth: 9, andVerticalHeight: 16)
            let cropViewController = Mantis.cropViewController(image: receivedImage!, config: config)
            cropViewController.delegate = self
            self.present(cropViewController, animated: true)
        case 13:
            config.ratioOptions = [.custom]
            config.addCustomRatio(byVerticalWidth: 4, andVerticalHeight: 3)
            let cropViewController = Mantis.cropViewController(image: receivedImage!, config: config)
            cropViewController.delegate = self
            self.present(cropViewController, animated: true)
        default:
            break
        }
        
        if let foundView = view.viewWithTag(selectedTag) as? UIButton {
            foundView.setButtonActiveColor(hex: getContentColor(), alpha: 1)
        }
        if let foundView = view.viewWithTag(Int("1\(selectedTag)")!) as? UILabel {
            foundView.textColor = UIColor(hexaRGB: getContentColor(), alpha: 1)
        }
        
        setButtonColorCrop(selectedButtonTag: selectedTag, selectedLabelTag: Int("1\(selectedTag)")!)
    }
    
    func cropViewControllerDidCrop(_ cropViewController: CropViewController,
                                   cropped: UIImage,
                                   transformation: Transformation,
                                   cropInfo: CropInfo) {
        uiImageView.image = cropped
        croppedImage = cropped
        dismiss(animated: true)
    }
    
    func cropViewControllerDidCancel(_ cropViewController: CropViewController, original: UIImage) {
        dismiss(animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
