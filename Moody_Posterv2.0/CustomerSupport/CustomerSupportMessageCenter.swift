//
//  CustomerSupportMessageCenter.swift
//  Moody_Posterv2.0
//
//  Created by Umer yasin on 13/09/2021.
//

import Foundation

extension CustomerSupport{
    
    //MARK: store messages json in local and check if already exist over write it.
    func storeMessageInLocal(localLink:String,object:[String:Any]){
        
        fileManager = FileManager.default
        let dirPaths:NSArray = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        documentDir = dirPaths[0] as? NSString
        let path1 = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url1 = NSURL(fileURLWithPath: path1)

        if let pathComponent1 = url1.appendingPathComponent(localLink) {
            let filePath1 = pathComponent1.path
            let fileManager1 = FileManager.default
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
        } else {
            //print("FILE PATH NOT AVAILABLE")
        }
        showChat(localLink: localLink)
    }
    
    // MARK: show chat from local
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
                let v = dictionary as! [String:Any]
                
                
                if(v["ticket_status"] as? String != nil){
                    ticketStatus = v["ticket_status"] as! String
                    if ticketStatus == "open"{
                        status = true
                    } else {
                        status = false
                    }
                    setTitleOfEndQueryBtn()
                }else{
                    whistleWebhook.sharedInstance.FoundNillWebhooks(Endpoint: ENDPOINTS.readTaskHistory, Key: "ticket_status")
                    addLoaderWhileFetching(flag: false)
                }
                
                if(v["ticket_id"] as? String != nil){
                    smallTicketId = v["ticket_id"] as! String
                    ticketIdForChat = smallTicketId
                    DispatchQueue.main.async {
                        self.setupNavigationBarBtn()
                    }
                }else{
                    whistleWebhook.sharedInstance.FoundNillWebhooks(Endpoint: ENDPOINTS.readTaskHistory, Key: "ticket_status")
                    addLoaderWhileFetching(flag: false)
                }
                if(v["messages"] as? [[String : Any]] != nil){
                    DispatchQueue.main.async { [self] in
                        messageList = v["messages"] as! [[String : Any]]
                        parseChatResponse(res: messageList)
                    }
                }else{
                    whistleWebhook.sharedInstance.FoundNillWebhooks(Endpoint: ENDPOINTS.readTaskHistory, Key: "messages")
                    addLoaderWhileFetching(flag: false)
                }
            }else{
                createQuery()
            }
          
        }
    }
    
    //MARK: Appends Sockets Message in chat
    //. functions gets socket data  and file link
    //. fetch data from file and seralize to json object 
    //. checks file and parse chat response
    func appendSocketMessageInChat(localLink:String,res: [String:Any]){
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
                let v = dictionary as? [String:Any]
                if v!["messages"] != nil {
                    var resp = v!["messages"] as? [[String : Any]]
                    resp?.append(res)
                    parseChatResponse(res: resp!)
                }
               createQuery()
            }
            
        }
    }
}
