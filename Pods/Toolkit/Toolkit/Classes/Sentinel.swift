//
//  Sentinel.swift
//  Toolkit
//
//  Created by Endless Summer on 2020/9/1.
//

import Foundation

public final class Sentinel {
    public var value: Int64 = 0
    
    public init() {
        
    }
    
    public func increase() {
        OSAtomicIncrement64(&value)
    }
}
