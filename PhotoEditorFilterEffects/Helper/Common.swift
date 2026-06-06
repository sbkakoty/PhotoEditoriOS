//
//  Common.swift
//  PhotoEditorFilterEffects
//
//  Created by MacBook on 10/26/22.
//

import UIKit

func getRelativeHeight(_ size: CGFloat) -> CGFloat {
    return (size * (CGFloat(UIScreen.main.bounds.height) / 812.0)) * 0.97
}

func getRelativeWidth(_ size: CGFloat) -> CGFloat {
    return size * (CGFloat(UIScreen.main.bounds.width) / 375.0)
}

func calculateImageViewScale(viewSize: CGSize?, imageSize: CGSize?, leftRightAnchorConstant: CGFloat?, topBottomAnchorConstant: CGFloat?) -> CGSize {
    let adjustedViewSize = CGSize(width: viewSize!.width-leftRightAnchorConstant!, height: viewSize!.height-topBottomAnchorConstant!)
    let xScale = imageSize!.width > 0 ? adjustedViewSize.width / imageSize!.width : 1
    let yScale = imageSize!.height > 0 ? adjustedViewSize.height / imageSize!.height : 1
    let scale = (xScale > 0 && yScale > 0) ? min (xScale, yScale) : 1
    let scaledSize = CGSize (width: scale * imageSize!.width, height: scale * imageSize!.height)
    
    return scaledSize
}

func getBackgroundColor()-> String{
    
    let preferences = UserDefaults.standard
    let themeColorKey = "themeColor"
    
    let themeColor = preferences.string(forKey: themeColorKey)
    return themeColor ?? "#000000";
}

func setBackgroundColor(themeColor: String){
    
    let preferences = UserDefaults.standard
    
    let themeColorKey = "themeColor"
    preferences.set(themeColor, forKey: themeColorKey)
    
    preferences.synchronize()
}

func getMenuBackColor()-> String{
    
    let preferences = UserDefaults.standard
    let menuBackColorKey = "menuBackColor"
    
    let menuBackColor = preferences.string(forKey: menuBackColorKey)
    return menuBackColor ?? "#474747";
}

func setMenuBackColor(menuBackColor: String){
    
    let preferences = UserDefaults.standard
    
    let menuBackColorKey = "menuBackColor"
    preferences.set(menuBackColor, forKey: menuBackColorKey)
    
    preferences.synchronize()
}

func getContentColor()-> String{
    
    let preferences = UserDefaults.standard
    let contentColorKey = "contentColor"
    
    let contentColor = preferences.string(forKey: contentColorKey)
    return contentColor ?? "#899A9A";
}

func setContentColor(contentColor: String){
    
    let preferences = UserDefaults.standard
    
    let contentColorKey = "contentColor"
    preferences.set(contentColor, forKey: contentColorKey)
    
    preferences.synchronize()
}

func setNavBarAppearance(backgroundColorString: String?, contentColorString: String?) {
    
    let newNavBarAppearance = customNavBarAppearance(backgroundColorString: backgroundColorString, contentColorString: contentColorString)
            
    let appearance = UINavigationBar.appearance()
    appearance.scrollEdgeAppearance = newNavBarAppearance
    appearance.compactAppearance = newNavBarAppearance
    appearance.standardAppearance = newNavBarAppearance
    appearance.prefersLargeTitles = false
    if #available(iOS 15.0, *) {
        appearance.compactScrollEdgeAppearance = newNavBarAppearance
    }
}

@available(iOS 13.0, *)
func customNavBarAppearance(backgroundColorString: String?, contentColorString: String?) -> UINavigationBarAppearance {
    
    let customNavBarAppearance = UINavigationBarAppearance()
    
    customNavBarAppearance.configureWithOpaqueBackground()
    customNavBarAppearance.backgroundColor = UIColor(hexaRGB: backgroundColorString!)!
    customNavBarAppearance.shadowColor = .clear
    customNavBarAppearance.shadowImage = UIImage()
    
    // Apply white colored normal and large titles.
    customNavBarAppearance.titleTextAttributes = [
        NSAttributedString.Key.foregroundColor : UIColor(hexaRGB: contentColorString!)!, NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .title2)]
    customNavBarAppearance.largeTitleTextAttributes = [
        NSAttributedString.Key.foregroundColor : UIColor(hexaRGB: contentColorString!)!, NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .title1)]
    
    return customNavBarAppearance
}

func heightForViewPE(text:String, font:UIFont, width:CGFloat) -> CGFloat{
    let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
    label.numberOfLines = 0
    label.lineBreakMode = NSLineBreakMode.byWordWrapping
    label.font = font
    label.text = text

    label.sizeToFit()
    return label.frame.height
}

func widthForViewPE(text: String, font: UIFont, height: CGFloat) -> CGFloat{
    let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: height))
    label.numberOfLines = 0
    label.lineBreakMode = NSLineBreakMode.byWordWrapping
    label.font = font
    label.text = text

    label.sizeToFit()
    return label.frame.width
}
