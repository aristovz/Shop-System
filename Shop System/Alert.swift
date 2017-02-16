//
//  Alert.swift
//  Shop System
//
//  Created by Pavel Aristov on 09.02.17.
//  Copyright © 2017 NetSharks. All rights reserved.
//

import Foundation
import SCLAlertView

class Alert {
    class var wait: SCLAlertView {
        let appearance = SCLAlertView.SCLAppearance (
            kDefaultShadowOpacity: 0.5,
            
            kTitleHeight: 0,
            
            kWindowWidth: 120,
            kWindowHeight: 100,
            
            kTextHeight: 0,
            kTextFieldHeight: 0,
            kTextViewdHeight: 0,
            kButtonHeight: 0,
            
            showCloseButton: false,
            showCircularIcon: false,
           
            hideWhenBackgroundViewIsTapped: true,
            
            contentViewColor: UIColor.groupTableViewBackground,
            contentViewBorderColor: UIColor.groupTableViewBackground
        )
        
        // Initialize SCLAlertView using custom Appearance
        let alert = SCLAlertView(appearance: appearance)
        
        // Creat the subview
        let subview = UIView(frame: CGRect(x: 0, y: 0, width: alert.view.frame.width, height: 90))
        
        let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 25, y: 30, width: 50, height: 50))
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.color = UIColor.darkGray
        activityIndicator.startAnimating()
        subview.addSubview(activityIndicator)
        
        // Add the subview to the alert's UI property
        alert.customSubview = subview
        
        return alert
    }
    
    class var result: SCLAlertView {
        let appearance = SCLAlertView.SCLAppearance (
            kDefaultShadowOpacity: 0.5,
            
            kTitleFont: UIFont(name: "HelveticaNeue", size: 20)!,
            kTextFont: UIFont(name: "HelveticaNeue", size: 14)!,
            kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
            
            hideWhenBackgroundViewIsTapped: true,
            
            contentViewColor: UIColor.groupTableViewBackground,
            contentViewBorderColor: UIColor.groupTableViewBackground
        )
        
        // Initialize SCLAlertView using custom Appearance
        let alert = SCLAlertView(appearance: appearance)
        
        return alert
    }
}






//let appearance = SCLAlertView.SCLAppearance (
//    kDefaultShadowOpacity: 0.8,
//    
//    kCircleTopPosition: 0,
//    kCircleBackgroundTopPosition: 0,
//    kCircleHeight: 0,
//    kCircleIconHeight: 0,
//    
//    kTitleTop: 0,
//    kTitleHeight: 0,
//    
//    kWindowWidth: 100,
//    kWindowHeight: 100,
//    
//    kTextHeight: 0,
//    kTextFieldHeight: 0,
//    kTextViewdHeight: 0,
//    kButtonHeight: 0,
//    
//    kTitleFont: UIFont(name: "HelveticaNeue", size: 20)!,
//    kTextFont: UIFont(name: "HelveticaNeue", size: 14)!,
//    kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
//    
//    showCloseButton: false,
//    showCircularIcon: false,
//    shouldAutoDismiss: false,
//    
//    contentViewCornerRadius: 0,
//    fieldCornerRadius: 0,
//    buttonCornerRadius: 0,
//    
//    hideWhenBackgroundViewIsTapped: true,
//    
//    contentViewColor: UIColor.darkGray,
//    contentViewBorderColor: UIColor.darkGray,
//    titleColor: UIColor.white
//)
