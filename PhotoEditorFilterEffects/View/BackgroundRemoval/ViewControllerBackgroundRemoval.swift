//
//  BackgroundRemovalViewController.swift
//  PhotoEditorFilterEffects
//
//  Created by Sonjoy Borkakoty on 29/12/22.
//

import UIKit

class ViewControllerBackgroundRemoval: UIViewController {
    
    var receivedImage: UIImage?
    var backgroundRemovedImage: UIImage?
    
    private var compactConstraints: [NSLayoutConstraint] = []
    private var regularConstraints: [NSLayoutConstraint] = []
    private var sharedConstraints: [NSLayoutConstraint] = []
    private var backgroundRemovalViewModel: BackgroundRemovalViewModel?
    
    private lazy var masterView: UIView = {
        let view = UINib(nibName: "MasterViewBackgroundRemoval", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
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
        view.text = NSLocalizedString("viewSubTitleBackgroundRemovalVC", comment: "")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = UIColor(hexaRGB: getContentColor(), alpha: 1)
        view.textAlignment = .center
        view.numberOfLines = 0
        view.lineBreakMode = .byWordWrapping
        view.sizeToFit()
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
        uiImageView.isUserInteractionEnabled = true
        return uiImageView
    }()
    
    private lazy var indicator: ProgressIndicatorPE = {
        let view = ProgressIndicatorPE(inview: self.view, loadingViewColor: UIColor(named: "Gray800")!, indicatorColor: UIColor.white, msg: NSLocalizedString("indicatorTitleBackgroundRemovalVC", comment: ""))
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let resizedImage = uiImageView.asImage()
        uiImageView.image = resizedImage
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //handle dark mode
        if #available(iOS 13.0, *) {
            view.overrideUserInterfaceStyle = .light
        }
        
        backgroundRemovedImage = receivedImage!
        setUpUIBackgroundRemoval()
        
        setUpConstraintsBackgroundRemoval()
        NSLayoutConstraint.activate(sharedConstraints)
        layoutTraitBackgroundRemoval(traitCollection: UIScreen.main.traitCollection)
    }
    
    func setUpUIBackgroundRemoval() {
        
        self.view.backgroundColor = UIColor(hexaRGB: getBackgroundColor())
        setNavBarBackgroundRemoval()
        masterView.addSubview(uiImageViewCartoonErase)
        masterView.addSubview(labelSubTitle)
        masterView.addSubview(uiImageView)
        masterView.addSubview(indicator)
        view.addSubview(masterView)
        
        uiImageView.backgroundColor = UIColor.init(patternImage: UIImage(named: "img_tile")!.alpha(0.9))
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        uiImageView.addGestureRecognizer(swipeRight)

        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipeGesture))
        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
        uiImageView.addGestureRecognizer(swipeLeft)
    }
    
    func setNavBarBackgroundRemoval() {
        
        self.navigationItem.setHidesBackButton(true, animated: false)
        let navTitle = UILabel()
        navTitle.text = NSLocalizedString("navTitleBackgroundRemovalVC", comment: "")
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
        leftView.addTarget(self, action: #selector(backButtonTapBackgroundRemoval), for: .allTouchEvents)
        leftButton.customView = leftView
            
        let rightButton = UIBarButtonItem(title: NSLocalizedString("navBarButtonDone", comment: ""), style: .done, target: self, action: #selector(doneButtonTapBackgroundRemoval))
        rightButton.tintColor = UIColor(hexaRGB: getContentColor())!
        rightButton.setTitleTextAttributes(navBarButtonTitleAttributes, for: .normal)
        
        self.navigationItem.leftBarButtonItem  = leftButton
        self.navigationItem.rightBarButtonItem  = rightButton
        
        self.navigationController?.navigationBar.semanticContentAttribute = .forceLeftToRight
    }
    
    @objc func backButtonTapBackgroundRemoval(sender: Any) {
        if let viewController = navigationController?.viewControllers.first(where: {$0 is ViewControllerStyleRedactor}) {
              navigationController?.popToViewController(viewController, animated: false)
        }
    }
    
    @objc func doneButtonTapBackgroundRemoval(sender: Any) {
        if let viewController = navigationController?.viewControllers.first(where: {$0 is ViewControllerStyleRedactor}) {
            
            NotificationCenter.default.removeObserver(self)
            let imageDataDict:[String: UIImage] = ["backgroundRemovedImage": backgroundRemovedImage!]
            NotificationCenter.default.post(name: Notification.Name("com.backgroundremovedimage.success"), object: nil, userInfo: imageDataDict)
              navigationController?.popToViewController(viewController, animated: false)
        }
    }
    
    func setUpConstraintsBackgroundRemoval() {
        let safeArea = view.safeAreaLayoutGuide
        let scaledSize = calculateImageViewScale(viewSize: self.view.bounds.size, imageSize: receivedImage!.size, leftRightAnchorConstant: 20, topBottomAnchorConstant: 126)
        
        sharedConstraints.append(contentsOf: [
            masterView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            masterView.leftAnchor.constraint(equalTo: safeArea.leftAnchor),
            masterView.rightAnchor.constraint(equalTo: safeArea.rightAnchor),
            masterView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            uiImageViewCartoonErase.topAnchor.constraint(equalTo: masterView.topAnchor, constant: 10),
            uiImageViewCartoonErase.leftAnchor.constraint(equalTo: masterView.leftAnchor, constant: 20),
            uiImageViewCartoonErase.widthAnchor.constraint(equalToConstant: 60),
            uiImageViewCartoonErase.heightAnchor.constraint(equalToConstant: 66),
            
            labelSubTitle.topAnchor.constraint(equalTo: masterView.topAnchor, constant: 5),
            labelSubTitle.leftAnchor.constraint(equalTo: uiImageViewCartoonErase.rightAnchor, constant: 10),
            labelSubTitle.rightAnchor.constraint(equalTo: masterView.rightAnchor, constant: -10),
            labelSubTitle.centerYAnchor.constraint(equalTo: uiImageViewCartoonErase.centerYAnchor),
            
            uiImageView.topAnchor.constraint(equalTo: uiImageViewCartoonErase.bottomAnchor, constant: 10),
            uiImageView.widthAnchor.constraint(equalToConstant: masterView.bounds.width-20),
            uiImageView.centerXAnchor.constraint(equalTo: masterView.centerXAnchor),
            uiImageView.heightAnchor.constraint(equalToConstant: scaledSize.height),
            
            indicator.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -75.0),
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
            uiImageViewCartoonErase.widthAnchor.constraint(equalToConstant: 60),
            uiImageViewCartoonErase.heightAnchor.constraint(equalToConstant: 66),
            
            labelSubTitle.topAnchor.constraint(equalTo: masterView.topAnchor, constant: 5),
            labelSubTitle.leftAnchor.constraint(equalTo: uiImageViewCartoonErase.rightAnchor, constant: 10),
            labelSubTitle.rightAnchor.constraint(equalTo: masterView.rightAnchor, constant: -10),
            labelSubTitle.centerYAnchor.constraint(equalTo: uiImageViewCartoonErase.centerYAnchor),
            
            uiImageView.topAnchor.constraint(equalTo: uiImageViewCartoonErase.bottomAnchor, constant: 10),
            uiImageView.widthAnchor.constraint(equalToConstant: masterView.bounds.width-20),
            uiImageView.centerXAnchor.constraint(equalTo: masterView.centerXAnchor),
            uiImageView.heightAnchor.constraint(equalToConstant: scaledSize.height),
            
            indicator.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -75.0),
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
            uiImageViewCartoonErase.widthAnchor.constraint(equalToConstant: 60),
            uiImageViewCartoonErase.heightAnchor.constraint(equalToConstant: 66),
            
            labelSubTitle.topAnchor.constraint(equalTo: masterView.topAnchor, constant: 5),
            labelSubTitle.leftAnchor.constraint(equalTo: uiImageViewCartoonErase.rightAnchor, constant: 10),
            labelSubTitle.rightAnchor.constraint(equalTo: masterView.rightAnchor, constant: -10),
            labelSubTitle.centerYAnchor.constraint(equalTo: uiImageViewCartoonErase.centerYAnchor),
            
            uiImageView.topAnchor.constraint(equalTo: uiImageViewCartoonErase.bottomAnchor, constant: 10),
            uiImageView.widthAnchor.constraint(equalToConstant: masterView.bounds.width-20),
            uiImageView.centerXAnchor.constraint(equalTo: masterView.centerXAnchor),
            uiImageView.heightAnchor.constraint(equalToConstant: scaledSize.height),
            
            indicator.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -75.0),
            indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -(indicator.messageFrame.bounds.width)/2),
            
            indicator.activityIndicator.topAnchor.constraint(equalTo: (indicator.messageFrame.topAnchor), constant: 10),
            indicator.activityIndicator.centerXAnchor.constraint(equalTo: (indicator.messageFrame.centerXAnchor)),
        ])
    }
    
    func layoutTraitBackgroundRemoval(traitCollection:UITraitCollection) {
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
        
        print(uiImageView.image!.size)
        
        backgroundRemovalViewModel = BackgroundRemovalViewModel()
        backgroundRemovalViewModel?.uploadRequest(imageDataOriginalImage: imageDataOriginalImage) { task_id, error in
            
            if error != nil {
                
                DispatchQueue.main.async() {
                    self.indicator.stop()
                    self.showAlert(alertTitle: nil, alertMsg: error)
                }
                return
            }
            
            guard let task_id = task_id else {
                return
            }
            
            self.backgroundRemovalViewModel?.fetchFinalImage(task_id: task_id) { data, error in
                
                DispatchQueue.main.async() {
                    self.indicator.stop()
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
                    self.backgroundRemovedImage = UIImage(data: data)
                    self.uiImageView.image = UIImage(data: data)
                }
            }
        }
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
        alertController.popoverPresentationController?.sourceView = self.view
        alertController.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 1, height: 1);

        self.present(alertController, animated: true, completion: {
            alertController.view.superview?.subviews.first?.isUserInteractionEnabled = true
        })
    }
    
    @objc func handleSwipeGesture(gesture: UIGestureRecognizer) {

        if let swipeGesture = gesture as? UISwipeGestureRecognizer {

            switch swipeGesture.direction {
            case .right:
                apiRequest()
            case .down:
                print("Swiped down")
            case .left:
                apiRequest()
            case .up:
                print("Swiped up")
            default:
                break
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
