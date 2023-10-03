//
//  API Manager.swift
//  Moody_Posterv2.0
//
//  Created by Syed Muhammad bin Saadat on 04/06/2021.
//

import Foundation
import UIKit
 
//MARK: All Status cases defined here
enum STATUSCODES:Int,Error {
    case SUCCESSFULL = 200
    case CREATED_SUCCESSFULLY = 201
    case BAD_REQUEST = 400
    case UNAUTHORIZED = 401
    case FORBIDDEN = 403
    case TOKEN_NOT_AUTHENTICATE = 402
    case RECORD_NOT_FOUND = 404
    case METHOD_NOT_ALLOWED = 405
    case INVALID_JSON = 406
    case NOT_AVAILABLE = 410
    case FAILED_REQUEST_SERVER = 418
    case TOO_MANY_REQUESTS = 429
    case INTERNAL_SERVER_ERROR = 500
    case SERVICE_UNAVAILABLE = 503
}

class ApiManager : NSObject,URLSessionTaskDelegate{
    
    
    static var sharedInstance = ApiManager()

    //MARK: Genric method to Create Request header for every network call
    //. recieves parameters to check request required token and body
    //. receives endpoint, httpmethod and dictronary to create header
    //. returns network call request header
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

    //MARK: Generic method Create Body data for every Network call
    //. ApiCaller recevies all parameters
    //. Parameters passes to setRequestHeader to create header of network call
    //. Response is fetched and searlised to JSon
    //. Response is passed in completion
    public func apiCaller(hasBodyData: Bool, hasToken: Bool, url: String, dictionary: [String:Any]? = nil, httpMethod: String, token:String? = nil, completion: @escaping (Result<[String:Any],CustomError>) -> Void) {
        Foundation.URLSession.shared.configuration.shouldUseExtendedBackgroundIdleMode = true
        Foundation.URLSession.shared.dataTask(with: setRequestHeader(hasBodyData: hasBodyData, hasToken: hasToken, endpoint: url, httpMethod: httpMethod, dictionary: dictionary, token: token)) { [self] (data, response, error) in
            guard let data = data, error == nil else{
                //whistleWebhook.sharedInstance.FoundNillWebhooks(Endpoint: url, Key: "\(error)")
                whistleWebhook.sharedInstance.APIFaliureWebhooks(Endpoint: url, response: "\(String(describing: error))", body: dictionary ?? [:])
                let error = CustomError(title: Strings.ERROR_MESSAGE, code: 500)
                completion(.failure(error))
                return
            }
            let httpresponse = response as? HTTPURLResponse
            let responseJSON:[String:Any]
            do{
                responseJSON = try JSONSerialization.jsonObject(with: data, options: []) as! [String : Any]
                if(httpresponse?.statusCode == STATUSCODES.SUCCESSFULL.rawValue || httpresponse?.statusCode == STATUSCODES.CREATED_SUCCESSFULLY.rawValue){
                    let responseData:[String:Any] = responseJSON["data"] as! [String : Any]
                    completion(.success(responseData))
                }
                else{
                    whistleWebhook.sharedInstance.APIFaliureWebhooks(Endpoint: url, response: "\(responseJSON)", body: dictionary ?? [:])

                    completion(.failure(errorHandler(httpresponse: httpresponse!, responseJSON: responseJSON)))
                }
            }catch{
                let error = CustomError(title: Strings.ERROR_MESSAGE, code: httpresponse!.statusCode)

                whistleWebhook.sharedInstance.APIFaliureWebhooks(Endpoint: url, response: "\(httpresponse!)", body: dictionary ?? [:])
                completion(.failure(error))
            }
        }.resume()
    }
    
    //MARK: API call to store application logs in Database
    // storeLogs Api is called on different events occuring in App (Success/Failure of Api)
    public func storeLogs(taskId: String, message: String,type:String,typee:String = "application"){
        var dict = [String:Any]()
        var log = [String:Any]()
        let messageToSend = "\(message)."
        log["message"] = messageToSend
        log["time"] = String(describing: Date())
        log["app_version"] = Constants.app_version
        log["device_info"] =  AppPermission.getDeviceInfo()
        log["type"] = typee
        log["protocol"] = SocketsManager.appProtocol
        if(type == "Poster_messages"){
            log["source"] = "Poster_messages"
        }else{
            log["source"] = "ios-poster"

        }
        dict["user_id"] = UserDefaults.standard.string(forKey: DefaultsKeys.posterId)
        dict["name"] = UserDefaults.standard.string(forKey: DefaultsKeys.name)
        dict["task_id"] = taskId
        dict["message"] = log
            apiCaller(hasBodyData: true, hasToken: true, url: ENDPOINTS.update_application_logs ,dictionary: dict, httpMethod: "POST",token: UserDefaults.standard.string(forKey: DefaultsKeys.token)!) {(result) in
                switch result {
                case .success(_):
                    break
                case .failure(let error):
                    print(error.title as Any)
                    break
                }
            }
        
    }
    
    //MARK: API call to store Video application logs in Database
    public func introVideoLog(message: String,type:String,typee:String = "IntroVideoDisplay"){
        var dict = [String:Any]()
        var log = [String:Any]()
        let messageToSend = "\(message)."
        log["message"] = messageToSend
        log["time"] = String(describing: Date())
        log["app_version"] = Constants.app_version
        log["device_info"] =  AppPermission.getDeviceInfo()
        log["type"] = typee
        log["protocol"] = SocketsManager.appProtocol
        log["source"] = "ios-poster"
        dict["user_id"] = UserDefaults.standard.string(forKey: DefaultsKeys.posterId)
        dict["name"] = UserDefaults.standard.string(forKey: DefaultsKeys.name)
        dict["message"] = log
            apiCaller(hasBodyData: true, hasToken: true, url: ENDPOINTS.save_user_logs ,dictionary: dict, httpMethod: "POST",token: UserDefaults.standard.string(forKey: DefaultsKeys.token)!) {(result) in
                switch result {
                case .success(_):
                    print("Success saveUserLog")
                    break
                case .failure(let error):
                    print("Failure saveUserLog")
                    print(error.title as Any)
                    break
                }
            }
        
    }
    
}

                            //MARK: URL Session Delegates 

//MARK: handling background api calling.
extension ApiManager : URLSessionDelegate {
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
               let completionHandler = appDelegate.backgroundSessionCompletionHandler {
                appDelegate.backgroundSessionCompletionHandler = nil
                completionHandler()
            }
        }
    }
}

//MARK: handling background api calling.
extension ApiManager : URLSessionDownloadDelegate{
    
  func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
   // print("Error in new :\(error?.localizedDescription ?? "")")
    if error?.localizedDescription == "The request timed out." {
        DispatchQueue.main.async {
        }
    }
      print("didCompleteWithError:\(error?.localizedDescription ?? "api caller didCompleteWithError")")

  }
    func URLSession(session: URLSession, didBecomeInvalidWithError error: NSError?) {
       // print("session error: \(error?.localizedDescription ?? "").")
        print("didBecomeInvalidWithError:\(error?.localizedDescription ?? "api caller didBecomeInvalidWithError")")

    }


  func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,didFinishDownloadingTo location: URL) {
    }

}
