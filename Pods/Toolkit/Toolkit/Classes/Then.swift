//
//  Then.swift
//  CalculatorVault
//
//  Created by Tracy on 19/04/2017.
//  Copyright © 2017 Tracy. All rights reserved.
//

import UIKit

public class Then {
    public typealias Action = (_ result: Any?, _ next: @escaping Next) -> Void
    public typealias Next = (_ result: Any?) -> Void
    
    private var actions: [Action]  = []
    
    public init() {
        //
    }

    public init(_ comment: String? = nil, action: @escaping Action) {
        self.actions.append(action)
    }
    
    @discardableResult
    public func then(_ comment: String? = nil, action: @escaping Action) -> Then {
        self.actions.append(action)
        return self
    }
    
    public func run() {
        self.runaction(at: 0, result: nil)
    }
    
    // MARK: - Private
    private func runaction(at index: Int, result: Any?) {
        if (self.actions.count <= 0) {
            return
        }
        
        if index < 0 || index > self.actions.count - 1 {
            return
        }
        
        let action = self.actions[index]
        
        let next: Next = { r in
            self.runaction(at: index + 1, result: r)
        }
        
        action(result, next)
    }
}
