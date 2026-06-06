//
//  ViewControllerDraw.swift
//  PhotoEditorFilterEffects
//
//  Created by MacBook on 10/26/22.
//

import UIKit
import Combine

class ViewControllerDraw: UIViewController {
    
    var cancellable: AnyCancellable?
    var receivedImage: UIImage?
    var drawonImage: UIImage?
    
    private var compactConstraints: [NSLayoutConstraint] = []
    private var regularConstraints: [NSLayoutConstraint] = []
    private var sharedConstraints: [NSLayoutConstraint] = []
    
    private var isPickingColor: Bool = true
    private var isDrwaing: Bool = false
    private var isErasing: Bool = false
    private var swiped = false
    private var selectionSize: CGFloat = 4.0
    
    private var context: CGContext?
    private var lastPoint = CGPoint.zero
    private var red: CGFloat = 0.0
    private var green: CGFloat = 0.0
    private var blue: CGFloat = 0.0
    private var opacity: CGFloat = 1.0
    
    private var isImageViewTapped: Bool = false
    private var pickedColor: UIColor = UIColor.white
    private var pickedColorRed: CGFloat = 1
    private var pickedColorGreen: CGFloat = 1
    private var pickedColorBlue: CGFloat = 1
    private var pickedColorAlpha: CGFloat = 0.5
    
    private lazy var masterView: UIView = {
        let view = UINib(nibName: "MasterViewDraw", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
        view.frame = UIScreen.main.bounds
        view.backgroundColor = UIColor(hexaRGB: getBackgroundColor())!
        view.translatesAutoresizingMaskIntoConstraints = false
        view.tag = 1
        return view
    }()
    
    private lazy var uiImageView: UIImageView = {
        let view = UIImageView()
        view.image = receivedImage!
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var tempImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var bottomActionPanel: UIScrollView = {
        let customView = UIScrollView()
        customView.isScrollEnabled = true
        customView.contentSize.width = 495.0
        customView.contentSize.height = 55.0
        customView.showsVerticalScrollIndicator = false
        customView.showsHorizontalScrollIndicator = false
        customView.translatesAutoresizingMaskIntoConstraints = false
        customView.backgroundColor = UIColor(hexaRGB: getMenuBackColor())!
        return customView
    }()
    
    private lazy var uiSliderContainer: UIView = {
        let view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = UIColor(hexaRGB: getMenuBackColor())
        view.translatesAutoresizingMaskIntoConstraints = false
        view.semanticContentAttribute = .forceLeftToRight
        return view
    }()
    
    private lazy var labelSliderLabel: UILabel = {
        let view = UILabel()
        view.text = NSLocalizedString("buttonLabelOpacity", comment: "")
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
        view.textAlignment = .right
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
    
    lazy private var buttonPickColor: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        button.setImage(UIImage(named: "img_color_picker")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.layer.cornerRadius = 10
        button.layer.backgroundColor = UIColor(named: "LightBlueA700")?.cgColor
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.white.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setButtonActiveColor(hex: getContentColor(), alpha: 1)
        button.tag = 2
        button.addTarget(self, action: #selector(tabOptionTap), for: .touchUpInside)
        return button
    }()
    
    lazy private var buttonBrush: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        button.setImage(UIImage(named: "img_brush")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setButtonActiveColor(hex: getContentColor(), alpha: 0.6)
        button.tag = 3
        button.addTarget(self, action: #selector(tabOptionTap), for: .touchUpInside)
        return button
    }()
    
    lazy private var buttonEraser: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        button.setImage(UIImage(named: "img_vector")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setButtonActiveColor(hex: getContentColor(), alpha: 0.6)
        button.tag = 9
        button.addTarget(self, action: #selector(tabOptionTap), for: .touchUpInside)
        return button
    }()
    
    lazy private var buttonCircle1: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "img_ellipse36")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setButtonActiveColor(hex: getContentColor(), alpha: 0.6)
        button.tag = 4
        button.addTarget(self, action: #selector(tabOptionTap), for: .touchUpInside)
        return button
    }()
    
    lazy private var buttonCircle2: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "img_ellipse37")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setButtonActiveColor(hex: getContentColor(), alpha: 0.6)
        button.tag = 5
        button.addTarget(self, action: #selector(tabOptionTap), for: .touchUpInside)
        return button
    }()
    
    lazy private var buttonCircle3: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "img_ellipse38")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setButtonActiveColor(hex: getContentColor(), alpha: 0.6)
        button.tag = 6
        button.addTarget(self, action: #selector(tabOptionTap), for: .touchUpInside)
        return button
    }()
    
    lazy private var buttonCircle4: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "img_ellipse39")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setButtonActiveColor(hex: getContentColor(), alpha: 0.6)
        button.tag = 7
        button.addTarget(self, action: #selector(tabOptionTap), for: .touchUpInside)
        return button
    }()
    
    lazy private var buttonCircle5: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "img_ellipse41")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setButtonActiveColor(hex: getContentColor(), alpha: 0.6)
        button.tag = 8
        button.addTarget(self, action: #selector(tabOptionTap), for: .touchUpInside)
        return button
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // ---
        // --- create a resized copy of the original image
        // --- (handles aspect fit scale)
        
        let resizedImage = uiImageView.asImage()
        uiImageView.image = resizedImage
        tempImageView.image = resizedImage

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //handle dark mode
        if #available(iOS 13.0, *) {
            view.overrideUserInterfaceStyle = .light
        }
        
        drawonImage = receivedImage!
        setUpUIDraw()
        setUpConstraintsDraw()
        NSLayoutConstraint.activate(sharedConstraints)
        layoutTraitDraw(traitCollection: UIScreen.main.traitCollection)
    }
    
    func setUpUIDraw() {
        
        setNavBarDraw()
        self.view.backgroundColor = UIColor(hexaRGB: getBackgroundColor())
        view.addSubview(masterView)
        setUpBottomActionPanelDraw()
        setUpBottomSliderPanelDraw()
        
        masterView.addSubview(uiImageView)
        masterView.addSubview(tempImageView)
        
        let gestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageViewTap))
        tempImageView.addGestureRecognizer(gestureRecognizer)
        tempImageView.isUserInteractionEnabled = true
    }
    
    func setNavBarDraw() {
        self.navigationItem.setHidesBackButton(true, animated: false)
        let navTitle = UILabel()
        navTitle.text = NSLocalizedString("navBarTitleDrawVC", comment: "")
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
        leftView.addTarget(self, action: #selector(backButtonTapDraw), for: .allTouchEvents)
        leftButton.customView = leftView
            
        let rightButton = UIBarButtonItem(title: NSLocalizedString("navBarButtonDone", comment: ""), style: .done, target: self, action: #selector(doneButtonTapDraw))
        rightButton.tintColor = UIColor(hexaRGB: getContentColor())!
        rightButton.setTitleTextAttributes(navBarButtonTitleAttributes, for: .normal)
        
        self.navigationItem.leftBarButtonItem  = leftButton
        self.navigationItem.rightBarButtonItem  = rightButton
        
        self.navigationController?.navigationBar.semanticContentAttribute = .forceLeftToRight
    }
    
    func setUpBottomSliderPanelDraw() {
        masterView.addSubview(uiSliderContainer)
        uiSliderContainer.addSubview(labelSliderLabel)
        uiSliderContainer.addSubview(labelSliderProgressPercent)
        uiSliderContainer.addSubview(uiSlider)
        
        NSLayoutConstraint.activate([
            uiSliderContainer.heightAnchor.constraint(equalToConstant: 75),
            uiSliderContainer.bottomAnchor.constraint(equalTo: bottomActionPanel.topAnchor),
            uiSliderContainer.leftAnchor.constraint(equalTo: masterView.leftAnchor),
            uiSliderContainer.rightAnchor.constraint(equalTo: masterView.rightAnchor),
            uiSliderContainer.centerXAnchor.constraint(equalTo: masterView.centerXAnchor),
            
            labelSliderLabel.leftAnchor.constraint(equalTo: uiSliderContainer.leftAnchor, constant: 10.0),
            labelSliderLabel.topAnchor.constraint(equalTo: uiSliderContainer.topAnchor, constant: 10.0),
            labelSliderLabel.widthAnchor.constraint(equalToConstant: 120),
            labelSliderLabel.heightAnchor.constraint(equalToConstant: 25),
            
            labelSliderProgressPercent.trailingAnchor.constraint(equalTo: uiSliderContainer.trailingAnchor, constant: -10.0),
            labelSliderProgressPercent.topAnchor.constraint(equalTo: uiSliderContainer.topAnchor, constant: 10.0),
            labelSliderProgressPercent.widthAnchor.constraint(equalToConstant: 120),
            labelSliderProgressPercent.heightAnchor.constraint(equalToConstant: 25),
            
            uiSlider.topAnchor.constraint(equalTo: labelSliderLabel.bottomAnchor, constant: 5.0),
            uiSlider.widthAnchor.constraint(equalTo: masterView.widthAnchor, constant: -70.0),
            uiSlider.centerXAnchor.constraint(equalTo: masterView.centerXAnchor),
            uiSlider.heightAnchor.constraint(equalToConstant: 50),
        ])
    }
    
    func setUpBottomActionPanelDraw() {
        masterView.addSubview(bottomActionPanel)
        bottomActionPanel.addSubview(buttonPickColor)
        bottomActionPanel.addSubview(buttonBrush)
        bottomActionPanel.addSubview(buttonEraser)
        bottomActionPanel.addSubview(buttonCircle1)
        bottomActionPanel.addSubview(buttonCircle2)
        bottomActionPanel.addSubview(buttonCircle3)
        bottomActionPanel.addSubview(buttonCircle4)
        bottomActionPanel.addSubview(buttonCircle5)
        
        NSLayoutConstraint.activate([
            bottomActionPanel.heightAnchor.constraint(equalToConstant: 100),
            bottomActionPanel.bottomAnchor.constraint(equalTo: masterView.bottomAnchor),
            bottomActionPanel.widthAnchor.constraint(equalTo: masterView.widthAnchor),
            bottomActionPanel.centerXAnchor.constraint(equalTo: masterView.centerXAnchor),
            
            buttonPickColor.leftAnchor.constraint(equalTo: bottomActionPanel.leftAnchor, constant: 30.0),
            buttonPickColor.topAnchor.constraint(equalTo: bottomActionPanel.topAnchor, constant: 15.0),
            buttonPickColor.widthAnchor.constraint(equalToConstant: 40),
            buttonPickColor.heightAnchor.constraint(equalToConstant: 40),
            
            buttonBrush.leftAnchor.constraint(equalTo: buttonPickColor.rightAnchor, constant: 25.0),
            buttonBrush.topAnchor.constraint(equalTo: bottomActionPanel.topAnchor, constant: 15.0),
            buttonBrush.widthAnchor.constraint(equalToConstant: 40),
            buttonBrush.heightAnchor.constraint(equalToConstant: 40),
            
            buttonEraser.leftAnchor.constraint(equalTo: buttonBrush.rightAnchor, constant: 25.0),
            buttonEraser.topAnchor.constraint(equalTo: bottomActionPanel.topAnchor, constant: 15.0),
            buttonEraser.widthAnchor.constraint(equalToConstant: 40),
            buttonEraser.heightAnchor.constraint(equalToConstant: 40),
            
            buttonCircle1.leftAnchor.constraint(equalTo: buttonEraser.rightAnchor, constant: 25.0),
            buttonCircle1.topAnchor.constraint(equalTo: bottomActionPanel.topAnchor, constant: 15.0),
            buttonCircle1.heightAnchor.constraint(equalToConstant: 55),
            
            buttonCircle2.leftAnchor.constraint(equalTo: buttonCircle1.rightAnchor, constant: 25.0),
            buttonCircle2.topAnchor.constraint(equalTo: bottomActionPanel.topAnchor, constant: 15.0),
            buttonCircle2.heightAnchor.constraint(equalToConstant: 55),
            
            buttonCircle3.leftAnchor.constraint(equalTo: buttonCircle2.rightAnchor, constant: 25.0),
            buttonCircle3.topAnchor.constraint(equalTo: bottomActionPanel.topAnchor, constant: 15.0),
            buttonCircle3.heightAnchor.constraint(equalToConstant: 55),
            
            buttonCircle4.leftAnchor.constraint(equalTo: buttonCircle3.rightAnchor, constant: 25.0),
            buttonCircle4.topAnchor.constraint(equalTo: bottomActionPanel.topAnchor, constant: 15.0),
            buttonCircle4.heightAnchor.constraint(equalToConstant: 55),
            
            buttonCircle5.leftAnchor.constraint(equalTo: buttonCircle4.rightAnchor, constant: 25.0),
            buttonCircle5.topAnchor.constraint(equalTo: bottomActionPanel.topAnchor, constant: 15.0),
            buttonCircle5.heightAnchor.constraint(equalToConstant: 55),
        ])
    }
    
    @objc func backButtonTapDraw(sender: Any) {
        if let viewController = navigationController?.viewControllers.first(where: {$0 is ViewControllerStyleRedactor}) {
              navigationController?.popToViewController(viewController, animated: false)
        }
    }
    
    @objc func doneButtonTapDraw(sender: Any) {
        if let viewController = navigationController?.viewControllers.first(where: {$0 is ViewControllerStyleRedactor}) {
            
            //NotificationCenter.default.removeObserver(self, name: Notification.Name("com.drawphoto.success"), object: nil)
            NotificationCenter.default.removeObserver(self)
            let imageDataDict:[String: UIImage] = ["drawonImage": drawonImage!]
            NotificationCenter.default.post(name: Notification.Name("com.drawphoto.success"), object: nil, userInfo: imageDataDict)
              navigationController?.popToViewController(viewController, animated: false)
        }
    }
    
    func setUpConstraintsDraw() {
        
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
            
            tempImageView.topAnchor.constraint(equalTo: masterView.topAnchor, constant: 5),
            tempImageView.widthAnchor.constraint(equalToConstant: masterView.bounds.width-20),
            tempImageView.centerXAnchor.constraint(equalTo: masterView.centerXAnchor),
            tempImageView.heightAnchor.constraint(equalToConstant: scaledSize.height),
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
            
            tempImageView.topAnchor.constraint(equalTo: masterView.topAnchor, constant: 5),
            tempImageView.widthAnchor.constraint(equalToConstant: masterView.bounds.width-20),
            tempImageView.centerXAnchor.constraint(equalTo: masterView.centerXAnchor),
            tempImageView.heightAnchor.constraint(equalToConstant: scaledSize.height),
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
            
            tempImageView.topAnchor.constraint(equalTo: masterView.topAnchor, constant: 5),
            tempImageView.widthAnchor.constraint(equalToConstant: masterView.bounds.width-20),
            tempImageView.centerXAnchor.constraint(equalTo: masterView.centerXAnchor),
            tempImageView.heightAnchor.constraint(equalToConstant: scaledSize.height),
        ])
    }
    
    func layoutTraitDraw(traitCollection:UITraitCollection) {
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
    
    @objc func uiSliderValueChange(sender: UISlider) {
        
        pickedColorAlpha = CGFloat(sender.value)
        let percent: Float = sender.value*100
        labelSliderProgressPercent.text = "\(Int(percent)) %"
    }
    
    @objc func imageViewTap(touch: UITapGestureRecognizer) {
        
        if !isDrwaing && !isErasing {
            isImageViewTapped = true
            touch.location(in: tempImageView)
            let point = touch.location(in: tempImageView)
            pickedColor = uiImageView.getPixelColorAt(point: point)

            pickedColor.getRed(&pickedColorRed, green: &pickedColorGreen, blue: &pickedColorBlue, alpha: &pickedColorAlpha)
            
            let foundView = view.viewWithTag(4) as? UIButton
            foundView?.tintColor = UIColor(red: pickedColorRed, green: pickedColorGreen, blue: pickedColorBlue, alpha: 1)
            foundView?.imageView?.layer.cornerRadius = 5
            foundView?.imageView?.layer.borderWidth = 1
            foundView?.imageView?.layer.borderColor = UIColor.white.cgColor
            
            for i in 5...8 {
                if let foundView = view.viewWithTag(i) as? UIButton {
                    foundView.tintColor = UIColor(red: pickedColorRed, green: pickedColorGreen, blue: pickedColorBlue, alpha: 0.6)
                }
            }
        }
    }
    
    func openColorPickerDialog() {
        let picker = UIColorPickerViewController()
        picker.selectedColor = self.pickedColor
        
        //  Subscribing selectedColor property changes.
        self.cancellable = picker.publisher(for: \.selectedColor)
            .sink { color in
                
                //  Changing view color on main thread.
                DispatchQueue.main.async {
                    self.isPickingColor = true
                    self.isImageViewTapped = true
                    self.pickedColor = color
                    self.pickedColor.getRed(&self.pickedColorRed, green: &self.pickedColorGreen, blue: &self.pickedColorBlue, alpha: &self.pickedColorAlpha)
                    
                    let foundView = self.view.viewWithTag(4) as? UIButton
                    foundView?.tintColor = UIColor(red: self.pickedColorRed, green: self.pickedColorGreen, blue: self.pickedColorBlue, alpha: 1)
                    foundView?.imageView?.layer.cornerRadius = 5
                    foundView?.imageView?.layer.borderWidth = 1
                    foundView?.imageView?.layer.borderColor = UIColor.white.cgColor
                    
                    for i in 5...8 {
                        if let foundView = self.view.viewWithTag(i) as? UIButton {
                            foundView.imageView?.layer.borderWidth = 1
                            foundView.imageView?.layer.borderColor = UIColor.clear.cgColor
                            foundView.tintColor = UIColor(red: self.pickedColorRed, green: self.pickedColorGreen, blue: self.pickedColorBlue, alpha: 0.6)
                        }
                    }
                }
            }
        
        self.present(picker, animated: true, completion: nil)
    }
    
    @objc func tabOptionTap(sender: UIButton) {
        let selectedTag = sender.tag
        
        switch sender.tag {
        case 2:
            isPickingColor = true
            isDrwaing = false
            isErasing = false
            setToolButtonActiveColor(selectedButtonTag: selectedTag)
            openColorPickerDialog()
        case 3:
            isPickingColor = false
            isDrwaing = true
            isErasing = false
            setToolButtonActiveColor(selectedButtonTag: selectedTag)
        case 4:
            selectionSize = 4.0
            setPencilSizeButtonActiveColor(selectedButtonTag: selectedTag)
        case 5:
            selectionSize = 8.0
            setPencilSizeButtonActiveColor(selectedButtonTag: selectedTag)
        case 6:
            selectionSize = 12.0
            setPencilSizeButtonActiveColor(selectedButtonTag: selectedTag)
        case 7:
            selectionSize = 16.0
            setPencilSizeButtonActiveColor(selectedButtonTag: selectedTag)
        case 8:
            selectionSize = 20.0
            setPencilSizeButtonActiveColor(selectedButtonTag: selectedTag)
        case 9:
            isPickingColor = false
            isDrwaing = false
            isErasing = true
            setEraserButtonActiveColor(selectedButtonTag: selectedTag)
        default:
            break
        }
    }
    
    func setToolButtonActiveColor(selectedButtonTag: Int?) {
        
        if let foundView = view.viewWithTag(selectedButtonTag!) as? UIButton {
            foundView.setButtonActiveColor(hex: getContentColor(), alpha: 1)
            foundView.layer.cornerRadius = 10
            foundView.layer.backgroundColor = UIColor(named: "LightBlueA700")?.cgColor
            foundView.layer.borderWidth = 2
            foundView.layer.borderColor = UIColor.white.cgColor
            foundView.bounds.size.width = 55.0
            foundView.bounds.size.height = 55.0
        }
        
        for i in 2...3 {
            if i != selectedButtonTag {
                if let foundView = view.viewWithTag(i) as? UIButton {
                    foundView.setButtonActiveColor(hex: getContentColor(), alpha: 0.6)
                    foundView.layer.backgroundColor = UIColor.clear.cgColor
                    foundView.layer.borderWidth = 0
                    foundView.layer.borderColor = UIColor.clear.cgColor
                }
            }
        }
        
        if let foundView = view.viewWithTag(9) as? UIButton {
            foundView.setButtonActiveColor(hex: getContentColor(), alpha: 0.6)
            foundView.layer.backgroundColor = UIColor.clear.cgColor
            foundView.layer.borderWidth = 0
            foundView.layer.borderColor = UIColor.clear.cgColor
        }
    }
    
    func setEraserButtonActiveColor(selectedButtonTag: Int?) {
        
        if let foundView = view.viewWithTag(9) as? UIButton {
            foundView.setButtonActiveColor(hex: getContentColor(), alpha: 1)
            foundView.layer.cornerRadius = 10
            foundView.layer.backgroundColor = UIColor(named: "LightBlueA700")?.cgColor
            foundView.layer.borderWidth = 2
            foundView.layer.borderColor = UIColor.white.cgColor
            foundView.bounds.size.width = 55.0
            foundView.bounds.size.height = 55.0
        }
        
        for i in 2...3 {
            if i != selectedButtonTag {
                if let foundView = view.viewWithTag(i) as? UIButton {
                    foundView.setButtonActiveColor(hex: getContentColor(), alpha: 0.6)
                    foundView.layer.backgroundColor = UIColor.clear.cgColor
                    foundView.layer.borderWidth = 0
                    foundView.layer.borderColor = UIColor.clear.cgColor
                }
            }
        }
    }
    
    func setPencilSizeButtonActiveColor(selectedButtonTag: Int?) {
        
        for i in 4...8 {
            if i != selectedButtonTag {
                if let foundView = view.viewWithTag(i) as? UIButton {
                    if isPickingColor || isImageViewTapped {
                        foundView.tintColor = UIColor(red: pickedColorRed, green: pickedColorGreen, blue: pickedColorBlue, alpha: 0.6)
                    } else {
                        foundView.setButtonActiveColor(hex: getContentColor(), alpha: 0.6)
                    }
                    foundView.imageView?.layer.borderWidth = 0
                    foundView.imageView?.layer.borderColor = UIColor.clear.cgColor
                }
            } else {
                if let foundView = view.viewWithTag(i) as? UIButton {
                    if isPickingColor || isImageViewTapped {
                        foundView.tintColor = UIColor(red: pickedColorRed, green: pickedColorGreen, blue: pickedColorBlue, alpha: 1)
                    } else {
                        foundView.setButtonActiveColor(hex: getContentColor(), alpha: 1)
                    }
                    foundView.imageView?.layer.cornerRadius = 5
                    foundView.imageView?.layer.borderWidth = 1
                    foundView.imageView?.layer.borderColor = UIColor.white.cgColor
                }
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isPickingColor {
            swiped = false
        
            if let touch = touches.first {
                lastPoint = touch.location(in: tempImageView)
            }
            
            /*if isErasing {
                self.tempImageView.image = self.uiImageView.image
                self.uiImageView.image = nil
            }*/
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if !isPickingColor {
            swiped = true
            let rect = tempImageView.bounds
            if let touch = touches.first {
                let currentPoint = touch.location(in: tempImageView)
                if currentPoint.y >= rect.maxY-10 || currentPoint.y <= 10 {
                    
                    // Merge tempImageView into mainImageView
                    UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
                    //UIGraphicsBeginImageContext(rect.size)
                    uiImageView.image?.draw(in: rect, blendMode: .normal, alpha: 1.0)
                    tempImageView.image?.draw(in: rect, blendMode: .normal, alpha: opacity)
                    uiImageView.image = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()

                    tempImageView.image = nil
                } else {
                    drawLineFrom(fromPoint: lastPoint, toPoint: currentPoint)

                    lastPoint = currentPoint
                }
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !swiped {
            drawLineFrom(fromPoint: lastPoint, toPoint: lastPoint)
        }

        let rect = tempImageView.bounds
        // Merge tempImageView into mainImageView
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        context = UIGraphicsGetCurrentContext()!
        
        uiImageView.image?.draw(in: rect, blendMode: .normal, alpha: 1.0)
        tempImageView.image?.draw(in: rect, blendMode: .normal, alpha: opacity)
        
        pickedColor = UIColor(red: pickedColorRed, green: pickedColorGreen, blue: pickedColorBlue, alpha: pickedColorAlpha)
        if isErasing {
            context?.setBlendMode(.copy)
        } else {
            if isDrwaing {
                context?.setStrokeColor(red: pickedColorRed, green: pickedColorGreen, blue: pickedColorBlue, alpha: pickedColorAlpha)
                context?.setBlendMode(.normal)
                context?.setShadow(offset: CGSize(width: 3, height: 3), blur: selectionSize/1.5, color: UIColor.white.cgColor)
            }
        }
        context?.setLineWidth(selectionSize)
        context?.setLineCap(.round)

        // 4
        context?.strokePath()
        context?.flush()
        
        uiImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        tempImageView.image = nil
        
        drawonImage = uiImageView.image
    }

    func drawLineFrom(fromPoint: CGPoint, toPoint: CGPoint) {
        
        let rect = tempImageView.bounds
        
        if toPoint.y <= rect.maxY {
            UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
            context = UIGraphicsGetCurrentContext()!
            tempImageView.image?.draw(in: rect)

            // 2
            context?.move(to: CGPoint(x: fromPoint.x, y: fromPoint.y))
            context?.addLine(to: CGPoint(x: toPoint.x, y: toPoint.y))

            // 3
            pickedColor = UIColor(red: pickedColorRed, green: pickedColorGreen, blue: pickedColorBlue, alpha: pickedColorAlpha)
            if isErasing {
                context?.setBlendMode(.copy)
            } else {
                if isDrwaing {
                    context?.setStrokeColor(red: pickedColorRed, green: pickedColorGreen, blue: pickedColorBlue, alpha: pickedColorAlpha)
                    context?.setBlendMode(.normal)
                    context?.setShadow(offset: CGSize(width: 3, height: 3), blur: selectionSize/1.5, color: UIColor.white.cgColor)
                }
            }
            context?.setLineWidth(selectionSize)
            context?.setLineCap(.round)

            // 4
            context?.strokePath()

            // 5
            let image = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
            tempImageView.image = image
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
