//
//  UIColor.swift
//  Toolkit
//
//  Created by lsc on 27/02/2017.
//
//

import UIKit

public extension UIColor {
    convenience init(red: Int, green: Int, blue: Int, a: CGFloat = 1.0) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: a)
    }
    
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        self.init(red:(hex >> 16) & 0xff, green:(hex >> 8) & 0xff, blue:hex & 0xff, a: alpha)
    }
    
    static var random: UIColor {
      return UIColor(red: CGFloat.random(in: 0...1),
                     green: CGFloat.random(in: 0...1),
                     blue: CGFloat.random(in: 0...1),
                     alpha: 1.0)
    }
}
