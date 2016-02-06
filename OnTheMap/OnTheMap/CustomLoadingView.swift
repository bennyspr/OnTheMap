//
//  CustomLoadingView.swift
//  OnTheMap
//
//  Created by Benny on 2/6/16.
//  Copyright © 2016 Benny Rodriguez. All rights reserved.
//

import UIKit

class CustomLoadingView: NSObject {
    
    private let backgroundView: UIView!
    private let activity: UIActivityIndicatorView!
    
    init(view forView: UIView) {
        
        activity = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        // activity.color = .blackColor()
        activity.center = forView.center
        
        backgroundView = UIView(frame: forView.frame)
        backgroundView.backgroundColor = .customBlackForLoadingColor()
        backgroundView.addSubview(activity)
        backgroundView.hidden = true
        
        forView.addSubview(backgroundView)
    }
    
    
    func startAnimating() {
        
        backgroundView.hidden = false
        activity.startAnimating()
    }
    
    func stopAnimating() {
        
        backgroundView.hidden = true
        activity.stopAnimating()
    }

}
