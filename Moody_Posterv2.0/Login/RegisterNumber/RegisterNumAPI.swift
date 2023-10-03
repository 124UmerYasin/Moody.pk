//
//  RegisterNumAPI.swift
//  Moody_Posterv2.0
//
//  Created by   on 04/06/2021.
//

import Foundation

extension RegisterNumber{
    
    //MARK: Dict is prepared for registerNumber
    func createDictnory() -> [String : Any]{
        if(number?.first != "0"){
            number = "+92" + number!
        }
        
        RegisterNumber.number = number
        let dic =  ["phone_number": number ,
                    "role": Constants.role,
                    "user_agent" : AppPermission.getDeviceInfo(),
                    "platform" : "ios",
                    "app_version" : "\(Constants.app_version)"
        ]
        
        return dic as [String : Any]
        
    }
    //MARK: Registering Number API calling
    //. On success of api ui chnages and navigate to OTP screen 
    func registerNumAPI(){
        activityLoader.startAnimating()
        ApiManager.sharedInstance.apiCaller(hasBodyData: true, hasToken: false, url: ENDPOINTS.createOTP, dictionary: createDictnory(), httpMethod: Constants.httpMethod) { [self] (result) in
            switch result{
            case .success(_):
                DispatchQueue.main.async {
                    termAndConditionText.isUserInteractionEnabled = true
                    activityLoader.stopAnimating()
                    enableBtn(continueBtn)
                    navigateToNextScreen("Main", "VerifyNumber")
                }
                break
            case .failure(let error):
                //printerror.title)
                DispatchQueue.main.async {
                    presentAlert(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString( error.title, comment: ""), parentController: self)
                    activityLoader.stopAnimating()
                    enableBtn(continueBtn)
                    termAndConditionText.isUserInteractionEnabled = true
                }
                break
            }
        }
        
    }
}
