//
//  ProfileViewController.swift
//  Moody_Posterv2.0
//
//  Created by   on 07/07/2021.
//

import Foundation
import UIKit

class ProfileViewController: UIViewController{
    
    //MARK: Outlets
    @IBOutlet weak var notificationBadgeLbl: UILabel!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var rating: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var appVersion: UILabel!
    @IBOutlet weak var topView: UIView!

    static var profileViewControllerVisible = false
    
    //MARK: Outlet Actions
    @IBAction func taskerDidTap(_ sender: Any) {
        tabBarController?.selectedIndex = 0
    }
    
    @IBAction func settingsDidTap(_ sender: Any) {
        navigateToNextScreen("Settings", "SettingsVC")
    }
    
    
    //MARK: Navigates to Help MoodyHelp Module
    @IBAction func helpBtnTap(_ sender: Any) {
                
        let nextVC = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "MoodyHelpViewController") as! MoodyHelpViewController
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    //MARK: Navigates to Invite a friend screen
    @IBAction func inviteBtnTap(_ sender: Any) {
        navigateToNextScreen("InviteAFriend", "InviteAFriend")
    }
    
    @IBAction func addPromoBtnTap(_ sender: Any) {
        navigateToNextScreen("Main", "UserInfo")
    }
    
    //MARK: Opens walkthrough screens of app
    @IBAction func appDemo(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        let main = storyboard.instantiateViewController(withIdentifier: "AppGuideViewController")
        main.modalPresentationStyle = .fullScreen
        main.navigationController?.navigationBar.isHidden = true
        main.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(main, animated: true)
    }
    
    //MARK: Logout Tapped in settings
    @IBAction func LogoutBtnTap(_ sender: Any) {
        logout()
    }
        
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.hidesBottomBarWhenPushed = true
    }
    
    //MARK: calls when first time View Loads
    //. Sets Profile rating/image to respective fields
    //. Setup NavigationBar
    //. NotifcationObserver register
    override func viewDidLoad() {
        setData()
        setupNavigationBar()
        addSwipeGestures()
        navigationController?.isNavigationBarHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateBadge(_:)), name: NSNotification.Name(rawValue: "updateTickStatus"), object: nil)
       
    }
    
    //MARK: Calls after view is appeared
    //. TapGesture target set top topView
    override func viewDidAppear(_ animated: Bool) {
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        topView.addGestureRecognizer(tap)
    }
    
    //MARK: Calls before view appears to screen
    //.Check TabBar profile icon badge
    //. Navigation/TabBar visibility is set
    override func viewWillAppear(_ animated: Bool) {
        checkProfileBadge()
        setVisibility()
    }
    
    //MARK: Calls when is about to disappears
    //. Profile Icon badge is set
    override func viewWillDisappear(_ animated: Bool) {
        ProfileViewController.profileViewControllerVisible = false
        if(UserDefaults.standard.bool(forKey: DefaultsKeys.helpBadge)){
            tabBarController?.tabBar.items![3].image = UIImage(named:"profileBadge")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
           
        }else{
            tabBarController?.tabBar.items![3].image = UIImage(named:"profileNew")
        }
    }
    
    //MARK: Checks Profile Badge
    func checkProfileBadge(){
        if(UserDefaults.standard.bool(forKey: DefaultsKeys.helpBadge)){
            tabBarController?.tabBar.items![3].image = UIImage(named:"notifiedSelectedProfile")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
            notificationBadgeLbl.isHidden = false
        }else{
            tabBarController?.tabBar.items![3].image = UIImage(named:"profileNew")
            notificationBadgeLbl.isHidden = true
        }
    }
    
    //MARK: Sets NavigationBar,TabBar visibility
    func setVisibility(){
        ProfileViewController.profileViewControllerVisible = true
        navigationController?.isNavigationBarHidden = true
        tabBarController?.tabBar.isHidden = false
    }
    
    
    
    //MARK: Sets user Profile information fetched from UserDefaults
    func setData(){
        if(UserDefaults.standard.string(forKey: DefaultsKeys.name) != nil){
            username.text = UserDefaults.standard.string(forKey: DefaultsKeys.name)
        }
        if(UserDefaults.standard.double(forKey: DefaultsKeys.poster_rating) != 0){
            rating.attributedText = NSMutableAttributedString().starWithRating(rating: Float(Int(UserDefaults.standard.double(forKey: DefaultsKeys.poster_rating))) , outOfTotal: 5, withFontSize: 70)
            rating.attributedText = NSMutableAttributedString().starWithRating(rating: Float(Int(UserDefaults.standard.double(forKey: DefaultsKeys.poster_rating))) , outOfTotal: 5, withFontSize: 70)
        }else{
            rating.attributedText = NSMutableAttributedString().starWithRating(rating: 0, outOfTotal: 5, withFontSize: 70)
        }
        
        if(UserDefaults.standard.data(forKey: DefaultsKeys.profile_picture) != nil){
            profilePicture.image = UIImage(data: Data(UserDefaults.standard.data(forKey: DefaultsKeys.profile_picture)!))
            
        }else{
            profilePicture.image = UIImage(named: "person2")
        }
        if let refer = UserDefaults.standard.string(forKey: "refCode"), refer != "" {
            print(refer)
        }
        appVersion.text = "App Version \(Constants.app_version)"
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        navigateToNextScreen("Settings", "PresonalInfoVC")
    }
    
    //MARK: Logout DialogBox
    //. If there is no active task logout Alert is shown
    //. If there is any active task active task message custom alert from AlertService class is shown
    func logout(){
        
        if(UserDefaults.standard.integer(forKey: DefaultsKeys.numberOfActiveTask) == 0){
            presentLogoutAlert()
        }else{
            let vc = AlertService().presentNotificationAlert()
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    //MARK: Logout Alert
    //. Allows user to cancel/logout the user
    //. onlogout navigates to LogoutVC
    func presentLogoutAlert(){
        let vc = AlertService().presentSimpleAlert( title: NSLocalizedString("Confirmation!", comment: ""),
                                                    message: NSLocalizedString("Are you sure you want to logout?", comment: ""),
                                                    image: UIImage(named: "Alert-New")!,
                                                    yesBtnText: NSLocalizedString("Yes", comment: ""),
                                                    noBtnStr: NSLocalizedString("Not Now", comment: "")){ [self] in
                        
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let main = storyboard.instantiateViewController(withIdentifier: "LogoutVC")
            main.modalPresentationStyle = .overFullScreen
            main.navigationController?.navigationBar.isHidden = true
            navigationController?.hidesBottomBarWhenPushed = true
            
            self.navigationController?.pushViewController(main, animated: true)
            
            dismiss(animated: true, completion: nil)
           

        }
        self.present(vc, animated: true, completion: nil)
    }
   

    
    //MARK: Updates Profile Badge in Bottom TabBar
    //. This method is called when onTicketUpdate emit is received
    //. Socket data is received is method and poster_active_ticket bool is fetched
    //. add badge to profile tab if poster_active_ticket bool is true
    @objc func updateBadge(_ notification:NSNotification){
        
        let ticketData = notification.userInfo as! [String:Any]
        
        let notificationBadge = ticketData["poster_active_ticket"] as? Bool ?? false
        
        UserDefaults.standard.setValue(notificationBadge, forKey: DefaultsKeys.helpBadge)
        
        if(UserDefaults.standard.bool(forKey: DefaultsKeys.helpBadge)){
            
            if(ProfileViewController.profileViewControllerVisible || MoodyHelpViewController.MoodyHelpViewControllerVisible || AskQuestionViewController.askQuestionVisible || SettingsVC.SettingVisible || LanguageVC.languageVisible || PresonalInfoVC.profileInfoVisible || InviteAFriend.invitefriendVisible){
                
                tabBarController?.tabBar.items![3].image = UIImage(named:"notifiedSelectedProfile")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
            }else{
               
                tabBarController?.tabBar.items![3].image  =  UIImage(named:"profileBadge")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
            }
            
            notificationBadgeLbl.isHidden = false
        }else{
            tabBarController?.tabBar.items![3].image = UIImage(named:"profileNew")
            notificationBadgeLbl.isHidden = true
        }
        
    }
}
