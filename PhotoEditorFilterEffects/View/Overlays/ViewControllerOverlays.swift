//
//  ViewControllerOverlays.swift
//  PhotoEditorFilterEffects
//
//  Created by Sonjoy Borkakoty on 02/11/22.
//

import UIKit

class ViewControllerOverlays: UIViewController {
    
    private var compactConstraints: [NSLayoutConstraint] = []
    private var regularConstraints: [NSLayoutConstraint] = []
    private var sharedConstraints: [NSLayoutConstraint] = []
    
    var receivedImage: UIImage?
    var overlaysImage: UIImage?
    var overlayImageName: String?
    
    private var topConstraint: NSLayoutConstraint!
    private var rightConstraint: NSLayoutConstraint!
    private var leftConstraint: NSLayoutConstraint!
    private var bottomConstraint: NSLayoutConstraint!
    private var borderBox = UIView()
    private var strokeBorder = CAShapeLayer()
    private var buttonClose = UIButton()
    private var buttonRotate = UIButton()
    private var isPanGestureRecognizerTouched: Bool = false
    private var scaledSize: CGSize = CGSize(width: 0.0, height: 0.0)
    
    struct OverlayRectangle {
        var overlayTopTouch = false
        var overlayLeftTouch = false
        var overlayRightTouch = false
        var overlayBottomTouch = false
        var overlayMiddleTouch = false
    }
    
    private var touchStart = CGPoint.zero
    private var proxyFactor = CGFloat(10)
    private var overlayRect = OverlayRectangle()
    private var cropRect = CGRect.zero
    private var initialBounds = CGRect.zero
    private var initialDistance:CGFloat = 0
    private var deltaAngle: Float = 0
    private var angleDiff: Float = 0.0
    private var defaultInset:NSInteger = 0
    private var defaultMinimumSize:NSInteger = 0
    private var minimumSize:NSInteger = 0
    
    private var dragDropX: CGFloat?
    private var dragDropY: CGFloat?
    
    private var selectedShade: Int = 12
    private var selectedOverlayImageName: String = ""
    
    private lazy var masterView: UIView = {
        let view = UINib(nibName: "MasterViewOverlay", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
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
    
    lazy var bottomPreviewPanel: UIScrollView = {
        let customView = UIScrollView()
        customView.isScrollEnabled = true
        customView.contentSize.width = 710.0
        customView.showsHorizontalScrollIndicator = false
        customView.translatesAutoresizingMaskIntoConstraints = false
        customView.backgroundColor = UIColor(hexaRGB: getMenuBackColor())!
        customView.tag = 21
        return customView
    }()
    
    private lazy var labelOVR1: UILabel = {
        let view = UILabel()
        view.text = "OVR 1"
        view.tag = 112
        view.translatesAutoresizingMaskIntoConstraints = false
        //view.backgroundColor = hexStringToUIColor(hex: "#33DDFF")
        view.textColor = UIColor(hexaRGB: getContentColor(), alpha: 1)
        view.textAlignment = .center
        view.font = UIFont.preferredFont(forTextStyle: .title3)
        view.adjustsFontForContentSizeCategory = true
        return view
    }()
    
    private lazy var labelOVR2: UILabel = {
        let view = UILabel()
        view.text = "OVR 2"
        view.tag = 113
        view.translatesAutoresizingMaskIntoConstraints = false
        //view.backgroundColor = hexStringToUIColor(hex: "#33DDFF")
        view.textColor = UIColor(hexaRGB: getContentColor(), alpha: 0.6)
        view.textAlignment = .center
        view.font = UIFont.preferredFont(forTextStyle: .title3)
        view.adjustsFontForContentSizeCategory = true
        return view
    }()
    
    private lazy var labelOVR3: UILabel = {
        let view = UILabel()
        view.text = "OVR 3"
        view.tag = 114
        view.translatesAutoresizingMaskIntoConstraints = false
        //view.backgroundColor = hexStringToUIColor(hex: "#33DDFF")
        view.textColor = UIColor(hexaRGB: getContentColor(), alpha: 0.6)
        view.textAlignment = .center
        view.font = UIFont.preferredFont(forTextStyle: .title3)
        view.adjustsFontForContentSizeCategory = true
        return view
    }()
    
    private lazy var labelOVR4: UILabel = {
        let view = UILabel()
        view.text = "OVR 4"
        view.tag = 115
        view.translatesAutoresizingMaskIntoConstraints = false
        //view.backgroundColor = hexStringToUIColor(hex: "#33DDFF")
        view.textColor = UIColor(hexaRGB: getContentColor(), alpha: 0.6)
        view.textAlignment = .center
        view.font = UIFont.preferredFont(forTextStyle: .title3)
        view.adjustsFontForContentSizeCategory = true
        return view
    }()
    
    private lazy var labelOVR5: UILabel = {
        let view = UILabel()
        view.text = "OVR 5"
        view.tag = 116
        view.translatesAutoresizingMaskIntoConstraints = false
        //view.backgroundColor = hexStringToUIColor(hex: "#33DDFF")
        view.textColor = UIColor(hexaRGB: getContentColor(), alpha: 0.6)
        view.textAlignment = .center
        view.font = UIFont.preferredFont(forTextStyle: .title3)
        view.adjustsFontForContentSizeCategory = true
        return view
    }()
    
    private lazy var labelOVR6: UILabel = {
        let view = UILabel()
        view.text = "OVR 6"
        view.tag = 117
        view.translatesAutoresizingMaskIntoConstraints = false
        //view.backgroundColor = hexStringToUIColor(hex: "#33DDFF")
        view.textColor = UIColor(hexaRGB: getContentColor(), alpha: 0.6)
        view.textAlignment = .center
        view.font = UIFont.preferredFont(forTextStyle: .title3)
        view.adjustsFontForContentSizeCategory = true
        return view
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let resizedImage = uiImageView.asImage()
        uiImageView.image = resizedImage
        //receivedImage = resizedImage
    }
    
    override func viewDidLayoutSubviews() {
        strokeBorder.frame = borderBox.bounds
        strokeBorder.path = UIBezierPath(rect: borderBox.bounds).cgPath
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //handle dark mode
        if #available(iOS 13.0, *) {
            view.overrideUserInterfaceStyle = .light
        }
        
        overlaysImage = receivedImage
        
        setUpUIOverlay()
        
        setUpConstraintsOverlay()
        NSLayoutConstraint.activate(sharedConstraints)
        layoutTraitOverlay(traitCollection: UIScreen.main.traitCollection)
    }
    
    func setUpUIOverlay() {
        setNavBarOverlay()
        masterView.addSubview(uiImageView)
        self.view.backgroundColor = UIColor(hexaRGB: getBackgroundColor())
        view.addSubview(masterView)
        setUpBottomPreviewPanelOverlay()
        setUpBorderBoxOverlay()
        borderBox.isHidden = true
    }
    
    func setNavBarOverlay() {
        
        self.navigationItem.setHidesBackButton(true, animated: false)
        let navTitle = UILabel()
        navTitle.text = NSLocalizedString("buttonLabelOverlays", comment: "")
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
        leftView.addTarget(self, action: #selector(backButtonTapOverlay), for: .allTouchEvents)
        leftButton.customView = leftView
            
        let rightButton = UIBarButtonItem(title: NSLocalizedString("navBarButtonDone", comment: ""), style: .done, target: self, action: #selector(doneButtonTapOverlay))
        rightButton.tintColor = UIColor(hexaRGB: getContentColor())!
        rightButton.setTitleTextAttributes(navBarButtonTitleAttributes, for: .normal)
        
        self.navigationItem.leftBarButtonItem  = leftButton
        self.navigationItem.rightBarButtonItem  = rightButton
        
        self.navigationController?.navigationBar.semanticContentAttribute = .forceLeftToRight
    }
    
    func setUpBorderBoxOverlay() {
        self.defaultInset = 11
        self.defaultMinimumSize = 4 * self.defaultInset
        self.minimumSize = self.defaultMinimumSize
        
        borderBox.translatesAutoresizingMaskIntoConstraints = false
        borderBox.isUserInteractionEnabled = true
        borderBox.tag = 61
        view.addSubview(borderBox) // not added to masterView otherwise masterView's layout constraints will not allows to adjust height of borderBox
        borderBox.semanticContentAttribute = .forceLeftToRight
        
        let safeArea = view.safeAreaLayoutGuide
        rightConstraint = NSLayoutConstraint(item: safeArea, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: borderBox, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1, constant: 15)
        bottomConstraint = NSLayoutConstraint(item: safeArea, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: borderBox, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: getRelativeHeight(220.0))
        leftConstraint = NSLayoutConstraint(item: borderBox, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: safeArea, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1, constant: 15)
        topConstraint = NSLayoutConstraint(item: borderBox, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: safeArea, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: getRelativeHeight(15.0))
        NSLayoutConstraint.activate([rightConstraint, bottomConstraint, leftConstraint, topConstraint])
        
        buttonClose = UIButton(frame: CGRect(x: borderBox.frame.width-12, y: -12, width: 24, height: 24))
        buttonClose.tag = 62
        buttonClose.addTarget(self, action: #selector(buttonBorderBoxCloseTap), for: .allTouchEvents)
        buttonClose.translatesAutoresizingMaskIntoConstraints = false
        buttonClose.setImage(UIImage(named: "img_group82")?.withRenderingMode(.alwaysOriginal), for: .normal)
        
        buttonRotate = UIButton(frame: CGRect(x: borderBox.frame.minX-12, y: borderBox.frame.height-12, width: 24, height: 24))
        buttonRotate.translatesAutoresizingMaskIntoConstraints = false
        buttonRotate.setImage(UIImage(named: "img_group654")?.withRenderingMode(.alwaysOriginal), for: .normal)
        buttonRotate.contentMode = .center
        buttonRotate.isUserInteractionEnabled = true
        buttonRotate.tag = 63
        
        strokeBorder = CAShapeLayer()
        strokeBorder.strokeColor = UIColor.white.cgColor
        strokeBorder.lineWidth = 3
        strokeBorder.lineDashPattern = [7, 7]
        strokeBorder.fillColor = UIColor.clear.cgColor
        
        strokeBorder.frame = borderBox.bounds
        strokeBorder.path = UIBezierPath(rect: borderBox.bounds).cgPath
        borderBox.layer.addSublayer(strokeBorder)
        borderBox.addSubview(buttonClose)
        borderBox.addSubview(buttonRotate)
        
        let rotationGesture = UIPanGestureRecognizer(target: self, action:#selector(self.rotationGestureOverlayTap(recognizer:)))
        buttonRotate.addGestureRecognizer(rotationGesture)
        
        let closeButtonTopConstraint = NSLayoutConstraint(item: buttonClose, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: borderBox, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: -12)
        let closeButtonRightConstraint = NSLayoutConstraint(item: buttonClose, attribute: NSLayoutConstraint.Attribute.right, relatedBy: NSLayoutConstraint.Relation.equal, toItem: borderBox, attribute: NSLayoutConstraint.Attribute.right, multiplier: 1, constant: 12)
        NSLayoutConstraint.activate([closeButtonTopConstraint, closeButtonRightConstraint])
        
        let rotateButtonTopConstraint = NSLayoutConstraint(item: buttonRotate, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: borderBox, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: -12)
        let rotateButtonLeftConstraint = NSLayoutConstraint(item: buttonRotate, attribute: NSLayoutConstraint.Attribute.left, relatedBy: NSLayoutConstraint.Relation.equal, toItem: borderBox, attribute: NSLayoutConstraint.Attribute.left, multiplier: 1, constant: -12)
        NSLayoutConstraint.activate([rotateButtonTopConstraint, rotateButtonLeftConstraint])
        
        let point = borderBox.frame.origin
        dragDropX = point.x
        dragDropY = point.y
    }
    
    @objc func buttonBorderBoxCloseTap(sender: UIButton) {
        
        removeBorderBoxFromOverlayView()
    }
    
    func setUpBottomPreviewPanelOverlay() {
        
        masterView.addSubview(bottomPreviewPanel)
        
        let imageButtonOVR1 = UIButton(frame: CGRect(x: 10.0, y: 10.0, width: 105, height: 125))
        imageButtonOVR1.tag = 12
        imageButtonOVR1.backgroundColor = UIColor(hexaRGB: "#899A9A", alpha: 1.0)
        imageButtonOVR1.addTarget(self, action: #selector(setImageOverlay), for: .touchUpInside)
        let imageViewOVR1 = UIImageView(frame: CGRect(x: 5, y: 5, width: 95, height: 115))
        imageViewOVR1.image = UIImage(named: "img_ovr1")?.withRenderingMode(.alwaysOriginal)
        imageButtonOVR1.addSubview(imageViewOVR1)
        bottomPreviewPanel.addSubview(imageButtonOVR1)
        
        let imageButtonOVR2 = UIButton(frame: CGRect(x: 125.0, y: 10.0, width: 105, height: 125))
        imageButtonOVR2.tag = 13
        imageButtonOVR2.backgroundColor = UIColor(hexaRGB: "#899A9A", alpha: 1.0)
        imageButtonOVR2.addTarget(self, action: #selector(setImageOverlay), for: .touchUpInside)
        let imageViewOVR2 = UIImageView(frame: CGRect(x: 5, y: 5, width: 95, height: 115))
        imageViewOVR2.image = UIImage(named: "img_ovr2")?.withRenderingMode(.alwaysOriginal)
        imageButtonOVR2.addSubview(imageViewOVR2)
        bottomPreviewPanel.addSubview(imageButtonOVR2)
        
        let imageButtonOVR3 = UIButton(frame: CGRect(x: 240.0, y: 10.0, width: 105, height: 125))
        imageButtonOVR3.tag = 14
        imageButtonOVR3.backgroundColor = UIColor(hexaRGB: "#899A9A", alpha: 1.0)
        imageButtonOVR3.addTarget(self, action: #selector(setImageOverlay), for: .touchUpInside)
        let imageViewOVR3 = UIImageView(frame: CGRect(x: 5, y: 5, width: 95, height: 115))
        imageViewOVR3.image = UIImage(named: "img_ovr3")?.withRenderingMode(.alwaysOriginal)
        imageButtonOVR3.addSubview(imageViewOVR3)
        bottomPreviewPanel.addSubview(imageButtonOVR3)
        
        let imageButtonOVR4 = UIButton(frame: CGRect(x: 355.0, y: 10.0, width: 105, height: 125))
        imageButtonOVR4.tag = 15
        imageButtonOVR4.backgroundColor = UIColor(hexaRGB: "#899A9A", alpha: 1.0)
        imageButtonOVR4.addTarget(self, action: #selector(setImageOverlay), for: .touchUpInside)
        let imageViewOVR4 = UIImageView(frame: CGRect(x: 5, y: 5, width: 95, height: 115))
        imageViewOVR4.image = UIImage(named: "img_ovr4")?.withRenderingMode(.alwaysOriginal)
        imageButtonOVR4.addSubview(imageViewOVR4)
        bottomPreviewPanel.addSubview(imageButtonOVR4)
        
        let imageButtonOVR5 = UIButton(frame: CGRect(x: 470.0, y: 10.0, width: 105, height: 125))
        imageButtonOVR5.tag = 16
        imageButtonOVR5.backgroundColor = UIColor(hexaRGB: "#899A9A", alpha: 1.0)
        imageButtonOVR5.addTarget(self, action: #selector(setImageOverlay), for: .touchUpInside)
        let imageViewOVR5 = UIImageView(frame: CGRect(x: 5, y: 5, width: 95, height: 115))
        imageViewOVR5.image = UIImage(named: "img_ovr5")?.withRenderingMode(.alwaysOriginal)
        imageButtonOVR5.addSubview(imageViewOVR5)
        bottomPreviewPanel.addSubview(imageButtonOVR5)
        
        let imageButtonOVR6 = UIButton(frame: CGRect(x: 585.0, y: 10.0, width: 105, height: 125))
        imageButtonOVR6.tag = 17
        imageButtonOVR6.backgroundColor = UIColor(hexaRGB: "#899A9A", alpha: 1.0)
        imageButtonOVR6.addTarget(self, action: #selector(setImageOverlay), for: .touchUpInside)
        let imageViewOVR6 = UIImageView(frame: CGRect(x: 5, y: 5, width: 95, height: 115))
        imageViewOVR6.image = UIImage(named: "img_ovr6")?.withRenderingMode(.alwaysOriginal)
        imageButtonOVR6.addSubview(imageViewOVR6)
        bottomPreviewPanel.addSubview(imageButtonOVR6)
        
        bottomPreviewPanel.addSubview(labelOVR1)
        bottomPreviewPanel.addSubview(labelOVR2)
        bottomPreviewPanel.addSubview(labelOVR3)
        bottomPreviewPanel.addSubview(labelOVR4)
        bottomPreviewPanel.addSubview(labelOVR5)
        bottomPreviewPanel.addSubview(labelOVR6)
        
        labelOVR1.topAnchor.constraint(equalTo: imageButtonOVR1.bottomAnchor, constant: 5).isActive = true
        labelOVR1.centerXAnchor.constraint(equalTo: imageButtonOVR1.centerXAnchor).isActive = true
        
        labelOVR2.topAnchor.constraint(equalTo: imageButtonOVR2.bottomAnchor, constant: 5).isActive = true
        labelOVR2.centerXAnchor.constraint(equalTo: imageButtonOVR2.centerXAnchor).isActive = true
        
        labelOVR3.topAnchor.constraint(equalTo: imageButtonOVR3.bottomAnchor, constant: 5).isActive = true
        labelOVR3.centerXAnchor.constraint(equalTo: imageButtonOVR3.centerXAnchor).isActive = true
        
        labelOVR4.topAnchor.constraint(equalTo: imageButtonOVR4.bottomAnchor, constant: 5).isActive = true
        labelOVR4.centerXAnchor.constraint(equalTo: imageButtonOVR4.centerXAnchor).isActive = true
        
        labelOVR5.topAnchor.constraint(equalTo: imageButtonOVR5.bottomAnchor, constant: 5).isActive = true
        labelOVR5.centerXAnchor.constraint(equalTo: imageButtonOVR5.centerXAnchor).isActive = true
        
        labelOVR6.topAnchor.constraint(equalTo: imageButtonOVR6.bottomAnchor, constant: 5).isActive = true
        labelOVR6.centerXAnchor.constraint(equalTo: imageButtonOVR6.centerXAnchor).isActive = true
        
        bottomPreviewPanel.bottomAnchor.constraint(equalTo: masterView.bottomAnchor).isActive = true
        bottomPreviewPanel.widthAnchor.constraint(equalTo: masterView.widthAnchor).isActive = true
        bottomPreviewPanel.heightAnchor.constraint(equalToConstant: 190).isActive = true
    }
    
    @objc func setImageOverlay(sender: UIButton) {
        
        angleDiff = 0
        dragDropX = 0
        dragDropY = 0
        
        switch sender.tag {
            case 12:
            self.selectedOverlayImageName = "img_ovr1"
            selectedShade = 12
            case 13:
            self.selectedOverlayImageName = "img_ovr2"
            selectedShade = 13
            case 14:
            self.selectedOverlayImageName = "img_ovr3"
            selectedShade = 14
            case 15:
            self.selectedOverlayImageName = "img_ovr4"
            selectedShade = 15
            case 16:
            self.selectedOverlayImageName = "img_ovr5"
            selectedShade = 16
            case 17:
            self.selectedOverlayImageName = "img_ovr6"
            selectedShade = 17
            default:
                break
        }
        
        if let foundView = view.viewWithTag(selectedShade) as? UIButton {
            foundView.setButtonActiveColor(hex: getContentColor(), alpha: 1)
        }
        if let foundView = view.viewWithTag(Int("1\(selectedShade)")!) as? UILabel {
            foundView.textColor = UIColor(hexaRGB: getContentColor(), alpha: 1)
        }
        
        setButtonColorOverlay(selectedButtonTag: selectedShade, selectedLabelTag: Int("1\(selectedShade)")!)
        
        removeBorderBoxFromOverlayView()
        setUpBorderBoxOverlay()
        borderBox.isHidden = false
        overlayImageOnBorderbox()
    }
    
    func overlayImageOnBorderbox() {
        
        if let foundView = self.view.viewWithTag(71) as? UIImageView {
            foundView.removeFromSuperview()
        }
        
        let cropImage = UIImage(named: self.selectedOverlayImageName)
        let cropImageView = UIImageView(frame: self.borderBox.bounds)
        cropImageView.tag = 71
        cropImageView.image = cropImage
        self.borderBox.addSubview(cropImageView)
    }
    
    func removeBorderBoxFromOverlayView() {
        
        if let foundView = view.viewWithTag(71) {
            foundView.removeFromSuperview()
        }
        if let foundView = view.viewWithTag(63) {
            foundView.removeFromSuperview()
        }
        
        if let foundView = view.viewWithTag(62) {
            foundView.removeFromSuperview()
        }
        strokeBorder.removeAllAnimations()
        strokeBorder.removeFromSuperlayer()
        strokeBorder.frame = borderBox.bounds
        strokeBorder.path = UIBezierPath(rect: borderBox.bounds).cgPath
        strokeBorder.transform = view.transform3D
        
        if let foundView = view.viewWithTag(61) {
            foundView.transform = CGAffineTransform(rotationAngle: CGFloat(0))
            foundView.removeFromSuperview()
        }
    }
    
    @objc func backButtonTapOverlay(sender: Any) {
        if let viewController = navigationController?.viewControllers.first(where: {$0 is ViewControllerStyleRedactor}) {
              navigationController?.popToViewController(viewController, animated: false)
        }
    }
    
    @objc func doneButtonTapOverlay(sender: Any) {
        
        if !selectedOverlayImageName.isEmpty {
            let image = UIImage(named: selectedOverlayImageName)
            overlaysImage = createOverlayCroppedImage(image: image)
            //uiImageView.image = overlaysImage
        }
        
        removeBorderBoxFromOverlayView()
        
        if let viewController = navigationController?.viewControllers.first(where: {$0 is ViewControllerStyleRedactor}) {
            
            //NotificationCenter.default.removeObserver(self, name: Notification.Name("com.overlaysphoto.success"), object: nil)
            NotificationCenter.default.removeObserver(self)
            let imageDataDict:[String: UIImage] = ["overlaysImage": overlaysImage!]
            NotificationCenter.default.post(name: Notification.Name("com.overlaysphoto.success"), object: nil, userInfo: imageDataDict)
              navigationController?.popToViewController(viewController, animated: false)
        }
    }
    
    func setUpConstraintsOverlay() {
        
        let safeArea = view.safeAreaLayoutGuide
        scaledSize = calculateImageViewScale(viewSize: self.view.bounds.size, imageSize: receivedImage!.size, leftRightAnchorConstant: 30, topBottomAnchorConstant: 195)
        
        sharedConstraints.append(contentsOf: [
            masterView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            masterView.leftAnchor.constraint(equalTo: safeArea.leftAnchor),
            masterView.rightAnchor.constraint(equalTo: safeArea.rightAnchor),
            masterView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            uiImageView.topAnchor.constraint(equalTo: masterView.topAnchor, constant: 15),
            uiImageView.leftAnchor.constraint(equalTo: masterView.leftAnchor, constant: 15),
            uiImageView.widthAnchor.constraint(equalTo: masterView.widthAnchor, constant: -30),
            uiImageView.heightAnchor.constraint(equalToConstant: scaledSize.height),
        ])
        
        regularConstraints.append(contentsOf: [
            masterView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            masterView.leftAnchor.constraint(equalTo: safeArea.leftAnchor),
            masterView.rightAnchor.constraint(equalTo: safeArea.rightAnchor),
            masterView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            uiImageView.topAnchor.constraint(equalTo: masterView.topAnchor, constant: 15),
            uiImageView.leftAnchor.constraint(equalTo: masterView.leftAnchor, constant: 15),
            uiImageView.widthAnchor.constraint(equalTo: masterView.widthAnchor, constant: -30),
            uiImageView.heightAnchor.constraint(equalToConstant: scaledSize.height),
        ])
        
        compactConstraints.append(contentsOf: [
            masterView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            masterView.leftAnchor.constraint(equalTo: safeArea.leftAnchor),
            masterView.rightAnchor.constraint(equalTo: safeArea.rightAnchor),
            masterView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            uiImageView.topAnchor.constraint(equalTo: masterView.topAnchor, constant: 15),
            uiImageView.leftAnchor.constraint(equalTo: masterView.leftAnchor, constant: 15),
            uiImageView.widthAnchor.constraint(equalTo: masterView.widthAnchor, constant: -30),
            uiImageView.heightAnchor.constraint(equalToConstant: scaledSize.height),
        ])
    }
    
    func layoutTraitOverlay(traitCollection:UITraitCollection) {
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
    
    func setButtonColorOverlay(selectedButtonTag: Int?, selectedLabelTag: Int?) {
        
        for i in 12...17 {
            if i != selectedButtonTag {
                if let foundView = view.viewWithTag(i) as? UIButton {
                    foundView.setButtonActiveColor(hex: getContentColor(), alpha: 0.6)
                }
            }
        }
        
        for i in 112...117 {
            if i != selectedLabelTag {
                if let foundView = view.viewWithTag(i) as? UILabel {
                    foundView.textColor = UIColor(hexaRGB: getContentColor(), alpha: 0.6)
                }
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first{
            
            if isPanGestureRecognizerTouched {
                isPanGestureRecognizerTouched = false
                return
            }
            
            let touchStart = touch.location(in: self.view)
            
            overlayRect.overlayTopTouch = false
            overlayRect.overlayLeftTouch = false
            overlayRect.overlayRightTouch = false
            overlayRect.overlayBottomTouch = false
            overlayRect.overlayMiddleTouch = false
            
            if  touchStart.y > borderBox.frame.minY + (proxyFactor*2) &&  touchStart.y < borderBox.frame.maxY - (proxyFactor*2) &&  touchStart.x > borderBox.frame.minX + (proxyFactor*2) &&  touchStart.x < borderBox.frame.maxX - (proxyFactor*2){
                overlayRect.overlayMiddleTouch = true
                return
            }
            
            if touchStart.y > borderBox.frame.maxY - proxyFactor &&  touchStart.y < borderBox.frame.maxY + proxyFactor {
                overlayRect.overlayBottomTouch = true
            }
            
            if touchStart.x > borderBox.frame.maxX - proxyFactor && touchStart.x < borderBox.frame.maxX + proxyFactor {
                overlayRect.overlayRightTouch = true
            }
            
            if touchStart.x > borderBox.frame.minX - proxyFactor &&  touchStart.x < borderBox.frame.minX + proxyFactor {
                overlayRect.overlayLeftTouch = true
            }
            
            if touchStart.y > borderBox.frame.minY - proxyFactor &&  touchStart.y < borderBox.frame.minY + proxyFactor {
                overlayRect.overlayTopTouch = true
            }
            
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first{
            let currentTouchPoint = touch.location(in: self.view)
            let previousTouchPoint = touch.previousLocation(in: self.view)
            
            let deltaX = currentTouchPoint.x - previousTouchPoint.x
            let deltaY = currentTouchPoint.y - previousTouchPoint.y
            
            if overlayRect.overlayMiddleTouch{
                topConstraint.constant += deltaY
                leftConstraint.constant += deltaX
                rightConstraint.constant -= deltaX
                bottomConstraint.constant -= deltaY
            }
            
            if overlayRect.overlayTopTouch {
                topConstraint.constant += deltaY
            }
            
            if overlayRect.overlayLeftTouch {
                leftConstraint.constant += deltaX
            }
            if overlayRect.overlayRightTouch {
                rightConstraint.constant -= deltaX
            }
            if overlayRect.overlayBottomTouch {
                bottomConstraint.constant -= deltaY
            }
            
            UIView.animate(withDuration: 0.25, delay: 0, options: UIView.AnimationOptions.curveEaseIn, animations: {
                self.view.layoutIfNeeded()
                
                self.dragDropX = self.leftConstraint.constant
                self.dragDropY = self.topConstraint.constant
            }, completion: { (ended) in
                if let foundView = self.view.viewWithTag(71) as? UIImageView {
                    foundView.removeFromSuperview()
                }
                self.cropRect = CGRect(x: self.leftConstraint.constant, y: self.topConstraint.constant, width: self.borderBox.bounds.width, height: self.borderBox.bounds.height)
                //print("cropRect: \(self.cropRect)")
                let cropImage = UIImage(named: self.selectedOverlayImageName)
                let cropImageView = UIImageView(frame: self.borderBox.bounds)
                cropImageView.tag = 71
                cropImageView.image = cropImage
                self.borderBox.addSubview(cropImageView)
                self.strokeBorder.path = UIBezierPath(rect: self.borderBox.bounds).cgPath
            })
        }
    }
    
    @objc func rotationGestureOverlayTap(recognizer: UIPanGestureRecognizer) {
        
        let touchLocation = recognizer.location(in: borderBox.superview)
        let center = borderBox.center
        
        switch recognizer.state {
        case .began:
            self.deltaAngle = Float(CGFloat(atan2f(Float(touchLocation.y - center.y), Float(touchLocation.x - center.x))) - CalculateFunctions.CGAffineTransformGetAngle(borderBox.transform))
            self.initialBounds = borderBox.bounds
            self.initialDistance = CalculateFunctions.CGpointGetDistance(center, point2: touchLocation)
        case .changed:
            let angle = atan2f(Float(touchLocation.y - center.y), Float(touchLocation.x - center.x))
            self.angleDiff = self.deltaAngle - angle
            borderBox.transform = CGAffineTransform(rotationAngle: CGFloat(-angleDiff))
            
            var scale = CalculateFunctions.CGpointGetDistance(center, point2: touchLocation) / self.initialDistance
            let minimumScale = CGFloat(self.minimumSize) / min(self.initialBounds.size.width, self.initialBounds.size.height)
            scale = max(scale, minimumScale)
            let scaledBounds = CalculateFunctions.CGRectScale(self.initialBounds, wScale: scale, hScale: scale)
            borderBox.bounds = scaledBounds
            borderBox.setNeedsDisplay()
            borderBox.layoutIfNeeded()
            let point = borderBox.frame.origin
            dragDropX = point.x
            dragDropY = point.y
        case .ended:
            let point = borderBox.frame.origin
            dragDropX = point.x
            dragDropY = point.y
        default:
            break
        }
    }
    
    /*func createOverlayImage(imageName: String?) -> UIImage {
        
        let topImage = UIImage(named: imageName!)!
        let viewSize = uiImageView.bounds.size
        let imageSize = receivedImage!.size

        let xScale = imageSize.width > 0 ? viewSize.width / imageSize.width : 1
        let yScale = imageSize.height > 0 ? viewSize.height / imageSize.height : 1
        let scale = (xScale > 0 && yScale > 0) ? min (xScale, yScale) : 1 // aspect fit, use "max" for aspect fill
        let scaledSize = CGSize (width: scale * imageSize.width, height: scale * imageSize.height)

        UIGraphicsBeginImageContextWithOptions (scaledSize, true, 0)
       
        receivedImage!.draw(in: CGRect(x: 0, y: 0, width: scaledSize.width, height: scaledSize.height))
        topImage.draw(in: CGRect(x: 0, y: 0, width: scaledSize.width, height: scaledSize.height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }*/
    
    func createOverlayCroppedImage(image: UIImage?) -> UIImage {
        let viewSize = uiImageView.bounds.size
        let imageSize = receivedImage!.size
        
        let xScale = imageSize.width > 0 ? viewSize.width / imageSize.width : 1
        let yScale = imageSize.height > 0 ? viewSize.height / imageSize.height : 1
        let scale = (xScale > 0 && yScale > 0) ? min (xScale, yScale) : 1
        let scaledSize = CGSize (width: scale * imageSize.width, height: scale * imageSize.height)

        UIGraphicsBeginImageContextWithOptions(scaledSize, false, 0)
        
        receivedImage!.draw(in: CGRect(x: 0, y: 0, width: scaledSize.width, height: scaledSize.height))
        //print("\(dragDropX!) X \(dragDropY!)")
        let rotatedImage = image!.rotated(angleDiff: CGFloat(angleDiff), flipped: false)
        if scaledSize.width > scaledSize.height {
            let heightDiff = (viewSize.height - scaledSize.height)/2
            let yPosition = heightDiff + (dragDropY!-15)
            rotatedImage!.draw(in: CGRect(x: (dragDropX!-10), y: yPosition, width: borderBox.bounds.width, height: borderBox.bounds.height))
        } else {
            rotatedImage!.draw(in: CGRect(x: (dragDropX!-10), y: (dragDropY!-15), width: borderBox.bounds.width, height: borderBox.bounds.height))
        }
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
        
        /* let viewSize = uiImageView.bounds.size
        let imageSize = receivedImage!.size
        
        let xScale = imageSize.width > 0 ? viewSize.width / imageSize.width : 1
        let yScale = imageSize.height > 0 ? viewSize.height / imageSize.height : 1
        let scale = (xScale > 0 && yScale > 0) ? min (xScale, yScale) : 1
        //"\(xScale) X \(yScale)")
        let scaledSize = CGSize (width: scale * imageSize.width, height: scale * imageSize.height)

        UIGraphicsBeginImageContextWithOptions(scaledSize, true, 0)
        
        receivedImage!.draw(in: CGRect(x: 0, y: 0, width: scaledSize.width, height: scaledSize.height))
        if let context = UIGraphicsGetCurrentContext() {
            let newSize: CGRect = CGRect(origin: CGPoint.zero, size: uiImageView.bounds.size).applying(CGAffineTransform(rotationAngle: -CGFloat(angleDiff)))
            // Move origin to middle
            context.translateBy(x: newSize.width/2, y: newSize.height/2)
            // Rotate around middle
            context.rotate(by: -CGFloat(angleDiff))
            //context.scaleBy(x: xScale, y: -yScale)
            image!.draw(at: CGPoint(x: (-uiImageView.bounds.size.width/2)+dragDropX!, y: (-uiImageView.bounds.size.height/2)+dragDropY!))
        }
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage! */
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
