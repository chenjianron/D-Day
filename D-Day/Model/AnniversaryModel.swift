//
//  Model.swift
//  D-Day
//
//  Created by GC on 2021/10/18.
//

import Foundation

class AnniversaryModel{
    
    let id:String
    var date:Date
    var title:String
    var isSetTop:Bool
    var isRealized:Bool
    var remindDate:Date?
    var remindType:Int?
    var backgroundImage:String?
    var isPreset:Bool = false
    var presetAnniversaryModel:LoveAnniversariesManager.PresetAnniversaryModel? = nil
    
    init(_ id:String,_ date:Date, _ title:String, _ isSetTop:Bool, _ isRealized:Bool, _ remindDate:Date? = nil, _ remindType:Int? = nil, _ backgroundImage:String? = nil) {
        self.id = id
        self.date = date
        self.title = title
        self.isSetTop = isSetTop
        self.isRealized = isRealized
        self.remindDate = remindDate
        self.remindType = remindType
        self.backgroundImage = backgroundImage
    }
    
    init(_ id:String,_ date:Date, _ title:String, _ isSetTop:Bool, _ isRealized:Bool, _ remindDate:Date? = nil, _ remindType:Int? = nil, _ backgroundImage:String? = nil,_ isPreset:Bool, _ presetAnniversaryModel:LoveAnniversariesManager.PresetAnniversaryModel) {
        self.id = id
        self.date = date
        self.title = title
        self.isSetTop = isSetTop
        self.isRealized = isRealized
        self.remindDate = remindDate
        self.remindType = remindType
        self.backgroundImage = backgroundImage
        self.isPreset = isPreset
        self.presetAnniversaryModel = presetAnniversaryModel
    }
}
