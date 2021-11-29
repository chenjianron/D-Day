//
//  InAppWebViewController.swift
//  Toolkit
//
//  Created by Kenji on 1/20/21.
//

import UIKit
import WebKit

public class InAppWebViewController: UIViewController {

    lazy var progressView: UIProgressView = {
        let view = UIProgressView(frame: .zero)
        view.progressTintColor = .systemBlue
        return view
    }()
    
    lazy var webView: WKWebView = {
        // 设置偏好设置
        let config = WKWebViewConfiguration()
        // 默认为0
        config.preferences.minimumFontSize = 10
        //是否支持JavaScript
        config.preferences.javaScriptEnabled = true
        //不通过用户交互，是否可以打开窗口
        config.preferences.javaScriptCanOpenWindowsAutomatically = false
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = self
        if let view = webView.subviews.first as? UIScrollView {
            view.bounces = false
        }
        return webView
    }()
    
    var backButton: UIBarButtonItem?
    var forwardButton: UIBarButtonItem?
    
    var url: URL?
    
    public init(url: URL?) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @available(iOSApplicationExtension, unavailable)
    public override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupUI()
        
        guard let url = url else { return }
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 20)
        webView.load(request)
    }
    
    deinit {
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
        webView.navigationDelegate = nil
    }

}

// MARK: - WKNavigationDelegate
extension InAppWebViewController: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        LLog(#function)
    }
    
    public func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        LLog(#function)
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript(
            "document.title"
        ) { (result, error) -> Void in
            self.navigationItem.title = result as? String
        }
    }
    
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        LLog(#function, "🔥 error = \(error.localizedDescription)")
    }
}

// MARK: - pravite
extension InAppWebViewController {
    @available(iOSApplicationExtension, unavailable)
    private func setupUI() {
        view.backgroundColor = .white
        automaticallyAdjustsScrollViewInsets = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: closeIcon())
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: reloadIcon())
        
        if #available(iOS 13.0, *) {
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                image: UIImage(systemName: "xmark")!.withTintColor(.black, renderingMode: .alwaysOriginal),
                style: .plain,
                target: self,
                action: #selector(leftAction))
        } else {
            // Fallback on earlier versions
            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: closeIcon())
        }

        if #available(iOS 13.0, *) {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                image: UIImage(systemName: "arrow.counterclockwise")!.withTintColor(.black, renderingMode: .alwaysOriginal),
                style: .plain,
                target: self.webView,
                action: #selector(WKWebView.reload))
        } else {
            // Fallback on earlier versions
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: reloadIcon())
        }
        
        view.addSubviews(webView, progressView)
        webView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(Util.safeAreaInsets.top + 44)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().inset(Util.safeAreaInsets.bottom)
        }
        progressView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(Util.safeAreaInsets.top + 44)
            make.left.right.equalToSuperview()
            make.height.equalTo(2)
        }
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress", (object as? WKWebView) == webView {
            progressView.alpha = 1.0
            progressView.setProgress(Float(webView.estimatedProgress), animated: true)
            if webView.estimatedProgress >= 1.0 {
                UIView.animate(withDuration: 0.3, delay: 0.3, options: .curveEaseOut, animations: { [self] in
                    progressView.alpha = 0.0
                }) { [self] finished in
                    progressView.setProgress(0.0, animated: true)
                }
            }
        }
    }
    
    @objc func leftAction() {
        LLog(#function)
        if let vcs = self.navigationController?.viewControllers {
            if vcs.count > 1 {
                if vcs[vcs.count - 1] == self {
                    // push
                    self.navigationController?.popViewController(animated: true)
                }
            } else {
                // present
                self.dismiss(animated: true, completion: nil)
            }
        } else {
            // present
            self.dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: - icon
extension InAppWebViewController {
    func closeIcon() -> UIView {
        let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 21, height: 21)))
        
        //// Color Declarations
        let fillColor = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 1.000)

        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 0.88, y: 19.19))
        bezierPath.addCurve(to: CGPoint(x: 0.88, y: 20.65), controlPoint1: CGPoint(x: 0.47, y: 19.59), controlPoint2: CGPoint(x: 0.47, y: 20.25))
        bezierPath.addCurve(to: CGPoint(x: 2.34, y: 20.65), controlPoint1: CGPoint(x: 1.28, y: 21.04), controlPoint2: CGPoint(x: 1.94, y: 21.04))
        bezierPath.addLine(to: CGPoint(x: 10.91, y: 12.06))
        bezierPath.addLine(to: CGPoint(x: 19.5, y: 20.65))
        bezierPath.addCurve(to: CGPoint(x: 20.96, y: 20.65), controlPoint1: CGPoint(x: 19.9, y: 21.04), controlPoint2: CGPoint(x: 20.56, y: 21.06))
        bezierPath.addCurve(to: CGPoint(x: 20.96, y: 19.19), controlPoint1: CGPoint(x: 21.35, y: 20.25), controlPoint2: CGPoint(x: 21.35, y: 19.59))
        bezierPath.addLine(to: CGPoint(x: 12.37, y: 10.6))
        bezierPath.addLine(to: CGPoint(x: 20.96, y: 2.03))
        bezierPath.addCurve(to: CGPoint(x: 20.96, y: 0.57), controlPoint1: CGPoint(x: 21.35, y: 1.63), controlPoint2: CGPoint(x: 21.37, y: 0.95))
        bezierPath.addCurve(to: CGPoint(x: 19.5, y: 0.57), controlPoint1: CGPoint(x: 20.56, y: 0.16), controlPoint2: CGPoint(x: 19.9, y: 0.16))
        bezierPath.addLine(to: CGPoint(x: 10.91, y: 9.14))
        bezierPath.addLine(to: CGPoint(x: 2.34, y: 0.57))
        bezierPath.addCurve(to: CGPoint(x: 0.88, y: 0.57), controlPoint1: CGPoint(x: 1.94, y: 0.16), controlPoint2: CGPoint(x: 1.26, y: 0.16))
        bezierPath.addCurve(to: CGPoint(x: 0.88, y: 2.03), controlPoint1: CGPoint(x: 0.47, y: 0.97), controlPoint2: CGPoint(x: 0.47, y: 1.63))
        bezierPath.addLine(to: CGPoint(x: 9.47, y: 10.6))
        bezierPath.addLine(to: CGPoint(x: 0.88, y: 19.19))
        bezierPath.close()
        fillColor.setFill()
        bezierPath.fill()

        let pathLayer = CAShapeLayer()
        pathLayer.path = bezierPath.cgPath
        
        view.layer.addSublayer(pathLayer)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(leftAction)))
        return view
    }
    
    func reloadIcon() -> UIView {
        let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 21, height: 21)))
        
        //// Color Declarations
        let fillColor = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 1.000)

        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 11.61, y: 12.89))
        bezierPath.addCurve(to: CGPoint(x: 12.45, y: 12.03), controlPoint1: CGPoint(x: 12.08, y: 12.89), controlPoint2: CGPoint(x: 12.45, y: 12.52))
        bezierPath.addCurve(to: CGPoint(x: 12.2, y: 11.43), controlPoint1: CGPoint(x: 12.45, y: 11.82), controlPoint2: CGPoint(x: 12.36, y: 11.6))
        bezierPath.addLine(to: CGPoint(x: 8.32, y: 7.57))
        bezierPath.addCurve(to: CGPoint(x: 11.06, y: 7.3), controlPoint1: CGPoint(x: 9.12, y: 7.39), controlPoint2: CGPoint(x: 10.05, y: 7.3))
        bezierPath.addCurve(to: CGPoint(x: 19.87, y: 16.08), controlPoint1: CGPoint(x: 15.96, y: 7.3), controlPoint2: CGPoint(x: 19.87, y: 11.19))
        bezierPath.addCurve(to: CGPoint(x: 11.06, y: 24.91), controlPoint1: CGPoint(x: 19.87, y: 21), controlPoint2: CGPoint(x: 15.96, y: 24.91))
        bezierPath.addCurve(to: CGPoint(x: 2.26, y: 16.08), controlPoint1: CGPoint(x: 6.17, y: 24.91), controlPoint2: CGPoint(x: 2.26, y: 21))
        bezierPath.addCurve(to: CGPoint(x: 1.45, y: 15.21), controlPoint1: CGPoint(x: 2.26, y: 15.57), controlPoint2: CGPoint(x: 1.94, y: 15.21))
        bezierPath.addCurve(to: CGPoint(x: 0.57, y: 16.08), controlPoint1: CGPoint(x: 0.93, y: 15.21), controlPoint2: CGPoint(x: 0.57, y: 15.57))
        bezierPath.addCurve(to: CGPoint(x: 11.06, y: 26.6), controlPoint1: CGPoint(x: 0.57, y: 21.93), controlPoint2: CGPoint(x: 5.24, y: 26.6))
        bezierPath.addCurve(to: CGPoint(x: 21.57, y: 16.08), controlPoint1: CGPoint(x: 16.89, y: 26.6), controlPoint2: CGPoint(x: 21.57, y: 21.93))
        bezierPath.addCurve(to: CGPoint(x: 11.06, y: 5.6), controlPoint1: CGPoint(x: 21.57, y: 10.26), controlPoint2: CGPoint(x: 16.89, y: 5.6))
        bezierPath.addCurve(to: CGPoint(x: 8.71, y: 5.83), controlPoint1: CGPoint(x: 10.26, y: 5.6), controlPoint2: CGPoint(x: 9.45, y: 5.69))
        bezierPath.addLine(to: CGPoint(x: 12.2, y: 2.38))
        bezierPath.addCurve(to: CGPoint(x: 12.45, y: 1.75), controlPoint1: CGPoint(x: 12.36, y: 2.19), controlPoint2: CGPoint(x: 12.45, y: 1.98))
        bezierPath.addCurve(to: CGPoint(x: 11.61, y: 0.9), controlPoint1: CGPoint(x: 12.45, y: 1.28), controlPoint2: CGPoint(x: 12.08, y: 0.9))
        bezierPath.addCurve(to: CGPoint(x: 11, y: 1.16), controlPoint1: CGPoint(x: 11.35, y: 0.9), controlPoint2: CGPoint(x: 11.15, y: 0.99))
        bezierPath.addLine(to: CGPoint(x: 5.99, y: 6.26))
        bezierPath.addCurve(to: CGPoint(x: 5.68, y: 6.91), controlPoint1: CGPoint(x: 5.79, y: 6.44), controlPoint2: CGPoint(x: 5.68, y: 6.68))
        bezierPath.addCurve(to: CGPoint(x: 5.99, y: 7.59), controlPoint1: CGPoint(x: 5.68, y: 7.16), controlPoint2: CGPoint(x: 5.77, y: 7.37))
        bezierPath.addLine(to: CGPoint(x: 11, y: 12.64))
        bezierPath.addCurve(to: CGPoint(x: 11.61, y: 12.89), controlPoint1: CGPoint(x: 11.15, y: 12.79), controlPoint2: CGPoint(x: 11.35, y: 12.89))
        bezierPath.close()
        fillColor.setFill()
        bezierPath.fill()

        let pathLayer = CAShapeLayer()
        pathLayer.path = bezierPath.cgPath
        
        view.layer.addSublayer(pathLayer)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self.webView, action: #selector(WKWebView.reload)))
        return view
    }
}
