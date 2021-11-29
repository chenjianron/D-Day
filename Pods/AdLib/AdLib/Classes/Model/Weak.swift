//
//  WeakBannerContainer.swift
//  AdLib
//
//  Created by 丁允鑫 on 2021/11/4.
//

import Foundation


class Weak<T: AnyObject> {
    
    weak var value: T?
    
    init(value: T) {
        self.value = value
    }
    
}
