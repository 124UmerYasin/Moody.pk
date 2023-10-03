//
//  LogoutVC.swift
//  Moody_Posterv2.0
//
//  Created by   on 07/06/2021.
//

import Foundation
import UIKit

class LogoutVC: UIViewController {

    //MARK: calls when first time View Loads
    //. Set Visibility of NavigationBar/TabBar
    //. logout API calls and clear all files from directory 
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.isHidden = true
        navigationController?.navigationBar.isHidden = true
        if(UserDefaults.standard.string(forKey: DefaultsKeys.token) != nil){
            logoutAPICall()
            clearAllFiles()
        }
    }
    
    //MARK: Clear All Files when user logouts
    func clearAllFiles() {
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsUrl,
                                                                       includingPropertiesForKeys: nil,
                                                                       options: .skipsHiddenFiles)
            for fileURL in fileURLs {
                try FileManager.default.removeItem(at: fileURL)
                print("File Deleted")
            }
        } catch  { print(error) }
    }
    

//MARK: Save Language selected by user before logging out
    func saveLang(){
        let lang = UserDefaults.standard.value(forKey: "language")
        UserDefaults.resetDefaults()
        UserDefaults.standard.setValue(lang, forKey: "language")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.navigationController?.navigationBar.isHidden = true
            SocketsManager.sharesInstance.socket.emit("onLogout", "logout")
            let originNav = UIApplication.shared.keyWindow?.rootViewController
             if let nav = originNav as? UINavigationController {
                 let tab = nav.topViewController!
                 DefaultsKeys.splashCheck = false
                 tab.navigationController?.popToRootViewController(animated: true)
             }
        }
    }

//MARK: Logout API call
    func logoutAPICall(){
        if(CheckInternet.Connection()){
            ApiManager.sharedInstance.apiCaller(hasBodyData: false, hasToken: true, url: ENDPOINTS.logout, dictionary: [:], httpMethod: "POST", token: UserDefaults.standard.string(forKey: DefaultsKeys.token)) { [self] Result in
                switch Result{
                case .success(_):
                    saveLang()
                case .failure(_):
                    saveLang()
                }
            }
        }else{
            self.presentAlert(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString( "No Internet Connection. Please Try again later when internet is available", comment: ""), parentController: self)
        }

        
    }
}
