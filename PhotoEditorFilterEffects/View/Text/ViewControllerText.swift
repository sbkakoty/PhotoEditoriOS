//
//  ViewControllerText.swift
//  PhotoEditorFilterEffects
//
//  Created by MacBook on 10/28/22.
//

import UIKit
import Combine
import IQLabelView

class ViewControllerText: UIViewController, IQLabelViewDelegate {
    
    private var compactConstraints: [NSLayoutConstraint] = []
    private var regularConstraints: [NSLayoutConstraint] = []
    private var sharedConstraints: [NSLayoutConstraint] = []
    var receivedImage: UIImage?
    var textedImage: UIImage?
    
    private var cancellable: AnyCancellable?
    private var angleDiff: CGFloat = 0
    private var dragDropX: CGFloat?
    private var dragDropY: CGFloat?
    
    private lazy var masterView: UIView = {
        let view = UINib(nibName: "MasterViewText", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
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
    
    private lazy var bottomActionPanel: UIView = {
        let bottomActionPanel = UIView()
        bottomActionPanel.backgroundColor = UIColor(hexaRGB: getMenuBackColor())!
        bottomActionPanel.translatesAutoresizingMaskIntoConstraints = false
        bottomActionPanel.backgroundColor = UIColor(hexaRGB: getMenuBackColor())!
        return bottomActionPanel
    }()
    
    lazy private var buttonAddText: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "img_group649")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setButtonActiveColor(hex: getContentColor(), alpha: 1)
        button.tag = 2
        button.addTarget(self, action: #selector(buttonAddTextPressed), for: .touchUpInside)
        return button
    }()
    
    lazy private var buttonFontStyle: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "img_group648")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setButtonActiveColor(hex: getContentColor(), alpha: 0.6)
        button.tag = 3
        button.addTarget(self, action: #selector(buttonFontStyleTap), for: .touchUpInside)
        return button
    }()
    
    lazy private var buttonTextColor: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "img_group650")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setButtonActiveColor(hex: getContentColor(), alpha: 0.6)
        button.tag = 4
        button.addTarget(self, action: #selector(buttonTextColorTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var uiSliderContainer: UIView = {
        let view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = UIColor(hexaRGB: getMenuBackColor())
        view.translatesAutoresizingMaskIntoConstraints = false
        view.semanticContentAttribute = .forceLeftToRight
        view.isHidden = true
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
        button.addTarget(self, action: #selector(buttonPickColorTapTextVC), for: .touchUpInside)
        return button
    }()
    
    private lazy var textOverlayView: IQLabelView = {
        let view = IQLabelView(frame: CGRect())
        view.attributedPlaceholder = NSAttributedString.init(string: NSLocalizedString("placeholder", comment: ""), attributes: [NSAttributedString.Key.foregroundColor : UIColor(hexaRGB: getBackgroundColor())!,  NSAttributedString.Key.font: UIFont(name: "TimesNewRomanPSMT", size: 28)!])
        view.delegate = self
        view.showsContentShadow = false
        view.isEnableMoveRestriction = false
        view.isEnableRotate = true
        view.closeImage = UIImage(named: "cancel")
        view.rotateImage = UIImage(named: "rotate-option")
        view.fontSize = 28.0
        view.borderColor = UIColor.white
        view.textColor = UIColor(hexaRGB: getBackgroundColor())!
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var currIQLabel = IQLabelView()
    private var iqLabels: [IQLabelView] = []
    
    private var fontPicker: UIAlertController?
    private var selectedFontName = "TimesNewRomanPSMT"
    private var selectedFontColor = UIColor(hexaRGB: getBackgroundColor())!
    private var selectedFontSize = 28.0
    private var attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.foregroundColor : UIColor(hexaRGB: getBackgroundColor())!,  NSAttributedString.Key.font: UIFont(name: "TimesNewRomanPSMT", size: 28)!]
    private var pickedColor: UIColor = UIColor(hexaRGB: getBackgroundColor())!
    private var pickedColorAlpha: CGFloat = 0.5
    private var pickedColorRed: CGFloat = 0
    private var pickedColorGreen: CGFloat = 0
    private var pickedColorBlue: CGFloat = 0
    
    var keyboardAdjusted = false
    var lastKeyboardOffset: CGFloat = 0.0

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        if keyboardAdjusted == false {
            lastKeyboardOffset = getPopupKeyboardHeight(notification: notification)
            uiImageView.frame.origin.y -= (lastKeyboardOffset-240)
            keyboardAdjusted = true
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if keyboardAdjusted == true {
            uiImageView.frame.origin.y += (lastKeyboardOffset-240)
            keyboardAdjusted = false
        }
    }

    func getPopupKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let resizedImage = uiImageView.asImage()
        uiImageView.image = resizedImage
        //receivedImage = resizedImage
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //handle dark mode
        if #available(iOS 13.0, *) {
            view.overrideUserInterfaceStyle = .light
        }
        
        textedImage = receivedImage
        setUpUIText()
        
        setUpConstraintsText()
        NSLayoutConstraint.activate(sharedConstraints)
        layoutTraitText(traitCollection: UIScreen.main.traitCollection)
    }
    
    func setUpUIText() {
        
        setNavBarText()
        self.view.backgroundColor = UIColor(hexaRGB: getBackgroundColor())
        view.addSubview(masterView)
        setUpBottomActionPanelText()
        setUpBottomSliderPanelText()
        masterView.addSubview(uiImageView)
    }
    
    func setUpOverlayText() {
        uiImageView.addSubview(textOverlayView)
        uiImageView.isUserInteractionEnabled = true
        currIQLabel = textOverlayView
        iqLabels.append(textOverlayView)
        
        let panGesture = UIPanGestureRecognizer(target: self, action:(#selector(handleGestureTextVC(_:))))
        textOverlayView.addGestureRecognizer(panGesture)
        
        let attributedText = NSAttributedString.init(string: NSLocalizedString("placeholder", comment: ""), attributes: attributes)
        
        textOverlayView.attributedPlaceholder = attributedText
        textOverlayView.textColor = selectedFontColor
        textOverlayView.fontSize = selectedFontSize
        textOverlayView.fontName = selectedFontName
        
        let rectWidth = textOverlayView.bounds.width-20
        
        textOverlayView.centerXAnchor.constraint(equalTo: uiImageView.centerXAnchor).isActive = true
        textOverlayView.centerYAnchor.constraint(equalTo: uiImageView.centerYAnchor).isActive = true
        textOverlayView.widthAnchor.constraint(equalToConstant: rectWidth).isActive = true
        textOverlayView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        dragDropX = textOverlayView.center.x
        dragDropY = textOverlayView.center.y
    }
    
    func setNavBarText() {
        
        self.navigationItem.setHidesBackButton(true, animated: false)
        let navTitle = UILabel()
        navTitle.text = NSLocalizedString("navBarTitleTextVC", comment: "")
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
        leftView.addTarget(self, action: #selector(backButtonTapText), for: .allTouchEvents)
        leftButton.customView = leftView
            
        let rightButton = UIBarButtonItem(title: NSLocalizedString("navBarButtonDone", comment: ""), style: .done, target: self, action: #selector(doneButtonTapText))
        rightButton.tintColor = UIColor(hexaRGB: getContentColor())!
        rightButton.setTitleTextAttributes(navBarButtonTitleAttributes, for: .normal)
        
        self.navigationItem.leftBarButtonItem  = leftButton
        self.navigationItem.rightBarButtonItem  = rightButton
        
        self.navigationController?.navigationBar.semanticContentAttribute = .forceLeftToRight
    }
    
    func setUpBottomSliderPanelText() {
        masterView.addSubview(uiSliderContainer)
        uiSliderContainer.addSubview(buttonPickColor)
        uiSliderContainer.addSubview(labelSliderLabel)
        uiSliderContainer.addSubview(labelSliderProgressPercent)
        uiSliderContainer.addSubview(uiSlider)
        
        NSLayoutConstraint.activate([
            uiSliderContainer.heightAnchor.constraint(equalToConstant: 75),
            uiSliderContainer.bottomAnchor.constraint(equalTo: bottomActionPanel.topAnchor),
            uiSliderContainer.leftAnchor.constraint(equalTo: masterView.leftAnchor),
            uiSliderContainer.rightAnchor.constraint(equalTo: masterView.rightAnchor),
            uiSliderContainer.centerXAnchor.constraint(equalTo: masterView.centerXAnchor),
            
            buttonPickColor.leftAnchor.constraint(equalTo: uiSliderContainer.leftAnchor, constant: 10.0),
            buttonPickColor.topAnchor.constraint(equalTo: uiSliderContainer.topAnchor, constant: 35.0),
            buttonPickColor.widthAnchor.constraint(equalToConstant: 40),
            buttonPickColor.heightAnchor.constraint(equalToConstant: 40),
            
            labelSliderLabel.leftAnchor.constraint(equalTo: buttonPickColor.rightAnchor, constant: 10.0),
            labelSliderLabel.topAnchor.constraint(equalTo: uiSliderContainer.topAnchor, constant: 10.0),
            labelSliderLabel.widthAnchor.constraint(equalToConstant: 100),
            labelSliderLabel.heightAnchor.constraint(equalToConstant: 25),
            
            labelSliderProgressPercent.trailingAnchor.constraint(equalTo: uiSliderContainer.trailingAnchor, constant: -10.0),
            labelSliderProgressPercent.topAnchor.constraint(equalTo: uiSliderContainer.topAnchor, constant: 10.0),
            labelSliderProgressPercent.widthAnchor.constraint(equalToConstant: 70),
            labelSliderProgressPercent.heightAnchor.constraint(equalToConstant: 25),
            
            uiSlider.leftAnchor.constraint(equalTo: buttonPickColor.rightAnchor, constant: 10.0),
            uiSlider.topAnchor.constraint(equalTo: labelSliderLabel.bottomAnchor, constant: 1.0),
            uiSlider.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width-120),
            uiSlider.heightAnchor.constraint(equalToConstant: 50),
        ])
    }
    
    func setUpBottomActionPanelText() {
        
        masterView.addSubview(bottomActionPanel)
        bottomActionPanel.addSubview(buttonAddText)
        bottomActionPanel.addSubview(buttonFontStyle)
        bottomActionPanel.addSubview(buttonTextColor)
        
        NSLayoutConstraint.activate([
            bottomActionPanel.bottomAnchor.constraint(equalTo: masterView.bottomAnchor),
            bottomActionPanel.widthAnchor.constraint(equalTo: masterView.widthAnchor),
            bottomActionPanel.centerXAnchor.constraint(equalTo: masterView.centerXAnchor),
            bottomActionPanel.heightAnchor.constraint(equalToConstant: 100),
            
            buttonAddText.leftAnchor.constraint(equalTo: bottomActionPanel.leftAnchor, constant: 50.0),
            buttonAddText.bottomAnchor.constraint(equalTo: bottomActionPanel.bottomAnchor, constant: 0.0),
            buttonAddText.heightAnchor.constraint(equalToConstant: 100),
            
            buttonFontStyle.centerXAnchor.constraint(equalTo: bottomActionPanel.centerXAnchor),
            buttonFontStyle.bottomAnchor.constraint(equalTo: bottomActionPanel.bottomAnchor, constant: 0.0),
            buttonFontStyle.heightAnchor.constraint(equalToConstant: 100),
            
            buttonTextColor.rightAnchor.constraint(equalTo: bottomActionPanel.rightAnchor, constant: -50.0),
            buttonTextColor.bottomAnchor.constraint(equalTo: bottomActionPanel.bottomAnchor, constant: 0.0),
            buttonTextColor.heightAnchor.constraint(equalToConstant: 100)
            
        ])
    }
    
    func suffleButtonActiveColorText(buttonIndex: Int?) {
        
        switch buttonIndex! {
            case 0:
            buttonAddText.setButtonActiveColor(hex: getContentColor(), alpha: 0.8)
                buttonFontStyle.setButtonActiveColor(hex: getContentColor(), alpha: 0.6)
                buttonTextColor.setButtonActiveColor(hex: getContentColor(), alpha: 0.3)
            case 1:
                buttonAddText.setButtonActiveColor(hex: getContentColor(), alpha: 0.3)
                buttonFontStyle.setButtonActiveColor(hex: getContentColor(), alpha: 1)
                buttonTextColor.setButtonActiveColor(hex: getContentColor(), alpha: 0.3)
            case 2:
                buttonAddText.setButtonActiveColor(hex: getContentColor(), alpha: 0.3)
                buttonFontStyle.setButtonActiveColor(hex: getContentColor(), alpha: 0.6)
                buttonTextColor.setButtonActiveColor(hex: getContentColor(), alpha: 0.8)
            default:
                buttonAddText.setButtonActiveColor(hex: getContentColor(), alpha: 0.8)
                buttonFontStyle.setButtonActiveColor(hex: getContentColor(), alpha: 0.6)
                buttonTextColor.setButtonActiveColor(hex: getContentColor(), alpha: 0.3)
        }
    }
    
    @objc func backButtonTapText(sender: Any) {
        if let viewController = navigationController?.viewControllers.first(where: {$0 is ViewControllerStyleRedactor}) {
              navigationController?.popToViewController(viewController, animated: false)
        }
    }
    
    @objc func doneButtonTapText(sender: Any) {
        dragDropX = textOverlayView.center.x
        dragDropY = textOverlayView.center.y
        
        angleDiff = currIQLabel.getAngleDiff
        self.selectedFontSize = currIQLabel.getFontSize()
        
        if let uiTextField = currIQLabel.subviews.first as? UITextField {
            let textToBeDraw = uiTextField.text?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
            
            let attributedTextToBeDraw = NSAttributedString(string: textToBeDraw!, attributes: [NSAttributedString.Key.foregroundColor : self.selectedFontColor,  NSAttributedString.Key.font: UIFont(name: self.selectedFontName, size: self.selectedFontSize)!])
            
            let viewSize = uiImageView.bounds.size
            let imageSize = receivedImage!.size
            
            let xScale = imageSize.width > 0 ? viewSize.width / imageSize.width : 1
            let yScale = imageSize.height > 0 ? viewSize.height / imageSize.height : 1
            let scale = (xScale > 0 && yScale > 0) ? min (xScale, yScale) : 1
            let scaledSize = CGSize (width: scale * imageSize.width, height: scale * imageSize.height)

            UIGraphicsBeginImageContextWithOptions(scaledSize, false, 0)
            receivedImage!.draw(in: CGRect(x: 0, y: 0, width: scaledSize.width, height: scaledSize.height))
            let textSize = attributedTextToBeDraw.size()
            if let context = UIGraphicsGetCurrentContext() {
                let translation: CGAffineTransform?
                if scaledSize.width > scaledSize.height {
                    let heightDiff = (viewSize.height - scaledSize.height)/2
                    translation = CGAffineTransform(translationX: dragDropX!-10, y: (dragDropY!-heightDiff)-5)
                } else {
                    translation = CGAffineTransform(translationX: dragDropX!-10, y: (dragDropY!)-5)
                }
                let rotation: CGAffineTransform = CGAffineTransform(rotationAngle: -CGFloat(angleDiff))
                context.concatenate(translation!)
                //context.scaleBy(x: 1, y: -1)
                context.concatenate(rotation)
                attributedTextToBeDraw.draw(at: CGPoint(x: (-textSize.width/2), y: (-textSize.height/2)))
                context.concatenate(rotation.inverted())
                context.concatenate(translation!.inverted())
            }
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            uiImageView.image = newImage
            receivedImage = newImage
            textedImage = newImage
            uiTextField.text = nil
        }
        
        if let viewController = navigationController?.viewControllers.first(where: {$0 is ViewControllerStyleRedactor}) {
            
            textOverlayView.removeFromSuperview()
            currIQLabel.removeFromSuperview()
            iqLabels.removeAll()
            
            //NotificationCenter.default.removeObserver(self, name: Notification.Name("com.textphoto.success"), object: nil)
            NotificationCenter.default.removeObserver(self)
            let imageDataDict:[String: UIImage] = ["textedImage": textedImage!]
            NotificationCenter.default.post(name: Notification.Name("com.textphoto.success"), object: nil, userInfo: imageDataDict)
              navigationController?.popToViewController(viewController, animated: false)
        }
    }
    
    @objc func buttonAddTextPressed(sender: Any) {
        suffleButtonActiveColorText(buttonIndex: 0)
        uiSliderContainer.isHidden = true
        setUpOverlayText()
    }
    
    @objc func buttonFontStyleTap(sender: Any) {
        suffleButtonActiveColorText(buttonIndex: 1)
        uiSliderContainer.isHidden = true
        
        fontPicker = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        fontPicker?.setBackgroundColor(color: UIColor(named: "Gray800")!)
        
        let font1Action = UIAlertAction(title: NSLocalizedString("sampleFont", comment: ""), style: .default , handler:{ (UIAlertAction)in
            self.selectedFontName = "ClickerScript-Regular"
            self.selectedFontSize = 28.0
            let font = UIFont(name: self.selectedFontName, size: self.selectedFontSize)
            self.attributes = [NSAttributedString.Key.foregroundColor : self.selectedFontColor,  NSAttributedString.Key.font: font!]
            self.textOverlayView.attributedPlaceholder = NSAttributedString.init(string: NSLocalizedString("placeholder", comment: ""), attributes: self.attributes)
            self.textOverlayView.fontName = "ClickerScript-Regular"
            self.textOverlayView.fontSize = self.selectedFontSize
            self.textOverlayView.layoutIfNeeded()
        })

        font1Action.setValue(UIColor.white, forKey: "titleTextColor")
        fontPicker?.addAction(font1Action)
        
        let font2Action = UIAlertAction(title: NSLocalizedString("sampleFont", comment: ""), style: .default , handler:{ (UIAlertAction)in
            self.textOverlayView.fontName = "BerkshireSwash-Regular"
            self.selectedFontName = "BerkshireSwash-Regular"
            self.selectedFontSize = 28.0
            let font = UIFont(name: self.selectedFontName, size: self.selectedFontSize)
            self.attributes = [NSAttributedString.Key.foregroundColor : self.selectedFontColor,  NSAttributedString.Key.font: font!]
            self.textOverlayView.attributedPlaceholder = NSAttributedString.init(string: NSLocalizedString("placeholder", comment: ""), attributes: self.attributes)
            self.textOverlayView.fontSize = self.selectedFontSize
            self.textOverlayView.layoutIfNeeded()
        })
        font2Action.setValue(UIColor.white, forKey: "titleTextColor")
        fontPicker?.addAction(font2Action)
        
        let font3Action = UIAlertAction(title: NSLocalizedString("sampleFont", comment: ""), style: .default , handler:{ (UIAlertAction)in
            self.textOverlayView.fontName = "Corben-Regular"
            self.selectedFontName = "Corben-Regular"
            self.selectedFontSize = 28.0
            let font = UIFont(name: self.selectedFontName, size: self.selectedFontSize)
            self.attributes = [NSAttributedString.Key.foregroundColor : self.selectedFontColor,  NSAttributedString.Key.font: font!]
            self.textOverlayView.attributedPlaceholder = NSAttributedString.init(string: NSLocalizedString("placeholder", comment: ""), attributes: self.attributes)
            self.textOverlayView.fontSize = self.selectedFontSize
            self.textOverlayView.layoutIfNeeded()
        })
        font3Action.setValue(UIColor.white, forKey: "titleTextColor")
        fontPicker?.addAction(font3Action)
        
        let font4Action = UIAlertAction(title: NSLocalizedString("sampleFont", comment: ""), style: .default , handler:{ (UIAlertAction)in
            self.textOverlayView.fontName = "Chango-Regular"
            self.selectedFontName = "Chango-Regular"
            self.selectedFontSize = 22.0
            let font = UIFont(name: self.selectedFontName, size: self.selectedFontSize)
            self.attributes = [NSAttributedString.Key.foregroundColor : self.selectedFontColor,  NSAttributedString.Key.font: font!]
            self.textOverlayView.attributedPlaceholder = NSAttributedString.init(string: NSLocalizedString("placeholder", comment: ""), attributes: self.attributes)
            self.textOverlayView.fontSize = self.selectedFontSize
            self.textOverlayView.layoutIfNeeded()
        })
        font4Action.setValue(UIColor.white, forKey: "titleTextColor")
        fontPicker?.addAction(font4Action)
        
        let font5Action = UIAlertAction(title: NSLocalizedString("sampleFont", comment: ""), style: .default , handler:{ (UIAlertAction)in
            self.textOverlayView.fontName = "Calligraffitti-Regular"
            self.selectedFontName = "Calligraffitti-Regular"
            self.selectedFontSize = 28.0
            let font = UIFont(name: self.selectedFontName, size: self.selectedFontSize)
            self.attributes = [NSAttributedString.Key.foregroundColor : self.selectedFontColor,  NSAttributedString.Key.font: font!]
            self.textOverlayView.attributedPlaceholder = NSAttributedString.init(string: NSLocalizedString("placeholder", comment: ""), attributes: self.attributes)
            self.textOverlayView.fontSize = self.selectedFontSize
            self.textOverlayView.layoutIfNeeded()
        })
        font5Action.setValue(UIColor.white, forKey: "titleTextColor")
        fontPicker?.addAction(font5Action)
        
        let font6Action = UIAlertAction(title: NSLocalizedString("sampleFont", comment: ""), style: .default , handler:{ (UIAlertAction)in
            self.textOverlayView.fontName = "DawningofaNewDay"
            self.selectedFontName = "DawningofaNewDay"
            self.selectedFontSize = 38.0
            let font = UIFont(name: self.selectedFontName, size: self.selectedFontSize)
            self.attributes = [NSAttributedString.Key.foregroundColor : self.selectedFontColor,  NSAttributedString.Key.font: font!]
            self.textOverlayView.attributedPlaceholder = NSAttributedString.init(string: NSLocalizedString("placeholder", comment: ""), attributes: self.attributes)
            self.textOverlayView.fontSize = self.selectedFontSize
            self.textOverlayView.layoutIfNeeded()
        })
        font6Action.setValue(UIColor.white, forKey: "titleTextColor")
        fontPicker?.addAction(font6Action)
        
        let font7Action = UIAlertAction(title: NSLocalizedString("sampleFont", comment: ""), style: .default , handler:{ (UIAlertAction)in
            self.textOverlayView.fontName = "JuliusSansOne-Regular"
            self.selectedFontName = "JuliusSansOne-Regular"
            self.selectedFontSize = 28.0
            let font = UIFont(name: self.selectedFontName, size: self.selectedFontSize)
            self.attributes = [NSAttributedString.Key.foregroundColor : self.selectedFontColor,  NSAttributedString.Key.font: font!]
            self.textOverlayView.attributedPlaceholder = NSAttributedString.init(string: NSLocalizedString("placeholder", comment: ""), attributes: self.attributes)
            self.textOverlayView.fontSize = self.selectedFontSize
            self.textOverlayView.layoutIfNeeded()
        })
        font7Action.setValue(UIColor.white, forKey: "titleTextColor")
        fontPicker?.addAction(font7Action)
        
        let font8Action = UIAlertAction(title: NSLocalizedString("sampleFont", comment: ""), style: .default , handler:{ (UIAlertAction)in
            self.textOverlayView.fontName = "AtomicAge-Regular"
            self.selectedFontName = "AtomicAge-Regular"
            self.selectedFontSize = 28.0
            let font = UIFont(name: self.selectedFontName, size: self.selectedFontSize)
            self.attributes = [NSAttributedString.Key.foregroundColor : self.selectedFontColor,  NSAttributedString.Key.font: font!]
            self.textOverlayView.attributedPlaceholder = NSAttributedString.init(string: NSLocalizedString("placeholder", comment: ""), attributes: self.attributes)
            self.textOverlayView.fontSize = self.selectedFontSize
            self.textOverlayView.layoutIfNeeded()
        })
        font8Action.setValue(UIColor.white, forKey: "titleTextColor")
        fontPicker?.addAction(font8Action)
        
        //uncomment for iPad Support
        fontPicker?.popoverPresentationController?.sourceView = self.view
        fontPicker?.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 1, height: 1);
        
        let font1ActionAttributedText = NSAttributedString(string: NSLocalizedString("sampleFont", comment: ""), attributes: [NSAttributedString.Key.font : UIFont(name: "ClickerScript-Regular", size: 28.0)!])
        
        let font2ActionAttributedText = NSAttributedString(string: NSLocalizedString("sampleFont", comment: ""), attributes: [NSAttributedString.Key.font : UIFont(name: "BerkshireSwash-Regular", size: 28.0)!])
        
        let font3ActionAttributedText = NSAttributedString(string: NSLocalizedString("sampleFont", comment: ""), attributes: [NSAttributedString.Key.font : UIFont(name: "Corben-Regular", size: 26.0)!])
        
        let font4ActionAttributedText = NSAttributedString(string: NSLocalizedString("sampleFont", comment: ""), attributes: [NSAttributedString.Key.font : UIFont(name: "Chango-Regular", size: 22.0)!])
        
        let font5ActionAttributedText = NSAttributedString(string: NSLocalizedString("sampleFont", comment: ""), attributes: [NSAttributedString.Key.font : UIFont(name: "Calligraffitti-Regular", size: 28.0)!])
        
        let font6ActionAttributedText = NSAttributedString(string: NSLocalizedString("sampleFont", comment: ""), attributes: [NSAttributedString.Key.font : UIFont(name: "DawningofaNewDay", size: 38.0)!])
        
        let font7ActionAttributedText = NSAttributedString(string: NSLocalizedString("sampleFont", comment: ""), attributes: [NSAttributedString.Key.font : UIFont(name: "JuliusSansOne-Regular", size: 28.0)!])
        
        let font8ActionAttributedText = NSAttributedString(string: NSLocalizedString("sampleFont", comment: ""), attributes: [NSAttributedString.Key.font : UIFont(name: "AtomicAge-Regular", size: 28.0)!])
        
        if let bottomConstraint = fontPicker?.view.subviews[0].subviews.last?.constraints.first(where: { ($0.firstAttribute == .bottom) }) {
            bottomConstraint.constant = bottomConstraint.constant - 66
        }
        
        // width constraint
        let constraintWidth = NSLayoutConstraint(
            item: fontPicker!.view!, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute:
                NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: UIScreen.main.bounds.width)
        fontPicker?.view.addConstraint(constraintWidth)
        
        self.present(fontPicker!, animated: true, completion: { [self] in
            
            guard let label1 = (font1Action.value(forKey: "__representer") as AnyObject).value(forKey: "label") as? UILabel else { return }
            label1.attributedText = font1ActionAttributedText
            guard let label2 = (font2Action.value(forKey: "__representer") as AnyObject).value(forKey: "label") as? UILabel else { return }
            label2.attributedText = font2ActionAttributedText
            guard let label3 = (font3Action.value(forKey: "__representer") as AnyObject).value(forKey: "label") as? UILabel else { return }
            label3.attributedText = font3ActionAttributedText
            guard let label4 = (font4Action.value(forKey: "__representer") as AnyObject).value(forKey: "label") as? UILabel else { return }
            label4.attributedText = font4ActionAttributedText
            guard let label5 = (font5Action.value(forKey: "__representer") as AnyObject).value(forKey: "label") as? UILabel else { return }
            label5.attributedText = font5ActionAttributedText
            guard let label6 = (font6Action.value(forKey: "__representer") as AnyObject).value(forKey: "label") as? UILabel else { return }
            label6.attributedText = font6ActionAttributedText
            guard let label7 = (font7Action.value(forKey: "__representer") as AnyObject).value(forKey: "label") as? UILabel else { return }
            label7.attributedText = font7ActionAttributedText
            guard let label8 = (font8Action.value(forKey: "__representer") as AnyObject).value(forKey: "label") as? UILabel else { return }
            label8.attributedText = font8ActionAttributedText
            
            fontPicker?.view.superview?.subviews.first?.isUserInteractionEnabled = true

            // Adding Tap Gesture to Overlay
            fontPicker?.view.superview?.subviews.first?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
        })
        //fontPicker.view.bottomAnchor.constraint(equalTo: bottomActionPanel.topAnchor).isActive = true
    }
    
    @objc func alertControllerBackgroundTapped()
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func buttonTextColorTap(sender: Any) {
        suffleButtonActiveColorText(buttonIndex: 2)
        uiSliderContainer.isHidden = false
    }
    
    @objc func uiSliderValueChange(sender: UISlider) {
        
        pickedColorAlpha = CGFloat(sender.value)
        let percent: Float = sender.value*100
        labelSliderProgressPercent.text = "\(Int(percent)) %"
        
        self.selectedFontColor = UIColor(red: self.pickedColorRed, green: self.pickedColorGreen, blue: self.pickedColorBlue, alpha: self.pickedColorAlpha)
        self.textOverlayView.textColor = self.selectedFontColor
        let font = UIFont(name: self.selectedFontName, size: self.selectedFontSize)
        self.attributes = [NSAttributedString.Key.foregroundColor : self.selectedFontColor,  NSAttributedString.Key.font: font!]
        self.textOverlayView.attributedPlaceholder = NSAttributedString.init(string: NSLocalizedString("placeholder", comment: ""), attributes: self.attributes)
    }
    
    @objc func buttonPickColorTapTextVC(sender: UIButton) {
        let picker = UIColorPickerViewController()
        picker.selectedColor = UIColor.white
        
        //  Subscribing selectedColor property changes.
        self.cancellable = picker.publisher(for: \.selectedColor)
            .sink { color in
                
                //  Changing view color on main thread.
                DispatchQueue.main.async {
                    self.pickedColor = color
                    self.pickedColor.getRed(&self.pickedColorRed, green: &self.pickedColorGreen, blue: &self.pickedColorBlue, alpha: &self.pickedColorAlpha)
                    
                    self.selectedFontColor = UIColor(red: self.pickedColorRed, green: self.pickedColorGreen, blue: self.pickedColorBlue, alpha: self.pickedColorAlpha)
                    self.textOverlayView.textColor = self.selectedFontColor
                    /*let font = UIFont(name: self.selectedFontName, size: self.selectedFontSize)
                    self.attributes = [NSAttributedString.Key.foregroundColor : self.selectedFontColor,  NSAttributedString.Key.font: font!]
                    self.textOverlayView.attributedPlaceholder = NSAttributedString.init(string: NSLocalizedString("placeholder", comment: ""), attributes: self.attributes)*/
                    //self.uiSliderContainer.isHidden = true
                }
            }
        
        self.present(picker, animated: true, completion: nil)
    }
    
    @objc func handleGestureTextVC(_ recognizer: UIPanGestureRecognizer) {

        let translation = recognizer.translation(in: self.uiImageView)
        if let view = recognizer.view {

            view.center = CGPoint(x:view.center.x + translation.x,
                                  y:view.center.y + translation.y)

            if recognizer.state == .ended {
                dragDropX = view.center.x
                dragDropY = view.center.y
            }
        }

        recognizer.setTranslation(.zero, in: view)
    }
    
    func setUpConstraintsText() {
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
    
    func layoutTraitText(traitCollection:UITraitCollection) {
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
    
    func labelViewDidShowEditingHandles(_ label: IQLabelView!) {
        currIQLabel = label
    }
    
    func labelViewDidClose(_ label: IQLabelView!) {
        
        dragDropX = textOverlayView.center.x
        dragDropY = textOverlayView.center.y
        
        angleDiff = label.getAngleDiff
        self.selectedFontSize = label.getFontSize()
        
        if let uiTextField = label.subviews.first as? UITextField {
            let textToBeDraw = uiTextField.text?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
            
            let attributedTextToBeDraw = NSAttributedString(string: textToBeDraw!, attributes: [NSAttributedString.Key.foregroundColor : self.selectedFontColor,  NSAttributedString.Key.font: UIFont(name: self.selectedFontName, size: self.selectedFontSize)!])
            
            let viewSize = uiImageView.bounds.size
            let imageSize = receivedImage!.size
            
            let xScale = imageSize.width > 0 ? viewSize.width / imageSize.width : 1
            let yScale = imageSize.height > 0 ? viewSize.height / imageSize.height : 1
            let scale = (xScale > 0 && yScale > 0) ? min (xScale, yScale) : 1
            let scaledSize = CGSize (width: scale * imageSize.width, height: scale * imageSize.height)

            UIGraphicsBeginImageContextWithOptions(scaledSize, false, 0)
            receivedImage!.draw(in: CGRect(x: 0, y: 0, width: scaledSize.width, height: scaledSize.height))
            let textSize = attributedTextToBeDraw.size()
            if let context = UIGraphicsGetCurrentContext() {
                let translation: CGAffineTransform?
                if scaledSize.width > scaledSize.height {
                    let heightDiff = (viewSize.height - scaledSize.height)/2
                    translation = CGAffineTransform(translationX: dragDropX!-10, y: (dragDropY!-heightDiff)-5)
                } else {
                    translation = CGAffineTransform(translationX: dragDropX!-10, y: (dragDropY!)-5)
                }
                let rotation: CGAffineTransform = CGAffineTransform(rotationAngle: -CGFloat(angleDiff))
                context.concatenate(translation!)
                //context.scaleBy(x: 1, y: -1)
                context.concatenate(rotation)
                attributedTextToBeDraw.draw(at: CGPoint(x: (-textSize.width/2), y: (-textSize.height/2)))
                context.concatenate(rotation.inverted())
                context.concatenate(translation!.inverted())
            }
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            uiImageView.image = newImage
            receivedImage = newImage
            textedImage = newImage
            uiTextField.text = nil
        }
        label.resetAngleDiff()
        
        if let uiTextField = label.subviews.first as? UITextField {
            uiTextField.text = ""
        }
        
        attributes = [NSAttributedString.Key.foregroundColor : pickedColor,  NSAttributedString.Key.font: UIFont(name: selectedFontName, size: 28)!]
        
        textOverlayView.attributedPlaceholder = NSAttributedString.init(string: NSLocalizedString("placeholder", comment: ""), attributes: attributes)
        textOverlayView.layer.removeAllAnimations()
        textOverlayView.layer.removeFromSuperlayer()
        textOverlayView.transform = CGAffineTransform(rotationAngle: CGFloat(0))
        textOverlayView.removeFromSuperview()
        currIQLabel.removeFromSuperview()
        iqLabels.removeAll()
    }
    
    func labelViewDidHideEditingHandles(_ label: IQLabelView!) {
        if let uiTextField = label.subviews.first as? UITextField {
            uiTextField.text = ""
        }
        attributes = [NSAttributedString.Key.foregroundColor : pickedColor,  NSAttributedString.Key.font: UIFont(name: selectedFontName, size: 28)!]
        textOverlayView.attributedPlaceholder = NSAttributedString.init(string: NSLocalizedString("placeholder", comment: ""), attributes: attributes)
        textOverlayView.removeFromSuperview()
        currIQLabel.removeFromSuperview()
        iqLabels.removeAll()
    }
    
    func labelViewDidStartEditing(_ label: IQLabelView!) {
        currIQLabel = label
    }
    
    func shouldChangeCharacters(inRange label: IQLabelView!) -> Bool {
        return true
    }
}
