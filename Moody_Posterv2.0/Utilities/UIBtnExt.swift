//
//  UIBtnExt.swift
//  Moody_Posterv2.0
//
//  Created by   on 03/06/2021.
//

import Foundation
import UIKit


extension UIApplication {
    
    //MARK: function will return reference to tabbarcontroller
    func tabbarController() -> UIViewController? {
        guard let vcs = self.keyWindow?.rootViewController?.children else { return nil }
        for vc in vcs {
            if  let _ = vc as? UITabBarController {
                return vc
            }
        }
        return nil
    }
}
