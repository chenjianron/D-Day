//
//  UIImage+Resize.swift
//  CalculatorPhotoVault
//
//  Created by Tracy on 27/02/2017.
//  Copyright © 2017 com.Flow. All rights reserved.
//

import UIKit

extension UIImage {
    
    public func scaled(to size: CGSize, scale: CGFloat = 1) -> UIImage {
        let targetSize = self.parse(size: size)
        
        if self.isResizable(targetSize: targetSize) == false {
            return self
        }
        
        UIGraphicsBeginImageContextWithOptions(targetSize, false, scale)
        draw(in: CGRect(origin: .zero, size: targetSize))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext() ?? self
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
    
    public func aspectScaled(toFit targetSize: CGSize, scale: CGFloat = 1) -> UIImage {
        if self.isResizable(targetSize: targetSize) == false {
            return self
        }
        
        let imageAspectRatio = self.size.width / self.size.height
        let canvasAspectRatio = targetSize.width / targetSize.height
        
        var resizeFactor: CGFloat
        
        if imageAspectRatio > canvasAspectRatio {
            resizeFactor = targetSize.width / self.size.width
        } else {
            resizeFactor = targetSize.height / self.size.height
        }
        
        let scaledSize = CGSize(width: self.size.width * resizeFactor, height: self.size.height * resizeFactor)
        let origin = CGPoint(x: (targetSize.width - scaledSize.width) / 2.0, y: (targetSize.height - scaledSize.height) / 2.0)
        
        UIGraphicsBeginImageContextWithOptions(targetSize, false, scale)
        draw(in: CGRect(origin: origin, size: scaledSize))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext() ?? self
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
    
    public func aspectScaled(toFill targetSize: CGSize, scale: CGFloat = 1) -> UIImage {
        if self.isResizable(targetSize: targetSize) == false {
            return self
        }
        
        let imageAspectRatio = self.size.width / self.size.height
        let canvasAspectRatio = targetSize.width / targetSize.height
        
        var resizeFactor: CGFloat
        
        if imageAspectRatio > canvasAspectRatio {
            resizeFactor = targetSize.height / self.size.height
        } else {
            resizeFactor = targetSize.width / self.size.width
        }
        
        let scaledSize = CGSize(width: self.size.width * resizeFactor, height: self.size.height * resizeFactor)
        let origin = CGPoint(x: (targetSize.width - scaledSize.width) / 2.0, y: (targetSize.height - scaledSize.height) / 2.0)
        
        UIGraphicsBeginImageContextWithOptions(targetSize, false, scale)
        draw(in: CGRect(origin: origin, size: scaledSize))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext() ?? self
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
    
    private func isResizable(targetSize: CGSize) -> Bool {
        return targetSize != self.size && self.size.width > 0 && self.size.height > 0 && targetSize.width > 0 && targetSize.height > 0
    }
    
    private func parse(size: CGSize) -> CGSize {
        var result = size
        
        if size.width == -1 && size.height == -1 {
            result = self.size
        }
        else if size.width == -1 {
            result.width = self.size.width / self.size.height * size.height
        }
        else if size.height == -1 {
            result.height = size.width / (self.size.width / self.size.height)
        }
        
        return result
    }
}
