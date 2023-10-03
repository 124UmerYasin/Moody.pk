//
//  ChatApiCaller.swift
//  Moody_Posterv2.0
//
//  Created by Umer yasin on 01/11/2021.
//

import Foundation
import UIKit

//MARK: Extension created for handling URL Session api call in background
extension ChatViewController : URLSessionDelegate, URLSessionDownloadDelegate {
    
    
    //MARK: URL Session Delegates
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async {
            if let completionHandler = backgroundSessionCompletionHandler {
                backgroundSessionCompletionHandler = nil
                completionHandler()
            }
        }
    }
    
    
    //MARK:URL Session Delegate called on request time out
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
      if error?.localizedDescription == "The request timed out." {
          DispatchQueue.main.async {
            whistleWebhook.sharedInstance.APIFaliureWebhooks(Endpoint: "get_conversation", response: "\(String(describing: error?.localizedDescription))", body: [:])
          }
      }
    }
    
    //MARK:URL Session Delegate called on invalid api call
    private func URLSession(session: URLSession, didBecomeInvalidWithError error: NSError?) {
        whistleWebhook.sharedInstance.APIFaliureWebhooks(Endpoint: "get_conversation", response: "\(String(describing: error?.localizedDescription))", body: [:])
      }

    
    //MARK: URL Session call of getConversation Api
    //. Searlized JSON response
    //. Store response in Local file directory
    //. View changes in chat on basis of task status
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,didFinishDownloadingTo location: URL) {
        do {
            let data = try Data(contentsOf: location)            
            let statusCode = Int((downloadTask.response as? HTTPURLResponse)?.statusCode ?? 0)
            let responseJSON:[String:Any]
            do{
                responseJSON = try JSONSerialization.jsonObject(with: data, options: []) as! [String : Any]
                if(statusCode == STATUSCODES.SUCCESSFULL.rawValue || statusCode == STATUSCODES.CREATED_SUCCESSFULLY.rawValue){
                    let response:[String:Any] = responseJSON["data"] as! [String : Any]
                    let hideMessageView = response["send_message"] as? Bool ?? true
                    let resp = response["messages"] as? [[String : Any]]
                    StoreDataToLocalInBackground(response: response)
                    if(!hideMessageView){
                        HideMessageBar()
                    }
                    if(response["task_status"] as! String != "assigned" && response["task_status"] as! String != "cancelled" && response["task_status"] as! String != "completed" && response["task_status"] as! String != "due_payment"){
                        if(response["task_duration"] != nil){
                            if response["task_duration"] as? Int != 0 {
                                findingTaskerTimer(response: response)
                            }
                        }
                    }else{
                        DispatchQueue.main.async { [self] in
                            timerView.removeFromSuperview()
                            ChatViewController.stopTimer?.stopTimer()
                        }
                    }
                }else{
                    addLoaderWhileFetching(flag: false)
                    whistleWebhook.sharedInstance.APIFaliureWebhooks(Endpoint: "get_conversation", response: "\(responseJSON)", body: [:])
                }
            }catch{
                addLoaderWhileFetching(flag: false)
                whistleWebhook.sharedInstance.APIFaliureWebhooks(Endpoint: "get_conversation", response: "error occur while parsing response", body: [:])
            }
        }
        catch {
            print("Json error\(error.localizedDescription)")
        }
    }
    
    
    
    //MARK: Create Request header for every network call
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
       // request.cachePolicy = .reloadIgnoringLocalCacheData
        return request
    }

    
}
