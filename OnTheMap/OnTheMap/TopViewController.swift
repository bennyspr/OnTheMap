//
//  TopViewController.swift
//  OnTheMap
//
//  Created by Benny on 1/23/16.
//  Copyright © 2016 Benny Rodriguez. All rights reserved.
//

import UIKit

class TopViewController: UIViewController {
    
    lazy var loading: CustomLoadingView = {
        
        return CustomLoadingView(view: self.view)
    }()
    
    lazy var connectionManager: ConnectionManager = {
        
        return ConnectionManager()
    }()
    
    lazy var dataSource: StudentsData = {
        
        return StudentsData.sharedInstance
    }()
    
    lazy var authUser: AuthUser = {
       
        return AuthUser.sharedInstance
    }()
    
    
}
