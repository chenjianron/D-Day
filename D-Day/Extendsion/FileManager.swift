//
//  FileManager.swift
//  D-Day
//
//  Created by GC on 2021/10/18.
//

import Foundation
extension FileManager {
    
    public static func homeDirectory() -> String {
        return NSHomeDirectory()
    }
    
    public static func libraryDirectory() -> String {
        return NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0]
    }
    
    public static func documentsDirectory() -> String {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    }
    
    public static func tmpDirectory() -> String {
        return NSTemporaryDirectory()
    }
    
    public static func cachesDirectory() -> String {
        return NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
    }
    
    public static func directoryExistAtPath(_ directory: String) -> Bool {
        var isDirectory = ObjCBool(false)
        let exists = FileManager.default.fileExists(atPath: directory, isDirectory: &isDirectory)
        if exists && isDirectory.boolValue {
            return true
        }
        return false
    }
    
    public static func fileExistAtPath(_ filePath: String) -> Bool {
        return FileManager.default.fileExists(atPath: filePath)
    }
    
    public static func createDirectoryAtPath(_ directoryPath: String) -> Bool {
        do {
            try FileManager.default.createDirectory(atPath: directoryPath, withIntermediateDirectories: true, attributes: nil)
        } catch let error {
            debugPrint(directoryPath + "目录创建失败：" + error.localizedDescription)
            return false
        }
        return true
    }
    
    public static func createFile(withFilePath: String, contents: Data?) -> Bool {
        return FileManager.default.createFile(atPath: withFilePath, contents: contents, attributes: nil)
    }
    
    public static func copyItem(atPath: String, toPath: String) -> Bool {
        do {
            try FileManager.default.copyItem(atPath: atPath, toPath: toPath)
        } catch let error {
            debugPrint("拷贝失败：" + error.localizedDescription)
            return false
        }
        return true
    }
    
    public static func moveItem(atPath: String, toPath: String) -> Bool {
        do {
            try FileManager.default.moveItem(atPath: atPath, toPath: toPath)
        } catch let error {
            debugPrint("移动失败：" + error.localizedDescription)
            return false
        }
        return true
    }
    
    public static func contentsOfDirectory(atPath: String) -> [String] {
        var contents = [String]()
        do {
            contents = try FileManager.default.contentsOfDirectory(atPath: atPath)
        } catch let error {
            debugPrint("获取文件失败：" + error.localizedDescription)
        }
        return contents
    }
    
    public static func attributesOfItem(atPath: String) -> String {
        var attributes = [FileAttributeKey: Any]()
        do {
            attributes = try FileManager.default.attributesOfItem(atPath: atPath)
        } catch let error {
            debugPrint("获取文件失败：" + error.localizedDescription)
        }
        
        var attributesString = String()
        for (key, value) in attributes {
            attributesString.append("\(key): \(value)")
            attributesString.append("\n")
        }
        return attributesString
    }
    
    public static func removeItem(atPath: String) -> Bool {
        do {
            try FileManager.default.removeItem(atPath: atPath)
        } catch let error {
            debugPrint("删除失败：" + error.localizedDescription)
            return false
        }
        return true
    }
}
