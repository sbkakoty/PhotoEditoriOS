//
//  ViewControllerBorders.swift
//  PhotoEditorFilterEffects
//
//  Created by Sonjoy Borkakoty on 07/11/22.
//

import UIKit
import Combine

class ViewControllerBorders: UIViewController {
    
    var cancellable: AnyCancellable?
    var receivedImage: UIImage?
    var bordersImage: UIImage?
    
    private var viewModelAdjust: ViewModelAdjust?
    
    private var compactConstraints: [NSLayoutConstraint] = []
    private var regularConstraints: [NSLayoutConstraint] = []
    private var sharedConstraints: [NSLayoutConstraint] = []
    
    private var selectedShade: Int?
    private var sliderInitialValue: Float = 0
    private var sliderCurrentValue: CGFloat = 0.5
    private var selectedOverlayImageName: String = "img_rectangle176"
    
    private var opacityOption: Int = 31
    private var pickedColor: UIColor = UIColor.white
    private var pickedColorRed: CGFloat = 0
    private var pickedColorGreen: CGFloat = 0
    private var pickedColorBlue: CGFloat = 0
    private var borderColorOpacity: CGFloat = 0.5
    private var borderOpacity: CGFloat = 0.5
    
    private lazy var masterView: UIView = {
        let view = UINib(nibName: "MasterViewBorder", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
        view.frame = UIScreen.main.bounds
        view.backgroundColor = UIColor(hexaRGB: getBackgroundColor())!
        view.translatesAutoresizingMaskIntoConstraints = false
        view.tag = 1
        return view
    }()
    
    private lazy var uiImageView: UIImageView = {
        let uiImageView = UIImageView()
        uiImageView.translatesAutoresizingMaskIntoConstraints = false
        uiImageView.image = receivedImage!
        uiImageView.contentMode = .scaleAspectFit
        return uiImageView
    }()
    
    private lazy var bottomActionPanel: UIScrollView = {
        let customView = UIScrollView()
        customView.isScrollEnabled = true
        customView.contentSize.width = getRelativeWidth(1030.0)
        customView.contentSize.height = getRelativeHeight(85.0)
        customView.showsVerticalScrollIndicator = false
        customView.showsHorizontalScrollIndicator = false
        customView.translatesAutoresizingMaskIntoConstraints = false
        customView.backgroundColor = UIColor(hexaRGB: getMenuBackColor())!
        return customView
    }()
    
    lazy private var buttonBorder1: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "img_rectangle176")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setButtonActiveColor(hex: getContentColor(), alpha: 0.6)
        button.tag = 2
        button.addTarget(self, action: #selector(buttonBordersOptionTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var labelBorder1: UILabel = {
        let view = UILabel()
        view.text = "\(NSLocalizedString("buttonLabelBorder", comment: "")) 1"
        view.translatesAutoresizingMaskIntoConstraints = false
        //view.backgroundColor = hexStringToUIColor(hex: "#33DDFF")
        view.textColor = UIColor(hexaRGB: getContentColor(), alpha: 0.6)
        view.textAlignment = .center
        view.font = UIFont.preferredFont(forTextStyle: .body)
        view.adjustsFontForContentSizeCategory = true
        view.tag = 12
        return view
    }()
    
    lazy private var buttonBorder2: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "img_rectangle177")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setButtonActiveColor(hex: getContentColor(), alpha: 0.6)
        button.tag = 3
        button.addTarget(self, action: #selector(buttonBordersOptionTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var labelBorder2: UILabel = {
        let view = UILabel()
        view.text = "\(NSLocalizedString("buttonLabelBorder", comment: "")) 2"
        view.translatesAutoresizingMaskIntoConstraints = false
        //view.backgroundColor = hexStringToUIColor(hex: "#33DDFF")
        view.textColor = UIColor(hexaRGB: getContentColor(), alpha: 0.6)
        view.textAlignment = .center
        view.font = UIFont.preferredFont(forTextStyle: .body)
        view.adjustsFontForContentSizeCategory = true
        view.tag = 13
        return view
    }()
    
    lazy private var buttonBorder3: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "img_rectangle178")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setButtonActiveColor(hex: getContentColor(), alpha: 0.6)
        button.tag = 4
        button.addTarget(self, action: #selector(buttonBordersOptionTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var labelBorder3: UILabel = {
        let view = UILabel()
        view.text = "\(NSLocalizedString("buttonLabelBorder", comment: "")) 3"
        view.translatesAutoresizingMaskIntoConstraints = false
        //view.backgroundColor = hexStringToUIColor(hex: "#33DDFF")
        view.textColor = UIColor(hexaRGB: getContentColor(), alpha: 0.6)
        view.textAlignment = .center
        view.font = UIFont.preferredFont(forTextStyle: .body)
        view.adjustsFontForContentSizeCategory = true
        view.tag = 14
        return view
    }()
    
    lazy private var buttonBorder4: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "img_rectangle179")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setButtonActiveColor(hex: getContentColor(), alpha: 0.6)
        button.tag = 5
        button.addTarget(self, action: #selector(buttonBordersOptionTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var labelBorder4: UILabel = {
        let view = UILabel()
        view.text = "\(NSLocalizedString("buttonLabelBorder", comment: "")) 4"
        view.translatesAutoresizingMaskIntoConstraints = false
        //view.backgroundColor = hexStringToUIColor(hex: "#33DDFF")
        view.textColor = UIColor(hexaRGB: getContentColor(), alpha: 0.6)
        view.textAlignment = .center
        view.font = UIFont.preferredFont(forTextStyle: .body)
        view.adjustsFontForContentSizeCategory = true
        view.tag = 15
        return view
    }()
    
    lazy private var buttonBorder5: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "img_rectangle179_23")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setButtonActiveColor(hex: getContentColor(), alpha: 0.6)
        button.tag = 6
        button.addTarget(self, action: #selector(buttonBordersOptionTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var labelBorder5: UILabel = {
        let view = UILabel()
        view.text = "\(NSLocalizedString("buttonLabelBorder", comment: "")) 5"
        view.translatesAutoresizingMaskIntoConstraints = false
        //view.backgroundColor = hexStringToUIColor(hex: "#33DDFF")
        view.textColor = UIColor(hexaRGB: getContentColor(), alpha: 0.6)
        view.textAlignment = .center
        view.font = UIFont.preferredFont(forTextStyle: .body)
        view.adjustsFontForContentSizeCategory = true
        view.tag = 16
        return view
    }()
    
    lazy private var buttonBorder6: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "img_rectangle179_24")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setButtonActiveColor(hex: getContentColor(), alpha: 0.6)
        button.tag = 7
        button.addTarget(self, action: #selector(buttonBordersOptionTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var labelBorder6: UILabel = {
        let view = UILabel()
        view.text = "\(NSLocalizedString("buttonLabelBorder", comment: "")) 6"
        view.translatesAutoresizingMaskIntoConstraints = false
        //view.backgroundColor = hexStringToUIColor(hex: "#33DDFF")
        view.textColor = UIColor(hexaRGB: getContentColor(), alpha: 0.6)
        view.textAlignment = .center
        view.font = UIFont.preferredFont(forTextStyle: .body)
        view.adjustsFontForContentSizeCategory = true
        view.tag = 17
        return view
    }()
    
    lazy private var buttonBorder7: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "img_rectangle179_25")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setButtonActiveColor(hex: getContentColor(), alpha: 0.6)
        button.tag = 8
        button.addTarget(self, action: #selector(buttonBordersOptionTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var labelBorder7: UILabel = {
        let view = UILabel()
        view.text = "\(NSLocalizedString("buttonLabelBorder", comment: "")) 7"
        view.translatesAutoresizingMaskIntoConstraints = false
        //view.backgroundColor = hexStringToUIColor(hex: "#33DDFF")
        view.textColor = UIColor(hexaRGB: getContentColor(), alpha: 0.6)
        view.textAlignment = .center
        view.font = UIFont.preferredFont(forTextStyle: .body)
        view.adjustsFontForContentSizeCategory = true
        view.tag = 18
        return view
    }()
    
    lazy private var buttonBorder8: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "img_rectangle179_26")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setButtonActiveColor(hex: getContentColor(), alpha: 0.6)
        button.tag = 9
        button.addTarget(self, action: #selector(buttonBordersOptionTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var labelBorder8: UILabel = {
        let view = UILabel()
        view.text = "\(NSLocalizedString("buttonLabelBorder", comment: "")) 8"
        view.translatesAutoresizingMaskIntoConstraints = false
        //view.backgroundColor = hexStringToUIColor(hex: "#33DDFF")
        view.textColor = UIColor(hexaRGB: getContentColor(), alpha: 0.6)
        view.textAlignment = .center
        view.font = UIFont.preferredFont(forTextStyle: .body)
        view.adjustsFontForContentSizeCategory = true
        view.tag = 19
        return view
    }()
    
    lazy private var buttonBorder9: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "img_rectangle179_27")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setButtonActiveColor(hex: getContentColor(), alpha: 0.6)
        button.tag = 10
        button.addTarget(self, action: #selector(buttonBordersOptionTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var labelBorder9: UILabel = {
        let view = UILabel()
        view.text = "\(NSLocalizedString("buttonLabelBorder", comment: "")) 9"
        view.translatesAutoresizingMaskIntoConstraints = false
        //view.backgroundColor = hexStringToUIColor(hex: "#33DDFF")
        view.textColor = UIColor(hexaRGB: getContentColor(), alpha: 0.6)
        view.textAlignment = .center
        view.font = UIFont.preferredFont(forTextStyle: .body)
        view.adjustsFontForContentSizeCategory = true
        view.tag = 110
        return view
    }()
    
    lazy private var buttonBorder10: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "img_rectangle179_28")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setButtonActiveColor(hex: getContentColor(), alpha: 0.6)
        button.tag = 11
        button.addTarget(self, action: #selector(buttonBordersOptionTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var labelBorder10: UILabel = {
        let view = UILabel()
        view.text = "\(NSLocalizedString("buttonLabelBorder", comment: "")) 10"
        view.translatesAutoresizingMaskIntoConstraints = false
        //view.backgroundColor = hexStringToUIColor(hex: "#33DDFF")
        view.textColor = UIColor(hexaRGB: getContentColor(), alpha: 0.6)
        view.textAlignment = .center
        view.font = UIFont.preferredFont(forTextStyle: .body)
        view.adjustsFontForContentSizeCategory = true
        view.tag = 111
        return view
    }()
    
    private lazy var opacityPanel: UIView = {
        let view = UIView(frame: UIScreen.main.bounds)
        view.isHidden = true
        view.layer.cornerRadius = 10
        view.semanticContentAttribute = .forceLeftToRight
        view.backgroundColor = UIColor(hexaRGB: getBackgroundColor())
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy private var buttonBorderOpacity: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "img_border_opacity")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setButtonActiveColor(hex: getContentColor(), alpha: 0.6)
        button.tag = 31
        button.addTarget(self, action: #selector(opacityOptionsTap), for: .touchUpInside)
        return button
    }()
    
    lazy private var buttonBorderColor: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "img_group650")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setButtonActiveColor(hex: getContentColor(), alpha: 0.6)
        button.tag = 32
        button.addTarget(self, action: #selector(opacityOptionsTap), for: .touchUpInside)
        return button
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
        view.addTarget(self, action: #selector(buttonSliderCloseTap), for: .touchUpInside)
        view.setImage(uiImage, for: .normal)
        return view
    }()
    
    private lazy var buttonSliderOK: UIButton = {
        let view = UIButton(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        let uiImage = UIImage(named: "img_vector2")?.withRenderingMode(.alwaysTemplate)
        view.tintColor = UIColor(hexaRGB: getContentColor())
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(buttonBorderSliderOKTap), for: .touchUpInside)
        view.setImage(uiImage, for: .normal)
        return view
    }()
    
    private lazy var labelSliderLabel: UILabel = {
        let view = UILabel()
        view.text = "Opacity"
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = UIColor(hexaRGB: getContentColor(), alpha: 1)
        view.textAlignment = .left
        view.font = UIFont.preferredFont(forTextStyle: .body)
        view.adjustsFontForContentSizeCategory = true
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
    
    lazy private var buttonAdjustOpacityType: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        button.setImage(UIImage(named: "img_border_opacity")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setButtonActiveColor(hex: getContentColor(), alpha: 1)
        button.addTarget(self, action: #selector(buttonPickColorTap), for: .touchUpInside)
        return button
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
        
        bordersImage = receivedImage!
        setUpUIBorders()
        
        setUpConstraintsBorders()
        NSLayoutConstraint.activate(sharedConstraints)
        layoutTraitBorders(traitCollection: UIScreen.main.traitCollection)
    }
    
    func setUpUIBorders() {
        
        setNavBarBorders()
        masterView.addSubview(uiImageView)
        self.view.backgroundColor = UIColor(hexaRGB: getBackgroundColor())
        view.addSubview(masterView)
        setUpBottomActionPanelBorders()
        setUpBottomOpacityPanel()
        setUpBottomSliderPanelBorders()
    }
    
    func setNavBarBorders() {
        
        self.navigationItem.setHidesBackButton(true, animated: false)
        let navTitle = UILabel()
        navTitle.text = NSLocalizedString("buttonLabelBorders", comment: "")
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
        leftView.addTarget(self, action: #selector(backButtonTapBorders), for: .allTouchEvents)
        leftButton.customView = leftView
            
        let rightButton = UIBarButtonItem(title: NSLocalizedString("navBarButtonDone", comment: ""), style: .done, target: self, action: #selector(doneButtonTapBorder))
        rightButton.tintColor = UIColor(hexaRGB: getContentColor())!
        rightButton.setTitleTextAttributes(navBarButtonTitleAttributes, for: .normal)
        
        self.navigationItem.leftBarButtonItem  = leftButton
        self.navigationItem.rightBarButtonItem  = rightButton
        
        self.navigationController?.navigationBar.semanticContentAttribute = .forceLeftToRight
    }
    
    func setUpBottomOpacityPanel() {
        masterView.addSubview(opacityPanel)
        opacityPanel.addSubview(buttonBorderOpacity)
        opacityPanel.addSubview(buttonBorderColor)
        
        NSLayoutConstraint.activate([
            opacityPanel.heightAnchor.constraint(equalToConstant: 75),
            opacityPanel.bottomAnchor.constraint(equalTo: bottomActionPanel.topAnchor, constant: -10),
            opacityPanel.widthAnchor.constraint(equalTo: masterView.widthAnchor, constant: -20),
            opacityPanel.centerXAnchor.constraint(equalTo: masterView.centerXAnchor),
            
            buttonBorderOpacity.leftAnchor.constraint(equalTo: opacityPanel.leftAnchor, constant: 40.0),
            buttonBorderOpacity.topAnchor.constraint(equalTo: opacityPanel.topAnchor, constant: 10.0),
            buttonBorderOpacity.widthAnchor.constraint(equalToConstant: 55),
            buttonBorderOpacity.heightAnchor.constraint(equalToConstant: 55),
            
            buttonBorderColor.trailingAnchor.constraint(equalTo: opacityPanel.trailingAnchor, constant: -40.0),
            buttonBorderColor.topAnchor.constraint(equalTo: opacityPanel.topAnchor, constant: 10.0),
            buttonBorderColor.widthAnchor.constraint(equalToConstant: 55),
            buttonBorderColor.heightAnchor.constraint(equalToConstant: 55),
            
        ])
    }
    
    func setUpBottomSliderPanelBorders() {
        masterView.addSubview(uiSliderContainer)
        uiSliderContainer.addSubview(uiSlider)
        uiSliderContainer.addSubview(buttonSliderClose)
        uiSliderContainer.addSubview(buttonSliderOK)
        uiSliderContainer.addSubview(buttonAdjustOpacityType)
        uiSliderContainer.addSubview(labelSliderLabel)
        uiSliderContainer.addSubview(labelSliderProgressPercent)
        
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
            
            buttonAdjustOpacityType.leftAnchor.constraint(equalTo: uiSliderContainer.leftAnchor, constant: 10.0),
            buttonAdjustOpacityType.topAnchor.constraint(equalTo: buttonSliderClose.bottomAnchor, constant: 10.0),
            buttonAdjustOpacityType.widthAnchor.constraint(equalToConstant: 40),
            buttonAdjustOpacityType.heightAnchor.constraint(equalToConstant: 40),
            
            labelSliderLabel.leftAnchor.constraint(equalTo: buttonAdjustOpacityType.rightAnchor, constant: 10.0),
            labelSliderLabel.topAnchor.constraint(equalTo: uiSliderContainer.topAnchor, constant: 25.0),
            labelSliderLabel.widthAnchor.constraint(equalToConstant: 100),
            labelSliderLabel.heightAnchor.constraint(equalToConstant: 25),
            
            labelSliderProgressPercent.trailingAnchor.constraint(equalTo: uiSliderContainer.trailingAnchor, constant: -10.0),
            labelSliderProgressPercent.topAnchor.constraint(equalTo: uiSliderContainer.topAnchor, constant: 25.0),
            labelSliderProgressPercent.widthAnchor.constraint(equalToConstant: 100),
            labelSliderProgressPercent.heightAnchor.constraint(equalToConstant: 25),
            
            uiSlider.leftAnchor.constraint(equalTo: buttonAdjustOpacityType.rightAnchor, constant: 10.0),
            uiSlider.topAnchor.constraint(equalTo: labelSliderLabel.bottomAnchor),
            uiSlider.widthAnchor.constraint(equalTo: masterView.widthAnchor, constant: -120.0),
            uiSlider.heightAnchor.constraint(equalToConstant: 50),
            
        ])
    }
    
    func setUpBottomActionPanelBorders() {
        
        masterView.addSubview(bottomActionPanel)
        bottomActionPanel.addSubview(buttonBorder1)
        bottomActionPanel.addSubview(labelBorder1)
        bottomActionPanel.addSubview(buttonBorder2)
        bottomActionPanel.addSubview(labelBorder2)
        bottomActionPanel.addSubview(buttonBorder3)
        bottomActionPanel.addSubview(labelBorder3)
        bottomActionPanel.addSubview(buttonBorder4)
        bottomActionPanel.addSubview(labelBorder4)
        bottomActionPanel.addSubview(buttonBorder5)
        bottomActionPanel.addSubview(labelBorder5)
        bottomActionPanel.addSubview(buttonBorder6)
        bottomActionPanel.addSubview(labelBorder6)
        bottomActionPanel.addSubview(buttonBorder7)
        bottomActionPanel.addSubview(labelBorder7)
        bottomActionPanel.addSubview(buttonBorder8)
        bottomActionPanel.addSubview(labelBorder8)
        bottomActionPanel.addSubview(buttonBorder9)
        bottomActionPanel.addSubview(labelBorder9)
        bottomActionPanel.addSubview(buttonBorder10)
        bottomActionPanel.addSubview(labelBorder10)
        
        NSLayoutConstraint.activate([
            bottomActionPanel.bottomAnchor.constraint(equalTo: masterView.bottomAnchor),
            bottomActionPanel.widthAnchor.constraint(equalTo: masterView.widthAnchor),
            bottomActionPanel.centerXAnchor.constraint(equalTo: masterView.centerXAnchor),
            bottomActionPanel.heightAnchor.constraint(equalToConstant: 120),
            
            buttonBorder1.leftAnchor.constraint(equalTo: bottomActionPanel.leftAnchor, constant: 30.0),
            buttonBorder1.topAnchor.constraint(equalTo: bottomActionPanel.topAnchor, constant: 15.0),
            buttonBorder1.widthAnchor.constraint(equalToConstant: 55),
            buttonBorder1.heightAnchor.constraint(equalToConstant: 55),
            labelBorder1.topAnchor.constraint(equalTo: buttonBorder1.bottomAnchor, constant: 5),
            labelBorder1.centerXAnchor.constraint(equalTo: buttonBorder1.centerXAnchor),
            
            buttonBorder2.leftAnchor.constraint(equalTo: buttonBorder1.rightAnchor, constant: 45.0),
            buttonBorder2.topAnchor.constraint(equalTo: bottomActionPanel.topAnchor, constant: 15.0),
            buttonBorder2.widthAnchor.constraint(equalToConstant: 55),
            buttonBorder2.heightAnchor.constraint(equalToConstant: 55),
            labelBorder2.topAnchor.constraint(equalTo: buttonBorder2.bottomAnchor, constant: 5),
            labelBorder2.centerXAnchor.constraint(equalTo: buttonBorder2.centerXAnchor),
            
            buttonBorder3.leftAnchor.constraint(equalTo: buttonBorder2.rightAnchor, constant: 45.0),
            buttonBorder3.topAnchor.constraint(equalTo: bottomActionPanel.topAnchor, constant: 15.0),
            buttonBorder3.widthAnchor.constraint(equalToConstant: 55),
            buttonBorder3.heightAnchor.constraint(equalToConstant: 55),
            labelBorder3.topAnchor.constraint(equalTo: buttonBorder3.bottomAnchor, constant: 5),
            labelBorder3.centerXAnchor.constraint(equalTo: buttonBorder3.centerXAnchor),
            
            buttonBorder4.leftAnchor.constraint(equalTo: buttonBorder3.rightAnchor, constant: 45.0),
            buttonBorder4.topAnchor.constraint(equalTo: bottomActionPanel.topAnchor, constant: 15.0),
            buttonBorder4.widthAnchor.constraint(equalToConstant: 55),
            buttonBorder4.heightAnchor.constraint(equalToConstant: 55),
            labelBorder4.topAnchor.constraint(equalTo: buttonBorder4.bottomAnchor, constant: 5),
            labelBorder4.centerXAnchor.constraint(equalTo: buttonBorder4.centerXAnchor),
            
            buttonBorder5.leftAnchor.constraint(equalTo: buttonBorder4.rightAnchor, constant: 55.0),
            buttonBorder5.topAnchor.constraint(equalTo: bottomActionPanel.topAnchor, constant: 15.0),
            buttonBorder5.widthAnchor.constraint(equalToConstant: 55),
            buttonBorder5.heightAnchor.constraint(equalToConstant: 55),
            labelBorder5.topAnchor.constraint(equalTo: buttonBorder5.bottomAnchor, constant: 5),
            labelBorder5.centerXAnchor.constraint(equalTo: buttonBorder5.centerXAnchor),
            
            buttonBorder6.leftAnchor.constraint(equalTo: buttonBorder5.rightAnchor, constant: 45.0),
            buttonBorder6.topAnchor.constraint(equalTo: bottomActionPanel.topAnchor, constant: 15.0),
            buttonBorder6.widthAnchor.constraint(equalToConstant: 55),
            buttonBorder6.heightAnchor.constraint(equalToConstant: 55),
            labelBorder6.topAnchor.constraint(equalTo: buttonBorder6.bottomAnchor, constant: 5),
            labelBorder6.centerXAnchor.constraint(equalTo: buttonBorder6.centerXAnchor),
            
            buttonBorder7.leftAnchor.constraint(equalTo: buttonBorder6.rightAnchor, constant: 45.0),
            buttonBorder7.topAnchor.constraint(equalTo: bottomActionPanel.topAnchor, constant: 15.0),
            buttonBorder7.widthAnchor.constraint(equalToConstant: 55),
            buttonBorder7.heightAnchor.constraint(equalToConstant: 55),
            labelBorder7.topAnchor.constraint(equalTo: buttonBorder7.bottomAnchor, constant: 5),
            labelBorder7.centerXAnchor.constraint(equalTo: buttonBorder7.centerXAnchor),
            
            buttonBorder8.leftAnchor.constraint(equalTo: buttonBorder7.rightAnchor, constant: 45.0),
            buttonBorder8.topAnchor.constraint(equalTo: bottomActionPanel.topAnchor, constant: 15.0),
            buttonBorder8.widthAnchor.constraint(equalToConstant: 55),
            buttonBorder8.heightAnchor.constraint(equalToConstant: 55),
            labelBorder8.topAnchor.constraint(equalTo: buttonBorder8.bottomAnchor, constant: 5),
            labelBorder8.centerXAnchor.constraint(equalTo: buttonBorder8.centerXAnchor),
            
            buttonBorder9.leftAnchor.constraint(equalTo: buttonBorder8.rightAnchor, constant: 45.0),
            buttonBorder9.topAnchor.constraint(equalTo: bottomActionPanel.topAnchor, constant: 15.0),
            buttonBorder9.widthAnchor.constraint(equalToConstant: 55),
            buttonBorder9.heightAnchor.constraint(equalToConstant: 55),
            labelBorder9.topAnchor.constraint(equalTo: buttonBorder9.bottomAnchor, constant: 5),
            labelBorder9.centerXAnchor.constraint(equalTo: buttonBorder9.centerXAnchor),
            
            buttonBorder10.leftAnchor.constraint(equalTo: buttonBorder9.rightAnchor, constant: 45.0),
            buttonBorder10.topAnchor.constraint(equalTo: bottomActionPanel.topAnchor, constant: 15.0),
            buttonBorder10.widthAnchor.constraint(equalToConstant: 55),
            buttonBorder10.heightAnchor.constraint(equalToConstant: 55),
            labelBorder10.topAnchor.constraint(equalTo: buttonBorder10.bottomAnchor, constant: 5),
            labelBorder10.centerXAnchor.constraint(equalTo: buttonBorder10.centerXAnchor),
        ])
    }
    
    @objc func backButtonTapBorders(sender: Any) {
        if let viewController = navigationController?.viewControllers.first(where: {$0 is ViewControllerStyleRedactor}) {
              navigationController?.popToViewController(viewController, animated: false)
        }
    }
    
    @objc func doneButtonTapBorder(sender: Any) {
        if let viewController = navigationController?.viewControllers.first(where: {$0 is ViewControllerStyleRedactor}) {
            
            NotificationCenter.default.removeObserver(self)
            let imageDataDict:[String: UIImage] = ["borderedImage": bordersImage!]
            NotificationCenter.default.post(name: Notification.Name("com.borderedphoto.success"), object: nil, userInfo: imageDataDict)
              navigationController?.popToViewController(viewController, animated: false)
        }
    }
    
    func setUpConstraintsBorders() {
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
    
    func layoutTraitBorders(traitCollection:UITraitCollection) {
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
    
    @objc func buttonBordersOptionTap(sender: UIButton) {
        opacityPanel.isHidden = false
        selectedShade = sender.tag
        
        switch sender.tag {
            case 2:
            self.selectedOverlayImageName = "img_rectangle176"
            case 3:
            self.selectedOverlayImageName = "img_rectangle177"
            case 4:
            self.selectedOverlayImageName = "img_rectangle178"
            case 5:
            self.selectedOverlayImageName = "img_rectangle179"
            case 6:
            self.selectedOverlayImageName = "img_rectangle179_23"
            case 7:
            self.selectedOverlayImageName = "img_rectangle179_24"
            case 8:
            self.selectedOverlayImageName = "img_rectangle179_25"
            case 9:
            self.selectedOverlayImageName = "img_rectangle179_26"
            case 10:
            self.selectedOverlayImageName = "img_rectangle179_27"
            case 11:
            self.selectedOverlayImageName = "img_rectangle179_28"
            default:
                break
        }
        
        if let foundView = view.viewWithTag(selectedShade!) as? UIButton {
            foundView.setButtonActiveColor(hex: getContentColor(), alpha: 1)
        }
        if let foundView = view.viewWithTag(Int("1\(selectedShade!)")!) as? UILabel {
            foundView.textColor = UIColor(hexaRGB: getContentColor(), alpha: 1)
        }
        
        setButtonColorBorders(selectedButtonTag: selectedShade, selectedLabelTag: Int("1\(selectedShade!)")!)
        overlayBorderImageOnBorderbox(borderColor: pickedColor, opacity: sliderCurrentValue)
    }
    
    func overlayBorderImageOnBorderbox(borderColor: UIColor, opacity: CGFloat) {
        
        let imageWidth = receivedImage!.size.width
        let imageHeight = receivedImage!.size.height

        let diameter = max(imageWidth, imageHeight)
        let isLandscape = imageWidth > imageHeight

        let xOffset = isLandscape ? (imageWidth - diameter) / 2 : 0
        let yOffset = isLandscape ? 0 : (imageHeight - diameter) / 2

        var imageSize = CGSize(width: imageWidth, height: imageHeight)
        let format = UIGraphicsImageRendererFormat()
        format.opaque = false
        format.scale = 1
        
        let newImage = UIGraphicsImageRenderer(size: imageSize, format: format).image { _ in
            var dashes: [ CGFloat ] = []
            var ovalPath: UIBezierPath?
            switch selectedShade{
            case 2:
                ovalPath = UIBezierPath(rect: CGRect(origin: .zero, size: imageSize))
                ovalPath?.addClip()
                receivedImage!.draw(at: CGPoint(x: xOffset, y: -yOffset))
                borderColor.withAlphaComponent(opacity).setStroke()
                ovalPath?.lineWidth = diameter / 50
            case 3:
                ovalPath = UIBezierPath(roundedRect: CGRect(origin: .zero, size: imageSize), cornerRadius: diameter / 10)
                ovalPath?.addClip()
                receivedImage!.draw(at: CGPoint(x: xOffset, y: -yOffset))
                borderColor.withAlphaComponent(opacity).setStroke()
                ovalPath?.lineWidth = diameter / 50
            case 4:
                imageSize = CGSize(width: imageWidth, height: imageWidth)
                ovalPath = UIBezierPath(ovalIn: CGRect(origin: .zero, size: imageSize))
                ovalPath?.addClip()
                receivedImage!.draw(at: CGPoint(x: -xOffset, y: -yOffset))
                borderColor.withAlphaComponent(opacity).setStroke()
                ovalPath?.lineWidth = diameter / 50
            case 5:
                dashes = [imageWidth/24/2, imageWidth/24, imageWidth/24, imageWidth/24, imageWidth/24, imageWidth/24, imageWidth/24, imageWidth/24, imageWidth/24, imageWidth/24, imageWidth/24, imageWidth/24, imageWidth/24, imageWidth/24, imageWidth/24, imageWidth/24, imageWidth/24, imageWidth/24, imageWidth/24, imageWidth/24, imageWidth/24, imageWidth/24, imageWidth/24, imageWidth/24, imageWidth/24/2, 0, (imageHeight/24/2), imageHeight/24, imageHeight/24, imageHeight/24, imageHeight/24, imageHeight/24, imageHeight/24, imageHeight/24, imageHeight/24, imageHeight/24, imageHeight/24, imageHeight/24, imageHeight/24, imageHeight/24, imageHeight/24, imageHeight/24, imageHeight/24, imageHeight/24, imageHeight/24, imageHeight/24, imageHeight/24, imageHeight/24, imageHeight/24, imageHeight/24, imageHeight/24, imageHeight/24, imageHeight/24, imageHeight/24, (imageHeight/24/2), 0, imageWidth/24/2, imageWidth/24, imageWidth/24, imageWidth/24, imageWidth/24, imageWidth/24, imageWidth/24, imageWidth/24, imageWidth/24, imageWidth/24, imageWidth/24, imageWidth/24, imageWidth/24, imageWidth/24, imageWidth/24, imageWidth/24, imageWidth/24, imageWidth/24, imageWidth/24, 0, (imageHeight/24/2), imageHeight/24, imageHeight/24, imageHeight/24, imageHeight/24, imageHeight/24, imageHeight/24, imageHeight/24, imageHeight/24, imageHeight/24, imageHeight/24, imageHeight/24, imageHeight/24, imageHeight/24, imageHeight/24, imageHeight/24, imageHeight/24, imageHeight/24, imageHeight/24, imageHeight/24, imageHeight/24, imageHeight/24, imageHeight/24, imageHeight/24, imageHeight/24, imageHeight/24, imageHeight/24, (imageHeight/24/2)]
                ovalPath = UIBezierPath(rect: CGRect(origin: .zero, size: imageSize))
                ovalPath?.addClip()
                receivedImage!.draw(at: CGPoint(x: xOffset, y: -yOffset))
                borderColor.withAlphaComponent(opacity).setStroke()
                ovalPath?.lineWidth = diameter / 50
                ovalPath?.setLineDash(dashes, count: dashes.count, phase: 0.0)
            case 6:
                dashes = [imageWidth/24, (imageWidth/24)*2, (imageWidth/24)*2, (imageWidth/24)*2, (imageWidth/24)*2, (imageWidth/24)*2, (imageWidth/24)*2, (imageWidth/24)*2, (imageWidth/24)*2, (imageWidth/24)*2, (imageWidth/24)*2, (imageWidth/24)*2, imageWidth/24, 0, imageHeight/24, (imageHeight/24)*2, (imageHeight/24)*2, (imageHeight/24)*2, (imageHeight/24)*2, (imageHeight/24)*2, (imageHeight/24)*2, (imageHeight/24)*2, (imageHeight/24)*2, (imageHeight/24)*2, (imageHeight/24)*2, (imageHeight/24)*2, imageHeight/24, 0, imageWidth/24, (imageWidth/24)*2, (imageWidth/24)*2, (imageWidth/24)*2, (imageWidth/24)*2, (imageWidth/24)*2, (imageWidth/24)*2, (imageWidth/24)*2, (imageWidth/24)*2, (imageWidth/24)*2, (imageWidth/24)*2, (imageWidth/24)*2, imageWidth/24, 0, imageHeight/24, (imageHeight/24)*2, (imageHeight/24)*2, (imageHeight/24)*2, (imageHeight/24)*2, (imageHeight/24)*2, (imageHeight/24)*2, (imageHeight/24)*2, (imageHeight/24)*2, (imageHeight/24)*2, (imageHeight/24)*2, (imageHeight/24)*2, imageHeight/24]
                ovalPath = UIBezierPath(rect: CGRect(origin: .zero, size: imageSize))
                ovalPath?.addClip()
                receivedImage!.draw(at: CGPoint(x: xOffset, y: -yOffset))
                borderColor.withAlphaComponent(opacity).setStroke()
                ovalPath?.lineWidth = diameter / 50
                ovalPath?.setLineDash(dashes, count: dashes.count, phase: 0.0)
            case 7:
                dashes = [imageWidth/8/2, imageWidth/8, imageWidth/8, imageWidth/8, imageWidth/8, imageWidth/8, imageWidth/8, imageWidth/8, imageWidth/8/2, 0, imageHeight/8/2, imageHeight/8, imageHeight/8, imageHeight/8, imageHeight/8, imageHeight/8, imageHeight/8, imageHeight/8, imageHeight/8/2, 0, imageWidth/8/2, imageWidth/8, imageWidth/8, imageWidth/8, imageWidth/8, imageWidth/8, imageWidth/8, imageWidth/8, imageWidth/8/2, 0, imageHeight/8/2, imageHeight/8, imageHeight/8, imageHeight/8, imageHeight/8, imageHeight/8, imageHeight/8, imageHeight/8, imageHeight/8/2]
                ovalPath = UIBezierPath(rect: CGRect(origin: .zero, size: imageSize))
                ovalPath?.addClip()
                receivedImage!.draw(at: CGPoint(x: xOffset, y: -yOffset))
                borderColor.withAlphaComponent(opacity).setStroke()
                ovalPath?.lineWidth = diameter / 50
                ovalPath?.setLineDash(dashes, count: dashes.count, phase: 0.0)
            case 8:
                dashes = [imageWidth/3/2/2, imageWidth/3/2/2, imageWidth/3/2, imageWidth/3/2/2, imageWidth/3/2, imageWidth/3/2/2, imageWidth/3/2, imageWidth/3/2/2, imageWidth/3/2/2, 0, imageHeight/3/2/2, imageHeight/3/2/2, imageHeight/3/2, imageHeight/3/2/2, imageHeight/3/2, imageHeight/3/2/2, imageHeight/3/2, imageHeight/3/2/2, imageHeight/3/2/2, 0, imageWidth/3/2/2, imageWidth/3/2/2, imageWidth/3/2, imageWidth/3/2/2, imageWidth/3/2, imageWidth/3/2/2, imageWidth/3/2, imageWidth/3/2/2, imageWidth/3/2/2, 0, imageHeight/3/2/2, imageHeight/3/2/2, imageHeight/3/2, imageHeight/3/2/2, imageHeight/3/2, imageHeight/3/2/2, imageHeight/3/2, imageHeight/3/2/2, imageHeight/3/2/2]
                ovalPath = UIBezierPath(rect: CGRect(origin: .zero, size: imageSize))
                ovalPath?.addClip()
                receivedImage!.draw(at: CGPoint(x: xOffset, y: -yOffset))
                borderColor.withAlphaComponent(opacity).setStroke()
                ovalPath?.lineWidth = diameter / 50
                ovalPath?.setLineDash(dashes, count: dashes.count, phase: 0.0)
                ovalPath?.lineCapStyle = .round
            case 9:
                dashes = [imageWidth/3/2, imageWidth/3/2, imageWidth/3, imageWidth/3/2, imageWidth/3/2, 0, imageHeight/3/2, imageHeight/3/2, imageHeight/3, imageHeight/3/2, imageHeight/3/2, 0, imageWidth/3/2, imageWidth/3/2, imageWidth/3, imageWidth/3/2, imageWidth/3/2, 0, imageHeight/3/2, imageHeight/3/2, imageHeight/3, imageHeight/3/2, imageHeight/3/2]
                ovalPath = UIBezierPath(rect: CGRect(origin: .zero, size: imageSize))
                ovalPath?.addClip()
                receivedImage!.draw(at: CGPoint(x: xOffset, y: -yOffset))
                borderColor.withAlphaComponent(opacity).setStroke()
                ovalPath?.lineWidth = diameter / 50
                ovalPath?.setLineDash(dashes, count: dashes.count, phase: 0.0)
            case 10:
                dashes = [(imageWidth/2)-50, 100, (imageWidth/2)-50, 0, (imageHeight/2)-50, 100, (imageHeight/2)-50, 0, (imageWidth/2)-50, 100, (imageWidth/2)-50, 0, (imageHeight/2)-50, 100, (imageHeight/2)-50]
                ovalPath = UIBezierPath(rect: CGRect(origin: .zero, size: imageSize))
                ovalPath?.addClip()
                receivedImage!.draw(at: CGPoint(x: xOffset, y: -yOffset))
                borderColor.withAlphaComponent(opacity).setStroke()
                ovalPath?.lineWidth = diameter / 5
                ovalPath?.setLineDash(dashes, count: dashes.count, phase: 0.0)
            case 11:
                dashes = [(imageWidth/2)-50, 100, (imageWidth/2)-50, 0, (imageHeight/2)-50, 100, (imageHeight/2)-50, 0, (imageWidth/2)-50, 100, (imageWidth/2)-50, 0, (imageHeight/2)-50, 100, (imageHeight/2)-50]
                ovalPath = UIBezierPath(rect: CGRect(origin: .zero, size: CGSize(width: imageWidth, height: imageHeight)))
                ovalPath?.addClip()
                receivedImage!.draw(at: CGPoint(x: xOffset, y: -yOffset))
                borderColor.withAlphaComponent(opacity).setStroke()
                ovalPath?.lineWidth = diameter / 12
                ovalPath?.setLineDash(dashes, count: dashes.count, phase: 0.0)
            default:
                break
            }
            ovalPath?.stroke()
        }
        
        bordersImage = newImage
        uiImageView.image = newImage
    }
    
    @objc func uiSliderValueChange(sender: UISlider) {
        
        sliderCurrentValue = CGFloat(sender.value)
        let percent: Float = sender.value*100
        labelSliderProgressPercent.text = "\(Int(percent)) %"
    }
    
    @objc func buttonBorderSliderOKTap(sender: UIButton?) {
        
        switch opacityOption {
            case 31:
            borderOpacity = sliderCurrentValue
            overlayBorderImageOnBorderbox(borderColor: pickedColor, opacity: borderOpacity)
        case 32:
            borderColorOpacity = sliderCurrentValue
            overlayBorderImageOnBorderbox(borderColor: pickedColor, opacity: borderColorOpacity)
        default:
            break
        }
        uiSliderContainer.isHidden = true
    }
    
    @objc func buttonSliderCloseTap(sender: UIButton?) {
        uiSliderContainer.isHidden = true
    }
    
    func setButtonColorBorders(selectedButtonTag: Int?, selectedLabelTag: Int?) {
        
        for i in 2...11 {
            if i != selectedButtonTag {
                if let foundView = view.viewWithTag(i) as? UIButton {
                    foundView.setButtonActiveColor(hex: getContentColor(), alpha: 0.6)
                }
            }
        }
        
        for i in 12...111 {
            if i != selectedLabelTag {
                if let foundView = view.viewWithTag(i) as? UILabel {
                    foundView.textColor = UIColor(hexaRGB: getContentColor(), alpha: 0.6)
                }
            }
        }
    }
    
    @objc func buttonPickColorTap(sender: UIButton) {
        
        if opacityOption == 32 {
            opacityPanel.isHidden = true
            let picker = UIColorPickerViewController()
            picker.selectedColor = UIColor.white
            
            //  Subscribing selectedColor property changes.
            self.cancellable = picker.publisher(for: \.selectedColor)
                .sink { color in
                    
                    //  Changing view color on main thread.
                    DispatchQueue.main.async {
                        self.pickedColor = color
                        self.pickedColor.getRed(&self.pickedColorRed, green: &self.pickedColorGreen, blue: &self.pickedColorBlue, alpha: &self.borderColorOpacity)
                        self.overlayBorderImageOnBorderbox(borderColor: self.pickedColor, opacity: self.borderColorOpacity)
                    }
                }
            
            self.present(picker, animated: true, completion: nil)
        }
    }
    
    @objc func opacityOptionsTap(sender: UIButton) {
        opacityPanel.isHidden = true
        uiSliderContainer.isHidden = false
        opacityOption = sender.tag
        
        switch opacityOption {
            case 31:
            buttonAdjustOpacityType.setImage(UIImage(named: "img_border_opacity")?.withRenderingMode(.alwaysOriginal), for: .normal)
            buttonAdjustOpacityType.layer.cornerRadius = 0
            buttonAdjustOpacityType.layer.backgroundColor = UIColor.clear.cgColor
            buttonAdjustOpacityType.layer.borderWidth = 0
            buttonAdjustOpacityType.layer.borderColor = UIColor.clear.cgColor
            buttonAdjustOpacityType.translatesAutoresizingMaskIntoConstraints = false
            buttonAdjustOpacityType.setButtonActiveColor(hex: getContentColor(), alpha: 1)
        case 32:
            buttonAdjustOpacityType.setImage(UIImage(named: "img_color_picker")?.withRenderingMode(.alwaysTemplate), for: .normal)
            buttonAdjustOpacityType.layer.cornerRadius = 10
            buttonAdjustOpacityType.layer.backgroundColor = UIColor(named: "LightBlueA700")?.cgColor
            buttonAdjustOpacityType.layer.borderWidth = 2
            buttonAdjustOpacityType.layer.borderColor = UIColor.white.cgColor
            buttonAdjustOpacityType.translatesAutoresizingMaskIntoConstraints = false
            buttonAdjustOpacityType.setButtonActiveColor(hex: getContentColor(), alpha: 1)
            buttonAdjustOpacityType.addTarget(self, action: #selector(buttonPickColorTap), for: .touchUpInside)
        default:
            break
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
