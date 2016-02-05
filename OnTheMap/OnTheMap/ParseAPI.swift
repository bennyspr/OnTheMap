//
//  ParseAPI.swift
//  OnTheMap
//
//  Created by Benny on 1/10/16.
//  Copyright © 2016 Benny Rodriguez. All rights reserved.
//

import Foundation

class ParseAPI: RequestAPIProtocol {
    
    private let urlPath: ParsePath!
    private var pathValues: [String: ParsePath]?
    private var method: HTTPRequestMethod!
    
    var urlParameters: [String: AnyObject]?
    var json: NSDictionary?
    
    init(pathValue: String, httpMethod: HTTPRequestMethod = .GET) {
        self.urlPath = ParsePath.None
        self.pathValues = [pathValue: ParsePath.None]
        self.method = httpMethod
    }
    
    init(urlPath: ParsePath, httpMethod: HTTPRequestMethod = .GET) {
        self.urlPath = urlPath
        self.pathValues = nil
        self.method = httpMethod
    }
    
    init(urlPath: ParsePath, withValue pathValue: String, httpMethod: HTTPRequestMethod = .GET) {
        self.urlPath = urlPath
        self.pathValues = [pathValue: ParsePath.None]
        self.method = httpMethod
    }
    
    init(urlPath: ParsePath, nextValuesForPath path: [String: ParsePath], httpMethod: HTTPRequestMethod = .GET) {
        self.urlPath = urlPath
        self.pathValues = path
        self.method = httpMethod
    }
    
    func url() -> NSURL {
        
        var url = Constant.Parse.baseURL + urlPath.rawValue
        
        if let values = pathValues where values.count > 0 {
            
            var urlVars = [String]()
            
            for (key, value) in values {
                
                /* Escape it */
                let escapedValue = key.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())
                
                /* Append it */
                urlVars += [escapedValue! + (value.rawValue.isEmpty ? "" : "/\(value.rawValue)")]
            }
            
            url += "/" + urlVars.joinWithSeparator("/")
        }
        
        if let parameters = urlParameters where parameters.count > 0  {
            
            url += OnTheMapHelper.escapedParameters(parameters)
        }
        
        return NSURL(string: url)!
    }
    
    func httpHeaderFields() -> [HeaderFieldForHTTP] {
        
        var parameters: [HeaderFieldForHTTP] = [
            
            (Constant.Parse.applicationID, "X-Parse-Application-Id"),
            
            (Constant.Parse.restAPIKey, "X-Parse-REST-API-Key")
        ]
        
        if let method = method {
            
            switch method {
                
            case .GET:
                
                break
                
            case .POST, .PUT:
                
                parameters.append(("application/json", "Content-Type"))
      
                break
                
            case .DELETE:
                
                break
            }
        }
        
        return parameters
    }
    
    func httpBody() -> NSDictionary? {
        
        return json
    }
    
    func httpMethod() -> HTTPRequestMethod {
        
        return method
    }
    
    func newDataAfterRequest(data: NSData) -> NSData {
        
        return data
    }
}