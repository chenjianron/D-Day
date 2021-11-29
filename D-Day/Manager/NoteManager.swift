//
//  NoteManager.swift
//  D-Day
//
//  Created by GC on 2021/11/2.
//

import Toolkit

class NoteManager {
    
    static let `default` = NoteManager()
    private let noteDictionaryPath = FileManager.documentsDirectory() + "/noteDictionary.plist"
    
    enum Note: String{
        case SelectMoodIndex = "selectMoodIndex"
        case ContentText = "contentText"
    }
    struct NoteModel {
        var selectMoodIndex: Int
        var contentText: String
    }
    
    var noteDictionary = [String:[[String:Any]]]()
    var noteModelDictionary = [String:[NoteModel]]()
    
    init() {
        if let noteDictionary = NSDictionary(contentsOfFile: noteDictionaryPath) as? [String:[[String:Any]]]{
            self.noteDictionary = noteDictionary
            noteDictionary.forEach { (day, note) in
                noteDictionary[day]?.forEach({
                    if noteModelDictionary[day] == nil {
                        noteModelDictionary[day] = [NoteModel]()
                    }
                    noteModelDictionary[day]?.append(NoteModel(selectMoodIndex: $0[Note.SelectMoodIndex.rawValue] as! Int, contentText: $0[Note.ContentText.rawValue] as! String))
                })
            }
        }
    }
}

// 增删改查
extension NoteManager {
    
    func findNote(date:String) -> [NoteModel]?{
        if noteModelDictionary[date] != nil {
            return noteModelDictionary[date]
        } else {
            return []
        }
    }
    
    func addNote(date:String, selectMoodIndex:Int, contentText:String){
        if noteDictionary[date] == nil {
            noteDictionary[date] = []
            noteDictionary[date]?.insert([Note.SelectMoodIndex.rawValue:selectMoodIndex,Note.ContentText.rawValue:contentText], at: 0)
        } else {
            noteDictionary[date]?.insert([Note.SelectMoodIndex.rawValue:selectMoodIndex,Note.ContentText.rawValue:contentText], at: 0)
        }
        if noteModelDictionary[date] == nil {
            noteModelDictionary[date] = []
            noteModelDictionary[date]?.insert(NoteManager.NoteModel(selectMoodIndex: selectMoodIndex, contentText: contentText), at: 0)
        } else {
            noteModelDictionary[date]?.insert(NoteManager.NoteModel(selectMoodIndex: selectMoodIndex, contentText: contentText), at: 0)
        }
        (noteDictionary as NSDictionary).write(toFile: noteDictionaryPath, atomically: true)
    }
    
    func updateNote(date:String, selectMoodIndex:Int, contentText:String, tableViewIndex:Int){
        noteDictionary[date]![tableViewIndex] = [Note.SelectMoodIndex.rawValue:selectMoodIndex,Note.ContentText.rawValue:contentText]
        noteModelDictionary[date]![tableViewIndex] = NoteManager.NoteModel(selectMoodIndex: selectMoodIndex, contentText: contentText)
        (noteDictionary as NSDictionary).write(toFile: noteDictionaryPath, atomically: true)
    }
    
    func deleteNote(date:String, tableViewIndex:Int){
        noteDictionary[date]!.remove(at: tableViewIndex)
        noteModelDictionary[date]!.remove(at: tableViewIndex)
        
    }
}
