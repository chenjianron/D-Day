//
//  VerticalAlignedButton.swift
//
//  Created by Tina on 2019/4/7.
//  Copyright © 2019年 Kevin. All rights reserved.
//

import UIKit

public class VerticallyAlignedButton: UIButton {
    
    public var spacing: CGFloat = 18

    override public func layoutSubviews() {
        super.layoutSubviews()
        self.alignContentsVertically()
    }
    
    private func alignContentsVertically() {
        let imageSize = self.imageView?.frame.size ?? .zero
        self.titleEdgeInsets = UIEdgeInsets(top: 0, left: -imageSize.width, bottom: -(imageSize.height + spacing), right: 0)
        
        let titleSize = self.titleLabel?.frame.size ?? .zero
        self.imageEdgeInsets = UIEdgeInsets(top: -(titleSize.height + spacing), left: 0, bottom: 0, right: -titleSize.width)
    }
}
