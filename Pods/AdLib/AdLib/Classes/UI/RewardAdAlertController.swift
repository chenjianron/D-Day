//
//  RewardAdAlertController.swift
//  Ad
//
//  Created by Kevin on 2018/11/7.
//

import UIKit

class RewardAdAlertAction: UIAlertAction {
    func wait(for seconds: Int) {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        
        self.isEnabled = false
        for delay in 0...seconds {
            self.perform(#selector(tick(left:)), with: NSNumber.init(value: seconds - delay), afterDelay: TimeInterval(delay))
        }
    }
    
    @objc func tick(left: NSNumber) {
        var title = (self.title ?? "") as NSString
        
        let regexPattern = "\\s\\(\\d+\\)"
        let range = title.range(of: regexPattern, options: .regularExpression)
        if range.length > 0 {
            title = title.replacingCharacters(in: range, with: "") as NSString
        }
        
        if left.intValue > 0 {
            title = "\(title) (\(left))" as NSString
        }

        self.setValue(title, forKey: "title")
        
        if left.intValue == 0 {
            self.isEnabled = true
        }
    }
}
