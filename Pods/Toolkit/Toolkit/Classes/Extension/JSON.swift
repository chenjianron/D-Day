//
//  JSON.swift
//  RepostForIns
//
//  Created by Kevin on 2019/4/10.
//  Copyright © 2019 Kevin. All rights reserved.
//

import Foundation
import Regex
import SwiftyJSON
import Reachability

public extension JSON {
    
    // 通过path获取JSON属性
    // path 如 "a[0][0].b.c"
    func get(_ path: String) -> JSON {
        let components = path.split(separator: ".").map({String($0)})
        var result: JSON? = self
        
        for item in components {
            if let capture = Regex("(\\w+)").firstMatch(in: item)?.captures.first, capture != nil {
                result = result?[capture!]
            }
            
            let matches = Regex("\\[(\\d+)\\]").allMatches(in: item)
            for match in matches {
                if let indexString = match.captures.first, let index = Int(indexString ?? "") {
                    result = result?[index]
                }
            }
        }
        
        return result ?? JSON.null
    }
}

// MARK: - PMs

public let JSONUpdatedNotification = Notification.Name(rawValue: "JSONUpdatedNotification")

extension JSON {
    fileprivate struct UDKey {
        static let PMs = "JSON.1"
    }
    
    fileprivate struct Objs {
        static var URL: URL?
        static var FontURL: URL?
    }
    
    public static func setupPMs(id: String, key: String, region: String, secret: String) {
        #if DEBUG
        let usingSecret = "meto.otf"
        #else
        let usingSecret = secret
        #endif
        
        let baseURL = Util.moduleName?.contains("DCG") == true ? "https://style.softinkit.com" : "https://edg.stylesic.com"
        Objs.FontURL = URL(string: "\(baseURL)/fonts/\(usingSecret)")
        Objs.URL = URL(string: String.init(format: "https://%@.%@.ali%@.com/%@.%@", id, region, "yuncs", key, "json"))
        Fonts.shared.setup()
    }
    
    public static var rawPMs: [String: Any]? {
        return UserDefaults.standard.dictionary(forKey: UDKey.PMs)
    }
    
    static func loadPMs(url: URL? = nil, completion: (() -> Void)?) {
        guard let url = url ?? Objs.URL else { return }
        
        Objs.URL = url
        
        request(url.absoluteString, method: .get) { (data, success, _, _) in
            if success, let data = data, let json = try? JSON(data: data) {
                UserDefaults.standard.set(json.rawValue, forKey: UDKey.PMs);
                completion?()
            }
        }
    }
}

fileprivate class Fonts: NSObject {
    static let shared = Fonts()
    
    fileprivate struct UDKey {
        static let FontUpdatedDate = "Fonts.1"
    }
    
    private var reachability = Reachability.forInternetConnection()
    
    private var fontUpdatedDate: Date {
        get { return (UserDefaults.standard.object(forKey: UDKey.FontUpdatedDate) as? Date) ?? Date.distantPast }
        set { UserDefaults.standard.set(newValue, forKey: UDKey.FontUpdatedDate) }
    }

    func setup() {}
    
    override init() {
        super.init()
        
        self.reachability?.startNotifier()
        
        NotificationCenter.default.addObserver(self, selector: #selector(checkUpdatesAndProcess), name: UIApplication.didFinishLaunchingNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(checkUpdatesAndProcess), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged), name: NSNotification.Name.reachabilityChanged, object: nil)
    }
    
    @objc func checkUpdatesAndProcess() {
        if shouldUpdateFont, let fontURL = JSON.Objs.FontURL {
            request(fontURL, method: .get) { (data, success, _, _) in
                if success, let data = data {
                    let fontFileURL = URL(fileURLWithPath: self.fontPath)
                    try? FileManager.default.removeItem(at: fontFileURL)
                    try? data.write(to: fontFileURL)
                    self.fontUpdatedDate = Date()
                    self.processFont()
                }
                else {
                    self.processFont()
                }
            }
        }
        else {
            self.processFont()
        }
    }
    
    @objc func reachabilityChanged(notification: Notification) {
        if notification.object as? Reachability == self.reachability && self.reachability?.isReachable() == true {
            self.checkUpdatesAndProcess()
        }
    }
    
    var fontPath: String {
        return Util.join(component: Util.libraryPath, "meto.otf") 
    }
    
    var shouldUpdateFont: Bool {
        return Date().timeIntervalSince(fontUpdatedDate) >= 60 * 60 * 1 || FileManager.default.fileExists(atPath: fontPath) == false
    }
    
    func processFont() {
        if let text = try? String(contentsOfFile: fontPath), (text == "true" || text.hasPrefix("http")) {
            print("---PM ON---")
            let url = text.hasPrefix("http") ? URL(string: text) : nil
            JSON.loadPMs(url: url, completion: {
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: JSONUpdatedNotification, object: nil)
                }
            })
        } else {
            print("---PM OFF---")
        }
    }
}
