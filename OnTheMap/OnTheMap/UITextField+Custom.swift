//
//  UITextField+Custom.swift
//  OnTheMap
//
//  Created by Benny on 1/9/16.
//  Copyright © 2016 Benny Rodriguez. All rights reserved.
//

import UIKit

extension UITextField {
    
    func loginStyleWithPlaceholder(_ placeholder: String) {
        
        let spaceView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: frame.size.height))
        
        spaceView.backgroundColor = .clear
        
        leftView = spaceView
        
        leftViewMode = .always
        
        borderStyle = .none
        
        backgroundColor = .customBurlywoodColor()
        
        attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [
            NSForegroundColorAttributeName: UIColor.white
        ])
        
        tintColor = .customOrangeredColor()
        
        textColor = .customOrangeredColor()
    }
}
