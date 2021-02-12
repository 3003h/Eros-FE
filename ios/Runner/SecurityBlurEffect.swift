//
//  SecurityBlurEffect.swift
//  Runner
//
//  Created by 三夜 on 2021/2/9.
//

import Foundation
import UIKit


public class SecurityBlurEffect
{
     class func addBlurEffect(){
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        
        blurEffectView.tag = 19999
        blurEffectView.alpha = 0.99
        blurEffectView.frame = UIApplication.shared.keyWindow!.bounds
    
        UIApplication.shared.keyWindow!.backgroundColor = UIColor.clear
    
        UIApplication.shared.keyWindow!.addSubview(blurEffectView)
        
        
    }
    
    
    class func removeBlurEffect(){
        
        let subViews = UIApplication.shared.keyWindow!.subviews;
        
        for  view in subViews {
            if view.tag == 19999 {
                if  view is UIVisualEffectView {
                    UIView.animate(withDuration: 0.3, animations: {
                        view.removeFromSuperview()
                    })
                }
            }
        }
    }
}
