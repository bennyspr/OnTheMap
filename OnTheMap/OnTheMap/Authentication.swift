//
//  Authentication.swift
//  OnTheMap
//
//  Created by Benny on 1/23/16.
//  Copyright © 2016 Benny Rodriguez. All rights reserved.
//

import Foundation

class Authentication: NSObject {
    
    class func logout(_ completion: @escaping ((Bool, String?)->Void)) {
        
        let request = UdacityAPI(urlPath: .Session, httpMethod: .DELETE)
        
        ConnectionManager().httpRequest(requestAPI: request) { (response, success, errorMessage) -> Void in
            
            DispatchQueue.main.async(execute: { () -> Void in
                
                if let data = response as? JSON, let session = data["session"] as? JSON {
                    
                    if let id = session["id"] as? String, let expiration = session["expiration"] as? String {
                        
                        let user = AuthUser.sharedInstance
                        
                        user.sessionID = id
                        
                        user.sessionExpiration = expiration
                        
                        completion(true, nil)
                        
                    } else {
                        
                        completion(false, "Sorry, something went wrong.")
                    }
                    
                } else if let data = response as? JSON, let message = data["error"] as? String {
                    
                    completion(false, message)
                    
                } else {
                    
                    completion(false, "Sorry, something went wrong.")
                    print("Error Message:\n\(errorMessage)\n")
                }
            })
        }
    }
}
