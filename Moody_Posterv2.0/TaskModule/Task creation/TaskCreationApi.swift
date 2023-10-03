//
//  TaskCreationApi.swift
//  Moody_Posterv2.0
//
//  Created by Umer yasin on 04/06/2021.
//

import Foundation
import UIKit
import MessageKit


extension TaskCreationViewController{
    
    //MARK: Creates Task Dict values are set here
    func createTaskDictionar() -> [String:Any] {
        do{
            var dictionary = [String:Any]()
            let base64 = recorder.audioFilename!.absoluteURL
            let data = try Data(contentsOf:base64).base64EncodedString()
            var loc = LocationManagers.locationSharesInstance.getUpdatedLocation()
            
            if(loc.coordinate.latitude == 0.0 || loc.coordinate.longitude == 0.0){
                loc = LocationManagers.locationSharesInstance.getUpdatedLocation()
            }
            dictionary["audio_message"] = data
            dictionary["extension"] = "m4a"
            dictionary["poster_location"] = "\(loc.coordinate.latitude), \(loc.coordinate.longitude)"
            dictionary["lang"] = "en"
            dictionary["user_agent"] = AppPermission.getDeviceInfo()
            dictionary["platform"] = "ios"
            dictionary["app_type"] = "native"
            dictionary["app_version"] = "\(Constants.app_version)"
            
            return dictionary
        }catch let error{
            whistleWebhook.sharedInstance.APIFaliureWebhooksEmptyBody(Endpoint: "Create Dictionary catch block", response: "\(error.localizedDescription)", body: [:])
            return [String:Any]()
        }
    }
    
}
