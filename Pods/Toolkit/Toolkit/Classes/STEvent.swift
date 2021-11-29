//
//  STEvent.swift
//  Toolkit
//
//  Created by Endless Summer on 2020/9/8.
//

import Foundation

public class STEvent: NSObject {
    public var sender: UIView
    
    public var info: [String : Any]
    
    public let identifier: Any
    
    public init(sender: UIView, info: [String: Any], identifier: Any) {
        self.sender = sender
        self.info = info
        self.identifier = identifier
        
        super.init()
    }
}

extension UIResponder {
    @objc open func responseEvent(_ event: STEvent) {
        self.next?.responseEvent(event)
    }
}
