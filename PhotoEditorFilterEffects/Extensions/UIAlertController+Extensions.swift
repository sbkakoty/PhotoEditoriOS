//
//  UIAlertController+Extensions.swift
//  PhotoEditorFilterEffects
//
//  Created by MacBook on 10/17/22.
//

import UIKit

extension UIAlertController {

    func setBackgroundColor(color: UIColor) {
        if let bgView = self.view.subviews.first, let groupView = bgView.subviews.first, let contentView = groupView.subviews.first {
            contentView.backgroundColor = color
        }
    }
    
    func handlePopupInBigScreenIfNeeded(sourceView: UIView, permittedArrowDirections: UIPopoverArrowDirection? = nil) {
        func handlePopupInBigScreen(sourceView: UIView, permittedArrowDirections: UIPopoverArrowDirection? = nil) {
            // https://stackoverflow.com/a/27823616/288724
            popoverPresentationController?.permittedArrowDirections = permittedArrowDirections ?? .any
            popoverPresentationController?.sourceView = sourceView
            popoverPresentationController?.sourceRect = sourceView.bounds
        }

        if #available(macCatalyst 14.0, iOS 14.0, *) {
            if UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.userInterfaceIdiom == .mac {
                handlePopupInBigScreen(sourceView: sourceView, permittedArrowDirections: permittedArrowDirections)
            }
        } else {
            if UIDevice.current.userInterfaceIdiom == .pad {
                handlePopupInBigScreen(sourceView: sourceView, permittedArrowDirections: permittedArrowDirections)
            }
        }
    }
}
