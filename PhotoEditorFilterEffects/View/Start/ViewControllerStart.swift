//
//  ViewControllerStart.swift
//  PhotoEditorFilterEffects
//
//  Created by MacBook on 10/17/22.
//

import UIKit
import AVFoundation
import PhotosUI

class ViewControllerStart: UIViewController, AVCapturePhotoCaptureDelegate, PHPickerViewControllerDelegate, PHPhotoLibraryChangeObserver {
    
    private var compactConstraints: [NSLayoutConstraint] = []
    private var regularConstraints: [NSLayoutConstraint] = []
    private var sharedConstraints: [NSLayoutConstraint] = []
    
    private var captureSession = AVCaptureSession()
    private var captureConnection: AVCaptureConnection?
    private let photoOutput = AVCapturePhotoOutput()
    private var cameraLayer = AVCaptureVideoPreviewLayer()
    
    private var usingFrontCamera = true
    
    var config: PHPickerConfiguration = {
        var cfg = PHPickerConfiguration()
        cfg.selectionLimit = 1
        cfg.filter = PHPickerFilter.images
        return cfg
    }()
    
    private lazy var masterView: UIView = {
        let view = UINib(nibName: "MasterView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
        view.frame = UIScreen.main.bounds
        view.tag = 4
        view.backgroundColor = UIColor(hexaRGB: getBackgroundColor())!
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var buttonLabel: UILabel = {
        let view = UILabel()
        view.text = NSLocalizedString("labelTapToOpen", comment: "")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = UIColor(hexaRGB: getContentColor())!
        view.textAlignment = .center
        view.font = UIFont.preferredFont(forTextStyle: .body).bold()
        view.adjustsFontForContentSizeCategory = true
        return view
    }()
    
    private lazy var buttonChooseFromGallery: UIButton = {
        let button = UIButton(type: .custom) as UIButton
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "img__white_A700")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.addTarget(self, action: #selector(openFileChooserDialog), for: .touchUpInside)
        button.tintColor = UIColor(hexaRGB: getContentColor())!
        return button
    }()
    
    lazy private var buttonTakePhoto: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "capture_photo")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tag = 2
        button.addTarget(self, action: #selector(buttonTakePhotoTap), for: .touchUpInside)
        return button
    }()
    
    lazy private var buttonExitTakePhoto: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "img_back")?.withRenderingMode(.alwaysOriginal), for: .normal)
        //button.tintColor = UIColor(hexaRGB: getContentColor())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(exitTakePhoto), for: .touchUpInside)
        return button
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor(hexaRGB: getBackgroundColor())
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.shadowColor = .clear
        appearance.shadowImage = UIImage()
        
        navigationController?.navigationBar.tintColor = UIColor(hexaRGB: getContentColor())
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        if #available(iOS 15.0, *) {
            navigationController?.navigationBar.compactScrollEdgeAppearance = appearance
        }
        
        self.view.backgroundColor = UIColor(hexaRGB: getBackgroundColor())
        self.masterView.backgroundColor = UIColor(hexaRGB: getBackgroundColor())
        buttonLabel.textColor = UIColor(hexaRGB: getContentColor())
        buttonChooseFromGallery.tintColor = UIColor(hexaRGB: getContentColor())
        buttonTakePhoto.tintColor = UIColor(hexaRGB: getContentColor())
        buttonExitTakePhoto.tintColor = UIColor(hexaRGB: getContentColor())
        
        NotificationCenter.default.addObserver(self, selector: #selector(takePhotoSuccess(_:)), name: Notification.Name ("com.takephoto.success"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(takePhotoRetake(_:)), name: Notification.Name ("com.takephoto.retake"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        setUpUI()
        
        setUpConstraints()
        NSLayoutConstraint.activate(sharedConstraints)
        layoutTrait(traitCollection: UIScreen.main.traitCollection)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //handle dark mode
        if #available(iOS 13.0, *) {
            view.overrideUserInterfaceStyle = .light
        }
    }
    
    func setNavBarStart() {
        
        self.navigationItem.setHidesBackButton(true, animated: false)
        let navTitle = UILabel()
        navTitle.text = NSLocalizedString("navBarTitleStartVC", comment: "")
        navTitle.font = UIFont.preferredFont(forTextStyle: .title1)
        navTitle.textColor = UIColor(hexaRGB: getContentColor())!
        navTitle.numberOfLines = 2
        navTitle.lineBreakMode = .byTruncatingTail
        navTitle.sizeToFit()
        navTitle.textAlignment = .center
        self.navigationItem.titleView = navTitle
            
        let rightButton = UIBarButtonItem(image: UIImage(named: "three_dots_vertical_icon_159806")?.withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(navBarRightButtonTap))
        rightButton.tintColor = UIColor(hexaRGB: getContentColor())!
        
        self.navigationItem.rightBarButtonItem  = rightButton
        
        self.navigationController?.navigationBar.semanticContentAttribute = .forceLeftToRight
    }
    
    func setUpUI() {
        
        setNavBarStart()
        
        self.masterView.addSubview(buttonChooseFromGallery)
        self.masterView.addSubview(buttonLabel)
        self.view.addSubview(masterView)
    }
    
    func setUpConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        sharedConstraints.append(contentsOf: [
            masterView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            masterView.leftAnchor.constraint(equalTo: safeArea.leftAnchor),
            masterView.rightAnchor.constraint(equalTo: safeArea.rightAnchor),
            masterView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            buttonChooseFromGallery.centerXAnchor.constraint(equalTo: masterView.centerXAnchor),
            buttonChooseFromGallery.centerYAnchor.constraint(equalTo: masterView.centerYAnchor, constant: -35),
            
            buttonLabel.topAnchor.constraint(equalTo: buttonChooseFromGallery.bottomAnchor, constant: 10),
            buttonLabel.centerXAnchor.constraint(equalTo: masterView.centerXAnchor)
        ])
        
        regularConstraints.append(contentsOf: [
            masterView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            masterView.leftAnchor.constraint(equalTo: safeArea.leftAnchor),
            masterView.rightAnchor.constraint(equalTo: safeArea.rightAnchor),
            masterView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            buttonChooseFromGallery.centerXAnchor.constraint(equalTo: masterView.centerXAnchor),
            buttonChooseFromGallery.centerYAnchor.constraint(equalTo: masterView.centerYAnchor, constant: -35),
            
            buttonLabel.topAnchor.constraint(equalTo: buttonChooseFromGallery.bottomAnchor, constant: 10),
            buttonLabel.centerXAnchor.constraint(equalTo: masterView.centerXAnchor)
        ])
        
        compactConstraints.append(contentsOf: [
            masterView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            masterView.leftAnchor.constraint(equalTo: safeArea.leftAnchor),
            masterView.rightAnchor.constraint(equalTo: safeArea.rightAnchor),
            masterView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            buttonChooseFromGallery.centerXAnchor.constraint(equalTo: masterView.centerXAnchor),
            buttonChooseFromGallery.centerYAnchor.constraint(equalTo: masterView.centerYAnchor, constant: -35),
            
            buttonLabel.topAnchor.constraint(equalTo: buttonChooseFromGallery.bottomAnchor, constant: 10),
            buttonLabel.centerXAnchor.constraint(equalTo: masterView.centerXAnchor)
        ])
    }
    
    func layoutTrait(traitCollection:UITraitCollection) {
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
    
    @objc func openFileChooserDialog(sender: UIButton) {
        
        masterView.backgroundColor = UIColor(named: "Gray500")
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.setBackgroundColor(color: UIColor(named: "Gray800")!)
        alertController.view.translatesAutoresizingMaskIntoConstraints = false
        let customView = UIScrollView()
        customView.contentSize.height = 145.0
        customView.isScrollEnabled = true
        customView.contentSize.width = 430.0
        customView.showsHorizontalScrollIndicator = false
        customView.translatesAutoresizingMaskIntoConstraints = false
        customView.backgroundColor = UIColor(named: "Bluegray400")!
        alertController.view.addSubview(customView)
        
        var imageView = UIImageView(frame: CGRect(x: 10.0, y: 10.0, width: 95, height: 125))
        imageView.image = UIImage(named: "img_rectangle136")
        customView.addSubview(imageView)
        
        imageView = UIImageView(frame: CGRect(x: 115.0, y: 10.0, width: 95, height: 125))
        imageView.image = UIImage(named: "img_rectangle137")
        customView.addSubview(imageView)
        
        imageView = UIImageView(frame: CGRect(x: 220.0, y: 10.0, width: 95, height: 125))
        imageView.image = UIImage(named: "img_rectangle138")
        customView.addSubview(imageView)
        
        imageView = UIImageView(frame: CGRect(x: 325.0, y: 10.0, width: 95, height: 125))
        imageView.image = UIImage(named: "img_rectangle139")
        customView.addSubview(imageView)
        
        let galleryAction = UIAlertAction(title: NSLocalizedString("actionSheetGallery", comment: ""), style: .default , handler:{ (UIAlertAction)in
            self.openGalleryDialog()
            self.masterView.backgroundColor = UIColor(hexaRGB: getBackgroundColor())!
        })
        galleryAction.setValue(UIColor.white, forKey: "titleTextColor")
        alertController.addAction(galleryAction)
        
        let cameraAction = UIAlertAction(title: NSLocalizedString("actionSheetCamera", comment: ""), style: .default , handler:{ (UIAlertAction)in
            
            self.openCameraDialog()
            self.masterView.backgroundColor = UIColor(hexaRGB: getBackgroundColor())!
        })
        cameraAction.setValue(UIColor.white, forKey: "titleTextColor")
        alertController.addAction(cameraAction)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("actionSheetCancel", comment: ""), style: .default , handler:{ (UIAlertAction)in
            self.masterView.backgroundColor = UIColor(hexaRGB: getBackgroundColor())!
        })
        cancelAction.setValue(UIColor.white, forKey: "titleTextColor")
        alertController.addAction(cancelAction)
        
        //uncomment for iPad Support
        alertController.popoverPresentationController?.sourceView = self.view
        alertController.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 1, height: 1);
        
        customView.topAnchor.constraint(equalTo: alertController.view.topAnchor, constant: 15).isActive = true
        customView.widthAnchor.constraint(equalTo: alertController.view.widthAnchor, constant: -25).isActive = true
        customView.heightAnchor.constraint(equalToConstant: 145).isActive = true
        customView.centerXAnchor.constraint(equalTo: alertController.view.centerXAnchor).isActive = true
        alertController.view.heightAnchor.constraint(equalToConstant: 340).isActive = true

        alertController.view.superview?.subviews.first?.isUserInteractionEnabled = true

        // Adding Tap Gesture to Overlay
        alertController.view.superview?.subviews.first?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func navBarRightButtonTap(sender: Any) {
        
        let vc = ViewControllerSettings()
        self.navigationController?.pushViewController(vc, animated: true)
        
        /* masterView.backgroundColor = UIColor(named: "Gray500")
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.setBackgroundColor(color: UIColor(named: "Gray800")!)
        
        let settingsAction = UIAlertAction(title: NSLocalizedString("actionSheetSettings", comment: ""), style: .default , handler:{ (UIAlertAction)in
            self.masterView.backgroundColor = UIColor(hexaRGB: getBackgroundColor())!
            let vc = ViewControllerSettings()
            self.navigationController?.pushViewController(vc, animated: true)
        })
        settingsAction.setValue(UIColor.white, forKey: "titleTextColor")
        alertController.addAction(settingsAction)
        
        let reviewAction = UIAlertAction(title: NSLocalizedString("actionSheetReviewReference", comment: ""), style: .default , handler:{ (UIAlertAction)in
            self.masterView.backgroundColor = UIColor(hexaRGB: getBackgroundColor())!
            let vc = ViewControllerReview()
            self.navigationController?.pushViewController(vc, animated: true)
        })
        reviewAction.setValue(UIColor.white, forKey: "titleTextColor")
        alertController.addAction(reviewAction)
        
        let guidesAction = UIAlertAction(title: NSLocalizedString("actionSheetGuides", comment: ""), style: .default , handler:{ (UIAlertAction)in
            self.masterView.backgroundColor = UIColor(hexaRGB: getBackgroundColor())!
            let vc = ViewControllerGuides()
            self.navigationController?.pushViewController(vc, animated: true)
        })
        guidesAction.setValue(UIColor.white, forKey: "titleTextColor")
        alertController.addAction(guidesAction)
        
        //uncomment for iPad Support
        alertController.popoverPresentationController?.sourceView = self.view
        alertController.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 1, height: 1);
        
        self.present(alertController, animated: true, completion: {
            alertController.view.superview?.subviews.first?.isUserInteractionEnabled = true

            // Adding Tap Gesture to Overlay
            alertController.view.superview?.subviews.first?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
        }) */
    }
    
    func openGalleryDialog() {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
            case .authorized, .limited:
                let pickerViewController = PHPickerViewController(configuration: self.config)
                pickerViewController.delegate = self
                self.present(pickerViewController, animated: true, completion: nil)
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization({
                    (newStatus) in
                    DispatchQueue.main.async {
                        if newStatus ==  PHAuthorizationStatus.authorized {
                            let pickerViewController = PHPickerViewController(configuration: self.config)
                            pickerViewController.delegate = self
                            self.present(pickerViewController, animated: true, completion: nil)
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
    
    /* PHPhotoLibraryChangeObserver event*/
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        
        DispatchQueue.main.async {
            let pickerViewController = PHPickerViewController(configuration: self.config)
            pickerViewController.delegate = self
            self.present(pickerViewController, animated: true, completion: nil)
        }
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
       picker.dismiss(animated: true, completion: nil)
       
       for result in results {
          result.itemProvider.loadObject(ofClass: UIImage.self, completionHandler: { (object, error) in
             if let image = object as? UIImage {
                DispatchQueue.main.async {
                    let vc = ViewControllerStyleRedactor()
                    vc.receivedImage = image
                    self.navigationController?.pushViewController(vc, animated: true)
                }
             }
          })
       }
    }
    
    private func setUpCameraPreviewUI() {
        
        self.view.backgroundColor = UIColor(hexaRGB: "#000000")
        
        let cameraButtonPanel = UIView()
        cameraButtonPanel.tag = 3
        cameraButtonPanel.backgroundColor = UIColor(hexaRGB: "#000000")!
        cameraButtonPanel.translatesAutoresizingMaskIntoConstraints = false
        cameraButtonPanel.addSubview(buttonExitTakePhoto)
        cameraButtonPanel.addSubview(buttonTakePhoto)
        //cameraButtonPanel.addSubview(buttonflipCamera)
        self.masterView.addSubview(cameraButtonPanel)
        NSLayoutConstraint.activate([
            cameraButtonPanel.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            cameraButtonPanel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cameraButtonPanel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cameraButtonPanel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cameraButtonPanel.heightAnchor.constraint(equalToConstant: 130),
            
            buttonTakePhoto.centerYAnchor.constraint(equalTo: cameraButtonPanel.centerYAnchor),
            buttonTakePhoto.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonTakePhoto.widthAnchor.constraint(equalToConstant: 80),
            buttonTakePhoto.heightAnchor.constraint(equalToConstant: 80),
            
            buttonExitTakePhoto.centerYAnchor.constraint(equalTo: cameraButtonPanel.centerYAnchor),
            buttonExitTakePhoto.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10),
            buttonExitTakePhoto.widthAnchor.constraint(equalToConstant: 55),
            buttonExitTakePhoto.heightAnchor.constraint(equalToConstant: 55),
            
            /*buttonflipCamera.centerYAnchor.constraint(equalTo: cameraButtonPanel.centerYAnchor),
            buttonflipCamera.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10),
            buttonflipCamera.widthAnchor.constraint(equalToConstant: 55),
            buttonflipCamera.heightAnchor.constraint(equalToConstant: 55)*/
            
        ])
    }
    
    func openCameraDialog() {
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        switch cameraAuthorizationStatus {
            case .authorized: // the user has already authorized to access the camera.
                setupCaptureSession()
            case .notDetermined: // the user has not yet asked for camera access.
                requestCameraPermission()
                return
            case .restricted, .denied: // previously denied
                alertCameraAccessNeeded()
                return
            @unknown default:
                return
        }
    }
    
    private func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { (granted) in
            if granted { // if user has granted to access the camera.
                print("the user has granted to access the camera")
                DispatchQueue.main.async {
                    self.setupCaptureSession()
                }
            } else {
                print("the user has not granted to access the camera")
                DispatchQueue.main.async {
                    self.alertCameraAccessNeeded()
                }
            }
        }
    }
    
    private  func alertCameraAccessNeeded() {
        let alert = UIAlertController(
            title: NSLocalizedString("alertTitleCameraSettings", comment: ""),
            message: NSLocalizedString("alertMessageCameraSettings", comment: ""),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: NSLocalizedString("actionSheetCancel", comment: ""), style: .cancel))
        alert.addAction(UIAlertAction(title: NSLocalizedString("alertButtonAllow", comment: ""), style: .default) { _ in
            self.goToPrivacySettingsStartVC()
        })
        //uncomment for iPad Support
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 1, height: 1)
        present(alert, animated: true)
    }
    
    private  func alertGalleryAccessNeeded() {
        let alert = UIAlertController(
            title: NSLocalizedString("alertTitleGallerySettings", comment: ""),
            message: NSLocalizedString("alertMessageGallerySettings", comment: ""),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: NSLocalizedString("actionSheetCancel", comment: ""), style: .cancel))
        alert.addAction(UIAlertAction(title: NSLocalizedString("alertButtonAllow", comment: ""), style: .default) { _ in
            self.goToPrivacySettingsStartVC()
        })
        //uncomment for iPad Support
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 1, height: 1)
        present(alert, animated: true)
    }
    
    func goToPrivacySettingsStartVC() {
        guard let url = URL(string: UIApplication.openSettingsURLString),
            UIApplication.shared.canOpenURL(url) else {
                return
        }

        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    private func setupCaptureSession() {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
        cameraLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        do {
            let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: usingFrontCamera ?  AVCaptureDevice.Position.front: AVCaptureDevice.Position.back)
            let cameraDevice = deviceDiscoverySession.devices[0]
            let videoInput = try AVCaptureDeviceInput(device: cameraDevice)
            captureSession.beginConfiguration()
            if captureSession.canAddInput(videoInput) {
                //print("Adding videoInput to captureSession")
                captureSession.addInput(videoInput)
            } else {
                print("Unable to add videoInput to captureSession")
            }
            if captureSession.canAddOutput(photoOutput) {
                captureSession.addOutput(photoOutput)
                //print("Adding videoOutput to captureSession")
            } else {
                print("Unable to add videoOutput to captureSession")
            }
            captureConnection = AVCaptureConnection(inputPorts: videoInput.ports, output: photoOutput)
            captureSession.commitConfiguration()
            if ((cameraLayer.connection?.isVideoMirroringSupported) != nil) {
                cameraLayer.connection?.automaticallyAdjustsVideoMirroring = false
                cameraLayer.connection?.isVideoMirrored = true
            }
            let rootLayer :CALayer = masterView.layer
            rootLayer.masksToBounds=true
            cameraLayer.frame = rootLayer.bounds
            rootLayer.addSublayer(cameraLayer)
            captureSession.startRunning()
            setUpCameraPreviewUI()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    @objc private func buttonTakePhotoTap() {
        
        let photoSettings = AVCapturePhotoSettings()
        if let photoPreviewType = photoSettings.availablePreviewPhotoPixelFormatTypes.first {
            photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: photoPreviewType]
            photoOutput.capturePhoto(with: photoSettings, delegate: self)
        }
    }
    
    @objc private func exitTakePhoto() {
        if let foundView = view.viewWithTag(1) {
            foundView.removeFromSuperview()
        }
        
        if let foundView = view.viewWithTag(2) {
            foundView.removeFromSuperview()
        }
        
        if let foundView = view.viewWithTag(3) {
            foundView.removeFromSuperview()
        }
            
        self.masterView.layer.sublayers?.forEach { if $0.isKind(of: AVCaptureVideoPreviewLayer.self) { $0.removeFromSuperlayer() }}
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
        
        guard let imageData = photo.fileDataRepresentation() else { return }
        let previewImage = UIImage(data: imageData)
        
        let photoPreviewContainer = PhotoPreviewView(frame: self.masterView.bounds)
        photoPreviewContainer.tag = 1
        photoPreviewContainer.photoImageView.image = previewImage
        self.masterView.addSubview(photoPreviewContainer)
    }
    
    @objc func alertControllerBackgroundTapped()
    {
        self.masterView.backgroundColor = UIColor(hexaRGB: getBackgroundColor())!
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func takePhotoSuccess(_ notification: Notification) {
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        if let capturedImage = notification.userInfo?["capturedImage"] as? UIImage {
            
            if let foundView = view.viewWithTag(1) {
                foundView.removeFromSuperview()
            }
            
            if let foundView = view.viewWithTag(2) {
                foundView.removeFromSuperview()
            }
            
            if let foundView = view.viewWithTag(3) {
                foundView.removeFromSuperview()
            }
            
            if let foundView = view.viewWithTag(4) {
                foundView.removeFromSuperview()
            }
            
            NotificationCenter.default.removeObserver(self)
            
            self.masterView.layer.sublayers?.forEach { if $0.isKind(of: AVCaptureVideoPreviewLayer.self) { $0.removeFromSuperlayer() }}
            
            let vc = ViewControllerStyleRedactor()
            vc.receivedImage = capturedImage
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func takePhotoRetake(_ notification: Notification) {
        
        if !captureSession.isRunning {
            captureSession.startRunning()
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
