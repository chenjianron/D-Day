//
//  IntentHandler.swift
//  D-DayIntent
//
//  Created by GC on 2021/11/17.
//
import WidgetKit
import SwiftUI
import Intents

class IntentHandler: INExtension, AnniversaryIntentHandling{
    
    func resolveParameter(for intent: AnniversaryIntent, with completion: @escaping (AnniversaryResolutionResult) -> Void) {
        
    }
    
    func provideParameterOptionsCollection(for intent: AnniversaryIntent, with completion: @escaping (INObjectCollection<Anniversary>?, Error?) -> Void) {
        let anniversarys = LoveAnniversariesManager.default.getAllAnniversary()
        var anniversaryModels = [Anniversary]()
        for i in 0 ..< anniversarys.count{
            anniversaryModels.append(Anniversary(identifier: anniversarys[i].id, display: anniversarys[i].title))
        }
        completion(INObjectCollection(items: anniversaryModels), nil)
    }
    
    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        return self
    }
    
}
