//
//  HomeContainer.swift
//  Moody_Posterv2.0
//
//  Created by   on 07/07/2021.
//

import Foundation
import UIKit

class HomeContainer: UIViewController{
    
    var images : [String]!
    
    //MARK: calls when first time View Loads
    //. Ui settings
    //. TabBar creation
    override func viewDidLoad() {
        
        self.view.backgroundColor = .white
        navigationController?.isNavigationBarHidden = true
        createTabBarController()
       
    }
    
    //Bottom TabBar created
    //. images array name are set
    //. tababar controller names are set
    //. Tabbar specfication are set
    func createTabBarController(){
        
        if(UserDefaults.standard.bool(forKey: DefaultsKeys.helpBadge)){
            images = ["homeNew", "historyNew",  "WalletNew", "profileBadge"]
        }else{
            images = ["homeNew", "historyNew",  "WalletNew", "profileNew"]
        }
        
        
        
        let tabBarVC = UITabBarController()
        
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font : UIFont(name: "Gilroy-SemiBold", size: 10) ?? .systemFont(ofSize: 10)], for: .normal)
        tabBarVC.view.backgroundColor = .white
        
        let profileVC = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "ProfileViewController")
        profileVC.title = NSLocalizedString("Profile", comment: "")
    
        let homeVC = UIStoryboard(name: "TaskCreation", bundle: nil).instantiateViewController(withIdentifier: "TaskCreationViewController")
        homeVC.title =  NSLocalizedString("Home", comment: "")
        
        let  historyVC = UIStoryboard(name: "TaskHistory", bundle: nil).instantiateViewController(withIdentifier: "TaskHistoryViewController")
        historyVC.title =  NSLocalizedString("Task History", comment: "")
        
        let accountVC  = UIStoryboard(name: "MoodyAccount", bundle: nil).instantiateViewController(withIdentifier: "SelectPaymentMethodViewController")
        accountVC.title = NSLocalizedString("Wallet", comment: "")
                
        let controllers = [homeVC, historyVC ,accountVC,profileVC]
        
       
       
        tabBarVC.viewControllers = controllers.map { UINavigationController(rootViewController: $0)}
        tabBarVC.tabBar.isTranslucent = false

        tabBarVC.tabBar.contentMode = .left
        tabBarVC.tabBar.semanticContentAttribute = .forceLeftToRight
        
        guard let item = tabBarVC.tabBar.items else {return}
        
        //MARK: Set images to tabbar icons
        for x in 0..<item.count {
            if(UserDefaults.standard.bool(forKey: DefaultsKeys.helpBadge) && x == 3){
                item[x].image =  UIImage(named: images[x])?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
            }else{
                item[x].image = UIImage(named: images[x])
            }
            
            
        }
           
        //MARK: Present Home Container 
        tabBarVC.modalPresentationStyle = .fullScreen
        navigationController?.isNavigationBarHidden = true
        self.navigationController?.pushViewController(tabBarVC, animated: true)
    }
    
}

