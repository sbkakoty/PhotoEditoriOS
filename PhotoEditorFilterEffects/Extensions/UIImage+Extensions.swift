//
//  UIImage+Extensions.swift
//  PhotoEditorFilterEffects
//
//  Created by MacBook on 10/19/22.
//

import Foundation
import UIKit

extension UIImage {
    
    func rotated(angleDiff: CGFloat?, flipped: Bool?) -> UIImage? {
        
        guard let cgImage = self.cgImage else { return nil }
        
        let transform = CGAffineTransform(rotationAngle: -angleDiff!)
        var rect = CGRect(origin: .zero, size: self.size).applying(transform)
        rect.origin = .zero

        let renderer = UIGraphicsImageRenderer(size: rect.size)
        
        return renderer.image { renderContext in
            
            renderContext.cgContext.translateBy(x: rect.midX, y: rect.midY)
            renderContext.cgContext.rotate(by: -angleDiff!)
            
            if flipped! {
                renderContext.cgContext.scaleBy(x: -1.0, y: -1.0)
            } else {
                renderContext.cgContext.scaleBy(x: 1.0, y: -1.0)
            }
            
            let drawRect = CGRect(origin: CGPoint(x: -self.size.width/2, y: -self.size.height/2), size: self.size)
            renderContext.cgContext.draw(cgImage, in: drawRect)
        }
    }
    
    public func imageRotatedByRadian(radian: CGFloat) -> UIImage {
        
        // calculate the size of the rotated view's containing box for our drawing space
        let rotatedViewBox = UIView(frame: CGRect(origin: CGPoint.zero, size: size))
        let t = CGAffineTransform(rotationAngle: -CGFloat(radian))
        rotatedViewBox.transform = t
        let rotatedSize = rotatedViewBox.frame.size
        
        // Create the bitmap context
        UIGraphicsBeginImageContext(rotatedSize)
        let bitmap = UIGraphicsGetCurrentContext()
        
        // Move the origin to the middle of the image so we will rotate and scale around the center.
        bitmap!.translateBy(x: rotatedSize.width / 2.0, y: rotatedSize.height / 2.0)
        
        //   // Rotate the image context
        bitmap!.rotate(by: radian);
        
        // Now, draw the rotated/scaled image into the context
        bitmap!.scaleBy(x: 1.0, y: -1.0)
        bitmap?.draw(self.cgImage!, in: CGRect(x: -size.width / 2, y: -size.height / 2, width: size.width, height: size.height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func crop(to:CGSize) -> UIImage {

        guard let cgimage = self.cgImage else { return self }

        let contextImage: UIImage = UIImage(cgImage: cgimage)

        guard let newCgImage = contextImage.cgImage else { return self }

        let contextSize: CGSize = contextImage.size

        //Set to square
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        let cropAspect: CGFloat = to.width / to.height

        var cropWidth: CGFloat = to.width
        var cropHeight: CGFloat = to.height

        if to.width > to.height { //Landscape
            cropWidth = contextSize.width
            cropHeight = contextSize.width / cropAspect
            posY = (contextSize.height - cropHeight) / 2
        } else if to.width < to.height { //Portrait
            cropHeight = contextSize.height
            cropWidth = contextSize.height * cropAspect
            posX = (contextSize.width - cropWidth) / 2
        } else { //Square
            if contextSize.width >= contextSize.height { //Square on landscape (or square)
                cropHeight = contextSize.height
                cropWidth = contextSize.height * cropAspect
                posX = (contextSize.width - cropWidth) / 2
            }else{ //Square on portrait
                cropWidth = contextSize.width
                cropHeight = contextSize.width / cropAspect
                posY = (contextSize.height - cropHeight) / 2
            }
        }

        let rect: CGRect = CGRect(x: posX, y: posY, width: cropWidth, height: cropHeight)

        // Create bitmap image from context using the rect
        guard let imageRef: CGImage = newCgImage.cropping(to: rect) else { return self}

        // Create a new image based on the imageRef and rotate back to the original orientation
        let cropped: UIImage = UIImage(cgImage: imageRef, scale: self.scale, orientation: self.imageOrientation)

        UIGraphicsBeginImageContextWithOptions(to, false, self.scale)
        cropped.draw(in: CGRect(x: 0, y: 0, width: to.width, height: to.height))
        let resized = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return resized ?? self
    }

    func alpha(_ value:CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: CGPoint.zero, blendMode: .normal, alpha: value)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    func fixOrientation() -> UIImage {
        if self.imageOrientation == UIImage.Orientation.up {
            return self

        }
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)

        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))

        let normalizedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!

        UIGraphicsEndImageContext()

        return normalizedImage;
    }
    
    func filterEffectMoon() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let bounds = CGRect(origin: .zero, size: size)
        UIRectFill(bounds)
        draw(in: bounds, blendMode: .luminosity, alpha: 1.0)
        let tinted = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return tinted!
        /*let context = CIContext(options: nil)
        let ciImage = CoreImage.CIImage(image: self)!

        // Set image color to b/w
        let bwFilter = CIFilter(name: "CIColorControls")!
        bwFilter.setValuesForKeys([kCIInputImageKey:ciImage, kCIInputBrightnessKey:NSNumber(value: 0), kCIInputContrastKey:NSNumber(value: 1.1), kCIInputSaturationKey:NSNumber(value: 0.0)])
        let bwFilterOutput = (bwFilter.outputImage)!

        // Adjust exposure
        let exposureFilter = CIFilter(name: "CIExposureAdjust")!
        exposureFilter.setValuesForKeys([kCIInputImageKey:bwFilterOutput, kCIInputEVKey:NSNumber(value: 0.3)])
        let exposureFilterOutput = (exposureFilter.outputImage)!

        // Create UIImage from context
        let bwCGIImage = context.createCGImage(exposureFilterOutput, from: ciImage.extent)
        let resultImage = UIImage(cgImage: bwCGIImage!, scale: 1.0, orientation: self.imageOrientation)

        return resultImage*/
    }
    
    func filterEffectLark() -> UIImage {
        let context = CIContext(options: nil)
        let ciImage = CoreImage.CIImage(image: self)!

        // Adjust exposure
        let exposureFilter = CIFilter(name: "CIHueAdjust")!
        exposureFilter.setValuesForKeys([kCIInputImageKey:ciImage, kCIInputAngleKey:NSNumber(value: 118.8)])
        let exposureFilterOutput = (exposureFilter.outputImage)!

        // Create UIImage from context
        let bwCGIImage = context.createCGImage(exposureFilterOutput, from: ciImage.extent)
        let resultImage = UIImage(cgImage: bwCGIImage!, scale: 1.0, orientation: self.imageOrientation)

        return resultImage
    }
    
    func filterEffectHueAdjust() -> UIImage {
        
        let context = CIContext(options: nil)
        let ciImage = CoreImage.CIImage(image: self)!
        
        // Adjust exposure
        let exposureFilter = CIFilter(name: "CIHueAdjust")!
        exposureFilter.setValuesForKeys([kCIInputImageKey:ciImage, kCIInputAngleKey:NSNumber(value: 119.8)])
        let exposureFilterOutput = (exposureFilter.outputImage)!

        // Create UIImage from context
        let bwCGIImage = context.createCGImage(exposureFilterOutput, from: ciImage.extent)
        let resultImage = UIImage(cgImage: bwCGIImage!, scale: 1.0, orientation: self.imageOrientation)

        return resultImage
    }
    
    func filterEffectReyes() -> UIImage {
        
        let context = CIContext(options: nil)
        let ciImage = CoreImage.CIImage(image: self)!
        
        let filter = CIFilter(name: "CIPhotoEffectInstant")
        // convert UIImage to CIImage and set as input
        let ciInput = CIImage(image: self)
        filter?.setValue(ciInput, forKey: "inputImage")
        // get output CIImage, render as CGImage first to retain proper UIImage scale
        let ciOutput = (filter?.outputImage)!
        
        // Adjust exposure
        let exposureFilter = CIFilter(name: "CIExposureAdjust")!
        exposureFilter.setValuesForKeys([kCIInputImageKey:ciOutput, kCIInputEVKey:NSNumber(value: 0)])
        let exposureFilterOutput = (exposureFilter.outputImage)!

        // Create UIImage from context
        let bwCGIImage = context.createCGImage(exposureFilterOutput, from: ciImage.extent)
        let resultImage = UIImage(cgImage: bwCGIImage!, scale: 1.0, orientation: self.imageOrientation)

        return resultImage
    }
    
    func createOverlayGreen() -> CIImage {
        let overlayColor = UIColor.systemGreen.withAlphaComponent(1)
        let c = CIColor(color: overlayColor)
        let parameters = [kCIInputColorKey: c]
        guard let filter = CIFilter(name: "CIConstantColorGenerator", parameters: parameters) else {
            fatalError()
        }
        guard let overlay = filter.outputImage else { fatalError() }
        return overlay
    }

    func compositeSourceOverGreen(img: CIImage, overlay:CIImage) -> CIImage {

        let parameters = [
            kCIInputBackgroundImageKey: img,
            kCIInputImageKey: createOverlayGreen()
        ]
        guard let filter = CIFilter(name: "CIColorBlendMode", parameters: parameters) else {
            fatalError()
        }
        guard let outputImage = filter.outputImage else { fatalError() }
        let cropRect = img.extent
        return outputImage.cropped(to: cropRect)
    }
    
    func filterEffectRedToGreen() -> UIImage {
        
        let context = CIContext(options: nil)
        let ciImage = compositeSourceOverGreen(img: CoreImage.CIImage(image: self)!, overlay:CoreImage.CIImage(image: self)!)

        // Create UIImage from context
        let cgiImage = context.createCGImage(ciImage, from: ciImage.extent)
        let resultImage = UIImage(cgImage: cgiImage!, scale: 1.0, orientation: self.imageOrientation)

        return resultImage
    }
    
    func createOverlay() -> CIImage {
        let overlayColor = UIColor.red.withAlphaComponent(0.7)
        let c = CIColor(color: overlayColor)
        let parameters = [kCIInputColorKey: c]
        guard let filter = CIFilter(name: "CIConstantColorGenerator", parameters: parameters) else {
            fatalError()
        }
        guard let overlay = filter.outputImage else { fatalError() }
        return overlay
    }

    func compositeSourceOver(img: CIImage, overlay:CIImage) -> CIImage {

        let parameters = [
            kCIInputBackgroundImageKey: img,
            kCIInputImageKey: createOverlay()
        ]
        guard let filter = CIFilter(name: "CIColorBlendMode", parameters: parameters) else {
            fatalError()
        }
        guard let outputImage = filter.outputImage else { fatalError() }
        let cropRect = img.extent
        return outputImage.cropped(to: cropRect)
    }
    
    func filterEffectRedInfluence() -> UIImage {
        
        let context = CIContext(options: nil)
        let ciImage = compositeSourceOver(img: CoreImage.CIImage(image: self)!, overlay:CoreImage.CIImage(image: self)!)

        // Create UIImage from context
        let cgiImage = context.createCGImage(ciImage, from: ciImage.extent)
        let resultImage = UIImage(cgImage: cgiImage!, scale: 1.0, orientation: self.imageOrientation)

        return resultImage
    }
    
    func filterEffectScan() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let bounds = CGRect(origin: .zero, size: size)
        UIRectFill(bounds)
        draw(in: bounds, blendMode: .luminosity, alpha: 1.0)
        let tinted = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return tinted!
    }
    
    func filterEffectExclusion() -> UIImage {
        let context = CIContext(options: nil)
        let ciImage = compositeSourceOverCustomColor(img: CoreImage.CIImage(image: self)!)

        // Create UIImage from context
        let cgiImage = context.createCGImage(ciImage, from: ciImage.extent)
        let resultImage = UIImage(cgImage: cgiImage!, scale: 1.0, orientation: self.imageOrientation)

        return resultImage
    }
    
    func compositeSourceOverCustomColor(img: CIImage) -> CIImage {

        let parameters = [
            kCIInputBackgroundImageKey: img,
            kCIInputImageKey: createOverlayCustomColor()
        ]
        guard let filter = CIFilter(name: "CIDifferenceBlendMode", parameters: parameters) else {
            fatalError()
        }
        guard let outputImage = filter.outputImage else { fatalError() }
        let cropRect = img.extent
        return outputImage.cropped(to: cropRect)
    }
    
    func createOverlayCustomColor() -> CIImage {
        let overlayColor = UIColor(hexaRGB: "#C4C4C4", alpha: 1.0)
        let c = CIColor(color: overlayColor!)
        let parameters = [kCIInputColorKey: c]
        guard let filter = CIFilter(name: "CIConstantColorGenerator", parameters: parameters) else {
            fatalError()
        }
        guard let overlay = filter.outputImage else { fatalError() }
        
        return overlay
    }
    
    func mixBlendModeOverlay(img: CIImage) -> CIImage {

        let parameters = [
            kCIInputBackgroundImageKey: img,
            kCIInputImageKey: createOverlayCustomColor()
        ]
        guard let filter = CIFilter(name: "CIMultiplyCompositing", parameters: parameters) else {
            fatalError()
        }
        guard let outputImage = filter.outputImage else { fatalError() }
        return outputImage
    }
    
    func resizeTopAlignedToFill(newWidth: CGFloat) -> UIImage? {
        let newHeight = size.height * newWidth / size.width

        let newSize = CGSize(width: newWidth, height: newHeight)

        UIGraphicsBeginImageContextWithOptions(newSize, false, UIScreen.main.scale)
        draw(in: CGRect(origin: .zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
    
    /// Resize the image to be the required size, stretching it as needed.
    ///
    /// - parameter newSize:      The new size of the image.
    /// - parameter contentMode:  The `UIView.ContentMode` to be applied when resizing image.
    ///                           Either `.scaleToFill`, `.scaleAspectFill`, or `.scaleAspectFit`.
    ///
    /// - returns:                Return `UIImage` of resized image.

    func scaled(to newSize: CGSize, contentMode: UIView.ContentMode = .scaleToFill) -> UIImage? {
        switch contentMode {
        case .scaleToFill:
            return filled(to: newSize)

        case .scaleAspectFill, .scaleAspectFit:
            let horizontalRatio = size.width  / newSize.width
            let verticalRatio   = size.height / newSize.height

            let ratio: CGFloat!
            if contentMode == .scaleAspectFill {
                ratio = min(horizontalRatio, verticalRatio)
            } else {
                ratio = max(horizontalRatio, verticalRatio)
            }

            let sizeForAspectScale = CGSize(width: size.width / ratio, height: size.height / ratio)
            let image = filled(to: sizeForAspectScale)
            let doesAspectFitNeedCropping = contentMode == .scaleAspectFit && (newSize.width > sizeForAspectScale.width || newSize.height > sizeForAspectScale.height)
            if contentMode == .scaleAspectFill || doesAspectFitNeedCropping {
                let subRect = CGRect(
                    x: floor((sizeForAspectScale.width - newSize.width) / 2.0),
                    y: floor((sizeForAspectScale.height - newSize.height) / 2.0),
                    width: newSize.width,
                    height: newSize.height)
                return image?.cropped(to: subRect)
            }
            return image

        default:
            return nil
        }
    }

    /// Resize the image to be the required size, stretching it as needed.
    ///
    /// - parameter newSize:   The new size of the image.
    ///
    /// - returns:             Resized `UIImage` of resized image.

    func filled(to newSize: CGSize) -> UIImage? {
        let format = UIGraphicsImageRendererFormat()
        format.opaque = false
        format.scale = scale

        return UIGraphicsImageRenderer(size: newSize, format: format).image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
    }

    /// Crop the image to be the required size.
    ///
    /// - parameter bounds:    The bounds to which the new image should be cropped.
    ///
    /// - returns:             Cropped `UIImage`.

    func cropped(to bounds: CGRect) -> UIImage? {
        // if bounds is entirely within image, do simple CGImage `cropping` ...

        if CGRect(origin: .zero, size: size).contains(bounds), imageOrientation == .up, let cgImage = cgImage {
            return cgImage.cropping(to: bounds * scale).flatMap {
                UIImage(cgImage: $0, scale: scale, orientation: imageOrientation)
            }
        }

        // ... otherwise, manually render whole image, only drawing what we need

        let format = UIGraphicsImageRendererFormat()
        format.opaque = false
        format.scale = scale

        return UIGraphicsImageRenderer(size: bounds.size, format: format).image { _ in
            let origin = CGPoint(x: -bounds.minX, y: -bounds.minY)
            draw(in: CGRect(origin: origin, size: size))
        }
    }

    /// Resize the image to fill the rectange of the specified size, preserving the aspect ratio, trimming if needed.
    ///
    /// - parameter newSize:   The new size of the image.
    ///
    /// - returns:             Return `UIImage` of resized image.

    func scaledAspectFill(to newSize: CGSize) -> UIImage? {
        return scaled(to: newSize, contentMode: .scaleAspectFill)
    }

    /// Resize the image to fit within the required size, preserving the aspect ratio, with no trimming taking place.
    ///
    /// - parameter newSize:   The new size of the image.
    ///
    /// - returns:             Return `UIImage` of resized image.

    func scaledAspectFit(to newSize: CGSize) -> UIImage? {
        return scaled(to: newSize, contentMode: .scaleAspectFit)
    }
    
    typealias EditSubviewClosure<T: UIView> = (_ parentSize: CGSize, _ viewToAdd: T)->()

    /*func with<T: UIView>(view: T, editSubviewClosure: EditSubviewClosure<T>) -> UIImage {

        if let copiedView = view.copyObject() as? T {
            UIGraphicsBeginImageContext(size)

            let basicSize = CGRect(origin: .zero, size: size)
            draw(in: basicSize)
            editSubviewClosure(size, copiedView)
            copiedView.draw(basicSize)

            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return newImage!
        }
        return self

    }*/
}

extension CGSize {
    static func * (lhs: CGSize, rhs: CGFloat) -> CGSize {
        return CGSize(width: lhs.width * rhs, height: lhs.height * rhs)
    }
}

extension CGPoint {
    static func * (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        return CGPoint(x: lhs.x * rhs, y: lhs.y * rhs)
    }
}

extension CGRect {
    static func * (lhs: CGRect, rhs: CGFloat) -> CGRect {
        return CGRect(origin: lhs.origin * rhs, size: lhs.size * rhs)
    }
}
