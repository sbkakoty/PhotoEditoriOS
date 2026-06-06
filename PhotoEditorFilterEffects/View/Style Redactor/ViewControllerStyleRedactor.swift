//
//  ViewControllerStyleRedactor.swift
//  PhotoEditorFilterEffects
//
//  Created by MacBook on 10/18/22.
//

import UIKit
import Photos
import PhotosUI

class ViewControllerStyleRedactor: UIViewController, PHPhotoLibraryChangeObserver  {
    
    private var compactConstraints: [NSLayoutConstraint] = []
    private var regularConstraints: [NSLayoutConstraint] = []
    private var sharedConstraints: [NSLayoutConstraint] = []
    
    private var albumName = AppConfig.albumName
    private var assetCollection: PHAssetCollection!
    private var selectedShade: Int = 11
    private var scaledSize: CGSize = CGSize(width: 0.0, height: 0.0)
    
    var receivedImage: UIImage?
    var filteredImage: UIImage?
    
    private var config: PHPickerConfiguration = {
        var cfg = PHPickerConfiguration()
        cfg.selectionLimit = 3
        cfg.filter = PHPickerFilter.images
        return cfg
    }()
    
    private lazy var masterView: UIView = {
        let view = UINib(nibName: "MasterViewStyleRedactor", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
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
        customView.contentSize.width = getRelativeWidth(700.0)
        customView.showsHorizontalScrollIndicator = false
        customView.translatesAutoresizingMaskIntoConstraints = false
        customView.backgroundColor = UIColor(hexaRGB: getMenuBackColor())!
        customView.tag = 21
        return customView
    }()
    
    lazy var toolsPanel: UIView = {
        let view = UIView(frame: UIScreen.main.bounds)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(hexaRGB: getMenuBackColor())!
        view.isHidden = true
        view.tag = 22
        return view
    }()
    
    private lazy var bottomActionPanel: UIView = {
        let bottomActionPanel = UIView()
        bottomActionPanel.backgroundColor = UIColor(hexaRGB: getBackgroundColor())!
        bottomActionPanel.translatesAutoresizingMaskIntoConstraints = false
        return bottomActionPanel
    }()
    
    lazy private var styleButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "img_group77")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setButtonActiveColor(hex: getContentColor(), alpha: 0.8)
        button.tag = 2
        button.addTarget(self, action: #selector(buttonStyleTap), for: .touchUpInside)
        return button
    }()
    
    lazy private var toolsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "img_group77_1")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setButtonActiveColor(hex: getContentColor(), alpha: 0.6)
        button.tag = 3
        button.addTarget(self, action: #selector(buttonToolsTap), for: .touchUpInside)
        return button
    }()
    
    lazy private var exportButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "img_group78")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setButtonActiveColor(hex: getContentColor(), alpha: 0.3)
        button.tag = 4
        button.addTarget(self, action: #selector(buttonExportTap), for: .touchUpInside)
        return button
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
    
    private lazy var labelMoon: UILabel = {
        let view = UILabel()
        view.text = NSLocalizedString("buttonLabelMoon", comment: "")
        view.translatesAutoresizingMaskIntoConstraints = false
        //view.backgroundColor = hexStringToUIColor(hex: "#33DDFF")
        view.textColor = UIColor(hexaRGB: getContentColor(), alpha: 0.6)
        view.textAlignment = .center
        view.font = UIFont.preferredFont(forTextStyle: .body)
        view.adjustsFontForContentSizeCategory = true
        view.tag = 112
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
        view.tag = 113
        return view
    }()
    
    private lazy var labelReyes: UILabel = {
        let view = UILabel()
        view.text = NSLocalizedString("buttonLabelReyes", comment: "")
        view.translatesAutoresizingMaskIntoConstraints = false
        //view.backgroundColor = hexStringToUIColor(hex: "#33DDFF")
        view.textColor = UIColor(hexaRGB: getContentColor(), alpha: 0.6)
        view.textAlignment = .center
        view.font = UIFont.preferredFont(forTextStyle: .body)
        view.adjustsFontForContentSizeCategory = true
        view.tag = 114
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
        view.tag = 115
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
        view.tag = 116
        return view
    }()
    
    lazy private var adjustButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "img_group661")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.addTarget(self, action: #selector(buttonAdjustTap), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setButtonActiveColor(hex: getContentColor(), alpha: 0.6)
        button.tag = 31
        return button
    }()
    
    private lazy var labelAdjust: UILabel = {
        let view = UILabel()
        view.text = NSLocalizedString("buttonLabelAdjust", comment: "")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = UIColor(hexaRGB: getContentColor(), alpha: 0.6)
        view.textAlignment = .center
        view.font = UIFont.preferredFont(forTextStyle: .headline)
        view.adjustsFontForContentSizeCategory = true
        return view
    }()
    
    lazy private var cropButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "img_group662")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setButtonActiveColor(hex: getContentColor(), alpha: 0.6)
        button.tag = 32
        button.addTarget(self, action: #selector(buttonCropPressed), for: .touchUpInside)
        return button
    }()
    
    private lazy var labelCrop: UILabel = {
        let view = UILabel()
        view.text = NSLocalizedString("buttonLabelCrop", comment: "")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = UIColor(hexaRGB: getContentColor(), alpha: 0.6)
        view.textAlignment = .center
        view.font = UIFont.preferredFont(forTextStyle: .headline)
        view.adjustsFontForContentSizeCategory = true
        return view
    }()
    
    lazy private var drawButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "img_group663")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setButtonActiveColor(hex: getContentColor(), alpha: 0.6)
        button.tag = 33
        button.addTarget(self, action: #selector(buttonDrawPressed), for: .touchUpInside)
        return button
    }()
    
    private lazy var labelDraw: UILabel = {
        let view = UILabel()
        view.text = NSLocalizedString("buttonLabelDraw", comment: "")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = UIColor(hexaRGB: getContentColor(), alpha: 0.6)
        view.textAlignment = .center
        view.font = UIFont.preferredFont(forTextStyle: .headline)
        view.adjustsFontForContentSizeCategory = true
        return view
    }()
    
    lazy private var textButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "img_iconstext")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setButtonActiveColor(hex: getContentColor(), alpha: 0.6)
        button.tag = 34
        button.addTarget(self, action: #selector(buttonTextTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var labelText: UILabel = {
        let view = UILabel()
        view.text = NSLocalizedString("buttonLabelText", comment: "")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = UIColor(hexaRGB: getContentColor(), alpha: 0.6)
        view.textAlignment = .center
        view.font = UIFont.preferredFont(forTextStyle: .headline)
        view.adjustsFontForContentSizeCategory = true
        return view
    }()
    
    lazy private var filtersButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "img_group668")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setButtonActiveColor(hex: getContentColor(), alpha: 0.6)
        button.tag = 35
        button.addTarget(self, action: #selector(buttonFiltersTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var labelFilters: UILabel = {
        let view = UILabel()
        view.text = NSLocalizedString("buttonLabelFilters", comment: "")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = UIColor(hexaRGB: getContentColor(), alpha: 0.6)
        view.textAlignment = .center
        view.font = UIFont.preferredFont(forTextStyle: .headline)
        view.adjustsFontForContentSizeCategory = true
        return view
    }()
    
    lazy private var overlaysButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "img_group669")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setButtonActiveColor(hex: getContentColor(), alpha: 0.6)
        button.tag = 36
        button.addTarget(self, action: #selector(buttonOverlaysTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var labelOverlays: UILabel = {
        let view = UILabel()
        view.text = NSLocalizedString("buttonLabelOverlays", comment: "")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = UIColor(hexaRGB: getContentColor(), alpha: 0.6)
        view.textAlignment = .center
        view.font = UIFont.preferredFont(forTextStyle: .headline)
        view.adjustsFontForContentSizeCategory = true
        return view
    }()
    
    lazy private var stickersButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "img_group670")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setButtonActiveColor(hex: getContentColor(), alpha: 0.6)
        button.tag = 37
        button.addTarget(self, action: #selector(buttonStickersTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var labelStickers: UILabel = {
        let view = UILabel()
        view.text = NSLocalizedString("buttonLabelStickers", comment: "")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = UIColor(hexaRGB: getContentColor(), alpha: 0.6)
        view.textAlignment = .center
        view.font = UIFont.preferredFont(forTextStyle: .headline)
        view.adjustsFontForContentSizeCategory = true
        return view
    }()
    
    lazy private var beautyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "img_group672")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setButtonActiveColor(hex: getContentColor(), alpha: 0.6)
        button.tag = 38
        button.addTarget(self, action: #selector(buttonBeautyTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var labelBeauty: UILabel = {
        let view = UILabel()
        view.text = NSLocalizedString("buttonLabelBeauty", comment: "")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = UIColor(hexaRGB: getContentColor(), alpha: 0.6)
        view.textAlignment = .center
        view.font = UIFont.preferredFont(forTextStyle: .headline)
        view.adjustsFontForContentSizeCategory = true
        return view
    }()
    
    lazy private var bordersButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "img_group670")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setButtonActiveColor(hex: getContentColor(), alpha: 0.6)
        button.tag = 39
        button.addTarget(self, action: #selector(buttonBordersTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var labelBorders: UILabel = {
        let view = UILabel()
        view.text = NSLocalizedString("buttonLabelBorders", comment: "")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = UIColor(hexaRGB: getContentColor(), alpha: 0.6)
        view.textAlignment = .center
        view.font = UIFont.preferredFont(forTextStyle: .headline)
        view.adjustsFontForContentSizeCategory = true
        return view
    }()
    
    lazy private var backgroundRemovalButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "img_remove_background")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setButtonActiveColor(hex: getContentColor(), alpha: 0.6)
        button.tag = 34
        button.addTarget(self, action: #selector(backgroundRemovalButtonTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var labelbackgroundRemoval: UILabel = {
        let view = UILabel()
        view.text = NSLocalizedString("buttonTitleBackgroundRemovalVC", comment: "")
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = UIColor(hexaRGB: getContentColor(), alpha: 0.6)
        view.textAlignment = .center
        view.font = UIFont.preferredFont(forTextStyle: .body)
        view.adjustsFontForContentSizeCategory = true
        view.setLineHeight(lineHeight: 0.8)
        return view
    }()
    
    lazy private var objectEraserButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "img_object_eraser")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setButtonActiveColor(hex: getContentColor(), alpha: 0.6)
        button.tag = 34
        button.addTarget(self, action: #selector(objectEraserButtonTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var labelobjectEraser: UILabel = {
        let view = UILabel()
        view.text = NSLocalizedString("buttonTitleObjectEraserVC", comment: "")
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = UIColor(hexaRGB: getContentColor(), alpha: 0.6)
        view.textAlignment = .center
        view.font = UIFont.preferredFont(forTextStyle: .headline)
        view.adjustsFontForContentSizeCategory = true
        view.setLineHeight(lineHeight: 0.8)
        return view
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(adjustPhotoSuccess(_:)), name: Notification.Name ("com.adjustphoto.success"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(cropPhotoSuccess(_:)), name: Notification.Name ("com.cropphoto.success"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(drawPhotoSuccess(_:)), name: Notification.Name ("com.drawphoto.success"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(textPhotoSuccess(_:)), name: Notification.Name ("com.textphoto.success"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(filterPhotoSuccess(_:)), name: Notification.Name ("com.filteredphoto.success"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(overlaysPhotoSuccess(_:)), name: Notification.Name ("com.overlaysphoto.success"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(stickersPhotoSuccess(_:)), name: Notification.Name ("com.stickersphoto.success"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(beautyPhotoSuccess(_:)), name: Notification.Name ("com.beautifiedphoto.success"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(borderPhotoSuccess(_:)), name: Notification.Name ("com.borderedphoto.success"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(backgroundRemovedImageSuccess(_:)), name: Notification.Name ("com.backgroundremovedimage.success"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reparedImageSuccess(_:)), name: Notification.Name ("com.reparedimage.success"), object: nil)
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
        
        filteredImage = receivedImage
        setUpUIStyleRedactor()
        
        setUpConstraintsStyleRedactor()
        NSLayoutConstraint.activate(sharedConstraints)
        layoutTraitStyleRedactor(traitCollection: UIScreen.main.traitCollection)
    }
    
    func setUpUIStyleRedactor() {
        
        setNavigationBar()
        
        self.view.backgroundColor = UIColor(hexaRGB: getBackgroundColor())
        masterView.addSubview(uiImageView)
        view.addSubview(masterView)
        setUpBottomActionPanel()
        setUpBottomPreviewPanel()
        setUpBottomToolsPanel()
    }
    
    func setNavigationBar() {
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationItem.setHidesBackButton(true, animated: false)
        let navTitle = UILabel()
        navTitle.text = NSLocalizedString("navBarTitleStyleRedactorVC", comment: "")
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
        leftView.addTarget(self, action: #selector(backButtonTap), for: .allTouchEvents)
        leftButton.customView = leftView
            
        let rightButton = UIBarButtonItem(title: NSLocalizedString("navBarButtonDone", comment: ""), style: .done, target: self, action: #selector(doneButtonTap))
        rightButton.tintColor = UIColor(hexaRGB: getContentColor())!
        rightButton.setTitleTextAttributes(navBarButtonTitleAttributes, for: .normal)
        
        self.navigationItem.leftBarButtonItem  = leftButton
        self.navigationItem.rightBarButtonItem  = rightButton
        
        self.navigationController?.navigationBar.semanticContentAttribute = .forceLeftToRight
    }
    
    func setUpBottomActionPanel() {
        
        masterView.addSubview(bottomActionPanel)
        bottomActionPanel.addSubview(styleButton)
        bottomActionPanel.addSubview(toolsButton)
        bottomActionPanel.addSubview(exportButton)
        
        NSLayoutConstraint.activate([
            bottomActionPanel.bottomAnchor.constraint(equalTo: masterView.bottomAnchor),
            bottomActionPanel.widthAnchor.constraint(equalTo: masterView.widthAnchor),
            bottomActionPanel.centerXAnchor.constraint(equalTo: masterView.centerXAnchor),
            bottomActionPanel.heightAnchor.constraint(equalToConstant: 55),
            
            styleButton.leftAnchor.constraint(equalTo: bottomActionPanel.leftAnchor, constant: 20.0),
            styleButton.bottomAnchor.constraint(equalTo: bottomActionPanel.bottomAnchor, constant: 0.0),
            styleButton.heightAnchor.constraint(equalToConstant: 55),
            
            toolsButton.centerXAnchor.constraint(equalTo: bottomActionPanel.centerXAnchor),
            toolsButton.bottomAnchor.constraint(equalTo: masterView.bottomAnchor, constant: 0.0),
            toolsButton.heightAnchor.constraint(equalToConstant: 55),
            
            exportButton.rightAnchor.constraint(equalTo: bottomActionPanel.rightAnchor, constant: -20.0),
            exportButton.bottomAnchor.constraint(equalTo: bottomActionPanel.bottomAnchor, constant: 0.0),
            exportButton.heightAnchor.constraint(equalToConstant: 55)
        ])
    }
    
    func setUpBottomPreviewPanel() {
        
        masterView.addSubview(bottomPreviewPanel)
        
        let imageButtonNormal = UIButton(frame: CGRect(x: 10.0, y: 10.0, width: 105, height: 125))
        imageButtonNormal.tag = 11
        imageButtonNormal.addTarget(self, action: #selector(setImageFilter), for: .touchUpInside)
        let imageViewNormal = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: 105, height: 125))
        imageViewNormal.image = receivedImage!
        imageViewNormal.contentMode = .scaleAspectFit
        imageViewNormal.tag = 41
        imageButtonNormal.addSubview(imageViewNormal)
        bottomPreviewPanel.addSubview(imageButtonNormal)
        
        let imageButtonMoon = UIButton(frame: CGRect(x: 125.0, y: 10.0, width: 105, height: 125))
        imageButtonMoon.tag = 12
        imageButtonMoon.addTarget(self, action: #selector(setImageFilter), for: .touchUpInside)
        let imageViewMoon = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: 105, height: 125))
        imageViewMoon.image = receivedImage!.filterEffectMoon()
        imageViewMoon.contentMode = .scaleAspectFit
        imageViewMoon.tag = 42
        imageButtonMoon.addSubview(imageViewMoon)
        bottomPreviewPanel.addSubview(imageButtonMoon)
        
        let imageButtonLark = UIButton(frame: CGRect(x: 240.0, y: 10.0, width: 105, height: 125))
        imageButtonLark.tag = 13
        imageButtonLark.addTarget(self, action: #selector(setImageFilter), for: .touchUpInside)
        let imageViewLark = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: 105, height: 125))
        imageViewLark.image = receivedImage!.filterEffectLark()
        imageViewLark.contentMode = .scaleAspectFit
        imageViewLark.tag = 43
        imageButtonLark.addSubview(imageViewLark)
        bottomPreviewPanel.addSubview(imageButtonLark)
        
        let imageButtonReyes = UIButton(frame: CGRect(x: 355.0, y: 10.0, width: 105, height: 125))
        imageButtonReyes.tag = 14
        imageButtonReyes.addTarget(self, action: #selector(setImageFilter), for: .touchUpInside)
        let imageViewReyes = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: 105, height: 125))
        imageViewReyes.image = receivedImage!.filterEffectReyes()
        imageViewReyes.contentMode = .scaleAspectFit
        imageViewReyes.tag = 44
        imageButtonReyes.addSubview(imageViewReyes)
        bottomPreviewPanel.addSubview(imageButtonReyes)
        
        let imageButtonHueAdjust = UIButton(frame: CGRect(x: 470.0, y: 10.0, width: 105, height: 125))
        imageButtonHueAdjust.tag = 15
        imageButtonHueAdjust.addTarget(self, action: #selector(setImageFilter), for: .touchUpInside)
        let imageViewHueAdjust = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: 105, height: 125))
        imageViewHueAdjust.image = receivedImage!.filterEffectHueAdjust()
        imageViewHueAdjust.contentMode = .scaleAspectFit
        imageViewHueAdjust.tag = 45
        imageButtonHueAdjust.addSubview(imageViewHueAdjust)
        bottomPreviewPanel.addSubview(imageButtonHueAdjust)
        
        let imageButtonRedToGreed = UIButton(frame: CGRect(x: 585.0, y: 10.0, width: 105, height: 125))
        imageButtonRedToGreed.tag = 16
        imageButtonRedToGreed.addTarget(self, action: #selector(setImageFilter), for: .touchUpInside)
        let imageViewRedToGreed = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: 105, height: 125))
        imageViewRedToGreed.image = receivedImage!.filterEffectRedToGreen()
        imageViewRedToGreed.contentMode = .scaleAspectFit
        imageViewRedToGreed.tag = 46
        imageButtonRedToGreed.addSubview(imageViewRedToGreed)
        bottomPreviewPanel.addSubview(imageButtonRedToGreed)
        
        bottomPreviewPanel.addSubview(labelNormal)
        bottomPreviewPanel.addSubview(labelMoon)
        bottomPreviewPanel.addSubview(labelLark)
        bottomPreviewPanel.addSubview(labelReyes)
        bottomPreviewPanel.addSubview(labelHue)
        bottomPreviewPanel.addSubview(labelRedToGreen)
        
        labelNormal.topAnchor.constraint(equalTo: imageButtonNormal.bottomAnchor, constant: 5).isActive = true
        labelNormal.centerXAnchor.constraint(equalTo: imageButtonNormal.centerXAnchor).isActive = true
        
        labelMoon.topAnchor.constraint(equalTo: imageButtonMoon.bottomAnchor, constant: 5).isActive = true
        labelMoon.centerXAnchor.constraint(equalTo: imageButtonMoon.centerXAnchor).isActive = true
        
        labelLark.topAnchor.constraint(equalTo: imageButtonLark.bottomAnchor, constant: 5).isActive = true
        labelLark.centerXAnchor.constraint(equalTo: imageButtonLark.centerXAnchor).isActive = true
        
        labelReyes.topAnchor.constraint(equalTo: imageButtonReyes.bottomAnchor, constant: 5).isActive = true
        labelReyes.centerXAnchor.constraint(equalTo: imageButtonReyes.centerXAnchor).isActive = true
        
        labelHue.topAnchor.constraint(equalTo: imageButtonHueAdjust.bottomAnchor, constant: 5).isActive = true
        labelHue.centerXAnchor.constraint(equalTo: imageButtonHueAdjust.centerXAnchor).isActive = true
        
        labelRedToGreen.topAnchor.constraint(equalTo: imageButtonRedToGreed.bottomAnchor, constant: 5).isActive = true
        labelRedToGreen.centerXAnchor.constraint(equalTo: imageButtonRedToGreed.centerXAnchor).isActive = true
        
        bottomPreviewPanel.bottomAnchor.constraint(equalTo: bottomActionPanel.topAnchor, constant: -5).isActive = true
        bottomPreviewPanel.widthAnchor.constraint(equalTo: masterView.widthAnchor).isActive = true
        bottomPreviewPanel.heightAnchor.constraint(equalToConstant: 165).isActive = true
    }
    
    func setUpBottomToolsPanel() {
        masterView.addSubview(toolsPanel)
        toolsPanel.addSubview(adjustButton)
        toolsPanel.addSubview(labelAdjust)
        toolsPanel.addSubview(cropButton)
        toolsPanel.addSubview(labelCrop)
        toolsPanel.addSubview(drawButton)
        toolsPanel.addSubview(labelDraw)
        toolsPanel.addSubview(textButton)
        toolsPanel.addSubview(labelText)
        toolsPanel.addSubview(filtersButton)
        toolsPanel.addSubview(labelFilters)
        toolsPanel.addSubview(overlaysButton)
        toolsPanel.addSubview(labelOverlays)
        toolsPanel.addSubview(stickersButton)
        toolsPanel.addSubview(labelStickers)
        toolsPanel.addSubview(beautyButton)
        toolsPanel.addSubview(labelBeauty)
        toolsPanel.addSubview(bordersButton)
        toolsPanel.addSubview(labelBorders)
        toolsPanel.addSubview(backgroundRemovalButton)
        toolsPanel.addSubview(labelbackgroundRemoval)
        toolsPanel.addSubview(objectEraserButton)
        toolsPanel.addSubview(labelobjectEraser)
        
        NSLayoutConstraint.activate([
            toolsPanel.bottomAnchor.constraint(equalTo: bottomActionPanel.topAnchor),
            toolsPanel.rightAnchor.constraint(equalTo: masterView.rightAnchor),
            toolsPanel.leftAnchor.constraint(equalTo: masterView.leftAnchor),
            toolsPanel.heightAnchor.constraint(equalToConstant: 380),
            
            adjustButton.topAnchor.constraint(equalTo: toolsPanel.topAnchor, constant: 10.0),
            adjustButton.leftAnchor.constraint(equalTo: toolsPanel.leftAnchor, constant: 40.0),
            adjustButton.heightAnchor.constraint(equalToConstant: 50),
            
            labelAdjust.topAnchor.constraint(equalTo: adjustButton.bottomAnchor, constant: 5.0),
            labelAdjust.centerXAnchor.constraint(equalTo: adjustButton.centerXAnchor),
            
            cropButton.topAnchor.constraint(equalTo: toolsPanel.topAnchor, constant: 10.0),
            cropButton.centerXAnchor.constraint(equalTo: toolsPanel.centerXAnchor),
            cropButton.heightAnchor.constraint(equalToConstant: 50),
            
            labelCrop.topAnchor.constraint(equalTo: cropButton.bottomAnchor, constant: 5.0),
            labelCrop.centerXAnchor.constraint(equalTo: cropButton.centerXAnchor),
            
            drawButton.topAnchor.constraint(equalTo: toolsPanel.topAnchor, constant: 10.0),
            drawButton.rightAnchor.constraint(equalTo: toolsPanel.rightAnchor, constant: -40.0),
            drawButton.heightAnchor.constraint(equalToConstant: 50),
            
            labelDraw.topAnchor.constraint(equalTo: drawButton.bottomAnchor, constant: 5.0),
            labelDraw.centerXAnchor.constraint(equalTo: drawButton.centerXAnchor),
            
            textButton.topAnchor.constraint(equalTo: labelDraw.bottomAnchor, constant: 10.0),
            textButton.leftAnchor.constraint(equalTo: toolsPanel.leftAnchor, constant: 40.0),
            textButton.heightAnchor.constraint(equalToConstant: 50),
            labelText.topAnchor.constraint(equalTo: textButton.bottomAnchor, constant: 5.0),
            labelText.centerXAnchor.constraint(equalTo: textButton.centerXAnchor),
            
            filtersButton.topAnchor.constraint(equalTo: labelCrop.bottomAnchor, constant: 10.0),
            filtersButton.centerXAnchor.constraint(equalTo: toolsPanel.centerXAnchor),
            filtersButton.heightAnchor.constraint(equalToConstant: 50),
            labelFilters.topAnchor.constraint(equalTo: filtersButton.bottomAnchor, constant: 5.0),
            labelFilters.centerXAnchor.constraint(equalTo: filtersButton.centerXAnchor),
            
            overlaysButton.topAnchor.constraint(equalTo: labelDraw.bottomAnchor, constant: 10.0),
            overlaysButton.rightAnchor.constraint(equalTo: toolsPanel.rightAnchor, constant: -40.0),
            overlaysButton.heightAnchor.constraint(equalToConstant: 50),
            labelOverlays.topAnchor.constraint(equalTo: overlaysButton.bottomAnchor, constant: 5.0),
            labelOverlays.centerXAnchor.constraint(equalTo: overlaysButton.centerXAnchor),
            
            stickersButton.topAnchor.constraint(equalTo: labelText.bottomAnchor, constant: 10.0),
            stickersButton.leftAnchor.constraint(equalTo: toolsPanel.leftAnchor, constant: 40.0),
            stickersButton.heightAnchor.constraint(equalToConstant: 50),
            labelStickers.topAnchor.constraint(equalTo: stickersButton.bottomAnchor, constant: 5.0),
            labelStickers.centerXAnchor.constraint(equalTo: stickersButton.centerXAnchor),
            
            beautyButton.topAnchor.constraint(equalTo: labelFilters.bottomAnchor, constant: 10.0),
            beautyButton.centerXAnchor.constraint(equalTo: toolsPanel.centerXAnchor),
            beautyButton.heightAnchor.constraint(equalToConstant: 50),
            labelBeauty.topAnchor.constraint(equalTo: beautyButton.bottomAnchor, constant: 5.0),
            labelBeauty.centerXAnchor.constraint(equalTo: beautyButton.centerXAnchor),
            
            bordersButton.topAnchor.constraint(equalTo: labelOverlays.bottomAnchor, constant: 10.0),
            bordersButton.rightAnchor.constraint(equalTo: toolsPanel.rightAnchor, constant: -40.0),
            bordersButton.heightAnchor.constraint(equalToConstant: 50),
            labelBorders.topAnchor.constraint(equalTo: bordersButton.bottomAnchor, constant: 5.0),
            labelBorders.centerXAnchor.constraint(equalTo: bordersButton.centerXAnchor),
            
            backgroundRemovalButton.topAnchor.constraint(equalTo: labelStickers.bottomAnchor, constant: 10.0),
            backgroundRemovalButton.leftAnchor.constraint(equalTo: toolsPanel.leftAnchor, constant: 40.0),
            backgroundRemovalButton.heightAnchor.constraint(equalToConstant: 50),
            
            labelbackgroundRemoval.topAnchor.constraint(equalTo: backgroundRemovalButton.bottomAnchor, constant: 10.0),
            labelbackgroundRemoval.centerXAnchor.constraint(equalTo: backgroundRemovalButton.centerXAnchor),
            
            objectEraserButton.topAnchor.constraint(equalTo: labelBeauty.bottomAnchor, constant: 10.0),
            objectEraserButton.rightAnchor.constraint(equalTo: toolsPanel.rightAnchor, constant: -40.0),
            objectEraserButton.heightAnchor.constraint(equalToConstant: 50),
            
            labelobjectEraser.topAnchor.constraint(equalTo: objectEraserButton.bottomAnchor, constant: 10.0),
            labelobjectEraser.centerXAnchor.constraint(equalTo: objectEraserButton.centerXAnchor),
        ])
    }
    
    @objc func setImageFilter(sender: UIButton) {
        
        selectedShade = sender.tag
        
        switch sender.tag {
            case 11:
                filteredImage = receivedImage!
                uiImageView.image = filteredImage
            case 12:
                filteredImage = receivedImage!.filterEffectMoon()
                uiImageView.image = filteredImage
            case 13:
                filteredImage = receivedImage!.filterEffectLark()
                uiImageView.image = filteredImage
            case 14:
                filteredImage = receivedImage!.filterEffectReyes()
                uiImageView.image = filteredImage
            case 15:
                filteredImage = receivedImage!.filterEffectHueAdjust()
                uiImageView.image = filteredImage
            case 16:
                filteredImage = receivedImage!.filterEffectRedToGreen()
                uiImageView.image = filteredImage
            default:
                break
        }
        
        if let foundView = view.viewWithTag(Int("1\(selectedShade)")!) as? UILabel {
            foundView.textColor = UIColor(hexaRGB: getContentColor(), alpha: 1)
        }
        
        setButtonsLabelsActiveColor(selectedButtonTag: selectedShade, selectedLabelTag: Int("1\(selectedShade)")!)
    }
    
    @objc func backButtonTap(sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func doneButtonTap(sender: Any) {
        receivedImage = filteredImage
        uiImageView.image = UIImage(cgImage: (filteredImage?.cgImage!)!, scale: receivedImage!.scale, orientation: receivedImage!.imageOrientation)
    }
    
    @objc func buttonStyleTap(sender: Any) {
        bottomPreviewPanel.isHidden = false
        toolsPanel.isHidden = true
        suffleButtonActiveColor(buttonIndex: 0)
    }
    
    @objc func buttonToolsTap(sender: Any) {
        toolsPanel.isHidden = false
        bottomPreviewPanel.isHidden = true
        suffleButtonActiveColor(buttonIndex: 1)
    }
    
    @objc func buttonExportTap(sender: Any) {
        toolsPanel.isHidden = true
        suffleButtonActiveColor(buttonIndex: 2)
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.setBackgroundColor(color: UIColor(named: "Gray800")!)
        
        let settingsAction = UIAlertAction(title: NSLocalizedString("actionSheetExportGallery", comment: ""), style: .default , handler:{ (UIAlertAction) in
            self.exportToAlbum()
        })
        settingsAction.setValue(UIColor.white, forKey: "titleTextColor")
        alertController.addAction(settingsAction)
        
        let reviewAction = UIAlertAction(title: NSLocalizedString("actionSheetShare", comment: ""), style: .default , handler:{ (UIAlertAction)in
            self.nearbyShare()
        })
        reviewAction.setValue(UIColor.white, forKey: "titleTextColor")
        alertController.addAction(reviewAction)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("actionSheetCancel", comment: ""), style: .default , handler:{ (UIAlertAction)in
            self.masterView.backgroundColor = UIColor(hexaRGB: getBackgroundColor())!
        })
        cancelAction.setValue(UIColor.white, forKey: "titleTextColor")
        alertController.addAction(cancelAction)
        
        //uncomment for iPad Support
        alertController.popoverPresentationController?.sourceView = self.view
        alertController.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 1, height: 1)
        
        self.present(alertController, animated: true, completion: {
            alertController.view.superview?.subviews.first?.isUserInteractionEnabled = true

            // Adding Tap Gesture to Overlay
            alertController.view.superview?.subviews.first?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
        })
    }
    
    @objc func buttonAdjustTap(sender: Any) {
        
        toolsPanel.isHidden = true
        bottomPreviewPanel.isHidden = false
        let vc = ViewControllerAdjust()
        vc.receivedImage = filteredImage
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func buttonCropPressed(sender: Any) {
        
        toolsPanel.isHidden = true
        bottomPreviewPanel.isHidden = false
        let vc = ViewControllerCrop()
        vc.receivedImage = filteredImage
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func buttonDrawPressed(sender: Any) {
        
        toolsPanel.isHidden = true
        bottomPreviewPanel.isHidden = false
        let vc = ViewControllerDraw()
        vc.receivedImage = filteredImage
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func buttonTextTap(sender: Any) {
        
        toolsPanel.isHidden = true
        bottomPreviewPanel.isHidden = false
        let vc = ViewControllerText()
        vc.receivedImage = filteredImage
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func buttonFiltersTap(sender: Any) {
        
        toolsPanel.isHidden = true
        bottomPreviewPanel.isHidden = false
        let vc = ViewControllerFilters()
        vc.receivedImage = filteredImage
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func buttonOverlaysTap(sender: Any) {
        
        toolsPanel.isHidden = true
        bottomPreviewPanel.isHidden = false
        let vc = ViewControllerOverlays()
        vc.receivedImage = filteredImage
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func buttonStickersTap(sender: Any) {
        
        toolsPanel.isHidden = true
        bottomPreviewPanel.isHidden = false
        let vc = ViewControllerStickers()
        vc.receivedImage = filteredImage
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func buttonBeautyTap(sender: Any) {
        
        toolsPanel.isHidden = true
        bottomPreviewPanel.isHidden = false
        let vc = ViewControllerBeauty()
        vc.receivedImage = filteredImage
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func buttonBordersTap(sender: Any) {
        
        toolsPanel.isHidden = true
        bottomPreviewPanel.isHidden = false
        let vc = ViewControllerBorders()
        vc.receivedImage = filteredImage
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func backgroundRemovalButtonTap(sender: Any) {
        
        toolsPanel.isHidden = true
        bottomPreviewPanel.isHidden = false
        let vc = ViewControllerBackgroundRemoval()
        vc.receivedImage = filteredImage
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func objectEraserButtonTap(sender: Any) {
        
        toolsPanel.isHidden = true
        bottomPreviewPanel.isHidden = false
        let vc = ViewControllerObjectEraser()
        vc.receivedImage = filteredImage
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func suffleButtonActiveColor(buttonIndex: Int?) {
        
        switch buttonIndex! {
            case 0:
            styleButton.setButtonActiveColor(hex: getContentColor(), alpha: 0.8)
                toolsButton.setButtonActiveColor(hex: getContentColor(), alpha: 0.6)
                exportButton.setButtonActiveColor(hex: getContentColor(), alpha: 0.3)
            case 1:
                styleButton.setButtonActiveColor(hex: getContentColor(), alpha: 0.3)
                toolsButton.setButtonActiveColor(hex: getContentColor(), alpha: 1)
                exportButton.setButtonActiveColor(hex: getContentColor(), alpha: 0.3)
            case 2:
                styleButton.setButtonActiveColor(hex: getContentColor(), alpha: 0.3)
                toolsButton.setButtonActiveColor(hex: getContentColor(), alpha: 0.6)
                exportButton.setButtonActiveColor(hex: getContentColor(), alpha: 0.8)
            default:
                styleButton.setButtonActiveColor(hex: getContentColor(), alpha: 0.8)
                toolsButton.setButtonActiveColor(hex: getContentColor(), alpha: 0.6)
                exportButton.setButtonActiveColor(hex: getContentColor(), alpha: 0.3)
        }
    }
    
    func setUpConstraintsStyleRedactor() {
        
        let safeArea = view.safeAreaLayoutGuide
        scaledSize = calculateImageViewScale(viewSize: self.view.bounds.size, imageSize: receivedImage!.size, leftRightAnchorConstant: 20, topBottomAnchorConstant: 165)
        
        sharedConstraints.append(contentsOf: [
            masterView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            masterView.leftAnchor.constraint(equalTo: safeArea.leftAnchor),
            masterView.rightAnchor.constraint(equalTo: safeArea.rightAnchor),
            masterView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: 10),
            
            uiImageView.topAnchor.constraint(equalTo: masterView.topAnchor, constant: 5),
            uiImageView.leftAnchor.constraint(equalTo: masterView.leftAnchor, constant: 10),
            uiImageView.widthAnchor.constraint(equalTo: masterView.widthAnchor, constant: -20),
            uiImageView.heightAnchor.constraint(equalToConstant: scaledSize.height),
            
        ])
        
        regularConstraints.append(contentsOf: [
            masterView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            masterView.leftAnchor.constraint(equalTo: safeArea.leftAnchor),
            masterView.rightAnchor.constraint(equalTo: safeArea.rightAnchor),
            masterView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: 10),
            
            uiImageView.topAnchor.constraint(equalTo: masterView.topAnchor, constant: 5),
            uiImageView.leftAnchor.constraint(equalTo: masterView.leftAnchor, constant: 10),
            uiImageView.widthAnchor.constraint(equalTo: masterView.widthAnchor, constant: -20),
            uiImageView.heightAnchor.constraint(equalToConstant: scaledSize.height),
        ])
        
        compactConstraints.append(contentsOf: [
            masterView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            masterView.leftAnchor.constraint(equalTo: safeArea.leftAnchor),
            masterView.rightAnchor.constraint(equalTo: safeArea.rightAnchor),
            masterView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: 10),
            
            uiImageView.topAnchor.constraint(equalTo: masterView.topAnchor, constant: 5),
            uiImageView.leftAnchor.constraint(equalTo: masterView.leftAnchor, constant: 10),
            uiImageView.widthAnchor.constraint(equalTo: masterView.widthAnchor, constant: -20),
            uiImageView.heightAnchor.constraint(equalToConstant: scaledSize.height),
        ])
    }
    
    func layoutTraitStyleRedactor(traitCollection:UITraitCollection) {
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
    
    func reloadBottomPreviewPanel() {
        
        if let foundView = view.viewWithTag(41) as? UIImageView {
            foundView.image = receivedImage!
        }
        if let foundView = view.viewWithTag(42) as? UIImageView {
            DispatchQueue.main.async {
                foundView.image = self.receivedImage!.filterEffectMoon()
            }
        }
        if let foundView = view.viewWithTag(43) as? UIImageView {
            DispatchQueue.main.async {
                foundView.image = self.receivedImage!.filterEffectLark()
            }
        }
        if let foundView = view.viewWithTag(44) as? UIImageView {
            DispatchQueue.main.async {
                foundView.image = self.receivedImage!.filterEffectReyes()
            }
        }
        if let foundView = view.viewWithTag(45) as? UIImageView {
            DispatchQueue.main.async {
                foundView.image = self.receivedImage!.filterEffectHueAdjust()
            }
        }
        if let foundView = view.viewWithTag(46) as? UIImageView {
            DispatchQueue.main.async {
                foundView.image = self.receivedImage!.filterEffectRedToGreen()
            }
        }
    }
    
    @objc func adjustPhotoSuccess(_ notification: Notification) {
        
        var notification = notification
        if let image = notification.userInfo?["image"] as? UIImage {
            uiImageView.image = image
            filteredImage = image
            receivedImage = image
            
            reloadBottomPreviewPanel()
            NotificationCenter.default.removeObserver(self, name: Notification.Name("com.adjustphoto.success"), object: nil)
            notification.userInfo?.removeAll()
        }
    }
    
    @objc func cropPhotoSuccess(_ notification: Notification) {
        
        var notification = notification
        if let image = notification.userInfo?["croppedImage"] as? UIImage {
            uiImageView.image = image
            filteredImage = image
            receivedImage = image
            
            reloadBottomPreviewPanel()
            NotificationCenter.default.removeObserver(self, name: Notification.Name("com.cropphoto.success"), object: nil)
            notification.userInfo?.removeAll()
        }
    }
    
    @objc func drawPhotoSuccess(_ notification: Notification) {
        
        var notification = notification
        if let image = notification.userInfo?["drawonImage"] as? UIImage {
            uiImageView.image = image
            filteredImage = image
            receivedImage = image
            
            reloadBottomPreviewPanel()
            NotificationCenter.default.removeObserver(self, name: Notification.Name("com.drawphoto.success"), object: nil)
            notification.userInfo?.removeAll()
        }
    }
    
    @objc func textPhotoSuccess(_ notification: Notification) {
        
        var notification = notification
        if let image = notification.userInfo?["textedImage"] as? UIImage {
            uiImageView.image = image
            filteredImage = image
            receivedImage = image
            
            reloadBottomPreviewPanel()
            NotificationCenter.default.removeObserver(self, name: Notification.Name("com.textphoto.success"), object: nil)
            notification.userInfo?.removeAll()
        }
    }
    
    @objc func filterPhotoSuccess(_ notification: Notification) {
        
        var notification = notification
        if let image = notification.userInfo?["filteredImage"] as? UIImage {
            uiImageView.image = image
            filteredImage = image
            receivedImage = image
            
            reloadBottomPreviewPanel()
            NotificationCenter.default.removeObserver(self, name: Notification.Name("com.filteredphoto.success"), object: nil)
            notification.userInfo?.removeAll()
        }
    }
    
    @objc func overlaysPhotoSuccess(_ notification: Notification) {
        
        var notification = notification
        if let image = notification.userInfo?["overlaysImage"] as? UIImage {
            uiImageView.image = image
            filteredImage = image
            receivedImage = image
            
            reloadBottomPreviewPanel()
            NotificationCenter.default.removeObserver(self, name: Notification.Name("com.overlaysphoto.success"), object: nil)
            notification.userInfo?.removeAll()
        }
    }
    
    @objc func stickersPhotoSuccess(_ notification: Notification) {
        
        var notification = notification
        if let image = notification.userInfo?["stickersImage"] as? UIImage {
            uiImageView.image = image
            filteredImage = image
            receivedImage = image
            
            reloadBottomPreviewPanel()
            NotificationCenter.default.removeObserver(self, name: Notification.Name("com.stickersphoto.success"), object: nil)
            notification.userInfo?.removeAll()
        }
    }
    
    @objc func beautyPhotoSuccess(_ notification: Notification) {
        
        var notification = notification
        if let image = notification.userInfo?["beautifiedImage"] as? UIImage {
            uiImageView.image = image
            filteredImage = image
            receivedImage = image
            
            reloadBottomPreviewPanel()
            NotificationCenter.default.removeObserver(self, name: Notification.Name("com.beautifiedphoto.success"), object: nil)
            notification.userInfo?.removeAll()
        }
    }
    
    @objc func borderPhotoSuccess(_ notification: Notification) {
        
        var notification = notification
        if let image = notification.userInfo?["borderedImage"] as? UIImage {
            uiImageView.image = image
            filteredImage = image
            receivedImage = image
            
            reloadBottomPreviewPanel()
            NotificationCenter.default.removeObserver(self, name: Notification.Name("com.borderedphoto.success"), object: nil)
            notification.userInfo?.removeAll()
        }
    }
    
    @objc func backgroundRemovedImageSuccess(_ notification: Notification) {
        
        var notification = notification
        if let image = notification.userInfo?["backgroundRemovedImage"] as? UIImage {
            uiImageView.image = image
            filteredImage = image
            receivedImage = image
            
            reloadBottomPreviewPanel()
            NotificationCenter.default.removeObserver(self, name: Notification.Name("com.backgroundremovedimage.success"), object: nil)
            notification.userInfo?.removeAll()
        }
    }
    
    @objc func reparedImageSuccess(_ notification: Notification) {
        
        var notification = notification
        if let image = notification.userInfo?["reparedImage"] as? UIImage {
            uiImageView.image = image
            filteredImage = image
            receivedImage = image
            
            reloadBottomPreviewPanel()
            NotificationCenter.default.removeObserver(self, name: Notification.Name("com.reparedimage.success"), object: nil)
            notification.userInfo?.removeAll()
        }
    }
    
    @objc func alertControllerBackgroundTapped()
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    func createAlbum(completionHandler:@escaping (_ createAlbumSuccess: Bool) -> Void) {
        //Get PHFetch Options
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", self.albumName)
        let collection : PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        //Check return value - If found, then get the first album out
        if collection.firstObject != nil{
            //found the album
            completionHandler(true)
            self.assetCollection = collection.firstObject!
        } else {
            //If not found - Then create a new album
            PHPhotoLibrary.shared().performChanges({
                PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: self.albumName)   // create an asset collection with the album name
                }) { success, error in
                    if success {
                        completionHandler(true)
                        self.assetCollection = self.fetchAssetCollectionForAlbum()
                    } else {
                        completionHandler(false)
                        DispatchQueue.main.async {
                            self.showAlert(alertTitle: NSLocalizedString("alertTitleCreateAlbum", comment: ""), alertMsg: error?.localizedDescription)
                        }
                    }
            }
        }
    }
    
    func exportToAlbum() {
        
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
            case .authorized, .limited:
                self.saveToGallery()
                break
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization({
                    (newStatus) in
                    DispatchQueue.main.async {
                        if newStatus ==  PHAuthorizationStatus.authorized {
                            self.saveToGallery()
                        }else{
                            self.alertGalleryAccessNeeded()
                        }
                }})
            break
            case .restricted, .denied: // previously denied
                self.alertGalleryAccessNeeded()
                break
            /*case .limited:
                // The user authorized this app for limited Photos access.
                // The user authorized this app for limited Photos access.
                PHPhotoLibrary.requestAuthorization() { result in
                    if #available(iOS 14, *) {
                        PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: self)
                        PHPhotoLibrary.shared().register(self)
                    }
                }
                break*/
            @unknown default:
                return
        }
    }
    
    private func saveToGallery() {
        
        PHPhotoLibrary.shared().performChanges({
            let fetchOptions = PHFetchOptions()
            fetchOptions.predicate = NSPredicate(format: "title = %@", self.albumName)
            let collection : PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
            //Check return value - If found, then get the first album out
            if collection.firstObject != nil{
                //found the album
                self.assetCollection = collection.firstObject!
                self.saveImage(image: self.filteredImage!)
            }
            else {
                self.createAlbum() { createAlbumSuccess in
                    if createAlbumSuccess {
                        self.saveImage(image: self.filteredImage!)
                    } else {
                        DispatchQueue.main.async {
                            self.showAlert(alertTitle: NSLocalizedString("alertTitleCreateAlbum", comment: ""), alertMsg: NSLocalizedString("alertMsgCreateAlbumError", comment: ""))
                        }
                    }
                }
            }
        }, completionHandler: { _, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.showAlert(alertTitle: NSLocalizedString("alertTitleCreateAlbum", comment: ""), alertMsg: error.localizedDescription)
                }
            }
        })
    }
    
    private  func alertGalleryAccessNeeded() {
        let alert = UIAlertController(
            title: NSLocalizedString("alertTitleGallerySettings", comment: ""),
            message: NSLocalizedString("alertMessageGallerySettings", comment: ""),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: NSLocalizedString("actionSheetCancel", comment: ""), style: .cancel))
        alert.addAction(UIAlertAction(title: NSLocalizedString("alertButtonAllow", comment: ""), style: .default) { _ in
            self.goToPrivacySettings()
        })
        //uncomment for iPad Support
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 1, height: 1)
        present(alert, animated: true)
    }
    
    func goToPrivacySettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString),
            UIApplication.shared.canOpenURL(url) else {
                return
        }

        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    /* PHPhotoLibraryChangeObserver event*/
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        
    }
    
    func fetchAssetCollectionForAlbum() -> PHAssetCollection! {
        let fetchOptions = PHFetchOptions()
        fetchOptions.includeHiddenAssets = false
        //fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.predicate = NSPredicate(format: "title = %@", self.albumName)
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        if let firstObject: AnyObject = collection.firstObject {
            return collection.firstObject
        }

        return nil
    }
    
    func saveImage(image: UIImage) {

        if assetCollection == nil {
            return   // If there was an error upstream, skip the save.
        }

        PHPhotoLibrary.shared().performChanges({
            let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
                let assetPlaceholder = assetChangeRequest.placeholderForCreatedAsset
            let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection)
            albumChangeRequest!.addAssets([assetPlaceholder] as NSFastEnumeration)
            DispatchQueue.main.async {
                self.showAlert(alertTitle: NSLocalizedString("alertTitleExportPhoto", comment: ""), alertMsg: NSLocalizedString("alertMsgExportPhotoSuccess", comment: ""))
            }
        }, completionHandler:  { _, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.showAlert(alertTitle: NSLocalizedString("alertTitleExportPhoto", comment: ""), alertMsg: error.localizedDescription)
                }
            }
        })
    }
    
    func nearbyShare() {
        let controller = UIActivityViewController(activityItems: [filteredImage!], applicationActivities: nil)
        controller.excludedActivityTypes = [.postToFacebook, .postToTwitter, .print, .copyToPasteboard, .assignToContact, .saveToCameraRoll, .mail]
        
        //uncomment for iPad Support
        controller.popoverPresentationController?.sourceView = self.view
        controller.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 1, height: 1)
        self.present(controller, animated: true, completion: nil)
    }
    
    func showAlert(alertTitle: String?, alertMsg: String?) {
        
        let attributedTitleString = NSAttributedString(string: alertTitle!, attributes: [
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20),
            NSAttributedString.Key.foregroundColor : UIColor.white
        ])
        let attributedMsgString = NSAttributedString(string: alertMsg!, attributes: [
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16),
            NSAttributedString.Key.foregroundColor : UIColor.white
        ])
        
        let alertController = UIAlertController(title: alertTitle, message: alertMsg, preferredStyle: .alert)
        alertController.setValue(attributedTitleString, forKey: "attributedTitle")
        alertController.setValue(attributedMsgString, forKey: "attributedMessage")
        alertController.setBackgroundColor(color: UIColor(named: "Gray800")!)
         
        let cancelAction = UIAlertAction(title: NSLocalizedString("alertActionOK", comment: ""), style: .default , handler:{ (UIAlertAction)in
            self.masterView.backgroundColor = UIColor(hexaRGB: getBackgroundColor())!
        })
        cancelAction.setValue(UIColor.white, forKey: "titleTextColor")
        alertController.addAction(cancelAction)

        //uncomment for iPad Support
        alertController.popoverPresentationController?.sourceView = self.view
        alertController.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 1, height: 1);

        self.present(alertController, animated: true, completion: {
            alertController.view.superview?.subviews.first?.isUserInteractionEnabled = true

            // Adding Tap Gesture to Overlay
            alertController.view.superview?.subviews.first?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
        })
    }
    
    func setButtonsLabelsActiveColor(selectedButtonTag: Int?, selectedLabelTag: Int?) {
        
        for i in 111...116 {
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
