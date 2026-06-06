//
//  ViewControllerFilters.swift
//  PhotoEditorFilterEffects
//
//  Created by Sonjoy Borkakoty on 31/10/22.
//

import UIKit

class ViewControllerFilters: UIViewController {
    
    private var compactConstraints: [NSLayoutConstraint] = []
    private var regularConstraints: [NSLayoutConstraint] = []
    private var sharedConstraints: [NSLayoutConstraint] = []
    
    var receivedImage: UIImage?
    var filteredImage: UIImage?
    
    private var viewModelAdjust: ViewModelAdjust?
    
    private var sliderCurrentValue: Float = 0.5
    private var selectedShade: Int = 11
    
    private lazy var masterView: UIView = {
        let view = UINib(nibName: "MasterViewFilter", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
        view.frame = UIScreen.main.bounds
        view.backgroundColor = UIColor(hexaRGB: getBackgroundColor())!
        view.translatesAutoresizingMaskIntoConstraints = false
        view.tag = 1
        return view
    }()
    
    private lazy var uiImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = receivedImage!.alpha(0.5)
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private lazy var indicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .medium)
        view.color = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var bottomPreviewPanel: UIScrollView = {
        let customView = UIScrollView()
        customView.isScrollEnabled = true
        customView.contentSize.width = 815.0
        customView.showsHorizontalScrollIndicator = false
        customView.translatesAutoresizingMaskIntoConstraints = false
        customView.backgroundColor = UIColor(hexaRGB: getMenuBackColor())!
        customView.tag = 21
        return customView
    }()
    
    private lazy var labelNormal: UILabel = {
        let view = UILabel()
        view.text = NSLocalizedString("buttonLabelNormal", comment: "")
        view.translatesAutoresizingMaskIntoConstraints = false
        //view.backgroundColor = hexStringToUIColor(hex: "#33DDFF")
        view.textColor = UIColor(hexaRGB: getContentColor(), alpha: 1)
        view.textAlignment = .center
        view.font = UIFont.preferredFont(forTextStyle: .body)
        view.adjustsFontForContentSizeCategory = true
        view.tag = 111
        return view
    }()
    
    private lazy var labelRedInfluence: UILabel = {
        let view = UILabel()
        view.text = NSLocalizedString("buttonLabelRedInfluence", comment: "")
        view.translatesAutoresizingMaskIntoConstraints = false
        //view.backgroundColor = hexStringToUIColor(hex: "#33DDFF")
        view.textColor = UIColor(hexaRGB: getContentColor(), alpha: 0.6)
        view.textAlignment = .center
        view.font = UIFont.preferredFont(forTextStyle: .body)
        view.adjustsFontForContentSizeCategory = true
        view.tag = 112
        return view
    }()
    
    private lazy var labelHue: UILabel = {
        let view = UILabel()
        view.text = NSLocalizedString("buttonLabelHueAdjust", comment: "")
        view.translatesAutoresizingMaskIntoConstraints = false
        //view.backgroundColor = hexStringToUIColor(hex: "#33DDFF")
        view.textColor = UIColor(hexaRGB: getContentColor(), alpha: 0.6)
        view.textAlignment = .center
        view.font = UIFont.preferredFont(forTextStyle: .body)
        view.adjustsFontForContentSizeCategory = true
        view.tag = 113
        return view
    }()
    
    private lazy var labelRedToGreen: UILabel = {
        let view = UILabel()
        view.text = NSLocalizedString("buttonLabelRedToGreen", comment: "")
        view.translatesAutoresizingMaskIntoConstraints = false
        //view.backgroundColor = hexStringToUIColor(hex: "#33DDFF")
        view.textColor = UIColor(hexaRGB: getContentColor(), alpha: 0.6)
        view.textAlignment = .center
        view.font = UIFont.preferredFont(forTextStyle: .body)
        view.adjustsFontForContentSizeCategory = true
        view.tag = 114
        return view
    }()
    
    private lazy var labelScan: UILabel = {
        let view = UILabel()
        view.text = NSLocalizedString("buttonLabelScan", comment: "")
        view.translatesAutoresizingMaskIntoConstraints = false
        //view.backgroundColor = hexStringToUIColor(hex: "#33DDFF")
        view.textColor = UIColor(hexaRGB: getContentColor(), alpha: 0.6)
        view.textAlignment = .center
        view.font = UIFont.preferredFont(forTextStyle: .body)
        view.adjustsFontForContentSizeCategory = true
        view.tag = 115
        return view
    }()
    
    private lazy var labelExclusion: UILabel = {
        let view = UILabel()
        view.text = NSLocalizedString("buttonLabelExclusion", comment: "")
        view.translatesAutoresizingMaskIntoConstraints = false
        //view.backgroundColor = hexStringToUIColor(hex: "#33DDFF")
        view.textColor = UIColor(hexaRGB: getContentColor(), alpha: 0.6)
        view.textAlignment = .center
        view.font = UIFont.preferredFont(forTextStyle: .body)
        view.adjustsFontForContentSizeCategory = true
        view.tag = 116
        return view
    }()
    
    private lazy var labelLark: UILabel = {
        let view = UILabel()
        view.text = NSLocalizedString("buttonLabelLark", comment: "")
        view.translatesAutoresizingMaskIntoConstraints = false
        //view.backgroundColor = hexStringToUIColor(hex: "#33DDFF")
        view.textColor = UIColor(hexaRGB: getContentColor(), alpha: 0.6)
        view.textAlignment = .center
        view.font = UIFont.preferredFont(forTextStyle: .body)
        view.adjustsFontForContentSizeCategory = true
        view.tag = 117
        return view
    }()
    
    private lazy var uiSliderContainer: UIView = {
        let view = UIView(frame: UIScreen.main.bounds)
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
        view.addTarget(self, action: #selector(buttonFilterSliderCloseTap), for: .touchUpInside)
        view.setImage(uiImage, for: .normal)
        return view
    }()
    
    private lazy var buttonSliderOK: UIButton = {
        let view = UIButton(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        let uiImage = UIImage(named: "img_vector2")?.withRenderingMode(.alwaysTemplate)
        view.tintColor = UIColor(hexaRGB: getContentColor())
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(buttonFilterSliderOKTap), for: .touchUpInside)
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
        view.value = sliderCurrentValue
        view.minimumValue = 0
        view.maximumValue = 1
        view.semanticContentAttribute = .forceLeftToRight
        view.addTarget(self, action: #selector(uiSliderValueChange), for: .valueChanged)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        DispatchQueue.main.asyncAfter(deadline:.now() + 0.1) {
            self.setUpBottomPreviewPanelFilters()
            self.setUpBottomSliderPanelFilters()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //handle dark mode
        if #available(iOS 13.0, *) {
            view.overrideUserInterfaceStyle = .light
        }
        
        filteredImage = receivedImage
        setUpUIFilters()
        
        setUpConstraintsFilters()
        setConstraintsOfBottomPreviewPanel()
        
        NSLayoutConstraint.activate(sharedConstraints)
        layoutTraitFilters(traitCollection: UIScreen.main.traitCollection)
    }
    
    func setUpUIFilters() {
        
        setNavBarFilters()
        masterView.addSubview(uiImageView)
        
        indicator.startAnimating()
        bottomPreviewPanel.addSubview(indicator)
        masterView.addSubview(bottomPreviewPanel)
        
        self.view.backgroundColor = UIColor(hexaRGB: getBackgroundColor())
        view.addSubview(masterView)
    }
    
    func setNavBarFilters() {
        
        self.navigationItem.setHidesBackButton(true, animated: false)
        let navTitle = UILabel()
        navTitle.text = NSLocalizedString("navBarTitleFiltersVC", comment: "")
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
        leftView.addTarget(self, action: #selector(backButtonTapFilters), for: .allTouchEvents)
        leftButton.customView = leftView
            
        let rightButton = UIBarButtonItem(title: NSLocalizedString("navBarButtonDone", comment: ""), style: .done, target: self, action: #selector(doneButtonTapFilters))
        rightButton.tintColor = UIColor(hexaRGB: getContentColor())!
        rightButton.setTitleTextAttributes(navBarButtonTitleAttributes, for: .normal)
        
        self.navigationItem.leftBarButtonItem  = leftButton
        self.navigationItem.rightBarButtonItem  = rightButton
        
        self.navigationController?.navigationBar.semanticContentAttribute = .forceLeftToRight
    }
    
    func setUpBottomSliderPanelFilters() {
        masterView.addSubview(uiSliderContainer)
        uiSliderContainer.addSubview(uiSlider)
        uiSliderContainer.addSubview(labelSliderProgressPercent)
        uiSliderContainer.addSubview(buttonSliderClose)
        uiSliderContainer.addSubview(buttonSliderOK)
        
        NSLayoutConstraint.activate([
            uiSliderContainer.heightAnchor.constraint(equalToConstant: 100),
            uiSliderContainer.bottomAnchor.constraint(equalTo: bottomPreviewPanel.topAnchor, constant: -10),
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
            uiSlider.widthAnchor.constraint(equalTo: uiSliderContainer.widthAnchor, constant: -100.0),
            uiSlider.centerXAnchor.constraint(equalTo: uiSliderContainer.centerXAnchor),
            uiSlider.heightAnchor.constraint(equalToConstant: 50),
            
            labelSliderProgressPercent.centerYAnchor.constraint(equalTo: uiSlider.centerYAnchor),
            labelSliderProgressPercent.leftAnchor.constraint(equalTo: uiSlider.rightAnchor, constant: 2.5),
            
        ])
    }
    
    func setUpBottomPreviewPanelFilters() {
        
        let imageButtonNormal = UIButton(frame: CGRect(x: 10.0, y: 10.0, width: 105, height: 125))
        imageButtonNormal.tag = 11
        imageButtonNormal.addTarget(self, action: #selector(setImageFilter), for: .touchUpInside)
        let imageViewNormal = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: 105, height: 125))
        imageViewNormal.image = receivedImage!
        imageViewNormal.contentMode = .scaleAspectFit
        imageButtonNormal.addSubview(imageViewNormal)
        bottomPreviewPanel.addSubview(imageButtonNormal)
        
        let imageButtonRedInfluence = UIButton(frame: CGRect(x: 125.0, y: 10.0, width: 105, height: 125))
        imageButtonRedInfluence.tag = 12
        imageButtonRedInfluence.addTarget(self, action: #selector(setImageFilter), for: .touchUpInside)
        let imageViewRedInfluence = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: 105, height: 125))
        imageViewRedInfluence.image = receivedImage?.filterEffectRedInfluence()
        imageViewRedInfluence.contentMode = .scaleAspectFit
        
        imageButtonRedInfluence.addSubview(imageViewRedInfluence)
        bottomPreviewPanel.addSubview(imageButtonRedInfluence)
        
        let imageButtonHueAdjust = UIButton(frame: CGRect(x: 240.0, y: 10.0, width: 105, height: 125))
        imageButtonHueAdjust.tag = 13
        imageButtonHueAdjust.addTarget(self, action: #selector(setImageFilter), for: .touchUpInside)
        let imageViewHueAdjust = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: 105, height: 125))
        imageViewHueAdjust.image = receivedImage?.filterEffectHueAdjust()
        imageViewHueAdjust.contentMode = .scaleAspectFit
        imageButtonHueAdjust.addSubview(imageViewHueAdjust)
        bottomPreviewPanel.addSubview(imageButtonHueAdjust)
        
        let imageButtonRedToGreed = UIButton(frame: CGRect(x: 355.0, y: 10.0, width: 105, height: 125))
        imageButtonRedToGreed.tag = 14
        imageButtonRedToGreed.addTarget(self, action: #selector(setImageFilter), for: .touchUpInside)
        let imageViewRedToGreed = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: 105, height: 125))
        imageViewRedToGreed.image = receivedImage?.filterEffectRedToGreen()
        imageViewRedToGreed.contentMode = .scaleAspectFit
        imageButtonRedToGreed.addSubview(imageViewRedToGreed)
        bottomPreviewPanel.addSubview(imageButtonRedToGreed)
        
        let imageButtonScan = UIButton(frame: CGRect(x: 470.0, y: 10.0, width: 105, height: 125))
        imageButtonScan.tag = 15
        imageButtonScan.addTarget(self, action: #selector(setImageFilter), for: .touchUpInside)
        let imageViewScan = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: 105, height: 125))
        imageViewScan.image = receivedImage?.filterEffectScan()
        imageViewScan.contentMode = .scaleAspectFit
        imageButtonScan.addSubview(imageViewScan)
        bottomPreviewPanel.addSubview(imageButtonScan)
        
        let imageButtonExclusion = UIButton(frame: CGRect(x: 585.0, y: 10.0, width: 105, height: 125))
        imageButtonExclusion.tag = 16
        imageButtonExclusion.addTarget(self, action: #selector(setImageFilter), for: .touchUpInside)
        let imageViewExclusion = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: 105, height: 125))
        imageViewExclusion.image = receivedImage?.filterEffectExclusion()
        imageViewExclusion.contentMode = .scaleAspectFit
        imageButtonExclusion.addSubview(imageViewExclusion)
        bottomPreviewPanel.addSubview(imageButtonExclusion)
        
        let imageButtonLark = UIButton(frame: CGRect(x: 700, y: 10.0, width: 105, height: 125))
        imageButtonLark.tag = 17
        imageButtonLark.addTarget(self, action: #selector(setImageFilter), for: .touchUpInside)
        let imageViewLark = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: 105, height: 125))
        imageViewLark.image = receivedImage?.filterEffectLark()
        imageViewLark.contentMode = .scaleAspectFit
        imageButtonLark.addSubview(imageViewLark)
        bottomPreviewPanel.addSubview(imageButtonLark)
        
        bottomPreviewPanel.addSubview(labelNormal)
        bottomPreviewPanel.addSubview(labelRedInfluence)
        bottomPreviewPanel.addSubview(labelHue)
        bottomPreviewPanel.addSubview(labelRedToGreen)
        bottomPreviewPanel.addSubview(labelScan)
        bottomPreviewPanel.addSubview(labelExclusion)
        bottomPreviewPanel.addSubview(labelLark)
        
        labelNormal.topAnchor.constraint(equalTo: imageButtonNormal.bottomAnchor, constant: 5).isActive = true
        labelNormal.centerXAnchor.constraint(equalTo: imageButtonNormal.centerXAnchor).isActive = true
        
        labelRedInfluence.topAnchor.constraint(equalTo: imageButtonRedInfluence.bottomAnchor, constant: 5).isActive = true
        labelRedInfluence.centerXAnchor.constraint(equalTo: imageButtonRedInfluence.centerXAnchor).isActive = true
        
        labelHue.topAnchor.constraint(equalTo: imageButtonHueAdjust.bottomAnchor, constant: 5).isActive = true
        labelHue.centerXAnchor.constraint(equalTo: imageButtonHueAdjust.centerXAnchor).isActive = true
        
        labelRedToGreen.topAnchor.constraint(equalTo: imageButtonRedToGreed.bottomAnchor, constant: 5).isActive = true
        labelRedToGreen.centerXAnchor.constraint(equalTo: imageButtonRedToGreed.centerXAnchor).isActive = true
        
        labelScan.topAnchor.constraint(equalTo: imageButtonScan.bottomAnchor, constant: 5).isActive = true
        labelScan.centerXAnchor.constraint(equalTo: imageButtonScan.centerXAnchor).isActive = true
        
        labelExclusion.topAnchor.constraint(equalTo: imageButtonExclusion.bottomAnchor, constant: 5).isActive = true
        labelExclusion.centerXAnchor.constraint(equalTo: imageButtonExclusion.centerXAnchor).isActive = true
        
        labelLark.topAnchor.constraint(equalTo: imageButtonLark.bottomAnchor, constant: 5).isActive = true
        labelLark.centerXAnchor.constraint(equalTo: imageButtonLark.centerXAnchor).isActive = true
        
        indicator.stopAnimating()
    }
    
    @objc func setImageFilter(sender: UIButton) {
        
        selectedShade = sender.tag
        sliderCurrentValue = 0.5
        uiSlider.value = 0.5
        uiSlider.minimumValue = 0
        uiSlider.maximumValue = 1
        labelSliderProgressPercent.text = "50%"
        uiSliderContainer.isHidden = false
        
        switch sender.tag {
            case 11:
                filteredImage = receivedImage!
            uiImageView.image = filteredImage?.alpha(CGFloat(sliderCurrentValue))
                selectedShade = 11
            case 12:
            self.filteredImage = self.receivedImage!.filterEffectRedInfluence()
            self.uiImageView.image = self.filteredImage?.alpha(CGFloat(sliderCurrentValue))
            selectedShade = 12
            case 13:
            self.filteredImage = self.receivedImage!.filterEffectHueAdjust()
            self.uiImageView.image = self.filteredImage?.alpha(CGFloat(sliderCurrentValue))
            selectedShade = 13
            case 14:
            self.filteredImage = self.receivedImage!.filterEffectRedToGreen()
            self.uiImageView.image = self.filteredImage?.alpha(CGFloat(sliderCurrentValue))
            selectedShade = 14
            case 15:
            self.filteredImage = self.receivedImage!.filterEffectScan()
            self.uiImageView.image = self.filteredImage?.alpha(CGFloat(sliderCurrentValue))
            selectedShade = 15
            case 16:
            self.filteredImage = self.receivedImage!.filterEffectExclusion()
            self.uiImageView.image = self.filteredImage?.alpha(CGFloat(sliderCurrentValue))
            selectedShade = 16
            case 17:
            self.filteredImage = self.receivedImage!.filterEffectLark()
            self.uiImageView.image = self.filteredImage?.alpha(CGFloat(sliderCurrentValue))
            selectedShade = 17
            default:
                break
        }
        
        if let foundView = view.viewWithTag(Int("1\(selectedShade)")!) as? UILabel {
            foundView.textColor = UIColor(hexaRGB: getContentColor(), alpha: 1)
        }
        
        setButtonColorFilters(selectedButtonTag: selectedShade, selectedLabelTag: Int("1\(selectedShade)")!)
    }
    
    @objc func backButtonTapFilters(sender: Any) {
        if let viewController = navigationController?.viewControllers.first(where: {$0 is ViewControllerStyleRedactor}) {
              navigationController?.popToViewController(viewController, animated: false)
        }
    }
    
    @objc func doneButtonTapFilters(sender: Any) {
        if let viewController = navigationController?.viewControllers.first(where: {$0 is ViewControllerStyleRedactor}) {
            
            //NotificationCenter.default.removeObserver(self, name: Notification.Name("com.filteredphoto.success"), object: nil)
            NotificationCenter.default.removeObserver(self)
            let imageDataDict:[String: UIImage] = ["filteredImage": filteredImage!]
            NotificationCenter.default.post(name: Notification.Name("com.filteredphoto.success"), object: nil, userInfo: imageDataDict)
              navigationController?.popToViewController(viewController, animated: false)
        }
    }
    
    @objc func uiSliderValueChange(sender: UISlider) {
        
        let percent: Float?
        sliderCurrentValue = sender.value
        percent = sender.value*100
        labelSliderProgressPercent.text = "\(Int(percent!)) %"
    }
    
    @objc func buttonFilterSliderOKTap(sender: UIButton?) {
        
        uiImageView.image = filteredImage?.alpha(CGFloat(sliderCurrentValue))
    }
    
    @objc func buttonFilterSliderCloseTap(sender: UIButton?) {
        uiImageView.image = filteredImage!
        uiSliderContainer.isHidden = true
    }
    
    func setUpConstraintsFilters() {
        let safeArea = view.safeAreaLayoutGuide
        let scaledSize = calculateImageViewScale(viewSize: self.view.bounds.size, imageSize: receivedImage!.size, leftRightAnchorConstant: 20, topBottomAnchorConstant: 315)
        
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
    
    func layoutTraitFilters(traitCollection:UITraitCollection) {
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
    
    func setConstraintsOfBottomPreviewPanel() {
        
        bottomPreviewPanel.bottomAnchor.constraint(equalTo: masterView.bottomAnchor).isActive = true
        bottomPreviewPanel.widthAnchor.constraint(equalTo: masterView.widthAnchor).isActive = true
        bottomPreviewPanel.heightAnchor.constraint(equalToConstant: 190).isActive = true
        
        indicator.widthAnchor.constraint(equalToConstant: 40).isActive = true
        indicator.heightAnchor.constraint(equalToConstant: 40).isActive = true
        indicator.centerXAnchor.constraint(equalTo: bottomPreviewPanel.centerXAnchor).isActive = true
        indicator.centerYAnchor.constraint(equalTo: bottomPreviewPanel.centerYAnchor).isActive = true
    }
    
    func setButtonColorFilters(selectedButtonTag: Int?, selectedLabelTag: Int?) {
        
        for i in 111...117 {
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
