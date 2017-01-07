//
//  AuthUser.swift
//  OnTheMap
//
//  Created by Benny on 1/10/16.
//  Copyright © 2016 Benny Rodriguez. All rights reserved.
//

import Foundation

// http://www.wadecantley.com/lifeblog/2014/11/25/global-variables-singletons-in-swift

class AuthUser {
    
    class var sharedInstance: AuthUser {
        
        struct Singleton {
            
            static let instance = AuthUser()
        }
        
        return Singleton.instance
    }
    
    var accountRegistered: Bool?
    var accountKey: String?
    var sessionID: String?
    var sessionExpiration: String?
    var firstName: String?
    var lastName: String?
    var studentInformation: StudentInformation?
    var fbAccessToken: String?
    
    fileprivate init() {}
    
    func queryingForLocation(_ completion: @escaping (Bool, String?)->Void) {
        
        guard let key = accountKey else {
            
            completion(true, "0")
            return
        }
        
        let request = ParseAPI(urlPath: .StudentLocation)
        
        request.urlParameters = [
        
            "where": "{\"uniqueKey\":\""+key+"\"}" as AnyObject
        ]
        
        ConnectionManager().httpRequest(requestAPI: request) { (response, success, errorMessage) -> Void in
            
            DispatchQueue.main.async(execute: { () -> Void in
                
                if let data = response as? JSON, let results = data["results"] as? JSONArray {
                    
                    if results.count == 1 {
                       
                        self.studentInformation = StudentInformation(dictionary: results[0])
                        
                        completion(true, nil)
                        
                    } else {
                        
                        self.studentInformation = nil
                        
                        completion(true, "0")
                    }
                    
                } else if let message = errorMessage {
                    
                    completion(false, message)
                    
                } else {
                    
                    completion(false, "Sorry, something went wrong loading your student information.")
                    print("Error Message:\n\(errorMessage)\n")
                }
            })
        }
    }
}
