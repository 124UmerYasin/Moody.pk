//
//  UserInfoAPI.swift
//  Moody_Posterv2.0
//
//  Created by   on 04/06/2021.
//

import Foundation

extension UserInfo{
    
    //MARK: New Users enters its name here
    //. checks if name is valid
    //. calls update name api
    func updateName(){
        var dictionary = [String:Any]()
        
        guard let name = nameTextField.text else{return}
        
        if isVaildName(name){
            disableBtn(enterBtn)
            dictionary["name"] = nameTextField.text!
            updateNameAPICall(dictionary: dictionary)
            errorField.isHidden = true
            
        }else {
            enableBtn(enterBtn)
            enterBtn.isUserInteractionEnabled = true
            continueBtn.isUserInteractionEnabled = true
            presentAlert(title: NSLocalizedString("Invaild Name", comment: ""), message: NSLocalizedString("Please enter a vaild username", comment: ""), parentController: self)
        }
    }
    
    
    //MARK: Promo code entered
    //. if field is not and empty promocode api is called
    func enterPromoCode(){
        var dictionary = [String:Any]()
        guard let promoCode = promoCodeField.text else{return}
        
        if promoCode != ""{
            dictionary["invite_code"] = promoCodeField.text!
            validatePromoCode(dictionary: dictionary)
        }
    }
    
    //MARK: Updates name API call
    //. OnSuccess Ui changes (Label changes to respect to Promo Screen)
    func updateNameAPICall(dictionary : [String:Any]){
        activityLoader.isHidden = false
        activityLoader.startAnimating()

        ApiManager.sharedInstance.apiCaller(hasBodyData: true, hasToken: true, url: ENDPOINTS.updateUser, dictionary: dictionary, httpMethod: Constants.httpMethod, token: UserDefaults.standard.string(forKey: DefaultsKeys.token)) { [self] (result) in
            
            switch result {
            case .success(_):
    
                DispatchQueue.main.async {
                    UserDefaults.standard.set(nameTextField.text!, forKey: DefaultsKeys.name)
                    
                    screenLabel.text = "Enter Promo Code"
                    nameTextField.placeholder = "Enter promo code (Optional)"
                    
                    nameTextField.text = ""
                    activityLoader.stopAnimating()
                    activityLoader.isHidden = true
                    NameView.isHidden = true
                    let promoCode = promoCodeField.text
                    if(promoCode?.count ?? 0 > 4){
                        enableBtn(continueBtn)
                    }else{
                        disableBtn(continueBtn)
                    }
                    errorField.isHidden = true
                    isPromocode = true
                }
                break
            case .failure(let error):
                DispatchQueue.main.async {
                    continueBtn.isUserInteractionEnabled = true
                    presentAlert(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString(error.title, comment: ""), parentController: self)
                    activityLoader.stopAnimating()
                    activityLoader.isHidden = true
                    
                }
                break
            }
        }
    }
    
    //MARK: validatePromo code api call
    //. On success screen navigate to introVideo
    func validatePromoCode(dictionary : [String:Any]){
        activityLoader.isHidden = false
        activityLoader.startAnimating()

        ApiManager.sharedInstance.apiCaller(hasBodyData: true, hasToken: true, url: ENDPOINTS.validateInviteCode, dictionary: dictionary, httpMethod: Constants.httpMethod, token: UserDefaults.standard.string(forKey: DefaultsKeys.token)) { [self] (result) in
            
            switch result {
            case .success(_):
    
                DispatchQueue.main.async {
                    activityLoader.stopAnimating()
                    activityLoader.isHidden = true
                    enableBtn(continueBtn)
                    navigateToPromoVideo()
                }
                break
            case .failure(let error):
                DispatchQueue.main.async {
                    continueBtn.isUserInteractionEnabled = true
                    
                    if(error.code == 400){
                        presentAlert(title: NSLocalizedString("Error", comment: ""), message: "Invalid Invite Code", parentController: self)
                    }else{
                        presentAlert(title: NSLocalizedString("Error", comment: ""), message: error.title, parentController: self)
                    }
                   
                    activityLoader.stopAnimating()
                    activityLoader.isHidden = true
                    
                }
                break
            }
        }
    }
    
    //MARK: Navigation to IntroVideo Screen
    func navigateToPromoVideo(){
        navigateToNextScreen("Main", "MoodyIntroVidoViewController")
    }
    
    
}
