//
//  UIView.swift
//  JM-Music
//
//  Created by Kevin on 2018/11/26.
//  Copyright © 2018年 Kevin. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

public extension UIView {
    func addSubviews(_ subviews: UIView...) {
        for aView in subviews {
            self.addSubview(aView)
        }
    }
    
    // handler: (subview) -> stopped
    func enumerateAllSubviews(_ handler: (UIView) -> Bool) {
        self.enumerateSubviews(handler)
    }
    
    @discardableResult
    func insertSeparator(height: CGFloat = 0.5, color: UIColor? = nil, maker: ((ConstraintMaker) -> Void)) -> UIView {
        let separator = UIView()
        separator.backgroundColor = color ?? UIColor.lightGray
        self.addSubview(separator)
        
        separator.snp.makeConstraints { (make) in
            make.height.equalTo(height)
            maker(make)
        }
        
        return separator
    }
}

private extension UIView {
    func enumerateSubviews(_ handler: (UIView) -> Bool) {
        for subview in self.subviews {
            let stopped = handler(subview)
            if stopped == false {
                subview.enumerateAllSubviews(handler)
            }
        }
    }
}
