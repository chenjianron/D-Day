//
//  MarketingHelper+TrackPage.swift
//  MarketingHelper
//
//  Created by Endless Summer on 2020/8/21.
//

import Foundation
#if canImport(Toolkit) //
import Toolkit
#elseif canImport(DCGKit) // DCG
import DCGKit
#endif

public protocol TrackPageProtocol {
    var pageName: String? { get }
}

public extension MarketingHelper {
    
    static private(set) var currentPageName = ""
    
    static fileprivate func controllerDidAppear(_ controller: UIViewController) {
        guard let vc = controller as? TrackPageProtocol else { return }
        guard let pageName = vc.pageName else { return }
        
        logPageView(pageName)
    }
    
    static func logPageView(_ pageName: String) {
        if pageName == currentPageName {
            return
        }
        if !currentPageName.isEmpty {
            DLog("[DEBUG] endPage: ", currentPageName)
            STHelper.endLogPageView(currentPageName)
        }
        DLog("[DEBUG] beginPage: ", pageName)
        STHelper.beginLogPageView(pageName)
        
        currentPageName = pageName
    }
}

extension MarketingHelper {
    static private func ReplaceMethod(_ _class: AnyClass, _ _originSelector: Selector, _ _newSelector: Selector) {
        let oriMethod = class_getInstanceMethod(_class, _originSelector)
        let newMethod = class_getInstanceMethod(_class, _newSelector)
        let isAddedMethod = class_addMethod(_class, _originSelector, method_getImplementation(newMethod!), method_getTypeEncoding(newMethod!))
        if isAddedMethod {
            class_replaceMethod(_class, _newSelector, method_getImplementation(oriMethod!), method_getTypeEncoding(oriMethod!))
        } else {
            method_exchangeImplementations(oriMethod!, newMethod!)
        }
    }
    
    /// 通过方法替换，实现路径统计，需要统计的 controller 实现 TrackPageProtocol
    static public let regiterTrackPage: Void = {
        let originalSelector = #selector(UIViewController.viewDidAppear(_:))
        let swizzledSelector = #selector(UIViewController.swizzled_viewDidAppear(_:))
        ReplaceMethod(UIViewController.self, originalSelector, swizzledSelector)
    }()
    
}

extension UIViewController {
    
    @objc fileprivate func swizzled_viewDidAppear(_ animated: Bool) {
        MarketingHelper.controllerDidAppear(self)
        swizzled_viewDidAppear(animated)
    }
    
}
