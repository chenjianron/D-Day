//
//  Helper.swift
//  AdLib
//
//  Created by Kevin on 2019/8/20.
//

import UIKit
import SwiftyJSON

// MARK: - LLog

public func LLog(_ items: Any...,
    file: String = #file,
    method: String = #function,
    line: Int = #line)
{
    #if DEBUG
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

// MARK: - Localizations

public func __(_ text: String) -> String {
    let onlineLocalizations = Preset.named("S.Helper.localizations")[text]
    if onlineLocalizations.exists(), let str = Util.localizedJSON(onlineLocalizations).string {
        return str
    }
    
    return NSLocalizedString(text, tableName: "Localizations", bundle: Bundle.main, value: "", comment: "")
}

// MARK: - Request

public enum RequestMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
}

public typealias RequestHeaders = [String: String]

public func request(_ url: String,
                    method: RequestMethod,
                    parameters: [String: Any?]? = nil,
                    headers: RequestHeaders? = nil,
                    timeout: TimeInterval = 30,
                    responseHandler: ((Data?, Bool, HTTPURLResponse?, Error?) -> Void)?) {
    request(URL(string: url), method: method, parameters: parameters, headers: headers, timeout: timeout, responseHandler: responseHandler)
}

// reponseHandler: (data, success, response, error) -> Void
public func request(_ url: URL?,
                    method: RequestMethod,
                    parameters: [String: Any?]? = nil,
                    headers: RequestHeaders? = nil,
                    timeout: TimeInterval = 30,
                    responseHandler: ((Data?, Bool, HTTPURLResponse?, Error?) -> Void)?) {
    
    guard let url = url else {
        let error = NSError(domain: "invalid URL", code: 0, userInfo: nil)
        responseHandler?(nil, false, nil, error)
        return
    }
    
    let cachePolicy: URLRequest.CachePolicy = .reloadIgnoringLocalCacheData
    var urlRequest = URLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: timeout)
    
    // parameters
    if parameters != nil {
        switch method {
        case .get:
            var components = URLComponents(string: url.absoluteString)
            
            var queryItems = [URLQueryItem]()
            let keys = parameters!.map({ String($0.key) }).sorted()
            for k in keys {
                if let v = parameters![k] {
                    let arr = (v as? Array<Any?>) ?? [v]
                    for item in arr {
                        queryItems.append(URLQueryItem(name: k, value: "\(item ?? "")"))
                    }
                }
            }
            
            if components?.queryItems == nil { components?.queryItems = [] }
            components?.queryItems?.append(contentsOf: queryItems)
            let requestURL = components?.url ?? url
            urlRequest = URLRequest(url: requestURL, cachePolicy: cachePolicy, timeoutInterval: timeout)
            
        case .post, .put:
            if let parameters = parameters {
                let contentType = headers?["Content-Type"]
                
                if contentType == nil {
                    urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                }
                
                if contentType == "application/json" || contentType == nil {
                    urlRequest.httpBody = try? JSON(parameters as Any).rawData()
                }
                else if contentType == "application/x-www-form-urlencoded" {
                    let components = parameters.map { (k, v) -> String in
                        return "\(k)=\(v ?? "")"
                    }
                    urlRequest.httpBody = components.joined(separator: "&").data(using: .utf8)
                }
                else {
                    print(#function, "Unsupported Content-Type")
                }
            }
        }
    }
    
    // headers
    for (k, v) in headers ?? [:] {
        urlRequest.setValue(v, forHTTPHeaderField: k)
    }
    
    //
    urlRequest.httpMethod = method.rawValue
    
    (URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
        let response = (response as? HTTPURLResponse)
        let statusCode = response?.statusCode ?? 500
        let success = ( error == nil && (200..<400).contains(statusCode) )
        DispatchQueue.main.async {
            responseHandler?(data, success, response, error)
        }
    }).resume()
}
