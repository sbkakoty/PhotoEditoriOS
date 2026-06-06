//
//  UIFont+Extensions.swift
//  PhotoEditorFilterEffects
//
//  Created by MacBook on 10/17/22.
//

import Foundation
import UIKit

extension UIFont {
    
    convenience init?(
        style: UIFont.TextStyle,
        weight: UIFont.Weight = .regular,
        design: UIFontDescriptor.SystemDesign = .default) {

        guard let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: style)
            .addingAttributes([UIFontDescriptor.AttributeName.traits: [UIFontDescriptor.TraitKey.weight: weight]])
            .withDesign(design) else {
                return nil
        }
        self.init(descriptor: descriptor, size: 0)
    }
    
    func preferredFontWithSize(withTextStyle textStyle: UIFont.TextStyle, maxSize: CGFloat) -> UIFont {
        // Get the descriptor
        let fontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: textStyle)

        return UIFont(descriptor: fontDescriptor, size: maxSize)
    }
    
    func withTraits(traits:UIFontDescriptor.SymbolicTraits) -> UIFont {
        let descriptor = fontDescriptor.withSymbolicTraits(traits)
        return UIFont(descriptor: descriptor!, size: 0) //size 0 means keep the size as it is
    }

    func bold() -> UIFont {
        return withTraits(traits: .traitBold)
    }

    func italic() -> UIFont {
        return withTraits(traits: .traitItalic)
    }
}

