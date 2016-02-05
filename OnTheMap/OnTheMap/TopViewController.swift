//
//  TopViewController.swift
//  OnTheMap
//
//  Created by Benny on 1/23/16.
//  Copyright © 2016 Benny Rodriguez. All rights reserved.
//

import UIKit

class TopViewController: UIViewController {

    lazy var loading: UIActivityIndicatorView = {
        
        let activity = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        activity.color = .blackColor()
        activity.center = self.view.center
        self.view.addSubview(activity)
        return activity
    }()
    
    lazy var connectionManager: ConnectionManager = {
        
        return ConnectionManager()
    }()

    
}
