//
//  UIButton+Extensions.swift
//  PhotoEditorFilterEffects
//
//  Created by MacBook on 10/18/22.
//



import UIKit

extension UIButton {
    func setButtonActiveColor(hex: String, alpha: CGFloat) {
        self.tintColor = UIColor(hexaRGB: hex, alpha: alpha)
    }
}
