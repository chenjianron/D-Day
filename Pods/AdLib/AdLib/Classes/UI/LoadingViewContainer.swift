//
//  LoadingView.swift
//  Alamofire
//
//  Created by Kevin on 16/10/2017.
//

import UIKit
import SwiftyJSON

#if canImport(Toolkit)
import Toolkit
#elseif canImport(DCGKit)
import DCGKit
#endif

public class LoadingViewContainer: UIView {
    
    public static let shared = LoadingViewContainer()
    
    public var isShown: Bool {
        return self.superview != nil
    }
    
    public let enterForegroundHideDelay: TimeInterval = 1
    
    public lazy var maxLoadingTime: TimeInterval = {
        var seconds: Double?
        let preset = Preset.named("S.Ad.maxLoadingTime")
        if preset != JSON.null {
            seconds = preset.doubleValue
        }
        return seconds ?? 5.0
    }()
    
    public lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    public var customView: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            if customView != nil {
                self.addSubview(customView!)
            }
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(backgroundImageView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationDidChange), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        let window = UIApplication.shared.keyWindow
        self.backgroundImageView.frame = window?.bounds ?? self.bounds
        self.customView?.frame = window?.bounds ?? self.bounds
    }
    
    // MARK: - Public
    
    public func show() {
        guard let window = UIApplication.shared.keyWindow else {
            return
        }
        
        self.alpha = 1.0
        window.addSubview(self)
        self.frame = window.bounds
        
        self.hideAfterDelay(self.maxLoadingTime)
    }
    
    // MARK: - Notification Action
    
    @objc func appDidEnterBackground() {
        DispatchQueue.main.async {
            self.canceHideInvoke()
        }
    }
    
    @objc func appWillEnterForeground() {
        self.hideAfterDelay(self.enterForegroundHideDelay)
    }
    
    @objc func deviceOrientationDidChange() {
        self.layoutSubviews()
    }
    
    // MARK: - Internal
    
    @objc func hide() {
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0
        }, completion: { (finished) in
            if finished {
                self.removeFromSuperview()
            }
        })
    }
    
    // MARK: - Private
    
    private func hideAfterDelay(_ delay: TimeInterval) {
        self.perform(#selector(hide), with: nil, afterDelay: delay)
    }
    
    private func canceHideInvoke() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.hide), object: nil)
    }
}

