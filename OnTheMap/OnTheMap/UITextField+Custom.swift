//
//  UITextField+Custom.swift
//  OnTheMap
//
//  Created by Benny on 1/9/16.
//  Copyright © 2016 Benny Rodriguez. All rights reserved.
//

import UIKit

extension UITextField {
    
    func loginStyleWithPlaceholder(placeholder: String) {
        
        let spaceView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: frame.size.height))
        
        spaceView.backgroundColor = .clearColor()
        
        leftView = spaceView
        
        leftViewMode = .Always
        
        borderStyle = .None
        
        backgroundColor = .customBurlywoodColor()
        
        attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [
            NSForegroundColorAttributeName: UIColor.whiteColor()
        ])
        
        tintColor = .customOrangeredColor()
        
        textColor = .customOrangeredColor()
    }
}