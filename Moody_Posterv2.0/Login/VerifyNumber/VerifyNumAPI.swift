//
//  VerifyNumAPI.swift
//  Moody_Posterv2.0
//
//  Created by   on 04/06/2021.
//

import Foundation
import UIKit

extension VerifyNumber{
    
    //MARK: Dict preapred for VerifyOtp api call
    func createDictnory()-> [String: Any]{
        let dic = ["phone_number": RegisterNumber.number,
                   "role": Constants.role,
                   "otp": recivedCode,
                   "device_token": VerifyNumber.deveiceToken,
                   "platform": "ios",
                   "user_agent": AppPermission.getDeviceInfo(),
                   "app_version" : "\(Constants.app_version)"
        ]
        
        return dic as [String : Any]
    }
    
    //MARK: VerifyOtp api calls
    //. Onsucess response is passed to method verifySucess which stores constants in userdefaults and calls active taskApi]
    func verifyNumAPI(){
        
        activityLoader.startAnimating()
        disableBackBtn()
        ApiManager.sharedInstance.apiCaller(hasBodyData: true, hasToken: false, url: ENDPOINTS.verifyOTP, dictionary: createDictnory(), httpMethod: Constants.httpMethod) { [self] (result) in
            switch result{
            case .success(let response):
                DispatchQueue.main.async {
                    verifySuccess(response)
                    
                    let firstLogin = response["first_login"] as! Bool
                    DefaultsKeys.firstLogin = firstLogin
                    UserDefaults.standard.set(response["moody_ad"] as! String, forKey: DefaultsKeys.moody_intro_video)
                    DefaultsKeys.IntroVideo = true
                }
                break
            case .failure(let error):
                print("Error otp :\(error)")
                print("Error title :\(error.title)")

                DispatchQueue.main.async {
        
                    errorLabel.isHidden = false
                    errorLabel.text = NSLocalizedString(error.title, comment: "")
                    setViewBoader(.red)
                    invalidOTP = true
                    activityLoader.stopAnimating()
                    enableBackBtn()
                    clearFields()
                }
                break
            }
        }
        
    }
    
    func clearFields(){
        
        textField1.text = ""
        textField2.text = ""
        textField3.text = ""
        textField4.text = ""
        
    }
    
   
    
    func verifySuccess(_ data: [String: Any]){
    
        setUserDefaults(data)
        getActiveTask()
    }
    
    

//MARK: Api Call to get Active task running of loggedIn user
    func getActiveTask(){
        var dict = [String:Any]()
        dict["user_role"] = "is_poster"
        dict["user_agent"] = AppPermission.getDeviceInfo()
        dict["platform"] = "ios"
        
        ApiManager.sharedInstance.apiCaller(hasBodyData: true, hasToken: true, url: ENDPOINTS.get_active_task_details, dictionary: dict, httpMethod: "POST", token: UserDefaults.standard.string(forKey: DefaultsKeys.token)) { Result in
            switch Result{
            case .success(let response):
                DispatchQueue.main.async { [self] in
                    let task = response["task"] as! [String:Any]
                    if(task["_id"] != nil){
                        UserDefaults.standard.setValue(task["_id"] as! String, forKey: DefaultsKeys.taskId)
                    }
                    resetFields()
                    activityLoader.stopAnimating()
                    enableBackBtn()
                    getConstants()
                    navigateScreen()
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "recallNotifications"), object: nil)

                }
            case .failure(_):
                DispatchQueue.main.async { [self] in
                    resetFields()
                    activityLoader.stopAnimating()
                    enableBackBtn()
                    getConstants()
                   navigateScreen()
                }
            }
        }
    }
    
    
    //MARK: naviagtes to Next screen
    //. checks if user is loggin first time it navigates to UserInfo Screen else to IntroVideo Screen
    func navigateScreen() {
        if DefaultsKeys.firstLogin {
            navigateToNextScreen("Main", "UserInfo")
        }else{
            navigateToNextScreen("Main", "MoodyIntroVidoViewController")
        }
    }
    
    //MARK: Disables back button
    //. while api call backBtn gets disable
    func disableBackBtn(){
        
        navigationController?.navigationBar.isUserInteractionEnabled = false
        navigationController?.navigationBar.tintColor = UIColor.lightGray
    }
    
    //MARK: Enables back button
    //. after api call back button gets enable
    func enableBackBtn(){
        
        navigationController?.navigationBar.isUserInteractionEnabled = true
        navigationController?.navigationBar.tintColor = UIColor.black
    }
    
    
    //MARK: Constants Api Call
    //. response receives loggedIn users constants which are saved in local userdefaults
    func getConstants(){
        
        ApiManager.sharedInstance.apiCaller(hasBodyData: false, hasToken: true, url: ENDPOINTS.getConstants, httpMethod: Constants.httpMethod, token: UserDefaults.standard.string(forKey: DefaultsKeys.token)) {(result) in
            switch result{
            case .success(let response):
                self.setConstantsInUserDefaults(response: response)
                break
            case .failure(_):
                break
            }
        }
        
    }
    
    //MARK: Dict create to resend otp code Api
    func createDictnoryResend() -> [String : Any]{
        let dic =  ["phone_number": RegisterNumber.number ,
                    "role": Constants.role,
                    "user_agent" : AppPermission.getDeviceInfo(),
                    "platform" : "ios",
                    "app_version" : "\(Constants.app_version)"
        ]
        return dic as [String : Any]
    }
    
    //MARK: Sets constant api response in UserDefaults
    func setConstantsInUserDefaults(response: [String:Any]){
        
        
        response["phone_number"] as? String != nil ? UserDefaults.standard.setValue(response["phone_number"] as? String ?? "", forKey: DefaultsKeys.moody_phone_number) : whistleWebhook.sharedInstance.FoundNillWebhooks(Endpoint: ENDPOINTS.getConstants, Key: "phone_number")
        
        response["moody_charges"] as? Int != nil ? UserDefaults.standard.setValue(response["moody_charges"] as? Int ?? 0, forKey: DefaultsKeys.moody_charges) :whistleWebhook.sharedInstance.FoundNillWebhooks(Endpoint: ENDPOINTS.getConstants, Key: "moody_charges")
        
        response["minimum_amount_for_top_up"] as? Int != nil ? UserDefaults.standard.setValue(response["minimum_amount_for_top_up"] as? Int ?? 0, forKey: DefaultsKeys.minimum_amount_for_top_up) :whistleWebhook.sharedInstance.FoundNillWebhooks(Endpoint: ENDPOINTS.getConstants, Key: "minimum_amount_for_top_up")
        
        response["maximum_amount_for_top_up"] as? Int != nil ? UserDefaults.standard.setValue(response["maximum_amount_for_top_up"] as? Int ?? nil, forKey: DefaultsKeys.maximum_top_up_amount) :whistleWebhook.sharedInstance.FoundNillWebhooks(Endpoint: ENDPOINTS.getConstants, Key: "maximum_amount_for_top_up")
        
        response["minimum_balance_for_creating_task"] as? Int != nil ? UserDefaults.standard.setValue(response["minimum_balance_for_creating_task"] as? Int ?? 0, forKey: DefaultsKeys.minimum_balance_for_creating_task) :whistleWebhook.sharedInstance.FoundNillWebhooks(Endpoint: ENDPOINTS.getConstants, Key: "minimum_balance_for_creating_task")
        
        response["qb_app_id"] as? String != nil ? UserDefaults.standard.setValue(response["qb_app_id"] as? String ?? "", forKey: DefaultsKeys.qb_app_id) :whistleWebhook.sharedInstance.FoundNillWebhooks(Endpoint: ENDPOINTS.getConstants, Key: "qb_app_id")
        
        response["qb_account_key"] as? String != nil ? UserDefaults.standard.setValue(response["qb_account_key"] as? String ?? "", forKey: DefaultsKeys.qb_account_key) :whistleWebhook.sharedInstance.FoundNillWebhooks(Endpoint: ENDPOINTS.getConstants, Key: "qb_account_key")
        
        response["qb_auth_key"] as? String != nil ? UserDefaults.standard.setValue(response["qb_auth_key"] as? String ?? "", forKey: DefaultsKeys.qb_auth_key) :whistleWebhook.sharedInstance.FoundNillWebhooks(Endpoint: ENDPOINTS.getConstants, Key: "qb_auth_key")
        
        response["qb_auth_secret"] as? String != nil ? UserDefaults.standard.setValue(response["qb_auth_secret"] as? String ?? "", forKey: DefaultsKeys.qb_auth_secret) :whistleWebhook.sharedInstance.FoundNillWebhooks(Endpoint: ENDPOINTS.getConstants, Key: "qb_auth_secret")
    
        response["wallet_balance"] as? Int != nil ? UserDefaults.standard.setValue(response["wallet_balance"] as? Int ?? "", forKey: DefaultsKeys.wallet_balance) :whistleWebhook.sharedInstance.FoundNillWebhooks(Endpoint: ENDPOINTS.getConstants, Key: "wallet_balance")
        
        response["promo_balance"] as? Int != nil ? UserDefaults.standard.setValue(response["promo_balance"] as? Int ?? "", forKey: DefaultsKeys.promo_balance) :whistleWebhook.sharedInstance.FoundNillWebhooks(Endpoint: ENDPOINTS.getConstants, Key: "promo_balance")
        
        response["unread_ticket"] as? Bool != nil ? UserDefaults.standard.setValue(response["unread_ticket"] as? Bool ?? false, forKey: DefaultsKeys.helpBadge) :whistleWebhook.sharedInstance.FoundNillWebhooks(Endpoint: ENDPOINTS.getConstants, Key: "unread_ticket")
        
    }
    
    
    //MARK: Register number api
    //. Calls when resend otp is called
    func registerNumAPI(){
        
        activityLoader.startAnimating()
        disableBackBtn()
        ApiManager.sharedInstance.apiCaller(hasBodyData: true, hasToken: false, url: ENDPOINTS.createOTP, dictionary: createDictnoryResend(), httpMethod: Constants.httpMethod) { [self] (result) in
            switch result{
            case .success(let response):
                DispatchQueue.main.async {
                    resendSuccess(response)
                }
                break
            case .failure(let error):
                //printerror.title)
                DispatchQueue.main.async {
                    presentAlert(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString( error.title, comment: ""), parentController: self)
                    activityLoader.stopAnimating()
                    enableBackBtn()
                }
                break
            }
        }
        
    }
    
    
    //MARK: calls when RegisterNumber api gets success
    //. UI changes 
    func resendSuccess(_ data: [String: Any]){
        textField1.becomeFirstResponder()
        successLabel.isHidden = false
        errorLabel.isHidden = true
        setViewBoader( UIColor(named: "GreenColor")!)
        resendBtn.isHidden = true
        resetFields()
        configTimer()
        activityLoader.stopAnimating()
        enableBackBtn()
        
    }
}
