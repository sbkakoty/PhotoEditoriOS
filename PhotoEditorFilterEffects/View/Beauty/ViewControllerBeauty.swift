//
//  ViewControllerBeauty.swift
//  PhotoEditorFilterEffects
//
//  Created by Sonjoy Borkakoty on 06/11/22.
//

import UIKit

class ViewControllerBeauty: UIViewController {
    
    var receivedImage: UIImage?
    var beautifiedImage: UIImage?
    
    private var viewModelAdjust: ViewModelAdjust?
    
    private var compactConstraints: [NSLayoutConstraint] = []
    private var regularConstraints: [NSLayoutConstraint] = []
    private var sharedConstraints: [NSLayoutConstraint] = []
    
    private var selectedShade: Int?
    private var sliderInitialValue: Float = 0
    private var sliderCurrentValue: Float = 0.5
    
    private lazy var masterView: UIView = {
        let view = UINib(nibName: "MasterViewBeauty", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
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
        view.addTarget(self, action: #selector(buttonBeautySliderCloseTap), for: .touchUpInside)
        view.setImage(uiImage, for: .normal)
        return view
    }()
    
    private lazy var buttonSliderOK: UIButton = {
        let view = UIButton(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        let uiImage = UIImage(named: "img_vector2")?.withRenderingMode(.alwaysTemplate)
        view.tintColor = UIColor(hexaRGB: getContentColor())
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(buttonBeautySliderOKTap), for: .touchUpInside)
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
        
        beautifiedImage = receivedImage!
        setUpUIBeauty()
        
        setUpConstraintsBeauty()
        NSLayoutConstraint.activate(sharedConstraints)
        layoutTraitBeauty(traitCollection: UIScreen.main.traitCollection)
        
        DispatchQueue.main.async {
            self.addBeautyEffect(opacity: CGFloat(self.sliderCurrentValue))
        }
    }
    
    func setUpUIBeauty() {
        
        setNavBarBeauty()
        //masterView.addSubview(tempImageView)
        masterView.addSubview(uiImageView)
        self.view.backgroundColor = UIColor(hexaRGB: getBackgroundColor())
        view.addSubview(masterView)
        setUpBottomSliderPanelBeauty()
    }
    
    func setNavBarBeauty() {
        
        self.navigationItem.setHidesBackButton(true, animated: false)
        let navTitle = UILabel()
        navTitle.text = NSLocalizedString("buttonLabelBeauty", comment: "")
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
        leftView.addTarget(self, action: #selector(backButtonTapBeauty), for: .allTouchEvents)
        leftButton.customView = leftView
            
        let rightButton = UIBarButtonItem(title: NSLocalizedString("navBarButtonDone", comment: ""), style: .done, target: self, action: #selector(doneButtonTapBeauty))
        rightButton.tintColor = UIColor(hexaRGB: getContentColor())!
        rightButton.setTitleTextAttributes(navBarButtonTitleAttributes, for: .normal)
        
        self.navigationItem.leftBarButtonItem  = leftButton
        self.navigationItem.rightBarButtonItem  = rightButton
        
        self.navigationController?.navigationBar.semanticContentAttribute = .forceLeftToRight
    }
    
    func setUpBottomSliderPanelBeauty() {
        masterView.addSubview(uiSliderContainer)
        uiSliderContainer.addSubview(uiSlider)
        uiSliderContainer.addSubview(labelSliderProgressPercent)
        uiSliderContainer.addSubview(buttonSliderClose)
        uiSliderContainer.addSubview(buttonSliderOK)
        
        NSLayoutConstraint.activate([
            uiSliderContainer.heightAnchor.constraint(equalToConstant: 100),
            uiSliderContainer.bottomAnchor.constraint(equalTo: masterView.bottomAnchor, constant: -50),
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
    
    @objc func backButtonTapBeauty(sender: Any) {
        if let viewController = navigationController?.viewControllers.first(where: {$0 is ViewControllerStyleRedactor}) {
              navigationController?.popToViewController(viewController, animated: false)
        }
    }
    
    @objc func doneButtonTapBeauty(sender: Any) {
        if let viewController = navigationController?.viewControllers.first(where: {$0 is ViewControllerStyleRedactor}) {
            
            //NotificationCenter.default.removeObserver(self, name: Notification.Name("com.beautifiedphoto.success"), object: nil)
            NotificationCenter.default.removeObserver(self)
            let imageDataDict:[String: UIImage] = ["beautifiedImage": beautifiedImage!]
            NotificationCenter.default.post(name: Notification.Name("com.beautifiedphoto.success"), object: nil, userInfo: imageDataDict)
              navigationController?.popToViewController(viewController, animated: false)
        }
    }
    
    func setUpConstraintsBeauty() {
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
    
    func layoutTraitBeauty(traitCollection:UITraitCollection) {
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
        
        sliderCurrentValue = sender.value
        let percent: Float = sender.value*100
        labelSliderProgressPercent.text = "\(Int(percent)) %"
    }
    
    @objc func buttonBeautySliderOKTap(sender: UIButton?) {
        
        addBeautyEffect(opacity: CGFloat(sliderCurrentValue))
    }
    
    @objc func buttonBeautySliderCloseTap(sender: UIButton?) {
        uiImageView.image = beautifiedImage
        uiSliderContainer.isHidden = true
    }
    
    func addBeautyEffect(opacity: CGFloat) {
        
        let topImage = receivedImage!
        let imageSize = receivedImage!.size

        UIGraphicsBeginImageContext(imageSize)

        receivedImage!.draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        topImage.draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height), blendMode: .overlay, alpha: opacity)

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        beautifiedImage = newImage
        uiImageView.image = newImage
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
