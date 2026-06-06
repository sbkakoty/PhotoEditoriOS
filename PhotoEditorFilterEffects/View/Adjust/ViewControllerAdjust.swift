//
//  ViewControllerAdjust.swift
//  PhotoEditorFilterEffects
//
//  Created by MacBook on 10/20/22.
//

import UIKit

class ViewControllerAdjust: UIViewController {
    
    var receivedImage: UIImage?
    var adjustededImage: UIImage?
    
    private var viewModelAdjust: ViewModelAdjust?
    
    private var compactConstraints: [NSLayoutConstraint] = []
    private var regularConstraints: [NSLayoutConstraint] = []
    private var sharedConstraints: [NSLayoutConstraint] = []
    
    private var selectedShade: Int?
    private var sliderInitialValue: Float = 0
    private var sliderCurrentValue: Float?
    
    private lazy var masterView: UIView = {
        let view = UINib(nibName: "MasterViewAdjust", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
        view.frame = UIScreen.main.bounds
        view.backgroundColor = UIColor(hexaRGB: getBackgroundColor())!
        view.translatesAutoresizingMaskIntoConstraints = false
        view.tag = 1
        return view
    }()
    
    private lazy var uiImageView: UIImageView = {
        let view = UIImageView()
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = receivedImage!
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private lazy var bottomActionPanel: UIScrollView = {
        let customView = UIScrollView()
        customView.isScrollEnabled = true
        customView.contentSize.width = getRelativeWidth(705.0)
        customView.contentSize.height = getRelativeHeight(85.0)
        customView.showsVerticalScrollIndicator = false
        customView.showsHorizontalScrollIndicator = false
        customView.translatesAutoresizingMaskIntoConstraints = false
        customView.backgroundColor = UIColor(hexaRGB: getMenuBackColor())!
        return customView
    }()
    
    lazy private var buttonBrightness: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "img_group685")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setButtonActiveColor(hex: getContentColor(), alpha: 0.6)
        button.tag = 2
        button.addTarget(self, action: #selector(adjustOptionPressed), for: .touchUpInside)
        return button
    }()
    
    private lazy var labelBrightness: UILabel = {
        let view = UILabel()
        view.text = NSLocalizedString("buttonLabelBrightness", comment: "")
        view.translatesAutoresizingMaskIntoConstraints = false
        //view.backgroundColor = hexStringToUIColor(hex: "#33DDFF")
        view.textColor = UIColor(hexaRGB: getContentColor(), alpha: 0.6)
        view.textAlignment = .center
        view.font = UIFont.preferredFont(forTextStyle: .body)
        view.adjustsFontForContentSizeCategory = true
        view.tag = 12
        return view
    }()
    
    lazy private var buttonContrast: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "img_group684")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setButtonActiveColor(hex: getContentColor(), alpha: 0.6)
        button.tag = 3
        button.addTarget(self, action: #selector(adjustOptionPressed), for: .touchUpInside)
        return button
    }()
    
    private lazy var labelContrast: UILabel = {
        let view = UILabel()
        view.text = NSLocalizedString("buttonLabelContrast", comment: "")
        view.translatesAutoresizingMaskIntoConstraints = false
        //view.backgroundColor = hexStringToUIColor(hex: "#33DDFF")
        view.textColor = UIColor(hexaRGB: getContentColor(), alpha: 0.6)
        view.textAlignment = .center
        view.font = UIFont.preferredFont(forTextStyle: .body)
        view.adjustsFontForContentSizeCategory = true
        view.tag = 13
        return view
    }()
    
    lazy private var buttonExposure: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "img_group687")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setButtonActiveColor(hex: getContentColor(), alpha: 0.6)
        button.tag = 4
        button.addTarget(self, action: #selector(adjustOptionPressed), for: .touchUpInside)
        return button
    }()
    
    private lazy var labelExposure: UILabel = {
        let view = UILabel()
        view.text = NSLocalizedString("buttonLabelExposure", comment: "")
        view.translatesAutoresizingMaskIntoConstraints = false
        //view.backgroundColor = hexStringToUIColor(hex: "#33DDFF")
        view.textColor = UIColor(hexaRGB: getContentColor(), alpha: 0.6)
        view.textAlignment = .center
        view.font = UIFont.preferredFont(forTextStyle: .body)
        view.adjustsFontForContentSizeCategory = true
        view.tag = 14
        return view
    }()
    
    lazy private var buttonSharpness: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "img_vector79")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setButtonActiveColor(hex: getContentColor(), alpha: 0.6)
        button.tag = 5
        button.addTarget(self, action: #selector(adjustOptionPressed), for: .touchUpInside)
        return button
    }()
    
    private lazy var labelSharpness: UILabel = {
        let view = UILabel()
        view.text = NSLocalizedString("buttonLabelSharpness", comment: "")
        view.translatesAutoresizingMaskIntoConstraints = false
        //view.backgroundColor = hexStringToUIColor(hex: "#33DDFF")
        view.textColor = UIColor(hexaRGB: getContentColor(), alpha: 0.6)
        view.textAlignment = .center
        view.font = UIFont.preferredFont(forTextStyle: .body)
        view.adjustsFontForContentSizeCategory = true
        view.tag = 15
        return view
    }()
    
    lazy private var buttonSaturation: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "img_ellipse32")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setButtonActiveColor(hex: getContentColor(), alpha: 0.6)
        button.tag = 6
        button.addTarget(self, action: #selector(adjustOptionPressed), for: .touchUpInside)
        return button
    }()
    
    private lazy var labelSaturation: UILabel = {
        let view = UILabel()
        view.text = NSLocalizedString("buttonLabelSaturation", comment: "")
        view.translatesAutoresizingMaskIntoConstraints = false
        //view.backgroundColor = hexStringToUIColor(hex: "#33DDFF")
        view.textColor = UIColor(hexaRGB: getContentColor(), alpha: 0.6)
        view.textAlignment = .center
        view.font = UIFont.preferredFont(forTextStyle: .body)
        view.adjustsFontForContentSizeCategory = true
        view.tag = 16
        return view
    }()
    
    lazy private var buttonWarm: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "img_group")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setButtonActiveColor(hex: getContentColor(), alpha: 0.6)
        button.tag = 7
        button.addTarget(self, action: #selector(adjustOptionPressed), for: .touchUpInside)
        return button
    }()
    
    private lazy var labelWarm: UILabel = {
        let view = UILabel()
        view.text = NSLocalizedString("buttonLabelWarm", comment: "")
        view.translatesAutoresizingMaskIntoConstraints = false
        //view.backgroundColor = hexStringToUIColor(hex: "#33DDFF")
        view.textColor = UIColor(hexaRGB: getContentColor(), alpha: 0.6)
        view.textAlignment = .center
        view.font = UIFont.preferredFont(forTextStyle: .body)
        view.adjustsFontForContentSizeCategory = true
        view.tag = 17
        return view
    }()
    
    lazy private var buttonFade: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "img_ellipse28")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setButtonActiveColor(hex: getContentColor(), alpha: 0.6)
        button.tag = 8
        button.addTarget(self, action: #selector(adjustOptionPressed), for: .touchUpInside)
        return button
    }()
    
    private lazy var labelFade: UILabel = {
        let view = UILabel()
        view.text = NSLocalizedString("buttonLabelFade", comment: "")
        
        view.translatesAutoresizingMaskIntoConstraints = false
        //view.backgroundColor = hexStringToUIColor(hex: "#33DDFF")
        view.textColor = UIColor(hexaRGB: getContentColor(), alpha: 0.6)
        view.textAlignment = .center
        view.font = UIFont.preferredFont(forTextStyle: .body)
        view.adjustsFontForContentSizeCategory = true
        view.tag = 18
        return view
    }()
    
    private lazy var uiSliderContainer: UIView = {
        let view = UIView(frame: UIScreen.main.bounds)
        view.isHidden = true
        view.layer.cornerRadius = 10
        view.semanticContentAttribute = .forceLeftToRight
        view.backgroundColor = UIColor(hexaRGB: getMenuBackColor())
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var buttonSliderClose: UIButton = {
        let view = UIButton(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        let uiImage = UIImage(named: "img_group97")?.withRenderingMode(.alwaysTemplate)
        view.tintColor = UIColor(hexaRGB: getContentColor())
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(buttonAdjustSliderCloseTap), for: .touchUpInside)
        view.setImage(uiImage, for: .normal)
        return view
    }()
    
    private lazy var buttonSliderOK: UIButton = {
        let view = UIButton(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        let uiImage = UIImage(named: "img_vector2")?.withRenderingMode(.alwaysTemplate)
        view.tintColor = UIColor(hexaRGB: getContentColor())
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(buttonAdjustSliderOKTap), for: .touchUpInside)
        view.setImage(uiImage, for: .normal)
        return view
    }()
    
    private lazy var labelSliderProgressPercent: UILabel = {
        let view = UILabel()
        view.text = "50%"
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = UIColor(hexaRGB: getContentColor(), alpha: 1)
        view.textAlignment = .center
        view.font = UIFont.preferredFont(forTextStyle: .body)
        view.adjustsFontForContentSizeCategory = true
        return view
    }()
    
    private lazy var uiSlider: UISlider = {
        let view = UISlider()
        view.value = 0.5
        view.minimumValue = 0
        view.maximumValue = 1
        view.semanticContentAttribute = .forceLeftToRight
        view.addTarget(self, action: #selector(uiSliderValueChange), for: .valueChanged)
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
        
        adjustededImage = receivedImage!
        setUpUIAdjust()
        
        setUpConstraintsAdjust()
        NSLayoutConstraint.activate(sharedConstraints)
        layoutTraitAdjust(traitCollection: UIScreen.main.traitCollection)
    }
    
    func setUpUIAdjust() {
        
        setNavBarAdjust()
        self.view.backgroundColor = UIColor(hexaRGB: getBackgroundColor())
        masterView.addSubview(uiImageView)
        view.addSubview(masterView)
        setUpBottomActionPanelAdjust()
        setUpBottomSliderPanelAdjust()
    }
    
    func setNavBarAdjust() {
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationItem.setHidesBackButton(true, animated: false)
        let navTitle = UILabel()
        navTitle.text = NSLocalizedString("navBarTitleAdjustVC", comment: "")
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
        leftView.addTarget(self, action: #selector(backButtonTapAdjust), for: .allTouchEvents)
        leftButton.customView = leftView
            
        let rightButton = UIBarButtonItem(title: NSLocalizedString("navBarButtonDone", comment: ""), style: .done, target: self, action: #selector(doneButtonTapAdjust))
        rightButton.tintColor = UIColor(hexaRGB: getContentColor())!
        rightButton.setTitleTextAttributes(navBarButtonTitleAttributes, for: .normal)
        
        self.navigationItem.leftBarButtonItem  = leftButton
        self.navigationItem.rightBarButtonItem  = rightButton
        
        self.navigationController?.navigationBar.semanticContentAttribute = .forceLeftToRight
    }
    
    func setUpBottomSliderPanelAdjust() {
        masterView.addSubview(uiSliderContainer)
        uiSliderContainer.addSubview(uiSlider)
        uiSliderContainer.addSubview(labelSliderProgressPercent)
        uiSliderContainer.addSubview(buttonSliderClose)
        uiSliderContainer.addSubview(buttonSliderOK)
        
        NSLayoutConstraint.activate([
            uiSliderContainer.heightAnchor.constraint(equalToConstant: 100),
            uiSliderContainer.bottomAnchor.constraint(equalTo: bottomActionPanel.topAnchor, constant: -10),
            uiSliderContainer.widthAnchor.constraint(equalTo: masterView.widthAnchor, constant: -20),
            uiSliderContainer.centerXAnchor.constraint(equalTo: masterView.centerXAnchor),
            
            buttonSliderClose.leftAnchor.constraint(equalTo: uiSliderContainer.leftAnchor, constant: 7.0),
            buttonSliderClose.topAnchor.constraint(equalTo: uiSliderContainer.topAnchor, constant: 10.0),
            buttonSliderClose.widthAnchor.constraint(equalToConstant: 25),
            buttonSliderClose.heightAnchor.constraint(equalToConstant: 25),
            
            buttonSliderOK.trailingAnchor.constraint(equalTo: uiSliderContainer.trailingAnchor, constant: -10.0),
            buttonSliderOK.topAnchor.constraint(equalTo: uiSliderContainer.topAnchor, constant: 10.0),
            buttonSliderOK.widthAnchor.constraint(equalToConstant: 25),
            buttonSliderOK.heightAnchor.constraint(equalToConstant: 25),
            
            uiSlider.topAnchor.constraint(equalTo: buttonSliderOK.bottomAnchor, constant: 20.0),
            uiSlider.widthAnchor.constraint(equalTo: uiSliderContainer.widthAnchor, constant: -110.0),
            uiSlider.leftAnchor.constraint(equalTo: buttonSliderClose.rightAnchor),
            uiSlider.heightAnchor.constraint(equalToConstant: 50),
            
            labelSliderProgressPercent.centerYAnchor.constraint(equalTo: uiSlider.centerYAnchor),
            labelSliderProgressPercent.leftAnchor.constraint(equalTo: uiSlider.rightAnchor, constant: 5),
        ])
    }
    
    func setUpBottomActionPanelAdjust() {
        
        masterView.addSubview(bottomActionPanel)
        bottomActionPanel.addSubview(buttonBrightness)
        bottomActionPanel.addSubview(labelBrightness)
        bottomActionPanel.addSubview(buttonContrast)
        bottomActionPanel.addSubview(labelContrast)
        bottomActionPanel.addSubview(buttonExposure)
        bottomActionPanel.addSubview(labelExposure)
        bottomActionPanel.addSubview(buttonSharpness)
        bottomActionPanel.addSubview(labelSharpness)
        bottomActionPanel.addSubview(buttonSaturation)
        bottomActionPanel.addSubview(labelSaturation)
        bottomActionPanel.addSubview(buttonWarm)
        bottomActionPanel.addSubview(labelWarm)
        bottomActionPanel.addSubview(buttonFade)
        bottomActionPanel.addSubview(labelFade)
        
        NSLayoutConstraint.activate([
            bottomActionPanel.bottomAnchor.constraint(equalTo: masterView.bottomAnchor),
            bottomActionPanel.widthAnchor.constraint(equalTo: masterView.widthAnchor),
            bottomActionPanel.centerXAnchor.constraint(equalTo: masterView.centerXAnchor),
            bottomActionPanel.heightAnchor.constraint(equalToConstant: getRelativeHeight(120.0)),
            
            buttonBrightness.leftAnchor.constraint(equalTo: bottomActionPanel.leftAnchor, constant: 30.0),
            buttonBrightness.topAnchor.constraint(equalTo: bottomActionPanel.topAnchor, constant: 15.0),
            buttonBrightness.widthAnchor.constraint(equalToConstant: 55),
            buttonBrightness.heightAnchor.constraint(equalToConstant: 55),
            labelBrightness.topAnchor.constraint(equalTo: buttonBrightness.bottomAnchor, constant: 5),
            labelBrightness.centerXAnchor.constraint(equalTo: buttonBrightness.centerXAnchor),
            
            buttonContrast.leftAnchor.constraint(equalTo: buttonBrightness.rightAnchor, constant: 45.0),
            buttonContrast.topAnchor.constraint(equalTo: bottomActionPanel.topAnchor, constant: 15.0),
            buttonContrast.widthAnchor.constraint(equalToConstant: 55),
            buttonContrast.heightAnchor.constraint(equalToConstant: 55),
            labelContrast.topAnchor.constraint(equalTo: buttonContrast.bottomAnchor, constant: 5),
            labelContrast.centerXAnchor.constraint(equalTo: buttonContrast.centerXAnchor),
            
            buttonExposure.leftAnchor.constraint(equalTo: buttonContrast.rightAnchor, constant: 45.0),
            buttonExposure.topAnchor.constraint(equalTo: bottomActionPanel.topAnchor, constant: 15.0),
            buttonExposure.widthAnchor.constraint(equalToConstant: 55),
            buttonExposure.heightAnchor.constraint(equalToConstant: 55),
            labelExposure.topAnchor.constraint(equalTo: buttonExposure.bottomAnchor, constant: 5),
            labelExposure.centerXAnchor.constraint(equalTo: buttonExposure.centerXAnchor),
            
            buttonSharpness.leftAnchor.constraint(equalTo: buttonExposure.rightAnchor, constant: 45.0),
            buttonSharpness.topAnchor.constraint(equalTo: bottomActionPanel.topAnchor, constant: 15.0),
            buttonSharpness.widthAnchor.constraint(equalToConstant: 55),
            buttonSharpness.heightAnchor.constraint(equalToConstant: 55),
            labelSharpness.topAnchor.constraint(equalTo: buttonSharpness.bottomAnchor, constant: 5),
            labelSharpness.centerXAnchor.constraint(equalTo: buttonSharpness.centerXAnchor),
            
            buttonSaturation.leftAnchor.constraint(equalTo: buttonSharpness.rightAnchor, constant: 55.0),
            buttonSaturation.topAnchor.constraint(equalTo: bottomActionPanel.topAnchor, constant: 15.0),
            buttonSaturation.widthAnchor.constraint(equalToConstant: 55),
            buttonSaturation.heightAnchor.constraint(equalToConstant: 55),
            labelSaturation.topAnchor.constraint(equalTo: buttonSaturation.bottomAnchor, constant: 5),
            labelSaturation.centerXAnchor.constraint(equalTo: buttonSaturation.centerXAnchor),
            
            buttonWarm.leftAnchor.constraint(equalTo: buttonSaturation.rightAnchor, constant: 45.0),
            buttonWarm.topAnchor.constraint(equalTo: bottomActionPanel.topAnchor, constant: 15.0),
            buttonWarm.widthAnchor.constraint(equalToConstant: 55),
            buttonWarm.heightAnchor.constraint(equalToConstant: 55),
            labelWarm.topAnchor.constraint(equalTo: buttonWarm.bottomAnchor, constant: 5),
            labelWarm.centerXAnchor.constraint(equalTo: buttonWarm.centerXAnchor),
            
            buttonFade.leftAnchor.constraint(equalTo: buttonWarm.rightAnchor, constant: 45.0),
            buttonFade.topAnchor.constraint(equalTo: bottomActionPanel.topAnchor, constant: 15.0),
            buttonFade.widthAnchor.constraint(equalToConstant: 55),
            buttonFade.heightAnchor.constraint(equalToConstant: 55),
            labelFade.topAnchor.constraint(equalTo: buttonFade.bottomAnchor, constant: 5),
            labelFade.centerXAnchor.constraint(equalTo: buttonFade.centerXAnchor),
        ])
    }
    
    @objc func backButtonTapAdjust(sender: Any) {
        if let viewController = navigationController?.viewControllers.first(where: {$0 is ViewControllerStyleRedactor}) {
              navigationController?.popToViewController(viewController, animated: false)
        }
    }
    
    @objc func doneButtonTapAdjust(sender: Any) {
        if let viewController = navigationController?.viewControllers.first(where: {$0 is ViewControllerStyleRedactor}) {
            
            let imageDataDict:[String: UIImage] = ["image": adjustededImage!]
            NotificationCenter.default.post(name: Notification.Name("com.adjustphoto.success"), object: nil, userInfo: imageDataDict)
              navigationController?.popToViewController(viewController, animated: false)
        }
    }
    
    func setUpConstraintsAdjust() {
        let safeArea = view.safeAreaLayoutGuide
        let scaledSize = calculateImageViewScale(viewSize: self.view.bounds.size, imageSize: receivedImage!.size, leftRightAnchorConstant: 20, topBottomAnchorConstant: 245)
        
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
    
    func layoutTraitAdjust(traitCollection:UITraitCollection) {
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
    
    @objc func adjustOptionPressed(sender: UIButton) {
        uiSliderContainer.isHidden = false
        selectedShade = sender.tag
        
        switch selectedShade {
            case 2:
            sliderCurrentValue = 0
            uiSlider.value = 0
            uiSlider.minimumValue = -0.5
            uiSlider.maximumValue = 0.5
            labelSliderProgressPercent.text = "0%"
            case 3:
            sliderCurrentValue = 1
            uiSlider.value = 1
            uiSlider.minimumValue = 0.5
            uiSlider.maximumValue = 1.5
            labelSliderProgressPercent.text = "100%"
            case 4:
            sliderCurrentValue = 0
            uiSlider.value = 0
            uiSlider.minimumValue = -2
            uiSlider.maximumValue = 2
            labelSliderProgressPercent.text = "0%"
            case 5:
            sliderCurrentValue = 0.4
            uiSlider.value = 0.4
            uiSlider.minimumValue = -1.2
            uiSlider.maximumValue = 2.0
            labelSliderProgressPercent.text = "40%"
            case 6:
            sliderCurrentValue = 1
            uiSlider.value = 1
            uiSlider.minimumValue = 0.0
            uiSlider.maximumValue = 2.0
            labelSliderProgressPercent.text = "100%"
            case 7:
            sliderCurrentValue = 157.67
            uiSlider.value = 157.67
            uiSlider.minimumValue = 145
            uiSlider.maximumValue = 172
            labelSliderProgressPercent.text = "157.67%"
            case 8:
            sliderCurrentValue = 0
            uiSlider.value = 0
            uiSlider.minimumValue = -1
            uiSlider.maximumValue = 1
            labelSliderProgressPercent.text = "0%"
            default:
            sliderCurrentValue = 0.5
            uiSlider.value = 0.5
            uiSlider.minimumValue = 0
            uiSlider.maximumValue = 1
            labelSliderProgressPercent.text = "50%"
        }
        
        uiSlider.setValue(sliderCurrentValue!, animated: false)
        
        if let foundView = view.viewWithTag(selectedShade!) as? UIButton {
            foundView.setButtonActiveColor(hex: getContentColor(), alpha: 1)
        }
        if let foundView = view.viewWithTag(Int("1\(selectedShade!)")!) as? UILabel {
            foundView.textColor = UIColor(hexaRGB: getContentColor(), alpha: 1)
        }
        
        setButtonColorAdjust(selectedButtonTag: selectedShade, selectedLabelTag: Int("1\(selectedShade!)")!)
    }
    
    @objc func uiSliderValueChange(sender: UISlider) {
        
        let percent: Float?
        sliderCurrentValue = sender.value
        
        switch selectedShade {
            case 2, 3, 4, 5, 6, 8:
            percent = sender.value*100
            case 7:
            percent = sender.value
            default:
            percent = sender.value*100
        }
        
        labelSliderProgressPercent.text = "\(Int(percent!)) %"
    }
    
    @objc func buttonAdjustSliderOKTap(sender: UIButton?) {
        
        viewModelAdjust = ViewModelAdjust()
        
        switch selectedShade {
            case 2:
            adjustededImage = viewModelAdjust?.adjustBrightness(uiImage: receivedImage!, adjustValue: sliderCurrentValue!)
            case 3:
            adjustededImage = viewModelAdjust?.adjustContrast(uiImage: receivedImage!, adjustValue: sliderCurrentValue!)
            case 4:
            adjustededImage = viewModelAdjust?.adjustExposure(uiImage: receivedImage!, adjustValue: sliderCurrentValue!)
            case 5:
            adjustededImage = viewModelAdjust?.adjustSharpness(uiImage: receivedImage!, adjustValue: sliderCurrentValue!)
            case 6:
            adjustededImage = viewModelAdjust?.adjustSaturation(uiImage: receivedImage!, adjustValue: sliderCurrentValue!)
            case 7:
            adjustededImage = viewModelAdjust?.adjustWarm(uiImage: receivedImage!, adjustValue: sliderCurrentValue!)
            case 8:
            adjustededImage = viewModelAdjust?.adjustFade(uiImage: receivedImage!, adjustValue: sliderCurrentValue!)
            default:
            break
        }
        self.uiImageView.image = adjustededImage
    }
    
    @objc func buttonAdjustSliderCloseTap(sender: UIButton?) {
        uiImageView.image = adjustededImage!
        uiSliderContainer.isHidden = true
    }
    
    func setButtonColorAdjust(selectedButtonTag: Int?, selectedLabelTag: Int?) {
        
        for i in 2...8 {
            if i != selectedButtonTag {
                if let foundView = view.viewWithTag(i) as? UIButton {
                    foundView.setButtonActiveColor(hex: getContentColor(), alpha: 0.6)
                }
            }
        }
        
        for i in 12...18 {
            if i != selectedLabelTag {
                if let foundView = view.viewWithTag(i) as? UILabel {
                    foundView.textColor = UIColor(hexaRGB: getContentColor(), alpha: 0.6)
                }
            }
        }
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
