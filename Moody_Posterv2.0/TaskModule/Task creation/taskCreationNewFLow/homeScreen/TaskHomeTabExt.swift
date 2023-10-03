//
//  TaskHomeTabExt.swift
//  Moody_Posterv2.0
//
//  Created by   on 06/07/2021.
//

import Foundation
import UIKit

extension HomeContainer : UITabBarDelegate{
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        switch item.tag {
        case 1:
            print("1")
            break
        case 2:
            print("2")
            break
        case 3:
            print("3")
            //navigateToNextScreen("Profile", "ProfileVC")
            break
        default:
            //navigateToNextScreenAsRoot("TaskCreation", "TaskHomeScreenViewController")
            print("0")
            
        }
    }
}
