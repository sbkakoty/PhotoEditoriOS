//
//  UIImageView+Extension.swift
//  PhotoEditorFilterEffects
//
//  Created by MacBook on 10/24/22.
//
import UIKit

extension UIImageView {
    
    func asImage() -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.opaque = false
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: bounds.size, format: format)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
    
    func asScaledImage(scaledSize: CGSize?) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.opaque = false
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: scaledSize!, format: format)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }

    func image(at rect: CGRect) -> UIImage? {
        guard
            let image = image,
            let rect = convertToImageCoordinates(rect)
        else {
            return nil
        }

        return image.cropped(to: rect)
    }

    func convertToImageCoordinates(_ rect: CGRect) -> CGRect? {
        guard let image = image else { return nil }

        let imageSize = CGSize(width: image.size.width, height: image.size.height)
        let imageCenter = CGPoint(x: imageSize.width / 2, y: imageSize.height / 2)

        let imageViewRatio = bounds.width / bounds.height
        let imageRatio = imageSize.width / imageSize.height

        let scale: CGPoint

        switch contentMode {
        case .scaleToFill:
            scale = CGPoint(x: imageSize.width / bounds.width, y: imageSize.height / bounds.height)

        case .scaleAspectFit:
            let value: CGFloat
            if imageRatio < imageViewRatio {
                value = imageSize.height / bounds.height
            } else {
                value = imageSize.width / bounds.width
            }
            scale = CGPoint(x: value, y: value)

        case .scaleAspectFill:
            let value: CGFloat
            if imageRatio > imageViewRatio {
                value = imageSize.height / bounds.height
            } else {
                value = imageSize.width / bounds.width
            }
            scale = CGPoint(x: value, y: value)

        case .center:
            scale = CGPoint(x: 1, y: 1)

        // unhandled cases include
        // case .redraw:
        // case .top:
        // case .bottom:
        // case .left:
        // case .right:
        // case .topLeft:
        // case .topRight:
        // case .bottomLeft:
        // case .bottomRight:

        default:
            fatalError("Unexpected contentMode")
        }

        var rect = rect
        if rect.width < 0 {
            rect.origin.x += rect.width
            rect.size.width = -rect.width
        }

        if rect.height < 0 {
            rect.origin.y += rect.height
            rect.size.height = -rect.height
        }

        return CGRect(x: (rect.minX - bounds.midX) * scale.x + imageCenter.x,
                      y: (rect.minY - bounds.midY) * scale.y + imageCenter.y,
                      width: rect.width * scale.x,
                      height: rect.height * scale.y)
    }
    
    func getPixelColorAt(point:CGPoint) -> UIColor{
            
        let pixel = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: 4)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: pixel, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        
        context!.translateBy(x: -point.x, y: -point.y)
        layer.render(in: context!)
        let color:UIColor = UIColor(red: CGFloat(pixel[0])/255.0,
                                    green: CGFloat(pixel[1])/255.0,
                                    blue: CGFloat(pixel[2])/255.0,
                                    alpha: CGFloat(pixel[3])/255.0)
        
        pixel.deallocate()
        return color
    }
}
