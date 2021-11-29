//
//  MHCommonDefines.swift
//  MarketingHelper
//
//  Created by Endless Summer on 2020/8/21.
//

import Foundation

public func DLog(_ items: Any...,
    file: String = #file,
    method: String = #function,
    line: Int = #line)
{
    #if DEBUG
    guard MarketingHelper.logEnable else { return }
    var output = ""
    for item in items {
        output += "\(item) "
    }
    output += "\n"
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm:ss:SSS"
    let timestamp = dateFormatter.string(from: Date())
    print("\(timestamp) | \((file as NSString).lastPathComponent)[\(line)] > \(method): ")
    print(output)
    #endif
}
