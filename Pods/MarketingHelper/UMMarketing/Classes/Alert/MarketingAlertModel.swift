//
//  MarketingAlertModel.swift
//  MarketingHelper
//
//  Created by Endless Summer on 2020/9/18.
//

import Foundation
import SwiftyJSON
#if canImport(Toolkit) //
import Toolkit
#elseif canImport(DCGKit) // DCG
import DCGKit
#endif

class MarketingAlertModel {
    
    let imageURL: URL?
    
    let title: String
    let message: String
    let buttonTitle: String
    
    let titleColor: UIColor
    
    let buttonColor: UIColor
    var buttonBackgroundColor: UIColor
    
    let closeButtonColor: UIColor
    
    let imageRatio: Double
    
    let buttonCornerRadius: Double
    
    init(json: JSON) {
        
        imageRatio = json["imageRatio"].double ?? 0.628
        
        buttonCornerRadius = json["buttonCornerRadius"].double ?? 10
        
        imageURL = json["imageUrl"].url
        
        title = Util.localizedJSON(json["title"]).stringValue
        message = Util.localizedJSON(json["message"]).stringValue
        buttonTitle = Util.localizedJSON(json["button_title"]).stringValue
        
        titleColor = MarketingAlertModel.color(json: json["title_color"], defaultColor: UIColor(hex: 0xFF4140))
        
        buttonColor = MarketingAlertModel.color(json: json["button_color"], defaultColor: UIColor.white)
        
        buttonBackgroundColor = MarketingAlertModel.color(json: json["buttonBackground_color"], defaultColor: UIColor(hex: 0xFF4140))
        
        closeButtonColor = MarketingAlertModel.color(json: json["close_button_color"], defaultColor: UIColor.black)
        
    }
    
    private static func color(json: JSON, defaultColor: UIColor) -> UIColor {
        if let color = try? UIColor(rgba_throws: json.stringValue) {
            return color
        } else {
            return defaultColor
        }
    }
}
