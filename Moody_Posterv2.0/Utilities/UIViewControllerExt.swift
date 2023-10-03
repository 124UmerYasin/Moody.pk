//
//  UIViewControllerExt.swift
//  Moody_Posterv2.0
//
//  Created by   on 03/06/2021.
//

import Foundation
import UIKit
import Quickblox
import QuickbloxWebRTC
import PushKit

extension UIViewController{

    //MARK: Generic function to Navigates to NextScreen
    func navigateToNextScreen(_ sb: String, _ vc: String){
        
        let storyboard = UIStoryboard(name: sb, bundle: nil)
        let main = storyboard.instantiateViewController(withIdentifier: vc)
        main.modalPresentationStyle = .fullScreen
        main.navigationController?.navigationBar.isHidden = true
        self.navigationController?.pushViewController(main, animated: true)
        
    }
    
    //MARK: Generic function to Navigates to Next to Screen and sets it to root
    func navigateToNextScreenAsRoot(_ sb: String, _ vc: String){
        
        let storyboard = UIStoryboard(name: sb, bundle: nil)
        let main = storyboard.instantiateViewController(withIdentifier: vc)
        main.modalPresentationStyle = .fullScreen
        self.navigationController?.navigationBar.isHidden = false
        navigationController?.viewControllers = [main]
        self.navigationController?.pushViewController(main, animated: true)
        
    }
    
    //MARK: it is called to naviagte to chat on tapping notification
    @objc func onClickNewMessageNotification(_ notification:NSNotification){
        let taskId = notification.userInfo as! [String:Any]
        UserDefaults.standard.setValue(taskId["task_id"], forKey: DefaultsKeys.taskId)
        let vc = ExtendedChat()
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
        tabBarController?.selectedIndex = 0

    }
    
    //MARK: it is called to naviagte to CustomerSupport on running task on tapping notification
    @objc func navigateToCustomerSupport(_ notification:NSNotification){
        let taskId = notification.userInfo as! [String:Any]
        UserDefaults.standard.setValue(taskId["task_id"], forKey: DefaultsKeys.taskId)
        UserDefaults.standard.setValue(false, forKey: DefaultsKeys.customer_support_notification)
        UserDefaults.standard.setValue(true, forKey: DefaultsKeys.isfromChatOrNot)
        let vc = CustomerSupport()
        vc.hidesBottomBarWhenPushed = true
        vc.ticket_id = taskId["ticket_id"] as! String
        vc.isFromNotification = true
        vc.status = true
        navigationController?.popViewController(animated: true)
        self.navigationController?.pushViewController(vc, animated: false)
        tabBarController?.selectedIndex = 0
        
    }
    
    //MARK: It is called to naviagte to CustomerSupport form help
    @objc func  navigateToCustomerSupportHelp(_ notification:NSNotification){
        
        let taskId = notification.userInfo as! [String:Any]
        UserDefaults.standard.setValue(false, forKey: DefaultsKeys.customer_support_notification)
        UserDefaults.standard.setValue(false, forKey: DefaultsKeys.isfromChatOrNot)
        let vc = CustomerSupport()
        vc.hidesBottomBarWhenPushed = true
        vc.ticket_id = taskId["ticket_id"] as! String
        vc.isFromNotification = true
        vc.status = true
        self.navigationController?.pushViewController(vc, animated: false)
        tabBarController?.selectedIndex = 0
        
    }
    
    
    //MARK: NotificationObserver Function called on socket emit of TicketStatus update
    @objc func  updateTickStatus(_ notification:NSNotification){
        
        let ticketData = notification.userInfo as! [String:Any]
        
        let notificationBadge = ticketData["poster_active_ticket"] as? Bool ?? false
        
        UserDefaults.standard.setValue(notificationBadge, forKey: DefaultsKeys.helpBadge)
        
        if(notificationBadge){
            tabBarController?.tabBar.items![3].image = UIImage(named:"profileBadge")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        }else{
            tabBarController?.tabBar.items![3].image = UIImage(named: "profileNew")
        }
    }
    
    
    //MARK: Tap on Wallet in bottom tabbar
    //. Navigates to Wallet Screen
    @objc func onClickWallet(_ notification:NSNotification){
        tabBarController?.selectedIndex = 2
    }
    
    //MARK: Tap on History in bottom tabbar
    //. Navigates to History Screen
    @objc func navigateToHistory(_ notification:NSNotification){
        tabBarController?.selectedIndex = 1
    }
    
    
    
    
    
    
    //MARK: on tap dismiss keyboard
    func setupToHideKeyboardOnTapOnView()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer( target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
    
    //MARK: - Present for loggout out Alert
    func presentAlert(title: String, message: String,parentController: UIViewController){
        
        if(message == "Token Not Authenticate" || message == "Token not found." || title == "Token not authenticated." || title == "Token not found."){
            
            
            
            let alert = UIAlertController(title: NSLocalizedString("Session Expired", comment: ""), message: NSLocalizedString("Please login again." , comment: ""), preferredStyle: .alert)
            
            alert.view.tintColor = UIColor(named: "ButtonColor")
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Dismiss", comment: ""), style: .cancel, handler: {_ in
                
                //                if !TaskHomeScreenViewController.logout{
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "logoutDidTap"), object: nil,userInfo: ["storyboard": "Main", "vc": "LogoutVC"])
                
                
                // NotificationCenter.default.post(name: NSNotification.Name(rawValue: "closeSideMenu"), object: nil)
                
                //  TaskHomeScreenViewController.logout = true
                
                //}
            }))
            parentController.present(alert, animated: true, completion: nil)
            
        }else{
            
            DispatchQueue.main.async {
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alert.view.tintColor = UIColor(named: "ButtonColor")
                alert.addAction(UIAlertAction(title: NSLocalizedString("Dismiss", comment: ""), style: .cancel, handler: nil))
                parentController.present(alert, animated: true, completion: nil)
            }
            
        }
        
    }
    
    
    func enableBtn(_ button: UIButton){
        button.isEnabled = true
        button.isUserInteractionEnabled = true
        button.backgroundColor = UIColor(named: "AccentColor")
        
    }
    
    func disableBtn(_ button: UIButton){
        button.isUserInteractionEnabled = false
        button.backgroundColor = UIColor(named: "DullGreen")
    }
        
    func setAttributedText(string: String, size: CGFloat, bold: Bool, alignment: NSTextAlignment, lineSpacing: CGFloat)-> NSAttributedString{
        
        var font: UIFont!
        
        if bold{
            font = UIFont(name: "Axiforma-SemiBold", size: size)
        }else{
            font = UIFont(name: "Axiforma-Regular", size: size)
        }
        
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.alignment = alignment
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font as Any,
            .paragraphStyle: paragraphStyle
        ]
        
        let str = NSLocalizedString(string, comment: "")
        return NSAttributedString(string: str, attributes: attributes)
        
    }
    
    func currencyFormation(number : Float)-> String{
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = Locale(identifier: "en_PK")
        return currencyFormatter.string(from: NSNumber(value: number))!
    }
    
    func configSideMenu(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.applyNavigation(_:)), name: NSNotification.Name(rawValue: "controllerDidTap"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.logout(_:)), name: NSNotification.Name(rawValue: "logoutDidTap"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.openHelp(_:)), name: NSNotification.Name(rawValue: "helpDidTap"), object: nil)
    }
    
    @objc func applyNavigation(_ notification:NSNotification){
        self.navigateToNextScreenAsRoot(notification.userInfo!["storyboard"] as! String, notification.userInfo!["vc"] as! String)
    }
    
    @objc func openHelp(_ notification:NSNotification){
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {[self] in
            let vc = CustomerSupport()
            vc.hidesBottomBarWhenPushed = true
            navigationController?.viewControllers = [vc]
            self.navigationController?.pushViewController(vc, animated: false)
        }
        
    }
    
    @objc func logout(_ notification:NSNotification){
        
        if(CheckInternet.Connection()){
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { // Change `2.0` to the desired number of seconds.
                self.navigateToNextScreen(notification.userInfo!["storyboard"] as! String, notification.userInfo!["vc"] as! String)
            }
        }else{
            self.presentAlert(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString( "Internet Not Available. Please check your internet connection and try again.", comment: ""), parentController: self)
        }
        
        
        
        
    }
    
    
    func textFieldLeftPadding(textFieldName: UITextField) {
        // Create a padding view
        textFieldName.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 3, height: textFieldName.frame.height))
        textFieldName.leftViewMode = .always//For left side padding
        textFieldName.rightViewMode = .always//For right side padding
    }
    
//Main HomeScreen Bottom TabBar inistiate
    func setTabBar(){
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.internetoffline(_:)), name: NSNotification.Name(rawValue: "checkInternetConnectionOffline"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.logout(_:)), name: NSNotification.Name(rawValue: "logoutDidTap"), object: nil)
        let vc = HomeContainer()
        vc.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(vc, animated: false)
        
    }
    
    func setupNavigationBar(){
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationController?.navigationBar.backItem?.hidesBackButton = true
        self.navigationController?.navigationBar.backgroundColor = .white
        self.navigationController?.navigationBar.isTranslucent = true
        
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        
        let backButton =  UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        backButton.setImage(UIImage(named: "blackBackButton"), for: .normal)
        backButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -15, bottom: 0, right: 0)
        backButton.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        let back = UIBarButtonItem(customView: backButton)
        self.navigationItem.leftBarButtonItems = [back]
        
        self.navigationController?.navigationBar.semanticContentAttribute = .forceLeftToRight
        
    }
    
    @objc func backAction(){
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
    
    @objc func internetoffline(_ notification: NSNotification) {
        DispatchQueue.main.async { [self] in
            showToast(message: "No Internet Connection", font: UIFont.boldSystemFont(ofSize: 22))
        }
    }
    //Line spacing between label text
    func setTextWithLineSpacing(label:UILabel,text:String,lineSpacing:CGFloat)
    {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        
        let attrString = NSMutableAttributedString(string: text)
        attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
        
        label.attributedText = attrString
    }
    //MARK: logging in to QB
//    func SignInQb(){
//        //MARK: Sign in to Quickblox
//        QBRTCClient.instance().add(self)
//        login(fullName: "Moody-Poster", login: UserDefaults.standard.string(forKey: DefaultsKeys.qb_login) ?? "")
//        setupToolbarButtonsEnabled(false)
//        voipRegistry.delegate = self
//        voipRegistry.desiredPushTypes = Set<PKPushType>([.voIP])
//    }
    
    
    func addSwipeGestures(){
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        leftSwipe.direction = .left
        rightSwipe.direction = .right
        self.view.addGestureRecognizer(leftSwipe)
        self.view.addGestureRecognizer(rightSwipe)
    }
    
    @objc func handleSwipes(_ sender:UISwipeGestureRecognizer) {
        if sender.direction == .left {
            self.tabBarController!.selectedIndex += 1
        }
        if sender.direction == .right {
            self.tabBarController!.selectedIndex -= 1
        }
    }
}

extension FileHandle : TextOutputStream {
    public func write(_ string: String) {
        guard let data = string.data(using: .utf8) else { return }
        self.write(data)
    }
}
