//
//  GetWidthHeight.swift
//  Image_Search
//
//  Created by GC on 2021/8/18.
//

import Toolkit
import SnapKit

class G {
    
    static let share = G()
    
    let fullScreenSize = UIScreen.main.bounds.size
    let IPhone11ProWidth = 375.0
    let IPhone11ProHeigth = 812.0
    
    func w(_ width:Float) -> CGFloat{
        return CGFloat(Float(fullScreenSize.width) * width / Float(IPhone11ProWidth))
    }
    
    func h(_ height:Float) -> CGFloat {
        return CGFloat(Float(fullScreenSize.height) * ( height / Float(IPhone11ProHeigth)))
    }
}
