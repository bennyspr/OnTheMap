//
//  UIColor+Custom.swift
//  OnTheMap
//
//  Created by Benny on 1/9/16.
//  Copyright © 2016 Benny Rodriguez. All rights reserved.
//

import UIKit

extension UIColor {
    
    
    class func customOrangeredColor() -> UIColor {
        
        return UIColor(red: 205/255, green: 55/255, blue: 0/255, alpha: 1.0)
    }
    
    class func customBurlywoodColor() -> UIColor {
        
        return UIColor(red: 255/255, green: 211/255, blue: 155/255, alpha: 1.0)
    }
    
    class func customSteelBlueColor() -> UIColor {
    
        return UIColor(red: 70/255, green: 130/255, blue: 180/255, alpha: 1.0)
    }
    
    class func customLightGrayColor() -> UIColor {
        
        return UIColor(red: 211/255, green: 211/255, blue: 211/255, alpha: 1.0)
    }
    
    class func customWhiteColorWithAlpha(alpha: CGFloat) -> UIColor {
        
        return UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: alpha)
    }
    
    class func customDarkBlueColor() -> UIColor {
        
        return UIColor(red: 0/255, green: 0/255, blue: 139/255, alpha: 1.0)
    }
    
    class func customBlackForLoadingColor() -> UIColor {
        
        return UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.5)
    }
}
