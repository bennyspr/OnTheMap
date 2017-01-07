//
//  CustomLoadingView.swift
//  OnTheMap
//
//  Created by Benny on 2/6/16.
//  Copyright © 2016 Benny Rodriguez. All rights reserved.
//

import UIKit

class CustomLoadingView: NSObject {
    
    fileprivate let backgroundView: UIView!
    fileprivate let activity: UIActivityIndicatorView!
    
    init(view forView: UIView) {
        
        activity = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        // activity.color = .blackColor()
        activity.center = forView.center
        
        backgroundView = UIView(frame: forView.frame)
        backgroundView.backgroundColor = .customBlackForLoadingColor()
        backgroundView.addSubview(activity)
        backgroundView.isHidden = true
        
        forView.addSubview(backgroundView)
    }
    
    
    func startAnimating() {
        
        backgroundView.isHidden = false
        activity.startAnimating()
    }
    
    func stopAnimating() {
        
        backgroundView.isHidden = true
        activity.stopAnimating()
    }

}
