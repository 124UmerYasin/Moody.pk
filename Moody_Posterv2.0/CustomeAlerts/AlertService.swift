//
//  AlertService.swift
//  Moody_IOS
//

import Foundation
import UIKit

//MARK: This class is for handling custom alerts in Application
class AlertService{
    
    //MARK: Alert shown when finishing the task or leaving help screen.
    func presentSimpleAlert( title: String, message: String, image: UIImage, yesBtnText: String, noBtnStr: String, complition: @escaping () -> Void)-> SimpelAlert{

        let customAlert = UIStoryboard(name: "CustomAlert", bundle: nil).instantiateViewController(withIdentifier: "SimpelAlert") as? SimpelAlert

        customAlert?.alertImage = image
        customAlert?.alertTitlee = title
        customAlert?.alertMessage = message
        customAlert?.yesBtnStr = yesBtnText
        customAlert?.noBtnStr = noBtnStr
        customAlert?.actionButton = complition
        
        return customAlert!
    }
    
    //MARK: Alert shown when Ongoing task is going and tried to logout
    func presentNotificationAlert() ->  NotificationAlert {
        
        let customAlert =  UIStoryboard(name: "CustomAlert", bundle: nil).instantiateViewController(withIdentifier: "NotificationAlert") as? NotificationAlert
        return customAlert!
        
    }
    
    //MARK: App update Alert shown only when new update available
    func presentUpdateAlert(complition: @escaping () -> Void) ->  UpdateAlert {
        
        let customAlert =  UIStoryboard(name: "CustomAlert", bundle: nil).instantiateViewController(withIdentifier: "UpdateAlert") as? UpdateAlert
        customAlert?.actionButton = complition
        return customAlert!
        
    }
    //MARK: Current Fare details Alert
    func presentFareCalculationsAlert() ->  FareCalculationsDetails {
        
        let customAlert =  UIStoryboard(name: "CustomAlert", bundle: nil).instantiateViewController(withIdentifier: "FareCalculationsDetails") as? FareCalculationsDetails
        return customAlert!
        
    }
    
    //MARK: EasyPaisa Alert on EsayPaisa Request 
    func presentEasyPaisaPayAlert() ->  EasyPaisaPayAlert {
        
        let customAlert =  UIStoryboard(name: "CustomAlert", bundle: nil).instantiateViewController(withIdentifier: "EasyPaisaPayAlert") as? EasyPaisaPayAlert
        return customAlert!
        
    }
}
