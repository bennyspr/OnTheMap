//
//  UdacityAPI.swift
//  OnTheMap
//
//  Created by Benny on 1/10/16.
//  Copyright © 2016 Benny Rodriguez. All rights reserved.
//

import Foundation

class UdacityAPI: RequestAPIProtocol {
    
    fileprivate let urlPath: UdacityPath!
    fileprivate var pathValues: [String: UdacityPath]?
    fileprivate var method: HTTPRequestMethod!
    
    var urlParameters: [String: AnyObject]?
    var json: NSDictionary?
    
    init(pathValue: String, httpMethod: HTTPRequestMethod = .GET) {
        self.urlPath = UdacityPath.None
        self.pathValues = [pathValue: UdacityPath.None]
        self.method = httpMethod
    }
    
    init(urlPath: UdacityPath, httpMethod: HTTPRequestMethod = .GET) {
        self.urlPath = urlPath
        self.pathValues = nil
        self.method = httpMethod
    }
    
    init(urlPath: UdacityPath, withValue pathValue: String, httpMethod: HTTPRequestMethod = .GET) {
        self.urlPath = urlPath
        self.pathValues = [pathValue: UdacityPath.None]
        self.method = httpMethod
    }
    
    init(urlPath: UdacityPath, nextValuesForPath path: [String: UdacityPath], httpMethod: HTTPRequestMethod = .GET) {
        self.urlPath = urlPath
        self.pathValues = path
        self.method = httpMethod
    }
    
    func url() -> URL {
        
        var url = Constant.Udacity.baseURL + urlPath.rawValue
        
        if let values = pathValues, values.count > 0 {
            
            var urlVars = [String]()
            
            for (key, value) in values {
                
                /* Escape it */
                let escapedValue = key.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
                
                /* Append it */
                urlVars += [escapedValue! + (value.rawValue.isEmpty ? "" : "/\(value.rawValue)")]
            }
            
            url += "/" + urlVars.joined(separator: "/")
        }
        
        if let parameters = urlParameters, parameters.count > 0  {
            
            url += OnTheMapHelper.escapedParameters(parameters)
        }
        
        return URL(string: url)!
    }
    
    func httpHeaderFields() -> [HeaderFieldForHTTP] {
        
        if let method = method {
            
            switch method {
                
            case .GET:
                
                break
                
            case .POST:
                return [
                    ("application/json", "Accept"),
                    ("application/json", "Content-Type")
                ]
                
            case .PUT:
                
                break
                
            case .DELETE:
                
                break
            }
        }
        
        return []
    }
    
    func httpBody() -> NSDictionary? {
        
        return json
    }
    
    func httpMethod() -> HTTPRequestMethod {
        
        return method
    }
    
    func newDataAfterRequest(_ data: Data) -> Data {
        
        //return data.subdata(in: NSMakeRange(5, data.length - 5)) as Data /* subset response data! */
        let range = Range(uncheckedBounds: (5, data.count))
        
        return data.subdata(in: range)
    }
}
