//
//  UIViewController+NavigationItem.swift
//  D-Day
//
//  Created by GC on 2021/10/27.
//
import Toolkit

extension UIViewController {
    
    // Back
    func showBackItem() {
        let image = #imageLiteral(resourceName: "Back").withRenderingMode(.alwaysOriginal)
        let barButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(backItemDidClick(_:)))
        navigationItem.leftBarButtonItem = barButtonItem
    }
    
    @objc func backItemDidClick(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // Close
    func showCloseItem() {
        let image = #imageLiteral(resourceName: "CloseIcon").withRenderingMode(.alwaysOriginal)
        let barButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(closeItemDidClick(_:)))
        navigationItem.leftBarButtonItem = barButtonItem
    }
    
    @objc func closeItemDidClick(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: false)
    }

}
