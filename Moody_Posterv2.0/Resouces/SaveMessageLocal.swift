//
//  SaveMessageLocal.swift
//  Moody_Posterv2.0
//
//  Created by Syed Mujtaba Hassan on 13/01/2022.
//

import Foundation

extension AppDelegate {
        
    func fetchFromLocalFile(localLink: String,data:[String:Any]){
        var localMessagesArray1 = [[String:Any]()]
        self.fileManager = FileManager.default
        let dirPaths:NSArray = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        self.documentDir = dirPaths[0] as? NSString
        let path1 = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url1 = NSURL(fileURLWithPath: path1)
        if let pathComponent1 = url1.appendingPathComponent("\(localLink).txt") {
            let filePath1 = pathComponent1.path
            let fileManager1 = FileManager.default
            if fileManager1.fileExists(atPath: filePath1) {
                let imgData = try! String(contentsOf: URL(string: pathComponent1.absoluteString)!)
                let jsonDataa = imgData.data(using: .utf8)!
                let dictionary = try? JSONSerialization.jsonObject(with: jsonDataa , options: .mutableLeaves)
                let response = dictionary as! [String:Any]
                if response["messages"] != nil {
                    
                    let resp = response["messages"] as? [[String : Any]]
                    localMessagesArray1 = resp!
                    
                    let dict = makeDictionaryForLocalStorage(messageType: data["message_type"] as! String, messageId: data["message_id"] as! String, role: data["role"]  as! String, textMessage: data["text_message"] as? String ?? "", index: 0, isNotified: false, messageTime: data["message_time"]  as! String, title: data["title"] as? String ?? "", taskID: data["task_id"]  as! String, attachment_path: data["attachment_path"]  as? String ?? "",location: data["poster_location"] as? String ?? "", details: data["details"] as? [String:Any] ?? [String:Any](), call_logs: data["call_logs"] as? String ?? "", rating: Int(data["rating"] as? Int ?? 0), fare_details: data["fare_details"] as? [String:Any] ?? [String:Any]())
                    
                    localMessagesArray1.append(dict)
                    UpdateMessageToLocal(localMessagesArray: localMessagesArray1, data: data)
                    
        
                
                }
                
            }
        }
    }
    
    
    //MARK: - return local message dictionary
    func makeDictionaryForLocalStorage(messageType:String,messageId:String,role:String,textMessage:String,index:Int,isNotified:Bool,messageTime:String,title:String,taskID:String,attachment_path:String,location:String,details:[String:Any],call_logs:String,rating:Int,fare_details:[String:Any]) -> [String:Any]{
        var dictionary = [String:Any]()
        dictionary["message_type"] = messageType
        dictionary["message_id"] = messageId
        dictionary["role"] = role
        dictionary["text_message"] = textMessage
        dictionary["index"] = 0
        dictionary["is_notified"] = false
        dictionary["message_time"] = messageTime
        dictionary["title"] = title
        dictionary["taskId"] = UserDefaults.standard.string(forKey:DefaultsKeys.taskId)
        dictionary["attachment_path"] = attachment_path
        dictionary["poster_location"] = location
        dictionary["details"] = details
        dictionary["call_logs"] = call_logs
        dictionary["rating"] = rating
        dictionary["fare_details"] = fare_details


        return dictionary
        
    }
    
    
    //MARK: - update message in local
    //- first get local message then update messages array then save back the messages in local
        func UpdateMessageToLocal(localMessagesArray: [[String:Any]], data: [String:Any]){
            let response = data
            self.fileManager = FileManager.default
            let dirPaths:NSArray = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
            self.documentDir = dirPaths[0] as? NSString
            let path1 = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
            let url1 = NSURL(fileURLWithPath: path1)
            if let pathComponent1 = url1.appendingPathComponent("\(response["task_id"] as! String).txt") {
                let filePath1 = pathComponent1.path
                let fileManager1 = FileManager.default
                if fileManager1.fileExists(atPath: filePath1) {
                    let imgData = try! String(contentsOf: URL(string: pathComponent1.absoluteString)!)
                    let jsonDataa = imgData.data(using: .utf8)!
                    let dictionary = try? JSONSerialization.jsonObject(with: jsonDataa , options: .mutableLeaves)
                    var v = dictionary as! [String:Any]
                    let resp = localMessagesArray
                    v.updateValue(resp, forKey: "messages")
                    let jsonData = try! JSONSerialization.data(withJSONObject: v)
                    let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)
                    try? jsonString!.write(to: URL(fileURLWithPath: (self.documentDir!.appendingPathComponent("\(response["task_id"] as! String).txt"))), atomically: true, encoding: String.Encoding.utf8.rawValue)
                }
            }
        }
}
