//
//  SettingsFeaturedApps.swift
//  AdLib
//
//  Created by Tina on 2019/8/16.
//

import UIKit
import SwiftyJSON

#if canImport(Toolkit)
import Toolkit
#elseif canImport(DCGKit)
import DCGKit
#endif

public class SettingsFeaturedApps: NSObject {
    
    public static var apps: [JSON] {
        return shared.apps
    }
    
    public static func createAppsView(width: CGFloat) -> UIView {
        return shared.createAppsView(width: width)
    }
    
    // MARK: - Internal
    
    static let shared = SettingsFeaturedApps()
    
    var apps = [JSON]()
    
    var appsNames: JSON? {
        let appIdToNames = Preset.named("S.Ad.settingsFeaturedAppsNames")
        var result = [String: String?]()
        for (appId, names) in (appIdToNames.dictionary ?? [:]) {
            var name = names[Util.languageCode()].string ?? names["others"].string
            if name?.count == 0 {
                name = nil
            }
            result[appId] = name
        }
        return JSON(result)
    }
    
    func createAppsView(width: CGFloat) -> UIView {
        let appsView = SettingsFeaturedAppsView()
        self.setupAppsView(appsView)
        appsView.size = CGSize(width: width, height: appsView.estimatedHeight)
        return appsView
    }
    
    var presets: JSON {
        return Preset.named("S.Ad.settingsFeaturedApps")
    }
    
    func setup() {
        NotificationCenter.default.addObserver(self, selector: #selector(jsonUpdated), name: JSONUpdatedNotification, object: nil)
    }
    
    func fetchApps(completion: (([JSON]) -> Void)?) {
        let appIDs = self.presets["apps"].arrayValue.map({ $0.stringValue })
        guard !appIDs.isEmpty else { return }
        
        var countryCode = Util.countryCode()
        if !["us","dk","ru","id","tr","gr","de","it","no",
             "jp","fr","th","se","cn","tw","fi","ca","au","gb",
             "nl","br","pt","mx","es","vn","kr","my","hr","cz",
             "hu","pl","ro","sk","ua","in",].contains(countryCode.lowercased()) {
            countryCode = "us"
        }
        
        let link = "https://itunes.apple.com/lookup?country=\(countryCode)&id=\(appIDs.joined(separator: ","))"
        request(link, method: .get) { (data, success, _, _) in
            if success, let data = data, let json = try? JSON(data: data), let results = json["results"].array, results.count > 0 {
                DispatchQueue.main.async {
                    completion?(results)
                }
            }
        }

    }
    
    @objc func jsonUpdated() {
        self.fetchApps { (apps) in
            self.apps = apps
        }
    }
    
    func setupAppsView(_ appsView: SettingsFeaturedAppsView) {
        appsView.apps = self.apps
        appsView.appsNames = self.appsNames
        
        if let insets = presets["insets"].array, insets.count == 4 {
            appsView.insets = UIEdgeInsets(top: CGFloat(insets[0].floatValue),
                                       left: CGFloat(insets[1].floatValue),
                                       bottom: CGFloat(insets[2].floatValue),
                                       right: CGFloat(insets[3].floatValue))
        }
        
        if let rowHeight = presets["rowHeight"].float {
            appsView.rowHeight = CGFloat(rowHeight)
        }
        
        if let fontSize = presets["fontSize"].float {
            appsView.fontSize = CGFloat(fontSize)
        }
        
        if let titleColorStr = presets["titleColor"].string,
            let colorHex = Int(titleColorStr.replacingOccurrences(of: "0x", with: ""), radix: 16) {
            appsView.titleColor = UIColor.init(hex: colorHex)
        }
        
        if let tableBackgroundColorStr = presets["backgroundColor"].string,
            let colorHex = Int(tableBackgroundColorStr.replacingOccurrences(of: "0x", with: ""), radix: 16) {
            appsView.tableBackgroundColor = UIColor.init(hex: colorHex)
        }
        
        if let colorStr = presets["imageBorderColor"].string,
            let colorHex = Int(colorStr.replacingOccurrences(of: "0x", with: ""), radix: 16) {
            appsView.imageBorderColor = UIColor.init(hex: colorHex)
        }
        
        if let iconSize = presets["iconSize"].float {
            appsView.iconSize = CGFloat(iconSize)
        }
        
        if let cornerRadius = presets["cornerRadius"].float {
            appsView.cornerRadius = CGFloat(cornerRadius)
        }
    }
}
