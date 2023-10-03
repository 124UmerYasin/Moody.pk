//
//  MessageCenter.swift
//  Moody_Posterv2.0
//
//  Created by Umer yasin on 01/09/2021.
//

import Foundation
import UIKit

extension ChatViewController {
    
    //MARK: Function to Store chat Messages Locally
    //. Method receives path of localfile and response of get conversastion
    //. From File path it checks if file does already exist
    //. If file exist it overwrites response on local file
    //. if file does not exist it creates new file in directory
    //. Searlised response and convert to json string to local directory file
    //. locallink sent to showchat to parse response
    func storeMessage(localLink:String,object:[String:Any]){
        fileManager = FileManager.default
        let dirPaths:NSArray = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        documentDir = dirPaths[0] as? NSString
        let path1 = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url1 = NSURL(fileURLWithPath: path1)
        
        if let pathComponent1 = url1.appendingPathComponent(localLink) {
            let filePath1 = pathComponent1.path
            let fileManager1 = FileManager.default
            //if file exist
            if fileManager1.fileExists(atPath: filePath1) {
                
                let jsonData = try! JSONSerialization.data(withJSONObject: object)
                let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)
                
                try? jsonString!.write(to: URL(fileURLWithPath: documentDir!.appendingPathComponent(localLink)), atomically: true, encoding: String.Encoding.utf8.rawValue)
                
            } else {
                self.filePath=documentDir?.appendingPathComponent(localLink) as NSString?
                self.fileManager?.createFile(atPath: filePath! as String, contents: nil, attributes: nil)
                let jsonData = try? JSONSerialization.data(withJSONObject: object, options: [])
                let jsonString = String(data: jsonData!, encoding: .utf8)
                
                try? jsonString!.write(to: URL(fileURLWithPath: documentDir!.appendingPathComponent(localLink)), atomically: true, encoding: String.Encoding.utf8)
            }
        }
        showChat(localLink: localLink)
    }
    //MARK: Shows chat from locally saved Messages
    //1. Checks if local file already exist
    //2. If file exist it fetch data from file and reponse is passed to parseResponse function
    //3. If file does not exist callMessages function call for getConversion api
    func showChat(localLink:String){
        addLoaderWhileFetching(flag: true)
        fileManager = FileManager.default
        let dirPaths:NSArray = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        documentDir = dirPaths[0] as? NSString
        let path1 = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url1 = NSURL(fileURLWithPath: path1)
        if let pathComponent1 = url1.appendingPathComponent(localLink) {
            let filePath1 = pathComponent1.path
            let fileManager1 = FileManager.default
            if fileManager1.fileExists(atPath: filePath1) {
                let imgData = try! String(contentsOf: URL(string: pathComponent1.absoluteString)!)
                let jsonDataa = imgData.data(using: .utf8)!
                let dictionary = try? JSONSerialization.jsonObject(with: jsonDataa , options: .mutableLeaves)
                let response = dictionary as! [String:Any]
                
                taskType = response["task_type"] as? String ?? ""
                taskStatus = response["task_status"] as? String ?? ""
                checkTaskStatus(response: response)
                
                if response["ticket_id"] != nil  {
                    ticketId = response["ticket_id"] as? String ?? ""
                }
                if response["current_fare_details"] != nil  {
                    
                    currentFare(response: response)
                }
                
                if response["tasker_details"] != nil {
                    taskerDetails(response: response)
                }
                if response["run_time_fare"] != nil  {
                    runTimeFare(response: response)
                }
                
                if response["dropoff_location"] != nil {
                    UserDefaults.standard.setValue(response["dropoff_location"] as? String ?? nil, forKey: DefaultsKeys.dropOffLocation)
                }else{
                    UserDefaults.standard.setValue(nil, forKey: DefaultsKeys.dropOffLocation)
                }
                if response["messages"] != nil {
                    let resp = response["messages"] as? [[String : Any]]
                    localMessagesArray = resp!
                    print("ShowChat parse called")
                    let serialQueue = DispatchQueue(label: "com.moodyPoster.mySerialQueue")
                    serialQueue.sync {
                        parseResponse(res: resp!)
                    }
                }
            }else{
                callMessages()
            }
            
        }
    }
    
    
    //MARK: Current Fare view shown
    //. Receives get conversion response
    //. current fare details stores to local userdefaults
    //. Current fare View is displayed
    func currentFare(response:[String:Any]){
        
        setCurrentFareDetails(response: response)
        if(ChatViewController.isFromActiveTask){
            DispatchQueue.main.async { [self] in
                currentFare.frame = CGRect(x: 0, y: (((UIScreen.main.bounds.height) -  messagesCollectionView.frame.height)) , width: UIScreen.main.bounds.width, height: 40)
                currentFare.backgroundColor = UIColor(named: "ButtonColor")!
                currentFare.setTitleColor(UIColor(named: "AppTextColor")!, for: .normal)
                currentFare.setTitle("Current Fare: \(response["run_time_fare"] as? String ?? "0.0")", for: .normal)
                currentFare.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
                if taskStatus == "assigned" && taskType != "top_up" {
                    self.view.addSubview(currentFare)
                    messagesCollectionView.bringSubviewToFront(currentFare)
                }
            }
        }
        
    }
    
    //MARK: Current Fare Details data saved to local Userfefaults
    //. current fare details data recieve in method and stored in userdefaults
    func setCurrentFareDetails(response:[String:Any]){
        
        let currentFareDetails = response["current_fare_details"] as? [String:Any]
        
        let baseFare = currentFareDetails?["base_fare"] as? Int
        let totalDistance = currentFareDetails?["total_distance"] as? String ?? "0.0"
        let totalTime = currentFareDetails?["total_time"] as? String
        let permin = currentFareDetails?["per_minute_rate"] as? Double
        let perkm = currentFareDetails?["per_km_rate"] as? Double
        
        UserDefaults.standard.setValue(baseFare, forKey: DefaultsKeys.basefare)
        UserDefaults.standard.setValue(totalDistance, forKey: DefaultsKeys.currentTotalDistance)
        UserDefaults.standard.setValue(totalTime, forKey: DefaultsKeys.totalTime)
        UserDefaults.standard.setValue(perkm, forKey: DefaultsKeys.ratePerKm)
        UserDefaults.standard.setValue(permin, forKey: DefaultsKeys.ratePerMin)
    }
    
    //MARK: taskerDetails are fetched from get conversion api
    //. tasker details stored in userdefaults
    //. View changes on basis of task status
    func taskerDetails(response:[String:Any]){
        
            let taskerDetails = response["tasker_details"] as! [String:Any]
            UserDefaults.standard.setValue(taskerDetails["qb_id"] as? Int ?? nil, forKey: DefaultsKeys.tasker_qb_id)
            UserDefaults.standard.setValue(taskerDetails["profile_picture"] as? String ?? "", forKey: DefaultsKeys.taskerProfileImage)
            UserDefaults.standard.setValue(taskerDetails["name"] as? String ?? nil, forKey: DefaultsKeys.taskerNameDetail)
            if(taskerDetails["name"] != nil)
            {
                if(taskerDetails["name"] as! String == ""){
                    DispatchQueue.main.async { [self] in
                        taskerName.text = NSLocalizedString("Finding Tasker", comment: "")
                        if(response["task_status"] as! String == "completed" || response["task_status"] as! String == "cancelled"){
                            taskCompleteOrCancelled()
                        }
                    }
                }else{
                    DispatchQueue.main.async { [self] in
                        if(response["task_status"] as! String == "completed" || response["task_status"] as! String == "cancelled"){
                            taskCompleteOrCancelled()
                            currentFare.isHidden = true
                        }else{
                            animationView.stop()
                            animationView.isHidden = true
                            let name = taskerDetails["name"] as? String
                            ChatViewController.riderName = name!
                            taskerName.text = name
                            let title = UIBarButtonItem(customView: titleStackView)
                            let back = UIBarButtonItem(customView: backButton)
                            self.navigationItem.leftBarButtonItems = [back,title]
                        }
                    }
                }
            }
        
    }
    
    
    //MARK: Post to Notification observer runTime fare data to which updates in chatViewController
    func runTimeFare(response:[String:Any]){
        
        var temp = [String:Any]()
        temp["run_time_fare"] = response["run_time_fare"] as? Double ?? 0.0
        if temp["run_time_fare"] as? Double ?? 0.0 > 0 {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "currentFare"), object: nil,userInfo: temp)
        }
    }
    
    
    //MARK: CheckTaskStatus get response in parameter and sets taskStatus
    func checkTaskStatus(response:[String:Any]){
        
        switch taskStatus {
        case "assigned":
            taskStatus = "assigned"
            taskerAssigned(response: response)
            break
        case "completed":
            taskStatus = "completed"
            break
        case "cancelled":
            taskStatus = "cancelled"
            break
        default:
            break
        }
    }
    
    //MARK: Tasker assigned status
    //1. pickupLocation sets to local userDefaults
    //2. calling buttons add
    func taskerAssigned(response:[String:Any]){
        
        response["pickup_location"] as? String != nil ? UserDefaults.standard.setValue(response["pickup_location"] as? String ?? "Not Found", forKey: DefaultsKeys.pickUpLocation) : whistleWebhook.sharedInstance.FoundNillWebhooks(Endpoint: ENDPOINTS.taskerAssigned, Key: "pickup_location")
        DispatchQueue.main.async { [self] in
            addCallButton()
        }
    }
    
    //MARK: View change of after Task ended
    func taskCompleteOrCancelled(){
        taskerName.text = NSLocalizedString("Chat History", comment: "")
        //taskerName.text = NSLocalizedString("Chat History", comment: "")
        taskerName.textColor = UIColor(named: "Green")
        taskerName.font = UIFont.boldSystemFont(ofSize: 16.0)
        let title = UIBarButtonItem(customView: taskerName)
        let back = UIBarButtonItem(customView: backButton)
        self.navigationItem.leftBarButtonItems = [back,title]
        self.navigationItem.rightBarButtonItems = []
    }
}
