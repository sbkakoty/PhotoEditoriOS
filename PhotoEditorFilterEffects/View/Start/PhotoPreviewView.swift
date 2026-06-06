//
//  PhotoPreviewView.swift
//  PhotoEditorFilterEffects
//
//  Created by MacBook on 10/18/22.
//

import UIKit
import Photos

class PhotoPreviewView: UIView {
    
    //static let albumName = AppConfig.albumName
    var assetCollection: PHAssetCollection!
    
    let photoImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    lazy private var retakeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle(NSLocalizedString("actionRetakePhoto", comment: ""), for: .normal)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title2)
        button.tintColor = UIColor.white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(retakeButtonPressed), for: .touchUpInside)
        return button
    }()
    
    lazy private var savePhotoButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle(NSLocalizedString("actionUsePhoto", comment: ""), for: .normal)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title2)
        button.tintColor = UIColor.white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(buttonSavePhoPressed), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let actionPanel = UIView()
        actionPanel.backgroundColor = UIColor(hexaRGB: "#000000")!
        actionPanel.translatesAutoresizingMaskIntoConstraints = false
        actionPanel.addSubview(retakeButton)
        actionPanel.addSubview(savePhotoButton)
        self.addSubview(actionPanel)
        
        NSLayoutConstraint.activate([
            actionPanel.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            actionPanel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            actionPanel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            actionPanel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            actionPanel.heightAnchor.constraint(equalToConstant: 130),
            
            retakeButton.leftAnchor.constraint(equalTo: actionPanel.leftAnchor, constant: 20.0),
            retakeButton.bottomAnchor.constraint(equalTo: actionPanel.bottomAnchor, constant: -30.0),
            retakeButton.heightAnchor.constraint(equalToConstant: 80),
            
            savePhotoButton.rightAnchor.constraint(equalTo: actionPanel.rightAnchor, constant: -20.0),
            savePhotoButton.bottomAnchor.constraint(equalTo: actionPanel.bottomAnchor, constant: -30.0),
            savePhotoButton.heightAnchor.constraint(equalToConstant: 80)
            
        ])
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    @objc private func retakeButtonPressed() {
        DispatchQueue.main.async {
            self.removeFromSuperview()
        }
        
        NotificationCenter.default.post(name: Notification.Name("com.takephoto.retake"), object: nil, userInfo: nil)
    }
    
    @objc private func buttonSavePhoPressed() {
        
        guard let previewImage = self.photoImageView.image else { return }
        let imageDataDict:[String: UIImage] = ["capturedImage": previewImage]
        
        DispatchQueue.main.async {
            self.removeFromSuperview()
        }
        
        NotificationCenter.default.post(name: Notification.Name("com.takephoto.success"), object: nil, userInfo: imageDataDict)
    }
}
