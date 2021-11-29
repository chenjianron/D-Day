//
//  NameSpace.swift
//  Toolkit
//
//  Created by Endless Summer on 2020/9/8.
//

import Foundation

// 定义泛型类
public struct STKit<Base> {
    public let base: Base
    public init(_ base: Base) {
        self.base = base
    }
}

// 定义泛型协议
public protocol STKitCompatible {
    associatedtype CompatibleType
    var st: CompatibleType { get }
}

// 协议的扩展
public extension STKitCompatible {
    var st: STKit<Self>{
        get { return STKit(self) }
    }
}
