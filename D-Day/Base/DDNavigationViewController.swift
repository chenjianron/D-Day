//
//  DDNavigationViewController.swift
//  D-Day
//
//  Created by GC on 2021/10/11.
//

import UIKit

class DDNavigationViewController: UINavigationController, UIGestureRecognizerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.shadowImage = UIImage()
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        interactivePopGestureRecognizer?.delegate = self
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

}
