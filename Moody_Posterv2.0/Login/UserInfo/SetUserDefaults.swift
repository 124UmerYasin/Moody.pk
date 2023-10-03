//
//  SetUserDefaults.swift
//  Moody_Posterv2.0
//
//  Created by   on 04/06/2021.
//

import Foundation
import UIKit

extension VerifyNumber{
    
  //MARK: GetConstants api reponse is passed to method and stored in local userdefaults
  //. Seting esstentials value/Constants to userDefaults
    func setUserDefaults(_ data: [String: Any]){
        
        data["token"] as? String != nil ? UserDefaults.standard.set(data["token"] as? String ?? "", forKey: DefaultsKeys.token) : whistleWebhook.sharedInstance.FoundNillWebhooks(Endpoint: ENDPOINTS.verifyOTP, Key: "token")
        data["_id"] as? String != nil ? UserDefaults.standard.set(data["_id"] as? String ?? "", forKey: DefaultsKeys.posterId) : whistleWebhook.sharedInstance.FoundNillWebhooks(Endpoint: ENDPOINTS.verifyOTP, Key: "_id")
        data["name"] as? String != nil ? UserDefaults.standard.set(data["name"] as? String ?? "", forKey: DefaultsKeys.name) : whistleWebhook.sharedInstance.FoundNillWebhooks(Endpoint: ENDPOINTS.verifyOTP, Key: "name")
        data["phone_number"] as? String != nil ? UserDefaults.standard.set(data["phone_number"] as? String ?? "", forKey: DefaultsKeys.phone_number) : whistleWebhook.sharedInstance.FoundNillWebhooks(Endpoint: ENDPOINTS.verifyOTP, Key: "phone_number")
        data["wallet_balance"] as? Int != nil ? UserDefaults.standard.set(data["wallet_balance"] as? Int ?? 0, forKey: DefaultsKeys.wallet_balance) : whistleWebhook.sharedInstance.FoundNillWebhooks(Endpoint: ENDPOINTS.verifyOTP, Key: "wallet_balance")
        
        data["promo_balance"] as? Int != nil ? UserDefaults.standard.setValue(data["promo_balance"] as? Int ?? "", forKey: DefaultsKeys.promo_balance) :whistleWebhook.sharedInstance.FoundNillWebhooks(Endpoint: ENDPOINTS.getConstants, Key: "promo_balance")
        
        data["poster_rating"] as? Double != nil ? UserDefaults.standard.set(data["poster_rating"] as? Double ?? 0.0, forKey: DefaultsKeys.poster_rating) : whistleWebhook.sharedInstance.FoundNillWebhooks(Endpoint: ENDPOINTS.verifyOTP, Key: "poster_rating")
        
        data["invite_a_friend"] as? Bool != nil ? UserDefaults.standard.set(data["invite_a_friend"] as? Bool ?? false, forKey: DefaultsKeys.inviteFriend) : whistleWebhook.sharedInstance.FoundNillWebhooks(Endpoint: ENDPOINTS.verifyOTP, Key: "invite_a_friend")
        data["invite_code"] as? Int != nil ? UserDefaults.standard.set(data["invite_code"] as? Int ?? nil, forKey: DefaultsKeys.inviteCode) : whistleWebhook.sharedInstance.FoundNillWebhooks(Endpoint: ENDPOINTS.verifyOTP, Key: "invite_code")

        data["poster_locale"] != nil ?  setlanguage( data["poster_locale"] as! String) : whistleWebhook.sharedInstance.FoundNillWebhooks(Endpoint: ENDPOINTS.verifyOTP, Key: "lang")
        
        
        data["email"] as? String != "" ? UserDefaults.standard.set(data["email"] as? String ?? "", forKey: DefaultsKeys.email) : whistleWebhook.sharedInstance.FoundNillWebhooks(Endpoint: ENDPOINTS.verifyOTP, Key: "email")
        
        setProfilePicture(temp: data)

    }
    
    //MARK: Setting profile picture to user defaults.
    // . fetch profile picture path string and convert to data to store in userdefaults
    func setProfilePicture(temp: [String: Any]){

        temp["profile_picture_path"] as? String != nil ? UserDefaults.standard.set(temp["profile_picture_path"] as? String ?? "", forKey: DefaultsKeys.profile_picture) : whistleWebhook.sharedInstance.FoundNillWebhooks(Endpoint: ENDPOINTS.verifyOTP, Key: "profile_picture")

        let polo = temp["profile_picture_path"] as? String
        
        
        if(polo != ""){
            let link = URL(string: temp["profile_picture_path"] as! String)
            guard let data = try? Data(contentsOf:link!) else {
                return
            }
            UserDefaults.standard.set(data, forKey: DefaultsKeys.profile_picture)
            
        }
        else{
            UserDefaults.standard.set(UIImage(named: "person2")!.pngData(), forKey: DefaultsKeys.profile_picture)
        }

    }
    
    //MARK: Language of application is set in this method 
    //. lang is fetched from constants
    //. by checking app language is set
    func setlanguage(_ lang : String){
        
        if lang == "en"{
            Bundle.setLanguage("Base")
            UserDefaults.standard.setValue("Base", forKey: "language")
        }else{
            Bundle.setLanguage("ur-Arab-PK")
            UserDefaults.standard.setValue("ur-Arab-PK", forKey: "language")
        }
    }
}
