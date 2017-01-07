//
//  ConnectionManager.swift
//  OnTheMap
//
//  Created by Benny on 1/10/16.
//  Copyright © 2016 Benny Rodriguez. All rights reserved.
//

import UIKit

protocol RequestAPIProtocol: class {
    
    func url() -> URL
    func httpHeaderFields() -> [HeaderFieldForHTTP]
    func httpBody() -> NSDictionary?
    func httpMethod() -> HTTPRequestMethod
    func newDataAfterRequest(_ data: NSData) -> NSData
}

class ConnectionManager: NSObject {
    
    func httpRequest(requestAPI: RequestAPIProtocol, completion: @escaping ((AnyObject?, Bool, String?) -> Void)) {
        
        switch Reach().connectionStatus() {
            
        case .unknown, .offline:
            
            completion(nil, false, "Unable to connect to the Internet. Please verify your network connection.")
            return
            
        default:
            break
        }
        
        let request = NSMutableURLRequest(url: requestAPI.url())
        
        request.httpMethod = requestAPI.httpMethod().rawValue
        
        if requestAPI.httpMethod() == .DELETE {
            
            var xsrfCookie: HTTPCookie? = nil
            
            let sharedCookieStorage = HTTPCookieStorage.shared
            
            for cookie in sharedCookieStorage.cookies! {
                
                if cookie.name == "XSRF-TOKEN" {
                    
                    xsrfCookie = cookie
                }
            }
            
            if let xsrfCookie = xsrfCookie {
                
                request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
            }
        }
        
        for (value, field) in requestAPI.httpHeaderFields() {
            
            request.addValue(value, forHTTPHeaderField: field)
        }
        
        if let json = requestAPI.httpBody() {
          
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: json, options: [])
                
            } catch let error as NSError {

                completion(nil, false, error.description)
                return
            }
        }
        
        let session = URLSession.shared
        
        session.configuration.timeoutIntervalForRequest = 30.0
        
        session.configuration.timeoutIntervalForResource = 60.0
        
        let task = session.dataTask(with: request as URLRequest) {data, response, error in
        
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                completion(nil, false, "There was an error with your request: \(error!.localizedDescription)")
                print("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                
                var errorMessage: String!
                
                if let response = response as? HTTPURLResponse {
                    errorMessage = "Your request returned an invalid response! Status code: \(response.statusCode)!"
                } else if let response = response {
                    errorMessage = "Your request returned an invalid response! Response: \(response)!"
                } else {
                    errorMessage = "Your request returned an invalid response!"
                }
                
                do {
                    
                    if let data = data {
                        
                        let parsedResult = try JSONSerialization.jsonObject(with: requestAPI.newDataAfterRequest(data as NSData) as Data, options: .allowFragments)
                        
                        completion(parsedResult as AnyObject?, false, errorMessage)
                        return
                    }
                } catch {
                    print("Could not parse the data as JSON: '\(data)'")
                }
                
                completion(nil, false, errorMessage)
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the request!")
                completion(nil, false, "No data was returned by the request!")
                return
            }
            
            /* 5. Parse the data */
            let parsedResult: AnyObject!
            
            /* subset response data! */
            let newData = requestAPI.newDataAfterRequest(data as NSData)
            
            do {
                parsedResult = try JSONSerialization.jsonObject(with: newData as Data, options: JSONSerialization.ReadingOptions.allowFragments) as AnyObject!
                
            } catch {
                parsedResult = nil
                completion(nil, false, "Could not parse the data as JSON: '\(data)'")
                print("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            completion(parsedResult, true, nil)

        }
        
        task.resume()
    }
    
    

}
