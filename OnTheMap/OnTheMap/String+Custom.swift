//
//  String+Custom.swift
//  OnTheMap
//
//  Created by Benny on 1/10/16.
//  Copyright © 2016 Benny Rodriguez. All rights reserved.
//

import Foundation

extension String {
    
    public func trim() -> String {
        
        return self.trimmingCharacters(in: CharacterSet.whitespaces)
    }
}
