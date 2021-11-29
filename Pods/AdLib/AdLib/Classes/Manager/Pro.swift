//
//  Pro.swift
//  Face
//
//  Created by Kevin on 2019/8/2.
//  Copyright © 2019 Kevin. All rights reserved.
//

import UIKit

#if canImport(Toolkit)
import Toolkit
#elseif canImport(DCGKit)
import DCGKit
#endif

public class Pro: NSObject {
    public static let shared = Pro()
    
    public func addLongPressGesture(to view: UIView?) {
        let longPressGR = UILongPressGestureRecognizer(target: self, action: #selector(self.handleProLongPress))
        longPressGR.minimumPressDuration = 10
        view?.addGestureRecognizer(longPressGR)
    }
    
    // MARK: - Internal
    
    struct UD {
        static let adEnabled = "Pro.1"
    }
    
    var adEnabled: Bool {
        get {
            return UserDefaults.standard.bool(forKey: UD.adEnabled)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UD.adEnabled)
        }
    }
    
    func setup() {
        UserDefaults.standard.register(defaults: [
            UD.adEnabled: true
        ])
        
        if self.adEnabled == false {
            Ad.default.isEnabled = false
        }
    }
    
    // MARK: - Private
    
    @objc func handleProLongPress(gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        
        adEnabled = !adEnabled
        Ad.default.isEnabled = adEnabled
        
        let alert = UIAlertController(title: "", message: adEnabled ? "Ad enabled" : "Ad disabled", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        Util.topViewController().present(alert, animated: true, completion: nil)
    }
}
