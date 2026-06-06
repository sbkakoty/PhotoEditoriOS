//
//  ObjectEraserViewController.swift
//  PhotoEditorFilterEffects
//
//  Created by Sonjoy Borkakoty on 29/12/22.
//

import UIKit
import Photos
import PhotosUI

class ViewControllerObjectEraser: UIViewController {
    
    private var assetCollection: PHAssetCollection!
    
    var receivedImage: UIImage?
    var reparedImage: UIImage?
    
    private var resizedImage: UIImage?
    private var maskImage: UIImage?
    private var selectionSize: CGFloat = 4.0
    private var scaledSize: CGSize?
    
    private var objectEraserViewModel: ObjectEraserViewModel?
    
    private var compactConstraints: [NSLayoutConstraint] = []
    private var regularConstraints: [NSLayoutConstraint] = []
    private var sharedConstraints: [NSLayoutConstraint] = []
    
    private lazy var masterView: UIView = {
        let view = UINib(nibName: "MasterViewObjectEraser", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
        view.frame = UIScreen.main.bounds
        view.backgroundColor = UIColor(hexaRGB: getBackgroundColor())!
        view.translatesAutoresizingMaskIntoConstraints = false
        view.tag = 1
        return view
    }()
    
    private lazy var uiImageViewCartoonErase: UIImageView = {
        let uiImageView = UIImageView()
        uiImageView.translatesAutoresizingMaskIntoConstraints = false
        uiImageView.image = UIImage(named: "img_cartoon_eraser")?.withRenderingMode(.alwaysOriginal)
        uiImageView.contentMode = .scaleAspectFit
        return uiImageView
    }()
    
    private lazy var labelSubTitle: UILabel = {
        let view = UILabel()
        view.text = NSLocalizedString("viewSubTitleObjectEraserVC", comment: "")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = UIColor(hexaRGB: getContentColor(), alpha: 1)
        view.textAlignment = .center
        view.numberOfLines = 2
        view.lineBreakMode = .byWordWrapping
        view.font = UIFont.preferredFont(forTextStyle: .body).bold()
        view.adjustsFontForContentSizeCategory = true
        return view
    }()
    
    private lazy var uiImageView: UIImageView = {
        let uiImageView = UIImageView()
        uiImageView.translatesAutoresizingMaskIntoConstraints = false
        uiImageView.image = receivedImage!
        uiImageView.layer.borderColor = UIColor(hexaRGB: "#DDDDDD")?.cgColor
        uiImageView.layer.borderWidth = 2
        uiImageView.layer.cornerRadius = 5
        uiImageView.clipsToBounds = true
        uiImageView.contentMode = .scaleAspectFit
        return uiImageView
    }()
    
    private lazy var maskImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        return view
    }()

    private lazy var selectionView: DrawingSelectionAreaView = {
        let view = DrawingSelectionAreaView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private lazy var indicator: ProgressIndicatorPE = {
        let view = ProgressIndicatorPE(inview: self.view, loadingViewColor: UIColor(named: "Gray800")!, indicatorColor: UIColor.white, msg: NSLocalizedString("indicatorTitleBackgroundRemovalVC", comment: ""))
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
    
    lazy private var buttonCircle1: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "img_ellipse36")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = UIColor(hexaRGB: "#7D038C", alpha: 1)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setButtonActiveColor(hex: "#7D038C", alpha: 1)
        button.tag = 20
        button.addTarget(self, action: #selector(tabOptionTap), for: .touchUpInside)
        return button
    }()
    
    lazy private var buttonCircle2: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "img_ellipse37")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setButtonActiveColor(hex: getContentColor(), alpha: 0.6)
        button.tag = 26
        button.addTarget(self, action: #selector(tabOptionTap), for: .touchUpInside)
        return button
    }()
    
    lazy private var buttonCircle3: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "img_ellipse38")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setButtonActiveColor(hex: getContentColor(), alpha: 0.6)
        button.tag = 30
        button.addTarget(self, action: #selector(tabOptionTap), for: .touchUpInside)
        return button
    }()
    
    lazy private var buttonCircle4: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "img_ellipse39")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setButtonActiveColor(hex: getContentColor(), alpha: 0.6)
        button.tag = 36
        button.addTarget(self, action: #selector(tabOptionTap), for: .touchUpInside)
        return button
    }()
    
    lazy private var buttonCircle5: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "img_ellipse41")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setButtonActiveColor(hex: getContentColor(), alpha: 0.6)
        button.tag = 42
        button.addTarget(self, action: #selector(tabOptionTap), for: .touchUpInside)
        return button
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        resizedImage = uiImageView.asScaledImage(scaledSize: scaledSize!)
        uiImageView.image = resizedImage
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //handle dark mode
        if #available(iOS 13.0, *) {
            view.overrideUserInterfaceStyle = .light
        }
        
        reparedImage = receivedImage!
        setUpUIObjectEraser()
        setUpBottomActionPanelObjectEraser()
        
        setUpConstraintsObjectEraser()
        NSLayoutConstraint.activate(sharedConstraints)
        layoutTraitObjectEraser(traitCollection: UIScreen.main.traitCollection)
        
        drawSelection()
    }
    
    func setUpUIObjectEraser() {
        
        view.backgroundColor = UIColor(hexaRGB: getBackgroundColor())
        setNavBarObjectEraser()
        masterView.addSubview(uiImageViewCartoonErase)
        masterView.addSubview(labelSubTitle)
        masterView.addSubview(uiImageView)
        masterView.addSubview(maskImageView)
        masterView.addSubview(selectionView)
        masterView.addSubview(indicator)
        view.addSubview(masterView)
    }
    
    func setNavBarObjectEraser() {
        
        self.navigationItem.setHidesBackButton(true, animated: false)
        let navTitle = UILabel()
        navTitle.text = NSLocalizedString("navTitleObjectEraserVC", comment: "")
        navTitle.font = UIFont.preferredFont(forTextStyle: .title3)
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
        leftView.addTarget(self, action: #selector(backButtonTapObjectEraser), for: .allTouchEvents)
        leftButton.customView = leftView
            
        let rightButton = UIBarButtonItem(title: NSLocalizedString("navBarButtonDone", comment: ""), style: .done, target: self, action: #selector(doneButtonTapObjectEraser))
        rightButton.tintColor = UIColor(hexaRGB: getContentColor())!
        rightButton.setTitleTextAttributes(navBarButtonTitleAttributes, for: .normal)
        
        self.navigationItem.leftBarButtonItem  = leftButton
        self.navigationItem.rightBarButtonItem  = rightButton
        
        self.navigationController?.navigationBar.semanticContentAttribute = .forceLeftToRight
    }
    
    func setUpBottomActionPanelObjectEraser() {
        
        let innerSpace: CGFloat = (masterView.bounds.width - (20+26+30+36+42))/6
        
        AppConstants.sharedHeightMultiplier.drawPathLineWidth = 5.0
        masterView.addSubview(bottomActionPanel)
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
            
            buttonCircle1.leftAnchor.constraint(equalTo: bottomActionPanel.leftAnchor, constant: innerSpace),
            buttonCircle1.topAnchor.constraint(equalTo: bottomActionPanel.topAnchor, constant: 15.0),
            buttonCircle1.heightAnchor.constraint(equalToConstant: 55),
            
            buttonCircle2.leftAnchor.constraint(equalTo: buttonCircle1.rightAnchor, constant: innerSpace),
            buttonCircle2.topAnchor.constraint(equalTo: bottomActionPanel.topAnchor, constant: 15.0),
            buttonCircle2.heightAnchor.constraint(equalToConstant: 55),
            
            buttonCircle3.leftAnchor.constraint(equalTo: buttonCircle2.rightAnchor, constant: innerSpace),
            buttonCircle3.topAnchor.constraint(equalTo: bottomActionPanel.topAnchor, constant: 15.0),
            buttonCircle3.heightAnchor.constraint(equalToConstant: 55),
            
            buttonCircle4.leftAnchor.constraint(equalTo: buttonCircle3.rightAnchor, constant: innerSpace),
            buttonCircle4.topAnchor.constraint(equalTo: bottomActionPanel.topAnchor, constant: 15.0),
            buttonCircle4.heightAnchor.constraint(equalToConstant: 55),
            
            buttonCircle5.leftAnchor.constraint(equalTo: buttonCircle4.rightAnchor, constant: innerSpace),
            buttonCircle5.topAnchor.constraint(equalTo: bottomActionPanel.topAnchor, constant: 15.0),
            buttonCircle5.heightAnchor.constraint(equalToConstant: 55),
        ])
    }
    
    func drawSelection() {
        selectionView.callback = { [unowned self] points in
            
            let path = UIBezierPath()
            
            if points.count > 0 {
                path.move(to: points.first!)
                for point in points {
                    path.addLine(to: point)
                }
            }

            let backLayer = CAShapeLayer()
            backLayer.frame = uiImageView.bounds
            backLayer.backgroundColor = UIColor.black.cgColor
            
            let shapeLayer = CAShapeLayer()
            shapeLayer.frame = uiImageView.bounds
            shapeLayer.path = path.cgPath
            shapeLayer.lineCap = .round
            shapeLayer.strokeColor = UIColor.white.cgColor
            shapeLayer.lineWidth = AppConstants.sharedHeightMultiplier.drawPathLineWidth
            shapeLayer.fillColor = UIColor.clear.cgColor
            maskImageView.layer.addSublayer(backLayer)
            maskImageView.layer.addSublayer(shapeLayer)
            
            UIGraphicsBeginImageContext(scaledSize!)
            maskImageView.layer.render(in: UIGraphicsGetCurrentContext()!)
            maskImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            backLayer.removeFromSuperlayer()
            shapeLayer.removeFromSuperlayer()
            
            //exportToAlbum()
            
            selectionView.isUserInteractionEnabled = false
            apiRequest()
         }
    }
    
    @objc func backButtonTapObjectEraser(sender: Any) {
        if let viewController = navigationController?.viewControllers.first(where: {$0 is ViewControllerStyleRedactor}) {
              navigationController?.popToViewController(viewController, animated: false)
        }
    }
    
    @objc func doneButtonTapObjectEraser(sender: Any) {
        if let viewController = navigationController?.viewControllers.first(where: {$0 is ViewControllerStyleRedactor}) {
            
            NotificationCenter.default.removeObserver(self)
            let imageDataDict:[String: UIImage] = ["reparedImage": reparedImage!]
            NotificationCenter.default.post(name: Notification.Name("com.reparedimage.success"), object: nil, userInfo: imageDataDict)
              navigationController?.popToViewController(viewController, animated: false)
        }
    }
    
    func setUpConstraintsObjectEraser() {
        let safeArea = view.safeAreaLayoutGuide
        scaledSize = calculateImageViewScale(viewSize: self.view.bounds.size, imageSize: receivedImage!.size, leftRightAnchorConstant: 20, topBottomAnchorConstant: 126)
        
        sharedConstraints.append(contentsOf: [
            masterView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            masterView.leftAnchor.constraint(equalTo: safeArea.leftAnchor),
            masterView.rightAnchor.constraint(equalTo: safeArea.rightAnchor),
            masterView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            uiImageViewCartoonErase.topAnchor.constraint(equalTo: masterView.topAnchor, constant: 10),
            uiImageViewCartoonErase.leftAnchor.constraint(equalTo: masterView.leftAnchor, constant: 20),
            uiImageViewCartoonErase.widthAnchor.constraint(equalToConstant: getRelativeWidth(60.0)),
            uiImageViewCartoonErase.heightAnchor.constraint(equalToConstant: getRelativeHeight(66.0)),
            
            labelSubTitle.topAnchor.constraint(equalTo: masterView.topAnchor, constant: 5),
            labelSubTitle.leftAnchor.constraint(equalTo: uiImageViewCartoonErase.rightAnchor, constant: 10),
            labelSubTitle.rightAnchor.constraint(equalTo: masterView.rightAnchor, constant: -10),
            labelSubTitle.centerYAnchor.constraint(equalTo: uiImageViewCartoonErase.centerYAnchor),
            
            uiImageView.topAnchor.constraint(equalTo: uiImageViewCartoonErase.bottomAnchor, constant: 10),
            uiImageView.widthAnchor.constraint(equalToConstant: scaledSize!.width),
            uiImageView.centerXAnchor.constraint(equalTo: masterView.centerXAnchor),
            uiImageView.heightAnchor.constraint(equalToConstant: scaledSize!.height),
            
            maskImageView.topAnchor.constraint(equalTo: uiImageViewCartoonErase.bottomAnchor, constant: 10),
            maskImageView.widthAnchor.constraint(equalToConstant: scaledSize!.width),
            maskImageView.centerXAnchor.constraint(equalTo: masterView.centerXAnchor),
            maskImageView.heightAnchor.constraint(equalToConstant: scaledSize!.height),
            
            selectionView.topAnchor.constraint(equalTo: uiImageViewCartoonErase.bottomAnchor, constant: 10),
            selectionView.widthAnchor.constraint(equalToConstant: masterView.bounds.width-20),
            selectionView.centerXAnchor.constraint(equalTo: masterView.centerXAnchor),
            selectionView.heightAnchor.constraint(equalToConstant: scaledSize!.height),
            
            indicator.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -140.0),
            indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -(indicator.messageFrame.bounds.width)/2),
            
            indicator.activityIndicator.topAnchor.constraint(equalTo: (indicator.messageFrame.topAnchor), constant: 10),
            indicator.activityIndicator.centerXAnchor.constraint(equalTo: (indicator.messageFrame.centerXAnchor)),
        ])
        
        regularConstraints.append(contentsOf: [
            masterView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            masterView.leftAnchor.constraint(equalTo: safeArea.leftAnchor),
            masterView.rightAnchor.constraint(equalTo: safeArea.rightAnchor),
            masterView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            uiImageViewCartoonErase.topAnchor.constraint(equalTo: masterView.topAnchor, constant: 10),
            uiImageViewCartoonErase.leftAnchor.constraint(equalTo: masterView.leftAnchor, constant: 20),
            uiImageViewCartoonErase.widthAnchor.constraint(equalToConstant: getRelativeWidth(60.0)),
            uiImageViewCartoonErase.heightAnchor.constraint(equalToConstant: getRelativeHeight(66.0)),
            
            labelSubTitle.topAnchor.constraint(equalTo: masterView.topAnchor, constant: 5),
            labelSubTitle.leftAnchor.constraint(equalTo: uiImageViewCartoonErase.rightAnchor, constant: 10),
            labelSubTitle.rightAnchor.constraint(equalTo: masterView.rightAnchor, constant: -10),
            labelSubTitle.centerYAnchor.constraint(equalTo: uiImageViewCartoonErase.centerYAnchor),
            
            uiImageView.topAnchor.constraint(equalTo: uiImageViewCartoonErase.bottomAnchor, constant: 10),
            uiImageView.widthAnchor.constraint(equalToConstant: scaledSize!.width),
            uiImageView.centerXAnchor.constraint(equalTo: masterView.centerXAnchor),
            uiImageView.heightAnchor.constraint(equalToConstant: scaledSize!.height),
            
            maskImageView.topAnchor.constraint(equalTo: uiImageViewCartoonErase.bottomAnchor, constant: 10),
            maskImageView.widthAnchor.constraint(equalToConstant: scaledSize!.width),
            maskImageView.centerXAnchor.constraint(equalTo: masterView.centerXAnchor),
            maskImageView.heightAnchor.constraint(equalToConstant: scaledSize!.height),
            
            selectionView.topAnchor.constraint(equalTo: uiImageViewCartoonErase.bottomAnchor, constant: 10),
            selectionView.widthAnchor.constraint(equalToConstant: masterView.bounds.width-20),
            selectionView.centerXAnchor.constraint(equalTo: masterView.centerXAnchor),
            selectionView.heightAnchor.constraint(equalToConstant: scaledSize!.height),
            
            indicator.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -140.0),
            indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -(indicator.messageFrame.bounds.width)/2),
            
            indicator.activityIndicator.topAnchor.constraint(equalTo: (indicator.messageFrame.topAnchor), constant: 10),
            indicator.activityIndicator.centerXAnchor.constraint(equalTo: (indicator.messageFrame.centerXAnchor)),
        ])
        
        compactConstraints.append(contentsOf: [
            masterView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            masterView.leftAnchor.constraint(equalTo: safeArea.leftAnchor),
            masterView.rightAnchor.constraint(equalTo: safeArea.rightAnchor),
            masterView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            uiImageViewCartoonErase.topAnchor.constraint(equalTo: masterView.topAnchor, constant: 10),
            uiImageViewCartoonErase.leftAnchor.constraint(equalTo: masterView.leftAnchor, constant: 20),
            uiImageViewCartoonErase.widthAnchor.constraint(equalToConstant: getRelativeWidth(60.0)),
            uiImageViewCartoonErase.heightAnchor.constraint(equalToConstant: getRelativeHeight(66.0)),
            
            labelSubTitle.topAnchor.constraint(equalTo: masterView.topAnchor, constant: 5),
            labelSubTitle.leftAnchor.constraint(equalTo: uiImageViewCartoonErase.rightAnchor, constant: 10),
            labelSubTitle.rightAnchor.constraint(equalTo: masterView.rightAnchor, constant: -10),
            labelSubTitle.centerYAnchor.constraint(equalTo: uiImageViewCartoonErase.centerYAnchor),
            
            uiImageView.topAnchor.constraint(equalTo: uiImageViewCartoonErase.bottomAnchor, constant: 10),
            uiImageView.widthAnchor.constraint(equalToConstant: scaledSize!.width),
            uiImageView.centerXAnchor.constraint(equalTo: masterView.centerXAnchor),
            uiImageView.heightAnchor.constraint(equalToConstant: scaledSize!.height),
            
            maskImageView.topAnchor.constraint(equalTo: uiImageViewCartoonErase.bottomAnchor, constant: 10),
            maskImageView.widthAnchor.constraint(equalToConstant: scaledSize!.width),
            maskImageView.centerXAnchor.constraint(equalTo: masterView.centerXAnchor),
            maskImageView.heightAnchor.constraint(equalToConstant: scaledSize!.height),
            
            selectionView.topAnchor.constraint(equalTo: uiImageViewCartoonErase.bottomAnchor, constant: 10),
            selectionView.widthAnchor.constraint(equalToConstant: masterView.bounds.width-20),
            selectionView.centerXAnchor.constraint(equalTo: masterView.centerXAnchor),
            selectionView.heightAnchor.constraint(equalToConstant: scaledSize!.height),
            
            indicator.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -140.0),
            indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -(indicator.messageFrame.bounds.width)/2),
            
            indicator.activityIndicator.topAnchor.constraint(equalTo: (indicator.messageFrame.topAnchor), constant: 10),
            indicator.activityIndicator.centerXAnchor.constraint(equalTo: (indicator.messageFrame.centerXAnchor)),
        ])
    }
    
    func layoutTraitObjectEraser(traitCollection:UITraitCollection) {
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
    
    func apiRequest() {
        
        indicator.start()
        
        let imageDataOriginalImage: Data = (uiImageView.image?.jpegData(compressionQuality: 1))!
        let imageDataMaskImage: Data = (maskImage?.jpegData(compressionQuality: 1)!)!
        
        print(uiImageView.image!.size)
        print(maskImage!.size)
        
        if maskImage != nil {
            objectEraserViewModel = ObjectEraserViewModel()
            objectEraserViewModel?.uploadRequest(imageDataOriginalImage: imageDataOriginalImage, imageDataMaskImage: imageDataMaskImage) { task_id, error in
                
                if error != nil {
                    
                    DispatchQueue.main.async() {
                        self.indicator.stop()
                        self.selectionView.isUserInteractionEnabled = true
                        self.clearSelectionView()
                        self.drawSelection()
                        self.showAlert(alertTitle: nil, alertMsg: error)
                    }
                    return
                }
                
                guard let task_id = task_id else {
                    return
                }
                
                self.objectEraserViewModel?.fetchFinalImage(task_id: task_id) { data, error in
                    
                    DispatchQueue.main.async() {
                        self.indicator.stop()
                        self.selectionView.isUserInteractionEnabled = true
                        self.clearSelectionView()
                        self.drawSelection()
                    }
                    
                    if error != nil {
                        
                        DispatchQueue.main.async() {
                            self.showAlert(alertTitle: nil, alertMsg: error)
                        }
                        return
                    }
                    
                    guard let data = data else {
                        return
                    }
                    
                    DispatchQueue.main.async() {
                        self.reparedImage = UIImage(data: data)
                        self.uiImageView.image = UIImage(data: data)
                    }
                }
            }
        }
    }
    
    func clearSelectionView() {
        selectionView.erase()
    }
    
    @objc func tabOptionTap(sender: UIButton) {
        let selectedTag = sender.tag
        
        switch sender.tag {
        case 20:
            selectionSize = 5.0
            AppConstants.sharedHeightMultiplier.drawPathLineWidth = 5.0
            setSelectionSizeButtonActiveColor(selectedButtonTag: selectedTag)
        case 26:
            selectionSize = 10.0
            AppConstants.sharedHeightMultiplier.drawPathLineWidth = 10.0
            setSelectionSizeButtonActiveColor(selectedButtonTag: selectedTag)
        case 30:
            selectionSize = 15.0
            AppConstants.sharedHeightMultiplier.drawPathLineWidth = 15.0
            setSelectionSizeButtonActiveColor(selectedButtonTag: selectedTag)
        case 36:
            selectionSize = 20.0
            AppConstants.sharedHeightMultiplier.drawPathLineWidth = 20.0
            setSelectionSizeButtonActiveColor(selectedButtonTag: selectedTag)
        case 42:
            selectionSize = 25.0
            AppConstants.sharedHeightMultiplier.drawPathLineWidth = 25.0
            setSelectionSizeButtonActiveColor(selectedButtonTag: selectedTag)
        default:
            break
        }
    }
    
    func setSelectionSizeButtonActiveColor(selectedButtonTag: Int?) {
        
        for i in 20...42 {
            if i != selectedButtonTag {
                if let foundView = view.viewWithTag(i) as? UIButton {
                    foundView.tintColor = UIColor(hexaRGB: getContentColor(), alpha: 0.6)
                    foundView.imageView?.layer.borderWidth = 0
                    foundView.imageView?.layer.borderColor = UIColor.clear.cgColor
                }
            } else {
                if let foundView = view.viewWithTag(i) as? UIButton {
                    foundView.tintColor = UIColor(hexaRGB: "#7D038C", alpha: 1.0)
                    foundView.imageView?.layer.cornerRadius = CGFloat(selectedButtonTag!/2)
                    foundView.imageView?.layer.borderWidth = 1
                    foundView.imageView?.layer.borderColor = UIColor.white.cgColor
                }
            }
        }
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
        fetchOptions.predicate = NSPredicate(format: "title = %@", "PhotoEditorAppImages")
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
    
    func createAlbum(completionHandler:@escaping (_ createAlbumSuccess: Bool) -> Void) {
        //Get PHFetch Options
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", "PhotoEditorAppImages")
        let collection : PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        //Check return value - If found, then get the first album out
        if collection.firstObject != nil{
            //found the album
            completionHandler(true)
            self.assetCollection = collection.firstObject!
        } else {
            //If not found - Then create a new album
            PHPhotoLibrary.shared().performChanges({
                PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: "PhotoEditorAppImages")   // create an asset collection with the album name
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
    
    private func saveToGallery() {
        
        PHPhotoLibrary.shared().performChanges({
            let fetchOptions = PHFetchOptions()
            fetchOptions.predicate = NSPredicate(format: "title = %@", "PhotoEditorAppImages")
            let collection : PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
            //Check return value - If found, then get the first album out
            if collection.firstObject != nil{
                //found the album
                self.assetCollection = collection.firstObject!
                DispatchQueue.main.async {
                    self.saveImage(image: self.uiImageView.image!)
                    self.saveImage(image: self.maskImage!)
                }
            }
            else {
                self.createAlbum() { createAlbumSuccess in
                    if createAlbumSuccess {
                        DispatchQueue.main.async {
                            self.saveImage(image: self.uiImageView.image!)
                            self.saveImage(image: self.maskImage!)
                        }
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
    
    func showAlert(alertTitle: String?, alertMsg: String?) {
        
        let attributedMsgString = NSAttributedString(string: alertMsg!, attributes: [
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16),
            NSAttributedString.Key.foregroundColor : UIColor.white
        ])
        
        let alertController = UIAlertController(title: nil, message: alertMsg, preferredStyle: .alert)
        alertController.setValue(attributedMsgString, forKey: "attributedMessage")
        alertController.setBackgroundColor(color: UIColor(named: "Gray800")!)
         
        let cancelAction = UIAlertAction(title: NSLocalizedString("alertActionOK", comment: ""), style: .default , handler:{ (UIAlertAction)in
            //self.masterView.backgroundColor = UIColor(hexaRGB: getBackgroundColor())!
        })
        cancelAction.setValue(UIColor.white, forKey: "titleTextColor")
        alertController.addAction(cancelAction)

        //uncomment for iPad Support
        alertController.popoverPresentationController?.sourceView = self.masterView
        alertController.popoverPresentationController?.sourceRect = CGRect(x: self.masterView.bounds.midX, y: self.masterView.bounds.midY, width: 1, height: 1);

        self.present(alertController, animated: true, completion: nil)
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
