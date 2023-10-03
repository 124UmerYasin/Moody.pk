//
//  whistleWebhook.sharedInstance.swift
//  Moody_Posterv2.0
//
//  Created by Syed Muhammad bin Saadat on 28/06/2021.
//

import Foundation
import UIKit


//MARK: Webhook class to sent on Whistle 
class whistleWebhook{
    
    static var sharedInstance = whistleWebhook()
    
    func errorLogsToWhistle(sendBodyData: [String:Any]){
            if let x = URL(string: Constants.webhookUrl){
                       var request = URLRequest(url: x)
                       request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                       request.httpMethod = "POST"
                       ///
                       ///
                       //
                       request.httpBody = sendBodyData.percentEncoded()

                       let task = URLSession.shared.dataTask(with: request) { data, response, error in
                           guard let _ = data,
                               let response = response as? HTTPURLResponse,
                               error == nil else {                                              // check for fundamental networking error
                               //print"error send crash report", error ?? "Unknown error")
                               return
                           }

                           guard (200 ... 299) ~= response.statusCode else {                    // check for http errors
                               //print"statusCode should be 2xx, but is \(response.statusCode)")
                               //print"response = \(response)")
                               return
                           }

                           UserDefaults.standard.setValue(nil, forKey: DefaultsKeys.errorReport)
                           
                       }

                       task.resume()
                   }
                   else{
                       print("Error on line 17 class whistleWebhook")
                   }
       
       }
    
    func FoundNillWebhooks(Endpoint: String, Key: String){
            
            let dict = ["device_name": UIDevice.current.name,
                                           "device-info": AppPermission.getDeviceInfo(),
                                           "Endpoint": "\(Endpoint)",
                                           "Key": "\(Key)",
                                           "Date": "\(Date())",
                                           "Application": "Moody Poster",
                                           "Version": Constants.app_version,
                                           "TaskId" : "\(UserDefaults.standard.string(forKey: DefaultsKeys.taskId) ?? "n/a")",
                                           "phone Number": "\(UserDefaults.standard.string(forKey: DefaultsKeys.phone_number) ?? "not found")",
                                           "user name": "\(UserDefaults.standard.string(forKey: DefaultsKeys.name) ?? "not found")",
                                           "phone Name": "\(UIDevice.current.name)"
                                           

                               ] as [String : Any]
            
            errorLogsToWhistle(sendBodyData: dict)
            
        }
     
    func APIFaliureWebhooks(Endpoint: String, response: String, body: [String:Any]){
        
        DispatchQueue.main.async{
            let netSpeed = NetworkSpeedTest()
            netSpeed.checkForSpeedTest() { [self] (netSpeed) in
                let dict = ["device_name": UIDevice.current.name,
                                               "device-info": AppPermission.getDeviceInfo(),
                                               "Endpoint": "\(Endpoint)",
                                               "Response": "\(response)",
                                               "Body Data": "\(body)",
                                               "Date": "\(Date())",
                                               "Application": "Moody Poster",
                                               "Version": Constants.app_version,
                                               "TaskId" : "\(UserDefaults.standard.string(forKey: DefaultsKeys.taskId) ?? "n/a")",
                                               "phone Number": "\(UserDefaults.standard.string(forKey: DefaultsKeys.phone_number) ?? "not found")",
                                               "user name": "\(UserDefaults.standard.string(forKey: DefaultsKeys.name) ?? "not found")",
                                               "phone Name": "\(UIDevice.current.name)",
                                               "Internet Speed": "\(netSpeed ?? "n/a")"

                                   ] as [String : Any]
                
                errorLogsToWhistle(sendBodyData: dict)
            }
        }
      
    }
    
    func APIFaliureWebhooksEmptyBody(Endpoint: String, response: String, body: [String:Any]){
        
        DispatchQueue.main.async{
            let netSpeed = NetworkSpeedTest()
            netSpeed.checkForSpeedTest() { (netSpeed) in
                let dict = ["device_name": UIDevice.current.name,
                                               "device-info": AppPermission.getDeviceInfo(),
                                               "Endpoint": "\(Endpoint)",
                                               "Response": "\(response)",
                                               "Body Data": "\(body)",
                                               "Date": "\(Date())",
                                               "Application": "Moody Poster",
                                               "Version": Constants.app_version,
                                               "TaskId" : "\(UserDefaults.standard.string(forKey: DefaultsKeys.taskId) ?? "n/a")",
                                               "phone Number": "\(UserDefaults.standard.string(forKey: DefaultsKeys.phone_number) ?? "not found")",
                                               "user name": "\(UserDefaults.standard.string(forKey: DefaultsKeys.name) ?? "not found")",
                                               "phone Name": "\(UIDevice.current.name)",
                                               "Internet Speed": "\(netSpeed ?? "n/a")"

                                   ] as [String : Any]
                
                let url = URL(string: Constants.webhookUrlEmpty)!
                var request = URLRequest(url: url)
                request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                request.httpMethod = "POST"

                request.httpBody = dict.percentEncoded()

                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    guard let _ = data,
                        let response = response as? HTTPURLResponse,
                        error == nil else {                                              // check for fundamental networking error
                        //print"error send crash report", error ?? "Unknown error")
                        return
                    }

                    guard (200 ... 299) ~= response.statusCode else {                    // check for http errors
                        //print"statusCode should be 2xx, but is \(response.statusCode)")
                        //print"response = \(response)")
                        return
                    }

                    UserDefaults.standard.setValue(nil, forKey: DefaultsKeys.errorReport)
                    
                }

                task.resume()
            }
        }
     
      
    }
    
}

extension Dictionary {
    func percentEncoded() -> Data? {
        return map { key, value in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
        }
        .joined(separator: "&")
        .data(using: .utf8)
    }
}

extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="

        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}
