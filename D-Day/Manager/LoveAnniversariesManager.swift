//
//  LoveAnniversaries.swift
//  D-Day
//
//  Created by GC on 2021/10/18.
//

import Toolkit
import WidgetKit

class LoveAnniversariesManager {
    
    enum AnniversaryInformation:String {
        case Id = "Id"
        case Date = "Date"
        case Title = "Title"
        case IsSetTop = "IsSetTop"
        case IsRealized = "IsRealized"
        case RemindDate = "RemindDate"
        case RemindType = "RemindType"
        case BackgroundImage = "BackgroundImage"
        case IsPreset = "IsPreset"
        case PresetAnniversaryModel = "PresetAnniversaryModel"
        case Years = "Years"
        case Months = "Months"
        case Days = "Days"
    }
    struct PresetAnniversaryModel {
        var name:String
        var years: Int?
        var months:Int?
        var days:Int?
    }
    
    let presetAnniversarys = [PresetAnniversaryModel(name: "一个月", months: 1),
                              PresetAnniversaryModel(name: "100天纪念日", days: 100),
                              PresetAnniversaryModel(name: "六个月纪念日", months: 6),
                              PresetAnniversaryModel(name: "一周年", years: 1),
                              PresetAnniversaryModel(name: "两周年", years: 2),
                              PresetAnniversaryModel(name: "999天", days: 999)]
    static let `default` = LoveAnniversariesManager()
    
    private let RealizedLoveAnniversariesPath = FileManager.documentsDirectory() + "/RealizedLoveAnniversiary.plist"
    private let ToRealizedLoveAnniversariesPath = FileManager.documentsDirectory() + "/ToRealizedLoveAnniversaryPath.plist"
    private let AllLoveAnniversariesPath = FileManager.documentsDirectory() + "/AllLoveAnniversaryPath.plist"
    private var loveAnniversaries = [[String:Any]]()
    
    lazy var realizedAnniversarys = [AnniversaryModel]()
    lazy var toRealizedAnniversarys = [AnniversaryModel]()
    lazy var allAnniversaries = [AnniversaryModel]()
    lazy var allAnniversariesTemp = [AnniversaryModel]()
    
    init() {
        if !AppStorageGroupsManager.default.bool(forKey: K.AppGroupsKey.PresetAnniversaryKey) {
            //预设纪念日
            setPresetAnniversaries()
            sortAnniversaries()
            storageAnniversaries()
            AppStorageGroupsManager.default.set(true, forKey: K.AppGroupsKey.PresetAnniversaryKey)
        }else {
            realizedAnniversarys = getAnniversaries(isRealized:true)
            toRealizedAnniversarys = getAnniversaries(isRealized:false)
        }
        
    }
}


// MARK: - Preset
extension LoveAnniversariesManager {
    
    func setPresetAnniversaries(){
        for anniversary in presetAnniversarys {
            let id:String = UUID().uuidString
            let name = anniversary.name
            let anniversaryDate = dateTransform(anniversay: anniversary)
            if anniversaryDate.toDay() < Date().toDay(){
                realizedAnniversarys.append(AnniversaryModel(id, anniversaryDate, name, false, true, nil, nil,nil,true,anniversary))
            } else {
                toRealizedAnniversarys.append(AnniversaryModel(id, anniversaryDate, name, false,false,nil,nil,nil,true,anniversary))
            }
        }
    }
    
    func dateTransform(anniversay:PresetAnniversaryModel) -> Date {
        let anniversaryDate:Date
        let dateComponents = DateComponents(year:anniversay.years,month: anniversay.months,day: anniversay.days)
        anniversaryDate = Calendar.current.date(byAdding: dateComponents, to: HeadInfoManager.default.loveDate)!
        return anniversaryDate
    }
    
    func sortAnniversaries(){
        realizedAnniversarys.sort(by: { return $0.date.compare($1.date) == .orderedDescending})
        toRealizedAnniversarys.sort(by: { return $0.date.compare($1.date) == .orderedAscending})
    }
    
    func storageAnniversaries(){
        var allAnniversariesArray = [[String:Any?]]()
        var realizedAnniversaryArray = [[String:Any?]]()
        var toRealizedAnniversaryArray = [[String:Any?]]()
        for model in realizedAnniversarys {
            var anniversaryDic = [String : Any?]()
            anniversaryDic[AnniversaryInformation.Id.rawValue] = model.id
            anniversaryDic[AnniversaryInformation.Date.rawValue] = model.date
            anniversaryDic[AnniversaryInformation.Title.rawValue] = model.title
            anniversaryDic[AnniversaryInformation.IsSetTop.rawValue] = model.isSetTop
            anniversaryDic[AnniversaryInformation.IsRealized.rawValue] = model.isRealized
            anniversaryDic[AnniversaryInformation.RemindDate.rawValue] = model.remindDate
            anniversaryDic[AnniversaryInformation.RemindType.rawValue] = model.remindType
            anniversaryDic[AnniversaryInformation.BackgroundImage.rawValue] = model.backgroundImage
            anniversaryDic[AnniversaryInformation.IsPreset.rawValue] = model.isPreset
            anniversaryDic[AnniversaryInformation.Years.rawValue] = model.presetAnniversaryModel?.years ?? 0
            anniversaryDic[AnniversaryInformation.Months.rawValue] = model.presetAnniversaryModel?.months ?? 0
            anniversaryDic[AnniversaryInformation.Days.rawValue] = model.presetAnniversaryModel?.days ?? 0
            realizedAnniversaryArray.append(anniversaryDic)
        }
        for model in toRealizedAnniversarys {
            var anniversaryDic = [String: Any?]()
            anniversaryDic[AnniversaryInformation.Id.rawValue] = model.id
            anniversaryDic[AnniversaryInformation.Date.rawValue] = model.date
            anniversaryDic[AnniversaryInformation.Title.rawValue] = model.title
            anniversaryDic[AnniversaryInformation.RemindDate.rawValue] = model.remindDate
            anniversaryDic[AnniversaryInformation.IsSetTop.rawValue] = model.isSetTop
            anniversaryDic[AnniversaryInformation.IsRealized.rawValue] = model.isRealized
            anniversaryDic[AnniversaryInformation.RemindType.rawValue] = model.remindType
            anniversaryDic[AnniversaryInformation.BackgroundImage.rawValue] = model.backgroundImage
            anniversaryDic[AnniversaryInformation.IsPreset.rawValue] = model.isPreset
            anniversaryDic[AnniversaryInformation.Years.rawValue] = model.presetAnniversaryModel?.years ?? 0
            anniversaryDic[AnniversaryInformation.Months.rawValue] = model.presetAnniversaryModel?.months ?? 0
            anniversaryDic[AnniversaryInformation.Days.rawValue] = model.presetAnniversaryModel?.days ?? 0
            toRealizedAnniversaryArray.append(anniversaryDic)
        }
        allAnniversariesArray = realizedAnniversaryArray + toRealizedAnniversaryArray
        (realizedAnniversaryArray as NSArray).write(toFile: RealizedLoveAnniversariesPath, atomically: true)
        (toRealizedAnniversaryArray as NSArray).write(toFile: ToRealizedLoveAnniversariesPath, atomically: true)
        (allAnniversariesArray as NSArray).write(toFile: AllLoveAnniversariesPath, atomically: true)
        AppStorageGroupsManager.default.setValue(allAnniversariesArray as NSArray, forKey: K.UserDefaultsKey.AnniversaryPath)
    }
}

// MARK: - Persist
extension LoveAnniversariesManager {
    
    func storageAllAnniversary(){
        var allAnniversariesArray = [[String:Any?]]()
        for model in allAnniversaries {
            var anniversaryDic = [String: Any?]()
            anniversaryDic[AnniversaryInformation.Id.rawValue] = model.id
            anniversaryDic[AnniversaryInformation.Date.rawValue] = model.date
            anniversaryDic[AnniversaryInformation.Title.rawValue] = model.title
            anniversaryDic[AnniversaryInformation.IsSetTop.rawValue] = model.isSetTop
            anniversaryDic[AnniversaryInformation.IsRealized.rawValue] = model.isRealized
            anniversaryDic[AnniversaryInformation.RemindDate.rawValue] = model.remindDate
            anniversaryDic[AnniversaryInformation.RemindType.rawValue] = model.remindType
            anniversaryDic[AnniversaryInformation.BackgroundImage.rawValue] = model.backgroundImage
            anniversaryDic[AnniversaryInformation.IsPreset.rawValue] = model.isPreset
            anniversaryDic[AnniversaryInformation.Years.rawValue] = model.presetAnniversaryModel?.years ?? 0
            anniversaryDic[AnniversaryInformation.Months.rawValue] = model.presetAnniversaryModel?.months ?? 0
            anniversaryDic[AnniversaryInformation.Days.rawValue] = model.presetAnniversaryModel?.days ?? 0
            allAnniversariesArray.append(anniversaryDic)
        }
        (allAnniversariesArray as NSArray).write(toFile: AllLoveAnniversariesPath, atomically: true)
        AppStorageGroupsManager.default.setValue(allAnniversariesArray as NSArray, forKey: K.UserDefaultsKey.AnniversaryPath)
        AppStorageGroupsManager.default.userDefaults.synchronize()
        realizedAnniversarys = getAnniversaries(isRealized: true)
        toRealizedAnniversarys = getAnniversaries(isRealized: false)
        sortAnniversaries()
    }
}

// MARK: - SetTop
extension LoveAnniversariesManager {
    
    func sortAnniversariesBySetTop(){
        allAnniversaries = toRealizedAnniversarys + realizedAnniversarys
        allAnniversariesTemp = allAnniversaries
        for (index,anniversary) in allAnniversariesTemp.enumerated() {
            if anniversary.isSetTop == true {
                allAnniversariesTemp.insert(anniversary, at: 0)
                allAnniversariesTemp.remove(at: index + 1)
            }
        }
    }
    
    func setTopAnniversary(_ selectedAnniversary:AnniversaryModel)-> [AnniversaryModel]{
        var tempAnniversaryId:String? = nil
        for  anniversary in allAnniversaries {
            if anniversary.isSetTop == true {
                anniversary.isSetTop = false
                tempAnniversaryId = anniversary.id
                break
            }
        }
        for anniversary in allAnniversaries {
            if anniversary.id == selectedAnniversary.id {
                if tempAnniversaryId != selectedAnniversary.id {
                    anniversary.isSetTop = true
                } else {
                    anniversary.isSetTop = false
                }
                break
            }
        }
        storageAllAnniversary()
        allAnniversariesTemp = allAnniversaries
        for (index,anniversary) in allAnniversariesTemp.enumerated() {
            if anniversary.isSetTop == true {
                allAnniversariesTemp.remove(at: index)
                allAnniversariesTemp.insert(anniversary, at: 0)
            }
        }
        return allAnniversariesTemp
    }
}

// MARK: 增删改查
extension LoveAnniversariesManager {
    
    //取已过和没过的全部数据
    func getAllAnniversary() -> [AnniversaryModel] {
        realizedAnniversarys = getAnniversaries(isRealized:true)
        toRealizedAnniversarys = getAnniversaries(isRealized:false)
        sortAnniversaries()
        sortAnniversariesBySetTop()
        return allAnniversariesTemp
    }
    
    //取已过或者没过的数据
    func getAnniversaries(isRealized:Bool) -> [AnniversaryModel] {
        var anniversaryModelAarray = [AnniversaryModel]()
        if let anniversarysArray = AppStorageGroupsManager.default.value(forKey: K.UserDefaultsKey.AnniversaryPath) as? [[String: Any?]] {
            anniversarysArray.forEach({
                let presetModel = PresetAnniversaryModel(name: "", years: $0[AnniversaryInformation.Years.rawValue] as? Int, months: $0[AnniversaryInformation.Months.rawValue] as? Int, days: $0[AnniversaryInformation.Days.rawValue] as? Int)
                if isRealized == true && (($0[AnniversaryInformation.Date.rawValue] as! Date).toDay() < Date().toDay()){
                    anniversaryModelAarray.append(
                        AnniversaryModel($0[AnniversaryInformation.Id.rawValue] as! String, $0[AnniversaryInformation.Date.rawValue] as! Date, $0[AnniversaryInformation.Title.rawValue] as! String, $0[AnniversaryInformation.IsSetTop.rawValue] as! Bool, true, $0[AnniversaryInformation.RemindDate.rawValue] as? Date, $0[AnniversaryInformation.RemindType.rawValue] as? Int, $0[AnniversaryInformation.BackgroundImage.rawValue] as? String, ($0[AnniversaryInformation.IsPreset.rawValue] as? Bool)!, presetModel)
                    )} else if isRealized == false && (($0[AnniversaryInformation.Date.rawValue] as! Date).toDay() >= Date().toDay()){
                        anniversaryModelAarray.append(
                            AnniversaryModel($0[AnniversaryInformation.Id.rawValue] as! String,
                                             $0[AnniversaryInformation.Date.rawValue] as! Date,
                                             $0[AnniversaryInformation.Title.rawValue] as! String,
                                             $0[AnniversaryInformation.IsSetTop.rawValue] as! Bool,
                                             false,
                                             $0[AnniversaryInformation.RemindDate.rawValue] as? Date,
                                             $0[AnniversaryInformation.RemindType.rawValue] as? Int,
                                             $0[AnniversaryInformation.BackgroundImage.rawValue] as? String,($0[AnniversaryInformation.IsPreset.rawValue] as? Bool)!, presetModel)
                        )}
            })
        }
        return anniversaryModelAarray
    }
    
    func removeAnniversaryItem(_ deleteAnniversary:AnniversaryModel)->[AnniversaryModel] {
        for (index,anniversary) in allAnniversaries.enumerated() {
            if anniversary.id == deleteAnniversary.id {
                allAnniversaries.remove(at: index)
                break
            }
        }
        storageAllAnniversary()
        sortAnniversariesBySetTop()
        return allAnniversariesTemp
    }
    
    func updateAnniversaryItem(_ updateAnniversary:AnniversaryModel)->[AnniversaryModel] {
        for (index,anniversary) in allAnniversaries.enumerated() {
            if updateAnniversary.id == anniversary.id {
                if updateAnniversary.date.toDay() < Date().toDay(){
                    allAnniversaries[index].isRealized = true
                } else {
                    allAnniversaries[index].isRealized = false
                }
            }
        }
        storageAllAnniversary()
        sortAnniversariesBySetTop()
        return allAnniversariesTemp
    }
    
    func addAnniversaryItem(_ addAnniversary:AnniversaryModel)->[AnniversaryModel]{
        if addAnniversary.isSetTop {
            for anniversary in allAnniversaries {
                if anniversary.isSetTop {
                    anniversary.isSetTop = false
                }
            }
        }
        if addAnniversary.date.toDay() < Date().toDay() {
            addAnniversary.isRealized = true
        } else {
            addAnniversary.isRealized = false
        }
        allAnniversaries.append(addAnniversary)
        storageAllAnniversary()
        sortAnniversariesBySetTop()
        return allAnniversariesTemp
    }
    
    func reset(){
        for anniversary in allAnniversaries {
            if anniversary.isPreset == true {
                anniversary.date = dateTransform(anniversay:anniversary.presetAnniversaryModel!)
            }
        }
        storageAllAnniversary()
    }
}
