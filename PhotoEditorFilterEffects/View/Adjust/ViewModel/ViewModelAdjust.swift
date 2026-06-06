//
//  ViewModelAdjust.swift
//  PhotoEditorFilterEffects
//
//  Created by MacBook on 10/20/22.
//

import Foundation
import UIKit

class ViewModelAdjust: NSObject {
    
    func adjustBrightness(uiImage: UIImage?, adjustValue: Float?) -> UIImage? {
        
        var resultImage: UIImage = uiImage!
        let ciContext = CIContext(options: nil)
        
        var coreImage = CIImage()
        if uiImage?.cgImage != nil{
            coreImage = CIImage(cgImage: (uiImage?.cgImage!)!)
        } else {
            coreImage = (uiImage?.ciImage!)!
        }
        
        let filter = CIFilter(name: "CIColorControls")
        filter?.setValue(adjustValue!, forKey: kCIInputBrightnessKey)
        filter?.setValue(coreImage, forKey: kCIInputImageKey)
        
        if let output = filter?.value(forKey: kCIOutputImageKey) as? CIImage {
            let cgimgresult = ciContext.createCGImage(output, from: output.extent)
            resultImage = UIImage(cgImage: cgimgresult!, scale: 1.0, orientation: uiImage!.imageOrientation)
        } else {
            print("image filtering failed")
        }
        
        return resultImage
    }
    
    func adjustContrast(uiImage: UIImage?, adjustValue: Float?) -> UIImage? {
        
        var resultImage: UIImage = uiImage!
        let ciContext = CIContext(options: nil)
        
        var coreImage = CIImage()
        if uiImage?.cgImage != nil{
            coreImage = CIImage(cgImage: (uiImage?.cgImage!)!)
        } else {
            coreImage = (uiImage?.ciImage!)!
        }
        
        let filter = CIFilter(name: "CIColorControls")
        filter?.setValue(adjustValue!, forKey: kCIInputContrastKey)
        filter?.setValue(coreImage, forKey: kCIInputImageKey)
        
        if let output = filter?.value(forKey: kCIOutputImageKey) as? CIImage {
            let cgimgresult = ciContext.createCGImage(output, from: output.extent)
            resultImage = UIImage(cgImage: cgimgresult!, scale: 1.0, orientation: uiImage!.imageOrientation)
        } else {
            print("image filtering failed")
        }
        
        return resultImage
    }
    
    func adjustExposure(uiImage: UIImage?, adjustValue: Float?) -> UIImage? {
        
        var resultImage: UIImage = uiImage!
        let ciContext = CIContext(options: nil)
        
        var coreImage = CIImage()
        if uiImage!.cgImage != nil {
            coreImage = CIImage(cgImage: uiImage!.cgImage!)
        } else {
            coreImage = uiImage!.ciImage!
        }
        
        let filter = CIFilter(name: "CIExposureAdjust")
        filter?.setValue(adjustValue, forKey: kCIInputEVKey)
        filter?.setValue(coreImage, forKey: kCIInputImageKey)
        
        if let output = filter?.value(forKey: kCIOutputImageKey) as? CIImage {
            let cgimgresult = ciContext.createCGImage(output, from: output.extent)
            resultImage = UIImage(cgImage: cgimgresult!, scale: 1.0, orientation: uiImage!.imageOrientation)
        } else {
            print("image filtering failed")
        }
        
        return resultImage
    }
    
    func adjustSharpness(uiImage: UIImage?, adjustValue: Float?) -> UIImage? {
        
        print("Sharpness: \(adjustValue)")
        var resultImage: UIImage = uiImage!
        let ciContext = CIContext(options: nil)
        
        var coreImage = CIImage()
        if uiImage!.cgImage != nil {
            coreImage = CIImage(cgImage: uiImage!.cgImage!)
        } else {
            coreImage = uiImage!.ciImage!
        }
        
        let filter = CIFilter(name: "CISharpenLuminance")
        filter?.setValue(adjustValue, forKey: kCIInputSharpnessKey)
        filter?.setValue(coreImage, forKey: kCIInputImageKey)
        
        if let output = filter?.value(forKey: kCIOutputImageKey) as? CIImage{
            let cgimgresult = ciContext.createCGImage(output, from: output.extent)
            resultImage = UIImage(cgImage: cgimgresult!, scale: 1.0, orientation: uiImage!.imageOrientation)
        } else {
            print("image filtering failed")
        }
        
        return resultImage
    }
    
    func adjustSaturation(uiImage: UIImage?, adjustValue: Float?) -> UIImage? {
        var resultImage: UIImage = uiImage!
        let ciContext = CIContext(options: nil)
        
        var coreImage = CIImage()
        if uiImage!.cgImage != nil {
            coreImage = CIImage(cgImage: uiImage!.cgImage!)
        } else {
            coreImage = uiImage!.ciImage!
        }
        
        let filter = CIFilter(name: "CIColorControls")
        filter?.setValue(adjustValue, forKey: kCIInputSaturationKey)
        filter?.setValue(coreImage, forKey: kCIInputImageKey)
        
        if let output = filter?.value(forKey: kCIOutputImageKey) as? CIImage{
            let cgimgresult = ciContext.createCGImage(output, from: output.extent)
            resultImage = UIImage(cgImage: cgimgresult!, scale: 1.0, orientation: uiImage!.imageOrientation)
        } else {
            print("image filtering failed")
        }
        
        return resultImage
    }
    
    func adjustWarm(uiImage: UIImage?, adjustValue: Float?) -> UIImage? {
        var resultImage: UIImage = uiImage!
        let ciContext = CIContext(options: nil)
        
        var coreImage = CIImage()
        if uiImage!.cgImage != nil {
            coreImage = CIImage(cgImage: uiImage!.cgImage!)
        } else {
            coreImage = uiImage!.ciImage!
        }
        
        var number = CGFloat(adjustValue!)
        if number > 157.9 {
            let minus = 172 - number
            number = 165 + minus
        } else {
            let minus = 157.9 - number
            number = 130 + minus
        }
        
        let vector0 = CIVector(x: 4000, y: number)
        let vector1 = CIVector(x: 5000, y: number)
        
        let filter = CIFilter(name: "CITemperatureAndTint")
        filter?.setValue(coreImage, forKey: kCIInputImageKey)
        filter?.setValue(vector0, forKey: "inputNeutral")
        filter?.setValue(vector1, forKey: "inputTargetNeutral")
        
        if let output = filter?.value(forKey: kCIOutputImageKey) as? CIImage {
            let cgimgresult = ciContext.createCGImage(output, from: output.extent)
            resultImage = UIImage(cgImage: cgimgresult!, scale: 1.0, orientation: uiImage!.imageOrientation)
        } else {
            print("image filtering failed")
        }
        
        return resultImage
    }
    
    func adjustFade(uiImage: UIImage?, adjustValue: Float?) -> UIImage? {
        
        var resultImage: UIImage = uiImage!
        let ciContext = CIContext(options: nil)
        
        var coreImage = CIImage()
        if uiImage?.cgImage != nil{
            coreImage = CIImage(cgImage: (uiImage?.cgImage!)!)
        } else {
            coreImage = (uiImage?.ciImage!)!
        }
        
        let filter = CIFilter(name: "CIPhotoEffectFade")
        filter?.setValue(adjustValue!, forKey: "inputImage")
        filter?.setValue(coreImage, forKey: kCIInputImageKey)
        
        if let output = filter?.value(forKey: kCIOutputImageKey) as? CIImage {
            let cgimgresult = ciContext.createCGImage(output, from: output.extent)
            let image = UIImage(cgImage: cgimgresult!)
            let filter = CIFilter(name: "CIHighlightShadowAdjust")
            filter?.setValue(adjustValue!, forKey: "inputShadowAmount")
            filter?.setValue(CIImage(cgImage: image.cgImage!), forKey: kCIInputImageKey)
            if let output = filter?.value(forKey: kCIOutputImageKey) as? CIImage
            {
                let cgimgresult = ciContext.createCGImage(output, from: output.extent)
                resultImage = UIImage(cgImage: cgimgresult!, scale: 1.0, orientation: uiImage!.imageOrientation)
            }
        } else {
            print("image filtering failed")
        }
        
        return resultImage
    }
}
