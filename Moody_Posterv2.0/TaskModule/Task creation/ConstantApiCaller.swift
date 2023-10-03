//
//  ConstantApiCaller.swift
//  Moody_Posterv2.0
//
//  Created by Umer yasin on 09/12/2021.
//

import Foundation
import UIKit
import SDWebImage

                            //MARK: URL Session Delegates For Api calling in background
extension TaskCreationViewController : URLSessionDelegate, URLSessionDownloadDelegate{
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async { [self] in
            if let completionHandler = backgroundSessionCompletionHandler {
                backgroundSessionCompletionHandler = nil
                completionHandler()
            }
        }
    }
    
    
    //MARK: Calls when there is error in Api call
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
      if error?.localizedDescription == "The request timed out." {
          DispatchQueue.main.async {
            whistleWebhook.sharedInstance.APIFaliureWebhooks(Endpoint: "get_Constants", response: "\(String(describing: error?.localizedDescription))", body: [:])
          }
      }

    }
    //MARK: Delgate calls with invalid api call
    private func URLSession(session: URLSession, didBecomeInvalidWithError error: NSError?) {
        whistleWebhook.sharedInstance.APIFaliureWebhooks(Endpoint: "get_Constants", response: "\(String(describing: error?.localizedDescription))", body: [:])
      }


    //MARK: Calls on api call finished
    //. response is parsed and sets to userdefaults
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,didFinishDownloadingTo location: URL) {
        do {
            let data = try Data(contentsOf: location)
            let statusCode = Int((downloadTask.response as? HTTPURLResponse)?.statusCode ?? 0)
            let responseJSON:[String:Any]
            do{
                responseJSON = try JSONSerialization.jsonObject(with: data, options: []) as! [String : Any]
                if(statusCode == STATUSCODES.SUCCESSFULL.rawValue || statusCode == STATUSCODES.CREATED_SUCCESSFULLY.rawValue){
                    let response:[String:Any] = responseJSON["data"] as! [String : Any]
                    setConstantsInUserDefaults(response: response)
                }else{
                    whistleWebhook.sharedInstance.APIFaliureWebhooks(Endpoint: "get_Constants", response: "\(responseJSON)", body: [:])

                }
            }catch{
                whistleWebhook.sharedInstance.APIFaliureWebhooks(Endpoint: "get_Constants", response: "error occur while parsing response", body: [:])

            }
        }catch {
            whistleWebhook.sharedInstance.APIFaliureWebhooks(Endpoint: "get_Constants", response: "Json error\(error.localizedDescription)", body: [:])

            print("Json error\(error.localizedDescription)")
        }
    }
    
    
    
    //MARK: Create Request header for network call
    func setRequestHeader(hasBodyData: Bool, hasToken: Bool, endpoint: String, httpMethod: String, dictionary: [String:Any]? = nil, token: String? = nil) -> URLRequest {
        
        URLCache.shared.removeAllCachedResponses()
        let url = URL(string: endpoint)!
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.setValue(Strings.APPLICATION_JSON, forHTTPHeaderField: Strings.CONTENT_TYPE)
        
        if hasToken{
            request.setValue(token ?? "", forHTTPHeaderField: "token")
        }
        if hasBodyData{
            let jsonData = try! JSONSerialization.data(withJSONObject: dictionary as Any, options: .prettyPrinted)
            request.httpBody = jsonData
        }
        return request
    }
    
    //MARK: Sets contants api response data in local userdefaults 
    func setConstantsInUserDefaults(response: [String:Any]){
        response["phone_number"] as? String != nil ? UserDefaults.standard.setValue(response["phone_number"] as? String ?? "", forKey: DefaultsKeys.moody_phone_number) : whistleWebhook.sharedInstance.FoundNillWebhooks(Endpoint: ENDPOINTS.getConstants, Key: "phone_number")
        
        response["moody_charges"] as? Int != nil ? UserDefaults.standard.setValue(response["moody_charges"] as? Int ?? 0, forKey: DefaultsKeys.moody_charges) :whistleWebhook.sharedInstance.FoundNillWebhooks(Endpoint: ENDPOINTS.getConstants, Key: "moody_charges")
        
        response["minimum_amount_for_top_up"] as? Int != nil ? UserDefaults.standard.setValue(response["minimum_amount_for_top_up"] as? Int ?? 0, forKey: DefaultsKeys.minimum_amount_for_top_up) :whistleWebhook.sharedInstance.FoundNillWebhooks(Endpoint: ENDPOINTS.getConstants, Key: "minimum_amount_for_top_up")
        
        response["maximum_amount_for_top_up"] as? Int != nil ? UserDefaults.standard.setValue(response["maximum_amount_for_top_up"] as? Int ?? nil, forKey: DefaultsKeys.maximum_top_up_amount) :whistleWebhook.sharedInstance.FoundNillWebhooks(Endpoint: ENDPOINTS.getConstants, Key: "maximum_amount_for_top_up")
        
        response["refresh_distance_kilometers"] as? Int != nil ? UserDefaults.standard.setValue(response["refresh_distance_kilometers"] as? Int ?? nil, forKey: DefaultsKeys.refresh_distance_kilometers) :whistleWebhook.sharedInstance.FoundNillWebhooks(Endpoint: ENDPOINTS.getConstants, Key: "refresh_distance_kilometers")
        
        response["refresh_distance_seconds"] as? Int != nil ? UserDefaults.standard.setValue(response["refresh_distance_seconds"] as? Int ?? nil, forKey: DefaultsKeys.refresh_distance_seconds) :whistleWebhook.sharedInstance.FoundNillWebhooks(Endpoint: ENDPOINTS.getConstants, Key: "refresh_distance_seconds")
        
        response["minimum_balance_for_creating_task"] as? Int != nil ? UserDefaults.standard.setValue(response["minimum_balance_for_creating_task"] as? Int ?? 0, forKey: DefaultsKeys.minimum_balance_for_creating_task) :whistleWebhook.sharedInstance.FoundNillWebhooks(Endpoint: ENDPOINTS.getConstants, Key: "minimum_balance_for_creating_task")
        
        response["qb_app_id"] as? String != nil ? UserDefaults.standard.setValue(response["qb_app_id"] as? String ?? "", forKey: DefaultsKeys.qb_app_id) :whistleWebhook.sharedInstance.FoundNillWebhooks(Endpoint: ENDPOINTS.getConstants, Key: "qb_app_id")
        
        response["qb_account_key"] as? String != nil ? UserDefaults.standard.setValue(response["qb_account_key"] as? String ?? "", forKey: DefaultsKeys.qb_account_key) :whistleWebhook.sharedInstance.FoundNillWebhooks(Endpoint: ENDPOINTS.getConstants, Key: "qb_account_key")
        
        response["qb_auth_key"] as? String != nil ? UserDefaults.standard.setValue(response["qb_auth_key"] as? String ?? "", forKey: DefaultsKeys.qb_auth_key) :whistleWebhook.sharedInstance.FoundNillWebhooks(Endpoint: ENDPOINTS.getConstants, Key: "qb_auth_key")
        
        response["qb_auth_secret"] as? String != nil ? UserDefaults.standard.setValue(response["qb_auth_secret"] as? String ?? "", forKey: DefaultsKeys.qb_auth_secret) :whistleWebhook.sharedInstance.FoundNillWebhooks(Endpoint: ENDPOINTS.getConstants, Key: "qb_auth_secret")
    
        
        response["wallet_balance"] as? Int != nil ? UserDefaults.standard.setValue(response["wallet_balance"] as? Int ?? "", forKey: DefaultsKeys.wallet_balance) :whistleWebhook.sharedInstance.FoundNillWebhooks(Endpoint: ENDPOINTS.getConstants, Key: "wallet_balance")
        
        
        response["promo_balance"] as? Int != nil ? UserDefaults.standard.setValue(response["promo_balance"] as? Int ?? "", forKey: DefaultsKeys.promo_balance) :whistleWebhook.sharedInstance.FoundNillWebhooks(Endpoint: ENDPOINTS.getConstants, Key: "promo_balance")
    
        
        response["unread_ticket"] as? Bool != nil ? UserDefaults.standard.setValue(response["unread_ticket"] as? Bool ?? false, forKey: DefaultsKeys.helpBadge) :whistleWebhook.sharedInstance.FoundNillWebhooks(Endpoint: ENDPOINTS.getConstants, Key: "unread_ticket")
        if(response["active_task_id"] as? String != "" && response["active_task_id"] as? String != nil){
            UserDefaults.standard.setValue(response["active_task_id"] as? String, forKey: DefaultsKeys.taskId)
        }
    }
}

