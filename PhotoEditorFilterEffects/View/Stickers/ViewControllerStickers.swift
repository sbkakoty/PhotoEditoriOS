//
//  StickerViewController.swift
//  PhotoEditorFilterEffects
//
//  Created by Sonjoy Borkakoty on 05/11/22.
//

import UIKit

class ViewControllerStickers: UIViewController {
    
    private var compactConstraints: [NSLayoutConstraint] = []
    private var regularConstraints: [NSLayoutConstraint] = []
    private var sharedConstraints: [NSLayoutConstraint] = []
    
    var receivedImage: UIImage?
    var finalStickerImage: UIImage?
    var stickerImageName: String?
    var stickerImage: UIImage?
    
    private var topConstraint: NSLayoutConstraint!
    private var rightConstraint: NSLayoutConstraint!
    private var leftConstraint: NSLayoutConstraint!
    private var bottomConstraint: NSLayoutConstraint!
    private var borderBox = UIView()
    private var strokeBorder = CAShapeLayer()
    private var buttonClose = UIButton()
    private var buttonRotate = UIButton()
    private var buttonFlip = UIButton()
    private var isPanGestureRecognizerTouched: Bool = false
    private var flipped: Bool = false
    private var scaledSize: CGSize = CGSize(width: 0.0, height: 0.0)
    
    struct StickerRectangle {
        var stickerTopTouch = false
        var stickerLeftTouch = false
        var stickerRightTouch = false
        var stickerBottomTouch = false
        var stickerMiddleTouch = false
    }
    
    private var touchStart = CGPoint.zero
    private var proxyFactor = CGFloat(10)
    private var resizeRect = StickerRectangle()
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
    private var selectedStickerImageName: String = "img_group31"
    
    private lazy var masterView: UIView = {
        let view = UINib(nibName: "MasterViewStickers", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
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
        customView.contentSize.width = 1160.0
        customView.showsHorizontalScrollIndicator = false
        customView.translatesAutoresizingMaskIntoConstraints = false
        customView.backgroundColor = UIColor(hexaRGB: getMenuBackColor())!
        customView.tag = 21
        return customView
    }()
    
    private lazy var labelStickers1: UILabel = {
        let view = UILabel()
        view.text = "\(NSLocalizedString("buttonLabelStickers", comment: "")) 1"
        view.tag = 112
        view.translatesAutoresizingMaskIntoConstraints = false
        //view.backgroundColor = hexStringToUIColor(hex: "#33DDFF")
        view.textColor = UIColor(hexaRGB: getContentColor(), alpha: 1)
        view.textAlignment = .center
        view.font = UIFont.preferredFont(forTextStyle: .body)
        view.adjustsFontForContentSizeCategory = true
        return view
    }()
    
    private lazy var labelStickers2: UILabel = {
        let view = UILabel()
        view.text = "\(NSLocalizedString("buttonLabelStickers", comment: "")) 2"
        view.tag = 113
        view.translatesAutoresizingMaskIntoConstraints = false
        //view.backgroundColor = hexStringToUIColor(hex: "#33DDFF")
        view.textColor = UIColor(hexaRGB: getContentColor(), alpha: 0.6)
        view.textAlignment = .center
        view.font = UIFont.preferredFont(forTextStyle: .body)
        view.adjustsFontForContentSizeCategory = true
        return view
    }()
    
    private lazy var labelStickers3: UILabel = {
        let view = UILabel()
        view.text = "\(NSLocalizedString("buttonLabelStickers", comment: "")) 3"
        view.tag = 114
        view.translatesAutoresizingMaskIntoConstraints = false
        //view.backgroundColor = hexStringToUIColor(hex: "#33DDFF")
        view.textColor = UIColor(hexaRGB: getContentColor(), alpha: 0.6)
        view.textAlignment = .center
        view.font = UIFont.preferredFont(forTextStyle: .body)
        view.adjustsFontForContentSizeCategory = true
        return view
    }()
    
    private lazy var labelStickers4: UILabel = {
        let view = UILabel()
        view.text = "\(NSLocalizedString("buttonLabelStickers", comment: "")) 4"
        view.tag = 115
        view.translatesAutoresizingMaskIntoConstraints = false
        //view.backgroundColor = hexStringToUIColor(hex: "#33DDFF")
        view.textColor = UIColor(hexaRGB: getContentColor(), alpha: 0.6)
        view.textAlignment = .center
        view.font = UIFont.preferredFont(forTextStyle: .body)
        view.adjustsFontForContentSizeCategory = true
        return view
    }()
    
    private lazy var labelStickers5: UILabel = {
        let view = UILabel()
        view.text = "\(NSLocalizedString("buttonLabelStickers", comment: "")) 5"
        view.tag = 116
        view.translatesAutoresizingMaskIntoConstraints = false
        //view.backgroundColor = hexStringToUIColor(hex: "#33DDFF")
        view.textColor = UIColor(hexaRGB: getContentColor(), alpha: 0.6)
        view.textAlignment = .center
        view.font = UIFont.preferredFont(forTextStyle: .body)
        view.adjustsFontForContentSizeCategory = true
        return view
    }()
    
    private lazy var labelStickers6: UILabel = {
        let view = UILabel()
        view.text = "\(NSLocalizedString("buttonLabelStickers", comment: "")) 6"
        view.tag = 117
        view.translatesAutoresizingMaskIntoConstraints = false
        //view.backgroundColor = hexStringToUIColor(hex: "#33DDFF")
        view.textColor = UIColor(hexaRGB: getContentColor(), alpha: 0.6)
        view.textAlignment = .center
        view.font = UIFont.preferredFont(forTextStyle: .body)
        view.adjustsFontForContentSizeCategory = true
        return view
    }()
    
    private lazy var labelStickers7: UILabel = {
        let view = UILabel()
        view.text = "\(NSLocalizedString("buttonLabelStickers", comment: "")) 7"
        view.tag = 118
        view.translatesAutoresizingMaskIntoConstraints = false
        //view.backgroundColor = hexStringToUIColor(hex: "#33DDFF")
        view.textColor = UIColor(hexaRGB: getContentColor(), alpha: 0.6)
        view.textAlignment = .center
        view.font = UIFont.preferredFont(forTextStyle: .body)
        view.adjustsFontForContentSizeCategory = true
        return view
    }()
    
    private lazy var labelStickers8: UILabel = {
        let view = UILabel()
        view.text = "\(NSLocalizedString("buttonLabelStickers", comment: "")) 8"
        view.tag = 119
        view.translatesAutoresizingMaskIntoConstraints = false
        //view.backgroundColor = hexStringToUIColor(hex: "#33DDFF")
        view.textColor = UIColor(hexaRGB: getContentColor(), alpha: 0.6)
        view.textAlignment = .center
        view.font = UIFont.preferredFont(forTextStyle: .body)
        view.adjustsFontForContentSizeCategory = true
        return view
    }()
    
    private lazy var labelStickers9: UILabel = {
        let view = UILabel()
        view.text = "\(NSLocalizedString("buttonLabelStickers", comment: "")) 9"
        view.tag = 120
        view.translatesAutoresizingMaskIntoConstraints = false
        //view.backgroundColor = hexStringToUIColor(hex: "#33DDFF")
        view.textColor = UIColor(hexaRGB: getContentColor(), alpha: 0.6)
        view.textAlignment = .center
        view.font = UIFont.preferredFont(forTextStyle: .body)
        view.adjustsFontForContentSizeCategory = true
        return view
    }()
    
    private lazy var labelStickers10: UILabel = {
        let view = UILabel()
        view.text = "\(NSLocalizedString("buttonLabelStickers", comment: "")) 10"
        view.tag = 121
        view.translatesAutoresizingMaskIntoConstraints = false
        //view.backgroundColor = hexStringToUIColor(hex: "#33DDFF")
        view.textColor = UIColor(hexaRGB: getContentColor(), alpha: 0.6)
        view.textAlignment = .center
        view.font = UIFont.preferredFont(forTextStyle: .body)
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
        
        setUpUIStickers()
        
        finalStickerImage = receivedImage
        
        setUpConstraintsStickers()
        NSLayoutConstraint.activate(sharedConstraints)
        layoutTraitStickers(traitCollection: UIScreen.main.traitCollection)
    }
    
    func setUpUIStickers() {
        setNavBarStickers()
        masterView.addSubview(uiImageView)
        self.view.backgroundColor = UIColor(hexaRGB: getBackgroundColor())
        view.addSubview(masterView)
        setUpBottomPreviewPanelStickers()
    }
    
    func setNavBarStickers() {
        
        self.navigationItem.setHidesBackButton(true, animated: false)
        let navTitle = UILabel()
        navTitle.text = NSLocalizedString("buttonLabelStickers", comment: "")
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
        leftView.addTarget(self, action: #selector(backButtonTapStickers), for: .allTouchEvents)
        leftButton.customView = leftView
            
        let rightButton = UIBarButtonItem(title: NSLocalizedString("navBarButtonDone", comment: ""), style: .done, target: self, action: #selector(doneButtonTapSticker))
        rightButton.tintColor = UIColor(hexaRGB: getContentColor())!
        rightButton.setTitleTextAttributes(navBarButtonTitleAttributes, for: .normal)
        
        self.navigationItem.leftBarButtonItem  = leftButton
        self.navigationItem.rightBarButtonItem  = rightButton
        
        self.navigationController?.navigationBar.semanticContentAttribute = .forceLeftToRight
    }
    
    func setUpBorderBoxSticker() {
        self.defaultInset = 11
        self.defaultMinimumSize = 4 * self.defaultInset
        self.minimumSize = self.defaultMinimumSize
        
        borderBox.translatesAutoresizingMaskIntoConstraints = false
        borderBox.isUserInteractionEnabled = true
        borderBox.tag = 61
        view.addSubview(borderBox) // not added to masterView otherwise masterView's layout constraints will not allows to adjust height of borderBox
        borderBox.semanticContentAttribute = .forceLeftToRight
        
        let safeArea = view.safeAreaLayoutGuide
        rightConstraint = NSLayoutConstraint(item: safeArea, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: borderBox, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1, constant: getRelativeWidth(100.0))
        bottomConstraint = NSLayoutConstraint(item: safeArea, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: borderBox, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: getRelativeHeight(300.0))
        leftConstraint = NSLayoutConstraint(item: borderBox, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: safeArea, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1, constant: getRelativeWidth(50.0))
        topConstraint = NSLayoutConstraint(item: borderBox, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: safeArea, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: getRelativeHeight(100.0))
        NSLayoutConstraint.activate([rightConstraint, bottomConstraint, leftConstraint, topConstraint])
        
        strokeBorder = CAShapeLayer()
        strokeBorder.strokeColor = UIColor.white.cgColor
        strokeBorder.lineWidth = 3
        strokeBorder.lineDashPattern = [7, 7]
        strokeBorder.fillColor = UIColor.clear.cgColor
        borderBox.layer.addSublayer(strokeBorder)
        
        buttonClose = UIButton(frame: CGRect(x: borderBox.frame.width-12, y: -12, width: 24, height: 24))
        buttonClose.tag = 62
        buttonClose.addTarget(self, action: #selector(buttonCloseTap), for: .allTouchEvents)
        buttonClose.translatesAutoresizingMaskIntoConstraints = false
        buttonClose.setImage(UIImage(named: "img_group82")?.withRenderingMode(.alwaysOriginal), for: .normal)
        
        buttonRotate = UIButton(frame: CGRect(x: borderBox.frame.minX-12, y: borderBox.frame.height-12, width: 24, height: 24))
        buttonRotate.translatesAutoresizingMaskIntoConstraints = false
        buttonRotate.setImage(UIImage(named: "img_group654")?.withRenderingMode(.alwaysOriginal), for: .normal)
        buttonRotate.contentMode = .center
        buttonRotate.isUserInteractionEnabled = true
        buttonRotate.tag = 63
        
        buttonFlip = UIButton(frame: CGRect(x: borderBox.frame.minX-12, y: -12, width: 24, height: 24))
        buttonFlip.translatesAutoresizingMaskIntoConstraints = false
        buttonFlip.setImage(UIImage(named: "img_group_2")?.withRenderingMode(.alwaysOriginal), for: .normal)
        buttonFlip.contentMode = .center
        buttonFlip.isUserInteractionEnabled = true
        buttonFlip.addTarget(self, action: #selector(buttonFlipStickerTap), for: .allTouchEvents)
        buttonFlip.tag = 64
        
        borderBox.addSubview(buttonClose)
        borderBox.addSubview(buttonRotate)
        borderBox.addSubview(buttonFlip)
        
        let rotationGesture = UIPanGestureRecognizer(target: self, action:#selector(self.rotationGestureStickersTap(recognizer:)))
        buttonRotate.addGestureRecognizer(rotationGesture)
        
        let closeButtonTopConstraint = NSLayoutConstraint(item: buttonClose, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: borderBox, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: -12)
        let closeButtonRightConstraint = NSLayoutConstraint(item: buttonClose, attribute: NSLayoutConstraint.Attribute.right, relatedBy: NSLayoutConstraint.Relation.equal, toItem: borderBox, attribute: NSLayoutConstraint.Attribute.right, multiplier: 1, constant: 12)
        NSLayoutConstraint.activate([closeButtonTopConstraint, closeButtonRightConstraint])
        
        let rotateButtonTopConstraint = NSLayoutConstraint(item: buttonRotate, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: borderBox, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: -12)
        let rotateButtonLeftConstraint = NSLayoutConstraint(item: buttonRotate, attribute: NSLayoutConstraint.Attribute.left, relatedBy: NSLayoutConstraint.Relation.equal, toItem: borderBox, attribute: NSLayoutConstraint.Attribute.left, multiplier: 1, constant: -12)
        NSLayoutConstraint.activate([rotateButtonTopConstraint, rotateButtonLeftConstraint])
        
        let flipButtonTopConstraint = NSLayoutConstraint(item: buttonFlip, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: borderBox, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: -12)
        let flipButtonRightConstraint = NSLayoutConstraint(item: buttonFlip, attribute: NSLayoutConstraint.Attribute.left, relatedBy: NSLayoutConstraint.Relation.equal, toItem: borderBox, attribute: NSLayoutConstraint.Attribute.left, multiplier: 1, constant: -12)
        NSLayoutConstraint.activate([flipButtonTopConstraint, flipButtonRightConstraint])
        
        let point = borderBox.frame.origin
        dragDropX = point.x
        dragDropY = point.y
    }
    
    @objc func buttonCloseTap(sender: UIButton) {
        
        removeBorderBoxFromStickersView()
    }
    
    @objc func buttonFlipStickerTap(sender: UIButton) {
        
        if let foundView = self.view.viewWithTag(71) as? UIImageView {
            foundView.removeFromSuperview()
        }
        
        view.layoutIfNeeded()
        
        var flippedImage: UIImage?
        flippedImage = UIImage(cgImage: (stickerImage?.cgImage!)!, scale: 1.0, orientation: .upMirrored)
        let stickerImageView = UIImageView(frame: borderBox.bounds)
        stickerImageView.tag = 71
        stickerImageView.image = flippedImage
        stickerImageView.contentMode = .scaleAspectFit
        borderBox.addSubview(stickerImageView)
        strokeBorder.frame = borderBox.bounds
        strokeBorder.path = UIBezierPath(rect: borderBox.bounds).cgPath
        
        flipped = true
        stickerImage = flippedImage
    }
    
    func setUpBottomPreviewPanelStickers() {
        
        masterView.addSubview(bottomPreviewPanel)
        
        let imageButtonStickers1 = UIButton(frame: CGRect(x: 10.0, y: 10.0, width: 105, height: 105))
        imageButtonStickers1.tag = 12
        imageButtonStickers1.backgroundColor = UIColor(hexaRGB: "#899A9A", alpha: 1.0)
        imageButtonStickers1.addTarget(self, action: #selector(setImageStickers), for: .touchUpInside)
        let imageViewStickers1 = UIImageView(frame: CGRect(x: 15, y: 15, width: 80, height: 80))
        imageViewStickers1.image = UIImage(named: "img_group31")?.withRenderingMode(.alwaysOriginal)
        imageViewStickers1.contentMode = .scaleAspectFit
        imageButtonStickers1.addSubview(imageViewStickers1)
        bottomPreviewPanel.addSubview(imageButtonStickers1)
        
        let imageButtonStickers2 = UIButton(frame: CGRect(x: 125.0, y: 10.0, width: 105, height: 105))
        imageButtonStickers2.tag = 13
        imageButtonStickers2.backgroundColor = UIColor(hexaRGB: "#899A9A", alpha: 1.0)
        imageButtonStickers2.addTarget(self, action: #selector(setImageStickers), for: .touchUpInside)
        let imageViewStickers2 = UIImageView(frame: CGRect(x: 15, y: 15, width: 80, height: 80))
        imageViewStickers2.image = UIImage(named: "img_group32")?.withRenderingMode(.alwaysOriginal)
        imageViewStickers2.contentMode = .scaleAspectFit
        imageButtonStickers2.addSubview(imageViewStickers2)
        bottomPreviewPanel.addSubview(imageButtonStickers2)
        
        let imageButtonStickers3 = UIButton(frame: CGRect(x: 240.0, y: 10.0, width: 105, height: 105))
        imageButtonStickers3.tag = 14
        imageButtonStickers3.backgroundColor = UIColor(hexaRGB: "#899A9A", alpha: 1.0)
        imageButtonStickers3.addTarget(self, action: #selector(setImageStickers), for: .touchUpInside)
        let imageViewStickers3 = UIImageView(frame: CGRect(x: 15, y: 15, width: 80, height: 80))
        imageViewStickers3.image = UIImage(named: "img_group34")?.withRenderingMode(.alwaysOriginal)
        imageViewStickers3.contentMode = .scaleAspectFit
        imageButtonStickers3.addSubview(imageViewStickers3)
        bottomPreviewPanel.addSubview(imageButtonStickers3)
        
        let imageButtonStickers4 = UIButton(frame: CGRect(x: 355.0, y: 10.0, width: 105, height: 105))
        imageButtonStickers4.tag = 15
        imageButtonStickers4.backgroundColor = UIColor(hexaRGB: "#899A9A", alpha: 1.0)
        imageButtonStickers4.addTarget(self, action: #selector(setImageStickers), for: .touchUpInside)
        let imageViewStickers4 = UIImageView(frame: CGRect(x: 15, y: 15, width: 80, height: 80))
        imageViewStickers4.image = UIImage(named: "img_group36")?.withRenderingMode(.alwaysOriginal)
        imageViewStickers4.contentMode = .scaleAspectFit
        imageButtonStickers4.addSubview(imageViewStickers4)
        bottomPreviewPanel.addSubview(imageButtonStickers4)
        
        let imageButtonStickers5 = UIButton(frame: CGRect(x: 470.0, y: 10.0, width: 105, height: 105))
        imageButtonStickers5.tag = 16
        imageButtonStickers5.backgroundColor = UIColor(hexaRGB: "#899A9A", alpha: 1.0)
        imageButtonStickers5.addTarget(self, action: #selector(setImageStickers), for: .touchUpInside)
        let imageViewStickers5 = UIImageView(frame: CGRect(x: 15, y: 15, width: 80, height: 80))
        imageViewStickers5.image = UIImage(named: "img_group639")?.withRenderingMode(.alwaysOriginal)
        imageViewStickers5.contentMode = .scaleAspectFit
        imageButtonStickers5.addSubview(imageViewStickers5)
        bottomPreviewPanel.addSubview(imageButtonStickers5)
        
        let imageButtonStickers6 = UIButton(frame: CGRect(x: 585.0, y: 10.0, width: 105, height: 105))
        imageButtonStickers6.tag = 17
        imageButtonStickers6.backgroundColor = UIColor(hexaRGB: "#899A9A", alpha: 1.0)
        imageButtonStickers6.addTarget(self, action: #selector(setImageStickers), for: .touchUpInside)
        let imageViewStickers6 = UIImageView(frame: CGRect(x: 15, y: 15, width: 80, height: 80))
        imageViewStickers6.image = UIImage(named: "img_group640")?.withRenderingMode(.alwaysOriginal)
        imageViewStickers6.contentMode = .scaleAspectFit
        imageButtonStickers6.addSubview(imageViewStickers6)
        bottomPreviewPanel.addSubview(imageButtonStickers6)
        
        let imageButtonStickers7 = UIButton(frame: CGRect(x: 700.0, y: 10.0, width: 105, height: 105))
        imageButtonStickers7.tag = 18
        imageButtonStickers7.backgroundColor = UIColor(hexaRGB: "#899A9A", alpha: 1.0)
        imageButtonStickers7.addTarget(self, action: #selector(setImageStickers), for: .touchUpInside)
        let imageViewStickers7 = UIImageView(frame: CGRect(x: 15, y: 15, width: 80, height: 80))
        imageViewStickers7.image = UIImage(named: "img_group59")?.withRenderingMode(.alwaysOriginal)
        imageViewStickers7.contentMode = .scaleAspectFit
        imageButtonStickers7.addSubview(imageViewStickers7)
        bottomPreviewPanel.addSubview(imageButtonStickers7)
        
        let imageButtonStickers8 = UIButton(frame: CGRect(x: 815.0, y: 10.0, width: 105, height: 105))
        imageButtonStickers8.tag = 19
        imageButtonStickers8.backgroundColor = UIColor(hexaRGB: "#899A9A", alpha: 1.0)
        imageButtonStickers8.addTarget(self, action: #selector(setImageStickers), for: .touchUpInside)
        let imageViewStickers8 = UIImageView(frame: CGRect(x: 15, y: 15, width: 80, height: 80))
        imageViewStickers8.image = UIImage(named: "img_group60")?.withRenderingMode(.alwaysOriginal)
        imageViewStickers8.contentMode = .scaleAspectFit
        imageButtonStickers8.addSubview(imageViewStickers8)
        bottomPreviewPanel.addSubview(imageButtonStickers8)
        
        let imageButtonStickers9 = UIButton(frame: CGRect(x: 930.0, y: 10.0, width: 105, height: 105))
        imageButtonStickers9.tag = 20
        imageButtonStickers9.backgroundColor = UIColor(hexaRGB: "#899A9A", alpha: 1.0)
        imageButtonStickers9.addTarget(self, action: #selector(setImageStickers), for: .touchUpInside)
        let imageViewStickers9 = UIImageView(frame: CGRect(x: 15, y: 15, width: 80, height: 80))
        imageViewStickers9.image = UIImage(named: "img_group61")?.withRenderingMode(.alwaysOriginal)
        imageViewStickers9.contentMode = .scaleAspectFit
        imageButtonStickers9.addSubview(imageViewStickers9)
        bottomPreviewPanel.addSubview(imageButtonStickers9)
        
        let imageButtonStickers10 = UIButton(frame: CGRect(x: 1045.0, y: 10.0, width: 105, height: 105))
        imageButtonStickers10.tag = 21
        imageButtonStickers10.backgroundColor = UIColor(hexaRGB: "#899A9A", alpha: 1.0)
        imageButtonStickers10.addTarget(self, action: #selector(setImageStickers), for: .touchUpInside)
        let imageViewStickers10 = UIImageView(frame: CGRect(x: 15, y: 15, width: 80, height: 80))
        imageViewStickers10.image = UIImage(named: "img_group62")?.withRenderingMode(.alwaysOriginal)
        imageViewStickers10.contentMode = .scaleAspectFit
        imageButtonStickers10.addSubview(imageViewStickers10)
        bottomPreviewPanel.addSubview(imageButtonStickers10)
        
        bottomPreviewPanel.addSubview(labelStickers1)
        bottomPreviewPanel.addSubview(labelStickers2)
        bottomPreviewPanel.addSubview(labelStickers3)
        bottomPreviewPanel.addSubview(labelStickers4)
        bottomPreviewPanel.addSubview(labelStickers5)
        bottomPreviewPanel.addSubview(labelStickers6)
        bottomPreviewPanel.addSubview(labelStickers7)
        bottomPreviewPanel.addSubview(labelStickers8)
        bottomPreviewPanel.addSubview(labelStickers9)
        bottomPreviewPanel.addSubview(labelStickers10)
        
        labelStickers1.topAnchor.constraint(equalTo: imageButtonStickers1.bottomAnchor, constant: 5).isActive = true
        labelStickers1.centerXAnchor.constraint(equalTo: imageButtonStickers1.centerXAnchor).isActive = true
        
        labelStickers2.topAnchor.constraint(equalTo: imageButtonStickers2.bottomAnchor, constant: 5).isActive = true
        labelStickers2.centerXAnchor.constraint(equalTo: imageButtonStickers2.centerXAnchor).isActive = true
        
        labelStickers3.topAnchor.constraint(equalTo: imageButtonStickers3.bottomAnchor, constant: 5).isActive = true
        labelStickers3.centerXAnchor.constraint(equalTo: imageButtonStickers3.centerXAnchor).isActive = true
        
        labelStickers4.topAnchor.constraint(equalTo: imageButtonStickers4.bottomAnchor, constant: 5).isActive = true
        labelStickers4.centerXAnchor.constraint(equalTo: imageButtonStickers4.centerXAnchor).isActive = true
        
        labelStickers5.topAnchor.constraint(equalTo: imageButtonStickers5.bottomAnchor, constant: 5).isActive = true
        labelStickers5.centerXAnchor.constraint(equalTo: imageButtonStickers5.centerXAnchor).isActive = true
        
        labelStickers6.topAnchor.constraint(equalTo: imageButtonStickers6.bottomAnchor, constant: 5).isActive = true
        labelStickers6.centerXAnchor.constraint(equalTo: imageButtonStickers6.centerXAnchor).isActive = true
        
        labelStickers7.topAnchor.constraint(equalTo: imageButtonStickers7.bottomAnchor, constant: 5).isActive = true
        labelStickers7.centerXAnchor.constraint(equalTo: imageButtonStickers7.centerXAnchor).isActive = true
        
        labelStickers8.topAnchor.constraint(equalTo: imageButtonStickers8.bottomAnchor, constant: 5).isActive = true
        labelStickers8.centerXAnchor.constraint(equalTo: imageButtonStickers8.centerXAnchor).isActive = true
        
        labelStickers9.topAnchor.constraint(equalTo: imageButtonStickers9.bottomAnchor, constant: 5).isActive = true
        labelStickers9.centerXAnchor.constraint(equalTo: imageButtonStickers9.centerXAnchor).isActive = true
        
        labelStickers10.topAnchor.constraint(equalTo: imageButtonStickers10.bottomAnchor, constant: 5).isActive = true
        labelStickers10.centerXAnchor.constraint(equalTo: imageButtonStickers10.centerXAnchor).isActive = true
        
        bottomPreviewPanel.bottomAnchor.constraint(equalTo: masterView.bottomAnchor).isActive = true
        bottomPreviewPanel.widthAnchor.constraint(equalTo: masterView.widthAnchor).isActive = true
        bottomPreviewPanel.heightAnchor.constraint(equalToConstant: 190).isActive = true
    }
    
    @objc func setImageStickers(sender: UIButton) {
        
        angleDiff = 0
        dragDropX = 0
        dragDropY = 0
        flipped = false
        
        switch sender.tag {
            case 12:
            self.selectedStickerImageName = "img_group31"
            selectedShade = 12
            case 13:
            self.selectedStickerImageName = "img_group32"
            selectedShade = 13
            case 14:
            self.selectedStickerImageName = "img_group34"
            selectedShade = 14
            case 15:
            self.selectedStickerImageName = "img_group36"
            selectedShade = 15
            case 16:
            self.selectedStickerImageName = "img_group639"
            selectedShade = 16
            case 17:
            self.selectedStickerImageName = "img_group640"
            selectedShade = 17
            case 18:
            self.selectedStickerImageName = "img_group59"
            selectedShade = 18
            case 19:
            self.selectedStickerImageName = "img_group60"
            selectedShade = 19
            case 20:
            self.selectedStickerImageName = "img_group61"
            selectedShade = 20
            case 21:
            self.selectedStickerImageName = "img_group62"
            selectedShade = 21
            default:
                break
        }
        
        if let foundView = view.viewWithTag(selectedShade) as? UIButton {
            foundView.setButtonActiveColor(hex: getContentColor(), alpha: 1)
        }
        if let foundView = view.viewWithTag(Int("1\(selectedShade)")!) as? UILabel {
            foundView.textColor = UIColor(hexaRGB: getContentColor(), alpha: 1)
        }
        
        setButtonColorStickers(selectedButtonTag: selectedShade, selectedLabelTag: Int("1\(selectedShade)")!)
        
        removeBorderBoxFromStickersView()
        setUpBorderBoxSticker()
        overlayStickerImageOnBorderbox()
    }
    
    func overlayStickerImageOnBorderbox() {
        
        if let foundView = self.view.viewWithTag(71) as? UIImageView {
            foundView.removeFromSuperview()
        }
        
        view.layoutIfNeeded()
        
        stickerImage = UIImage(named: selectedStickerImageName)
        let stickerImageView = UIImageView(frame: borderBox.bounds)
        stickerImageView.tag = 71
        stickerImageView.image = stickerImage
        stickerImageView.contentMode = .scaleAspectFit
        borderBox.addSubview(stickerImageView)
        strokeBorder.frame = borderBox.bounds
        strokeBorder.path = UIBezierPath(rect: borderBox.bounds).cgPath
        
        let point = borderBox.frame.origin
        dragDropX = point.x
        dragDropY = point.y
    }
    
    func removeBorderBoxFromStickersView() {
        
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
    
    @objc func backButtonTapStickers(sender: Any) {
        if let viewController = navigationController?.viewControllers.first(where: {$0 is ViewControllerStyleRedactor}) {
              navigationController?.popToViewController(viewController, animated: false)
        }
    }
    
    @objc func doneButtonTapSticker(sender: Any) {
        
        //let croppedImage = stickerImage?.crop(to: cropRect.size)
        if stickerImage != nil {
            finalStickerImage = createCroppedStickerImage(image: stickerImage)
        }
        //uiImageView.image = finalStickerImage
        
        removeBorderBoxFromStickersView()
        
        if let viewController = navigationController?.viewControllers.first(where: {$0 is ViewControllerStyleRedactor}) {
            
            //NotificationCenter.default.removeObserver(self, name: Notification.Name("com.stickersphoto.success"), object: nil)
            NotificationCenter.default.removeObserver(self)
            let imageDataDict:[String: UIImage] = ["stickersImage": finalStickerImage!]
            NotificationCenter.default.post(name: Notification.Name("com.stickersphoto.success"), object: nil, userInfo: imageDataDict)
              navigationController?.popToViewController(viewController, animated: false)
        }
    }
    
    func setUpConstraintsStickers() {
        
        let safeArea = view.safeAreaLayoutGuide
        scaledSize = calculateImageViewScale(viewSize: self.view.bounds.size, imageSize: receivedImage!.size, leftRightAnchorConstant: 20, topBottomAnchorConstant: 175)
        
        sharedConstraints.append(contentsOf: [
            masterView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            masterView.leftAnchor.constraint(equalTo: safeArea.leftAnchor),
            masterView.rightAnchor.constraint(equalTo: safeArea.rightAnchor),
            masterView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            uiImageView.topAnchor.constraint(equalTo: masterView.topAnchor, constant: 5),
            uiImageView.leftAnchor.constraint(equalTo: masterView.leftAnchor, constant: 10),
            uiImageView.widthAnchor.constraint(equalTo: masterView.widthAnchor, constant: -20),
            uiImageView.heightAnchor.constraint(equalToConstant: scaledSize.height),
        ])
        
        regularConstraints.append(contentsOf: [
            masterView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            masterView.leftAnchor.constraint(equalTo: safeArea.leftAnchor),
            masterView.rightAnchor.constraint(equalTo: safeArea.rightAnchor),
            masterView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            uiImageView.topAnchor.constraint(equalTo: masterView.topAnchor, constant: 5),
            uiImageView.leftAnchor.constraint(equalTo: masterView.leftAnchor, constant: 10),
            uiImageView.widthAnchor.constraint(equalTo: masterView.widthAnchor, constant: -20),
            uiImageView.heightAnchor.constraint(equalToConstant: scaledSize.height),
        ])
        
        compactConstraints.append(contentsOf: [
            masterView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            masterView.leftAnchor.constraint(equalTo: safeArea.leftAnchor),
            masterView.rightAnchor.constraint(equalTo: safeArea.rightAnchor),
            masterView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            uiImageView.topAnchor.constraint(equalTo: masterView.topAnchor, constant: 5),
            uiImageView.leftAnchor.constraint(equalTo: masterView.leftAnchor, constant: 10),
            uiImageView.widthAnchor.constraint(equalTo: masterView.widthAnchor, constant: -20),
            uiImageView.heightAnchor.constraint(equalToConstant: scaledSize.height),
        ])
    }
    
    func layoutTraitStickers(traitCollection:UITraitCollection) {
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
    
    func setButtonColorStickers(selectedButtonTag: Int?, selectedLabelTag: Int?) {
        
        for i in 12...21 {
            if i != selectedButtonTag {
                if let foundView = view.viewWithTag(i) as? UIButton {
                    foundView.setButtonActiveColor(hex: getContentColor(), alpha: 0.6)
                }
            }
        }
        
        for i in 112...121 {
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
            
            resizeRect.stickerTopTouch = false
            resizeRect.stickerLeftTouch = false
            resizeRect.stickerRightTouch = false
            resizeRect.stickerBottomTouch = false
            resizeRect.stickerMiddleTouch = false
            
            if  touchStart.y > borderBox.frame.minY + (proxyFactor*2) &&  touchStart.y < borderBox.frame.maxY - (proxyFactor*2) &&  touchStart.x > borderBox.frame.minX + (proxyFactor*2) &&  touchStart.x < borderBox.frame.maxX - (proxyFactor*2){
                resizeRect.stickerMiddleTouch = true
                return
            }
            
            if touchStart.y > borderBox.frame.maxY - proxyFactor &&  touchStart.y < borderBox.frame.maxY + proxyFactor {
                resizeRect.stickerBottomTouch = true
            }
            
            if touchStart.x > borderBox.frame.maxX - proxyFactor && touchStart.x < borderBox.frame.maxX + proxyFactor {
                resizeRect.stickerRightTouch = true
            }
            
            if touchStart.x > borderBox.frame.minX - proxyFactor &&  touchStart.x < borderBox.frame.minX + proxyFactor {
                resizeRect.stickerLeftTouch = true
            }
            
            if touchStart.y > borderBox.frame.minY - proxyFactor &&  touchStart.y < borderBox.frame.minY + proxyFactor {
                resizeRect.stickerTopTouch = true
            }
            
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first{
            let currentTouchPoint = touch.location(in: self.view)
            let previousTouchPoint = touch.previousLocation(in: self.view)
            
            let deltaX = currentTouchPoint.x - previousTouchPoint.x
            let deltaY = currentTouchPoint.y - previousTouchPoint.y
            
            if resizeRect.stickerMiddleTouch{
                topConstraint.constant += deltaY
                leftConstraint.constant += deltaX
                rightConstraint.constant -= deltaX
                bottomConstraint.constant -= deltaY
            }
            
            if resizeRect.stickerTopTouch {
                topConstraint.constant += deltaY
            }
            
            if resizeRect.stickerLeftTouch {
                leftConstraint.constant += deltaX
            }
            if resizeRect.stickerRightTouch {
                rightConstraint.constant -= deltaX
            }
            if resizeRect.stickerBottomTouch {
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
                let stickerImageView = UIImageView(frame: self.borderBox.bounds)
                stickerImageView.tag = 71
                stickerImageView.image = self.stickerImage
                stickerImageView.contentMode = .scaleAspectFit
                self.borderBox.addSubview(stickerImageView)
                self.strokeBorder.path = UIBezierPath(rect: self.borderBox.bounds).cgPath
            })
        }
    }
    
    @objc func rotationGestureStickersTap(recognizer: UIPanGestureRecognizer) {
        
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
    
    func createCroppedStickerImage(image: UIImage?) -> UIImage {
        
        let viewSize = uiImageView.bounds.size
        let imageSize = receivedImage!.size
        
        let xScale = imageSize.width > 0 ? viewSize.width / imageSize.width : 1
        let yScale = imageSize.height > 0 ? viewSize.height / imageSize.height : 1
        let scale = (xScale > 0 && yScale > 0) ? min (xScale, yScale) : 1
        let scaledSize = CGSize (width: scale * imageSize.width, height: scale * imageSize.height)

        UIGraphicsBeginImageContextWithOptions(scaledSize, false, 0)
        
        receivedImage!.draw(in: CGRect(x: 0, y: 0, width: scaledSize.width, height: scaledSize.height))
        //print("\(dragDropX!) X \(dragDropY!)")
        let rotatedImage = image!.rotated(angleDiff: CGFloat(angleDiff), flipped: flipped)
        if scaledSize.width > scaledSize.height {
            let heightDiff = (viewSize.height - scaledSize.height)/2
            let yPosition = heightDiff + (dragDropY!-5)
            rotatedImage!.draw(in: CGRect(x: (dragDropX!-10), y: yPosition, width: borderBox.bounds.width, height: borderBox.bounds.height))
        } else {
            rotatedImage!.draw(in: CGRect(x: (dragDropX!-10), y: (dragDropY!-5), width: borderBox.bounds.width, height: borderBox.bounds.height))
        }
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
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
