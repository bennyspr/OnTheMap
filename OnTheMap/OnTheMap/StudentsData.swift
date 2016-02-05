//
//  StudentsData.swift
//  OnTheMap
//
//  Created by Benny on 1/10/16.
//  Copyright © 2016 Benny Rodriguez. All rights reserved.
//

import Foundation

class StudentsData {
    
    class var sharedInstance: StudentsData {
       
        struct Singleton {
           
            static let instance = StudentsData()
        }
    
        return Singleton.instance
    }
    
    var students = [StudentInformation]()
    
    
    private init() {}
    
    func fetchStudents(completion: ((Bool, String?)->Void)) {
        
        let request = ParseAPI(urlPath: .StudentLocation)
        
        ConnectionManager().httpRequest(requestAPI: request, completion: { (response, success, errorMessage) -> Void in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                if success {
                    
                    if let data = response as? JSON, let results = data["results"] as? JSONArray {
                        
                        if results.count > 0 {
                            
                            for data in results {
                                
                                self.students.append(StudentInformation(dictionary: data))
                            }
                            
                        } else {
                            
                            self.students = []
                        }
                        
                        completion(true, nil)
                        
                    } else {
                        
                        completion(false, "Sorry, there was a problem reading the result of the request. Please try again.")
                    }
                    
                } else if let message = errorMessage {
                
                    completion(false, message)
                    
                } else {
                    
                    completion(false, "Sorry, something went wrong.")
                }
            })
        })
    }
    
}