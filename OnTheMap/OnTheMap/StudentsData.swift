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
    
    fileprivate init() {}
    
}
