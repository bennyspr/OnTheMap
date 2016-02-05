//
//  Enums.swift
//  OnTheMap
//
//  Created by Benny on 1/10/16.
//  Copyright © 2016 Benny Rodriguez. All rights reserved.
//

import UIKit

enum HTTPRequestMethod: String {
    
    case GET, POST, PUT, DELETE
}

enum UdacityPath: String {
    
    case None = ""
    case Session = "session"
    case Users = "users"
}

enum ParsePath: String {
    
    case None = ""
    case StudentLocation
}

enum InformationPostStatus: String {
    
    case Find
    case Submit
}