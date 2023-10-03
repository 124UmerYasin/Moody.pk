//
//  FetchMessages.swift
//  Moody_Posterv2.0
//
//  Created by Umer yasin on 05/06/2021.
//

import Foundation
import UIKit
import ReplayKit
import MessageKit
import MobileCoreServices
import QuickLook
import CoreLocation
import SDWebImage

extension ChatViewController{
    
    //MARK: fetch messages from server and store in array messages of message type
    @objc func fetchMessages(_ notification:NSNotification){
        animationView.play()
        callMessages()
        
    }
    
    //MARK: Reconnects socket when app enters foregorund
    @objc func reconnectSocket(_ notification:NSNotification){
        SocketsManager.sharesInstance.establishSocketConnection()
        SocketsManager.sharesInstance.socket.setReconnecting(reason: "i was gone in background.")
        animationView.play()
    }
    
    
    //MARK: read conversation api calling in Background.
    func callMessages(){
        print("i am called. from call messages")
        addLoaderWhileFetching(flag: true)
        let req = setRequestHeader(hasBodyData: true, hasToken: true, endpoint: ENDPOINTS.get_conversation, httpMethod: "POST", dictionary: prepareDictionaryToFetchMessages(), token: UserDefaults.standard.string(forKey: DefaultsKeys.token))
        task = downloadsSession.downloadTask(with: req)
        task?.resume()
    }
    
    

    //MARK: Hiding Bottom message bar
    func HideMessageBar(){
        DispatchQueue.main.async {
            self.messageInputBar.isHidden = true
            self.dismissKeyboard()
        }
    }
    
    //MARK: FindingTasker Timer View
    //. When new task is created Finding tasker timer view is shown until tasker is assigned
    func findingTaskerTimer(response:[String:Any]){
        UserDefaults.standard.setValue(response["task_duration"], forKey: DefaultsKeys.arrivalTimeDuration)
        DispatchQueue.main.async { [self] in
            if timerView.isDescendant(of: self.view) {
            } else {
                messagesCollectionView.willRemoveSubview(timerView)
                self.view.willRemoveSubview(timerView)
                timerView.addSubview((Bundle(for: type(of: self)).loadNibNamed("assignTimerView", owner: self, options: nil)?.first as? UIView)!)
                timerView.frame = CGRect(x: 0, y: (((UIScreen.main.bounds.height) -  messagesCollectionView.frame.height)) , width: UIScreen.main.bounds.width, height: 40)
                self.view.addSubview(timerView)
                messagesCollectionView.bringSubviewToFront(timerView)
            }
        }
    }
    
        
    
    //MARK: prepare dictionary for get conversation api
    func prepareDictionaryToFetchMessages() -> [String:Any]{
        var dictionary = [String:Any]()
        dictionary["task_id"] = UserDefaults.standard.string(forKey:DefaultsKeys.taskId)
        dictionary["user_agent"] = AppPermission.getDeviceInfo()
        dictionary["platform"] = "ios"
        
        return dictionary
    }
    
    //MARK: Parse fetch Message Response and add in chat
    //1. Creating Directory in File Manager
    //2. Parsing Response By MessageType check
    //3. Setting Tasker Details to Qb Custom Struct
    //4. Refresh on Swipe
    func parseResponse(res: [[String:Any]]){
        let serialQueue = DispatchQueue(label: "com.moodyPoster.mySerialQueue")
        serialQueue.sync {
            fileManager = FileManager.default
            let dirPaths:NSArray = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
            documentDir = dirPaths[0] as? NSString
            let path1 = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
            let url1 = NSURL(fileURLWithPath: path1)
            if(res.first != nil){
                for resp in res {
                    messageId = resp["message_id"] as! String
                    if messagesDictionary[messageId] != nil {
                        
                    }else{
                        ParseMessageType(resp: resp,url1: url1)
                    }
                }
            }
            refreshOnSwipe()
        }
    
    }

    //MARK: Parse response of read conversation messages
    // . conversation api response is bring resceived
    // . On messageType each message is being parsed respectively
    func ParseMessageType(resp:[String:Any],url1:NSURL){
        let messageType =  resp["message_type"] as? String
        messagesDictionary["\(messageId)"] = "\(messageId)"
        
        switch messageType {
        case "fare_estimate":
            fareEstimate(resp: resp,messageId: messageId)
            break
        case "task_completed":
            messsageStatus(resp: resp,messageId: messageId)
            break
        case "task_cancelled":
            messsageStatus(resp: resp,messageId: messageId)
            break
        case "poster_receipt":
            posterReceipt(resp: resp,messageId: messageId)
            break
        case "poster_rating":
            posterRating(resp: resp, messageId: messageId)
            break
        case "text":
            textMessage(resp: resp,messageId: messageId)
            break
        case "audio":
            audioMessage(resp: resp,messageId: messageId)
            break
        case "image":
            imageMessage(resp: resp,messageId: messageId)
            break
        case "poster_location":
            posterLocation(resp: resp,messageId: messageId)
            break
        case "tasker_details":
            taskerDetails(resp: resp,messageId: messageId)
            break
        case "call_logs":
            setCallLogs(response: resp,messageId: messageId)
            break
        default:
            break
        }
    }
    
    
    //MARK: Refresh chat on swiping from top and bottom
    func refreshOnSwipe(){
        DispatchQueue.main.async { [self] in

            if refreshControl1.isRefreshing{
                self.refreshControl1.endRefreshing()
            }
            messagesCollectionView.refreshControl = refreshControl1
            addLoaderWhileFetching(flag: false)
        }
    }
    
    //MARK: call logs are parsed after any call activity in task
    //. Method is called when there is any activity releted to call
    //. recevies message id and get conversation api response
    //. Message id stored in static dict to avoid duplication
    //. Call log is shown in chat
    func setCallLogs(response:[String:Any], messageId:String){
        
        let callMessage = response["call_logs"] as? String ?? ""
        UserDefaults.standard.setValue(callMessage, forKey: DefaultsKeys.callLogMessage)
        DispatchQueue.main.async { [self] in
            deo.displayName = NSLocalizedString("\(" ")", comment: "")
          //  messagesDictionary["\(messageId)"] = "\(messageId)"
            messages.append((Messgae(sender: deo, messageId: "CallLogView-" + "\(callMessage)",sentDate: Date(), kind:.custom(CallLogViewScreen.self), downloadURL: "")))
            notifyBool.append(true)
            notifyStatus.append("sent")
            messagesTime.append("")
            reloadAfterSending()
            messagesCollectionView.scrollToLastItem()
        }
        
        UserDefaults.standard.setValue(nil, forKey: DefaultsKeys.taskIdInCall)
        let serialQueue = DispatchQueue(label: "com.moodyPoster.mySerialQueue")
        serialQueue.sync {
            makeDictionaryForLocalMessageStorage(messageType: "call_logs", messageId: messageId, role: "", textMessage: "", index: 0, isNotified: false, messageTime: "", title: "", taskID: UserDefaults.standard.string(forKey:DefaultsKeys.taskId)!, attachment_path: "", location: "", details: [String:Any](), call_logs: callMessage, rating: 0, fare_details: [String : Any]())
        }
    }
    
    //MARK: set TaskerDetails Qb details from socket
    func setTaskerQbDetails(userInfo:[String:Any]){

        let nameTasker = userInfo["name"] as! String
        let taskerId = userInfo["qb_id"] as? String ?? ""
        let taskerImageUrl = userInfo["image"] as! String
        let taskId = userInfo["task_id"] as! String
        
        setTaskerDetails(id: taskerId, name: nameTasker, imageUrl: taskerImageUrl, taskId: taskId)
    }
    

    
    //MARK: Parse poster Rating view. It is called when task is finsihed.
    //. recevies message id and conversation messages in response
    //. Message id stored in static dict to avoid duplication
    //. Poster Rating is shown and view changes in chat
    func posterRating(resp: [String:Any],messageId:String){
        
        DispatchQueue.main.async { [self] in
           // messagesDictionary["\(messageId)"] = "\(messageId)"
            makeButtonsNormal()
            optionsButton.isHidden = true
            taskerName.text = NSLocalizedString("Chat History", comment: "")
            taskerName.textColor = UIColor(named: "Green")
            taskerName.font = UIFont.boldSystemFont(ofSize: 16.0)
            let title = UIBarButtonItem(customView: taskerName)
            let back = UIBarButtonItem(customView: backButton)
            self.navigationItem.leftBarButtonItems = [back,title]
            self.navigationItem.rightBarButtonItems = []
            currentFare.isHidden = true
        
        }

        UserDefaults.standard.setValue(resp["attachment_path"] as! String, forKey: DefaultsKeys.feedBackAudio)
        ChatViewController.istaskfinisherOrNot = true
        if(resp["rating"] != nil){
            CustomRatingScreen.numberOfStars = Int(resp["rating"] as? Int ?? 0)
        }
        
        taskerQbClear()
        showRatingXib()
        showCloseBtn()
        
        let serialQueue = DispatchQueue(label: "com.moodyPoster.mySerialQueue")
        serialQueue.sync {
            makeDictionaryForLocalMessageStorage(messageType: "poster_rating", messageId: messageId, role: "", textMessage: "", index: 0, isNotified: false, messageTime: "", title: "", taskID: UserDefaults.standard.string(forKey:DefaultsKeys.taskId)!, attachment_path: "", location: "", details: [String:Any](), call_logs: "", rating: Int(resp["rating"] as? Int ?? 0), fare_details: [String : Any]())
        }
        
        
    }
    
    //MARK: Tasker qb data clear on task finish
    //. On Task end qb details of tasker is removed from our local array of tasker details in userdefaults
    //. On taskid tasker details is removed from array and array get updated
    func taskerQbClear(){
        let data = UserDefaults.standard.value(forKey: DefaultsKeys.taskerDetails) as? Data ?? nil
        let taskId = UserDefaults.standard.string(forKey: (DefaultsKeys.completedTaskId)) ??  UserDefaults.standard.string(forKey: DefaultsKeys.taskId)!
        
        if(data != nil){
            var taskerQb = try? PropertyListDecoder().decode(Array<TaskerQbDetails>.self, from: data!)
            var index = 0
            if(taskerQb!.count > 0){
                for arr in taskerQb! {
                    print("Task Id : \(arr.taskId)")
                    if arr.taskId == taskId {
                        taskerQb?.remove(at: index)
                       // ChatViewController.taskerDetails.remove(at: index)
                        print("Removed")
                        break
                    }
                    index = index + 1
                }
            }
            UserDefaults.standard.set(try? PropertyListEncoder().encode(taskerQb), forKey:DefaultsKeys.taskerDetails)
            
        }
    }
    
    //MARK: Parse poster receipt view from read conversation response
    //. recevies message id and conversation messages in response
    //. Message id stored in static dict to avoid duplication
    //. Recepit details fetched from response and stored in local userdefaults
    //. Recepit message is shown in chat
    func posterReceipt(resp: [String:Any],messageId:String){
        
        
        ChatViewController.showReceipt = true
        ChatViewController.istaskfinisherOrNot = true
        DispatchQueue.main.async { [self] in
            makeButtonsNormal()
            optionsButton.isHidden = true
        }
        setFareDetailsUserDefault(resp: resp)
        
        var title = ""
        if(resp["title"] != nil){
            title = resp["title"] as? String ?? ""
        }
        deo.displayName = NSLocalizedString("\(title)", comment: "")
        DispatchQueue.main.async { [self] in
           // messagesDictionary["\(messageId)"] = "\(messageId)"
            messages.append((Messgae(sender: deo, messageId: "rating",sentDate: Date(), kind:.custom(FareScreen.self), downloadURL: "")))
            notifyBool.append(true)
            notifyStatus.append("sent")
            messagesTime.append("")
            reloadAfterSending()
            messagesCollectionView.scrollToLastItem()
            
        }
        let serialQueue = DispatchQueue(label: "com.moodyPoster.mySerialQueue")
        serialQueue.sync {
            makeDictionaryForLocalMessageStorage(messageType: "poster_receipt", messageId: messageId, role: "", textMessage: "", index: 0, isNotified: false, messageTime: "", title: title, taskID: UserDefaults.standard.string(forKey:DefaultsKeys.taskId)!, attachment_path: "", location: "", details: [String:Any](), call_logs: "", rating: 0, fare_details: resp["fare_details"] as? [String:Any] ?? [String:Any]())
        }
        
    }
    
    //MARK: set receipt fareDetails of task in local userDefaults
    func setFareDetailsUserDefault(resp:[String:Any]){
        
        let fareDetails = resp["fare_details"] as? [String:Any]
        UserDefaults.standard.setValue(fareDetails?["base_fare"] as? Int, forKey: DefaultsKeys.baseFare)
        UserDefaults.standard.setValue(fareDetails?["total_time_taken2"] as? String, forKey: DefaultsKeys.timeTaken)
        UserDefaults.standard.setValue(fareDetails?["per_minute"] as? Double, forKey: DefaultsKeys.perMinuteRate)
        UserDefaults.standard.setValue(fareDetails!["discount"] as! String, forKey: DefaultsKeys.totalDiscount)
        UserDefaults.standard.setValue(fareDetails?["total_fare_after_discount"] as? Int, forKey: DefaultsKeys.fareAfterDiscount)
        UserDefaults.standard.setValue(fareDetails?["total_fare"] as? Int, forKey: DefaultsKeys.totalAmountPaid)
        UserDefaults.standard.setValue(fareDetails?["per_kilometer"] as? Double, forKey: DefaultsKeys.ratePerKm)
        UserDefaults.standard.setValue(fareDetails?["total_distance"] as? Double ?? 0.0, forKey: DefaultsKeys.totalDistance)
        UserDefaults.standard.setValue(fareDetails?["payable_amount"] as? Int ?? 0, forKey: DefaultsKeys.payableAmounts)

        
        let shoppingDetail = resp["task_product_receipts"] as? [String:Any]
        UserDefaults.standard.setValue(shoppingDetail, forKey: DefaultsKeys.shoppingDetails)
        
    }
    
    //MARK: Parse FareEstimate view
    func fareEstimate(resp: [String:Any], messageId:String){
        
       // messagesDictionary["\(messageId)"] = "\(messageId)"
        let estFare = (resp["estimated_fare"] as? Double)
        UserDefaults.standard.setValue(estFare, forKey: DefaultsKeys.estimateFare)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "estimateFare"), object: nil)
        
    }
    
    //MARK: Parse location view from read conversation response
    //. Method receieves response and message id
    //. Message id added in static dictonary to avoid duplication
    //. Lat long split from posterLocation received get conversation response
    //. Lat long convereted into CLLocation and location message shown in chat
    func posterLocation(resp: [String:Any],messageId:String){
      //  messagesDictionary["\(messageId)"] = "\(messageId)"
        var title = ""
        if(resp["title"] != nil){
            title = resp["title"] as? String ?? ""
        }
        let loc = "\(resp["poster_location"] as! String)"
        let latLongString = loc.components(separatedBy: ", ")
        
        let lat = latLongString[0]
        let long = latLongString[1]
        if let latitude =  Double(lat), let longitude = Double(long) {
            let coordinate:CLLocation = CLLocation(latitude: latitude, longitude: longitude)
            addlocationInChat(messageId: "\(resp["message_id"] as! String)", role: "\(resp["role"] as! String)", location: loc, index: 0, is_notified: resp["is_notified"] as! Bool, time: resp["message_time"] as! String, title: title)
        }
    }
    
    //MARK: Parse tasker details view from read conversation response
    //. TaskerDetails fetched from response and saved  in local userDefaults
    //. TaskerDetails view displayed on mainthread
    func taskerDetails(resp: [String:Any],messageId:String){
        var title = ""
        if(resp["title"] != nil){
            title = resp["title"] as? String ?? ""
        }
        deo.displayName = NSLocalizedString("\(title)", comment: "")
        
        if(resp["details"] as? [String:Any] != nil){
            let det = resp["details"] as! [String:Any]
            
            UserDefaults.standard.setValue(det["qb_id"] as? Int ?? nil, forKey: DefaultsKeys.tasker_qb_id)
            UserDefaults.standard.setValue(det["profile_picture"] as? String ?? "", forKey: DefaultsKeys.taskerProfileImage)
            UserDefaults.standard.setValue(det["vehicle_number"] as? String ?? "", forKey: DefaultsKeys.VehicleNumber)
            UserDefaults.standard.setValue(det["name"] as? String ?? nil, forKey: DefaultsKeys.taskerNameDetail)
            UserDefaults.standard.setValue(det["tasker_rating"] as? Double ?? 0.0, forKey: DefaultsKeys.RatingOfTasker)
            
            DispatchQueue.main.async { [self] in
                deo.displayName = NSLocalizedString("\(title)", comment: "")
               // messagesDictionary["\(messageId)"] = "\(messageId)"
                messages.append((Messgae(sender: deo, messageId: "TaskerDetailsView",sentDate: Date(), kind:.custom(TaskerDetailScreen.self), downloadURL: "")))
                notifyBool.append(true)
                notifyStatus.append("sent")
                messagesTime.append("")
                reloadAfterSending()
                messagesCollectionView.scrollToLastItem()
            }
            
            if(det["name"] != nil) {
                activeTaskStatus(taskerInfo: det)
            }
            
            let serialQueue = DispatchQueue(label: "com.moodyPoster.mySerialQueue")
            serialQueue.sync {
                makeDictionaryForLocalMessageStorage(messageType: "tasker_details", messageId: messageId, role: "", textMessage: "", index: 0, isNotified: false, messageTime: "", title: title, taskID: UserDefaults.standard.string(forKey:DefaultsKeys.taskId)!, attachment_path: "", location: "", details: det, call_logs: "", rating: 0, fare_details: [String : Any]())
            }
            
        }
        
    }
    
    //MARK: Rating View appends in chat screen
    func showRatingXib(){
        DispatchQueue.main.async { [self] in
            deo.displayName = NSLocalizedString("\("Task Rating")", comment: "")
            messages.append((Messgae(sender: deo, messageId: "receipt",sentDate: Date(), kind:.custom(CustomRatingScreen.self), downloadURL: "")))
            notifyBool.append(true)
            notifyStatus.append("sent")
            messagesTime.append("")
            reloadAfterSending()
            messagesCollectionView.scrollToLastItem()

        }
        
    }
    
    //MARK: On task end after rating close button is appended in chat screen
    func showCloseBtn(){
        
        DispatchQueue.main.async { [self] in
            deo.displayName = NSLocalizedString("\(" ")", comment: "")
            messages.append((Messgae(sender: deo, messageId: "closeView",sentDate: Date(), kind:.custom(CloseViewScreen.self), downloadURL: "")))
            notifyBool.append(true)
            notifyStatus.append("sent")
            messagesTime.append("")
            reloadAfterSending()
            messagesCollectionView.scrollToLastItem()
        }
    }
    
    //MARK: Appends image in chat
    //. attachment_path is fetched from response received in method
    //. MessageId is stored in dictinary to avoid dublication of messages
    //. Thumbnail of image is fetched from response thumbnail_attachment_path
    func imageMessage(resp: [String:Any],messageId:String){
        var title = ""
        var index = -1
        if(resp["title"] != nil){
            title = resp["title"] as? String ?? ""
        }
        
        let p = resp["attachment_path"] as? String
        if (p != nil){
            
            //imageStorageAndSendMessage(localLink: "\(resp["message_id"] as! String).png", messageID: "\(resp["message_id"] as! String)", type: "\(resp["role"] as! String)", is_notified: resp["is_notified"] as! Bool, time: resp["message_time"] as! String, imagePathLink: resp["attachment_path"] as! String, title: title)
            
            DispatchQueue.main.async { [self] in
               // messagesDictionary["\(messageId)"] = "\(messageId)"
                messagesDictionaryText.append("\(resp["thumbnail_attachment_path"] as? String ?? "img\(Date())" )")
                messages.append(Messgae(sender: checkSenderType(senderType: resp["role"] as! String, botTitle: title), messageId: "\(messageId)", sentDate: Date(), kind: .photo(Media(imageURL: URL(string: resp["thumbnail_attachment_path"] as? String ?? resp["attachment_path"] as! String)!, thumb: UIImage(named: "load")!, realImageUrl: resp["attachment_path"] as! String)), downloadURL: ""))
                    notifyBool.append(resp["is_notified"] as! Bool)
                    notifyStatus.append("sent")
                    messagesTime.append(resp["message_time"] as! String)
                    reloadAfterSending()
                messagesCollectionView.scrollToLastItem()
                index = messages.count - 1
                if( index != -1){
                        SDWebImageManager.shared.loadImage(with: URL(string: resp["thumbnail_attachment_path"] as? String ?? resp["attachment_path"] as! String), options: .highPriority, progress: nil) { (image, data, error, cacheType, isFinished, imageUrl) in
                            if error == nil {
                                messages[index] = Messgae(sender: checkSenderType(senderType: resp["role"] as! String, botTitle: title), messageId: resp["message_id"] as! String, sentDate: Date(), kind: .photo(Media(image: (UIImage(data: (data ?? image?.pngData())!))!, realImageUrl: resp["attachment_path"] as! String)), downloadURL: "")
                                notifyBool[index] = resp["is_notified"] as! Bool
                                notifyStatus[index] = "sent"
                                messagesTime[index] = resp["message_time"] as! String
                                let indexPath = IndexPath(row: 0, section: index)
                                    messagesCollectionView.reloadSections([indexPath.section,indexPath.section - 1])
                                addImageinChat(messageId: resp["message_id"] as! String, role: resp["role"] as! String, imagData: (data ?? image?.pngData())!, index: 0, is_notified: resp["is_notified"] as! Bool, time: resp["message_time"] as! String, title: title, resp: resp)
                            }
                           
                        }
                        
                }
                

            }
 
            
        }
        
    }
    
    //MARK: Text type Message is parsed here
    //. calls addTextMessage which appends message in chat
    func textMessage(resp: [String:Any],messageId:String){
        
       // messagesDictionary["\(messageId)"] = "\(messageId)"

        var title = ""
        if(resp["title"] != nil){
            title = resp["title"] as? String ?? ""
        }
        
        addTextMessage(messageId: "\(resp["message_id"] as! String)", role: "\(resp["role"] as! String)", textMessage: "\(resp["text_message"] as? String ?? "")", index: 0,is_notified: resp["is_notified"] as! Bool,time: resp["message_time"] as! String, title: title)
    }
    
    //MARK: Audio type Message is parsed here
    //. On basis of title audio is add in chat
    //. Tasker Assigned and request received audios are added from locally saved audios
    //. Rest are fetched link received in reponse
    //. calls audioMessage which appends audio in chat
    func audioMessage(resp: [String:Any],messageId:String){
      //  messagesDictionary["\(messageId)"] = "\(messageId)"
        
        var title = ""
        if(resp["title"] != nil){
            title = resp["title"] as? String ?? ""
        }
        if title.contains("Request Received") {
            let url = Bundle.main.url(forResource: "request_received", withExtension: "mp3")!
            addAudioMessageinChat(messageId: resp["message_id"] as! String, role: resp["role"] as! String, audioLink: "\(url)", index: 0,is_notified: resp["is_notified"] as! Bool,time: resp["message_time"] as! String, title: title)

        }else if title.contains("Tasker Assigned") {
            print("mushi audio")
            let url = Bundle.main.url(forResource: "tasker_assigned", withExtension: "mp3")!
            addAudioMessageinChat(messageId: resp["message_id"] as! String, role: resp["role"] as! String, audioLink: "\(url)", index: 0,is_notified: resp["is_notified"] as! Bool,time: resp["message_time"] as! String, title: title)

        }else{
            addAudioMessageinChat(messageId: resp["message_id"] as! String, role: resp["role"] as! String, audioLink: resp["attachment_path"] as! String, index: 0,is_notified: resp["is_notified"] as! Bool,time: resp["message_time"] as! String, title: title)
        }
        //fileStorageAndSendMessage(localLink: "\(resp["message_id"] as! String)bj.mp3", messageID: "\(resp["message_id"] as! String)", type: "\(resp["role"] as! String)",is_notified: resp["is_notified"] as! Bool,time: resp["message_time"] as! String, title: title, audioLinkPath: resp["attachment_path"] as! String)
       

    }
    
    //MARK: Parse message status view from read conversation response
    func messsageStatus(resp: [String:Any],messageId:String){
        
        let taskStatus = (resp["text_message"] as? String)
        let taskTitle =  (resp["title"] as? String)
        if taskStatus != nil {
            UserDefaults.standard.setValue(taskStatus, forKey: DefaultsKeys.taskStatusMessage)
        }else{
            UserDefaults.standard.setValue(taskTitle, forKey: DefaultsKeys.taskStatusMessage)
        }
        
        DispatchQueue.main.async { [self] in
            
            deo.displayName = NSLocalizedString("\(" ")", comment: "")
           // messagesDictionary["\(messageId)"] = "\(messageId)"
            messages.append((Messgae(sender: deo, messageId: "TaskStatusScreen",sentDate: Date(), kind:.custom(TaskStatusScreen.self), downloadURL: "")))
            notifyBool.append(true)
            notifyStatus.append("sent")
            messagesTime.append("")
            reloadAfterSending()
            messagesCollectionView.scrollToLastItem()
        }
        let serialQueue = DispatchQueue(label: "com.moodyPoster.mySerialQueue")
        serialQueue.sync {
            if resp["message_type"] as? String == "task_cancelled" {
                makeDictionaryForLocalMessageStorage(messageType: "task_cancelled", messageId: messageId, role: "", textMessage: taskStatus ?? "Not Found", index: 0, isNotified: false, messageTime: "", title: taskTitle ?? "Not Found", taskID: UserDefaults.standard.string(forKey:DefaultsKeys.taskId)!, attachment_path: "", location: "", details: [String : Any](), call_logs: "", rating: 0, fare_details: [String : Any]())

            } else if resp["message_type"] as? String == "task_completed" {
                makeDictionaryForLocalMessageStorage(messageType: "task_completed", messageId: messageId, role: "", textMessage: taskStatus ?? "Not Found", index: 0, isNotified: false, messageTime: "", title: taskTitle ?? "Not Found", taskID: UserDefaults.standard.string(forKey:DefaultsKeys.taskId)!, attachment_path: "", location: "", details: [String : Any](), call_logs: "", rating: 0, fare_details: [String : Any]())

            }
        }
    }
    
    //MARK: Sets tasker QbDetails when task is accepted
    //. details are saved in array of userdefaults
    func setTaskerDetails(id:String, name:String, imageUrl:String, taskId : String ){
        
        var qbFlag: Bool = false
        let obj = TaskerQbDetails(id: id, imageUrl: imageUrl, name: name, taskID: taskId)
        
        taskerDetails1.append(obj)
        
        guard let data = UserDefaults.standard.value(forKey: DefaultsKeys.taskerDetails) as? Data else {
            UserDefaults.standard.set(try? PropertyListEncoder().encode(taskerDetails1), forKey:DefaultsKeys.taskerDetails)
            return
        }
        
        var taskerQb = try? PropertyListDecoder().decode(Array<TaskerQbDetails>.self, from: data)
        
        for i in taskerQb! {
            if(i.taskId == taskId){
                qbFlag = true
            }
        }
        if(!qbFlag){
            taskerQb?.append(obj)
            UserDefaults.standard.set(try? PropertyListEncoder().encode(taskerQb), forKey:DefaultsKeys.taskerDetails)
        }
    }
    
    //MARK: download audio in local if found then show else download and save to local then show.
    func fileStorageAndSendMessage(localLink:String,messageID:String,type:String,is_notified:Bool,time:String,title:String,audioLinkPath:String){
        
        fileManager = FileManager.default
        let dirPaths:NSArray = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        documentDir = dirPaths[0] as? NSString
        let path1 = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url1 = NSURL(fileURLWithPath: path1)
        
        if let pathComponent1 = url1.appendingPathComponent(localLink) {
            let filePath1 = pathComponent1.path
            let fileManager1 = FileManager.default
            if fileManager1.fileExists(atPath: filePath1) {
                addAudioMessageinChat(messageId: "\(messageID)", role: type, audioLink: pathComponent1.absoluteString, index: 0,is_notified: is_notified,time: time, title: title)
            } else {
                let link = URL(string: audioLinkPath)
                guard let data = try? Data(contentsOf: link!) else{
                    return
                }
                saveToLocalStorage(localPath: localLink, base64Data: data.base64EncodedString())
                addAudioMessageinChat(messageId: "\(messageID)", role: type, audioLink: pathComponent1.absoluteString, index: 0,is_notified: is_notified,time: time, title: title)
            }
        } else {
            //print("FILE PATH NOT AVAILABLE")
        }
    }
    
    //MARK: Save  audio File to Local Storage
    func saveToLocalStorage(localPath:String,base64Data:String){
        
        self.filePath=documentDir?.appendingPathComponent(localPath) as NSString?
        self.fileManager?.createFile(atPath: filePath! as String, contents: nil, attributes: nil)
        let decodedData = Data(base64Encoded: base64Data)
        let content: Data = decodedData!
        let fileContent: Data = content
        try? fileContent.write(to: URL(fileURLWithPath: documentDir!.appendingPathComponent(localPath)), options: [.atomicWrite])
        
        
    }
    
    //MARK: download image in local if found then show else download and save to local then show.
    func imageStorageAndSendMessage(localLink:String,messageID:String,type:String,is_notified:Bool,time:String,imagePathLink:String,title:String){
        
        fileManager = FileManager.default
        let dirPaths:NSArray = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        documentDir = dirPaths[0] as? NSString
        let path1 = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url1 = NSURL(fileURLWithPath: path1)
        
        if let pathComponent1 = url1.appendingPathComponent(localLink) {
            let filePath1 = pathComponent1.path
            let fileManager1 = FileManager.default
            if fileManager1.fileExists(atPath: filePath1) {
                do{
                    let imgData = try! Data(contentsOf: URL(string: pathComponent1.absoluteString)!)
                    addImageinChat(messageId: messageID, role: type, imagData: imgData, index: 0,is_notified:is_notified,time: time, title: title, resp: [String : Any]())
                    
                }
            } else {
                let link = URL(string: imagePathLink)
                guard let data = try? Data(contentsOf: link!) else{
                    return
                }
                saveImageToLocalStorage(localPath: localLink, base64Data: data)
                addImageinChat(messageId: messageID, role: type, imagData: data, index: 0,is_notified:is_notified,time: time, title: title, resp: [String : Any]())
            }
        } else {
            //print("FILE PATH NOT AVAILABLE")
        }
    }
    //MARK: Save  image File to Local Storage
    func saveImageToLocalStorage(localPath:String,base64Data:Data){
        
        self.filePath=documentDir?.appendingPathComponent(localPath) as NSString?
        self.fileManager?.createFile(atPath: filePath! as String, contents: nil, attributes: nil)
        let decodedData = base64Data
        let content: Data = decodedData
        let fileContent: Data = content
        try? fileContent.write(to: URL(fileURLWithPath: documentDir!.appendingPathComponent(localPath)), options: [.atomicWrite])
        
        
    }
    
    
    //MARK: This function determine and return the send type
    func checkSenderType(senderType:String,botTitle:String) -> SenderType{
        
        if(senderType == "is_poster"){
            return currentUser
        }else if(senderType == "is_tasker") && botTitle != ""{
            otherUser.displayName = NSLocalizedString("\(botTitle)", comment: "")
            return otherUser
        }else if(senderType == "is_tasker") && botTitle == ""{
            otherUser.displayName = NSLocalizedString("Tasker", comment: "")
            return otherUser
        }else{
            if(botTitle != ""){
                deo.displayName = NSLocalizedString("\(botTitle)", comment: "")
            }else{
                deo.displayName = NSLocalizedString("Moody Support", comment: "")
                
            }
            return deo
        }
    }

    //MARK:add audioMessage in the chat
    //. Message id is received which is saved in dict to avoid duplication in messages
    //. audio link is recevied
    //. message index is received to keep record postion of message
    //. other useful parameters are received to append text message in chat
    //. onBackground local file also get updated
    func addAudioMessageinChat(messageId:String,role:String,audioLink:String,index:Int,is_notified:Bool,time:String,title:String){
        DispatchQueue.main.async { [self] in
            //messagesDictionary["\(messageId)"] = "\(messageId)"
            messagesDictionaryText.append("\(audioLink)")
            if(index != 0){
                messagesDictionary["\(messageId)"] = "\(messageId)"
                messages[index] = Messgae(sender: checkSenderType(senderType: role, botTitle: title), messageId: "\(messageId)", sentDate: Date(), kind: .audio(audio(url: URL(string: audioLink)!)),downloadURL: "")
                notifyBool[index] = is_notified
                notifyStatus[index] = "sent"
                messagesTime[index] = time
                let indexPath = IndexPath(row: 0, section: index)
                messagesCollectionView.reloadItems(at: [indexPath])
                refreshOnSwipe()
            } else {
                messages.append(Messgae(sender: checkSenderType(senderType: role, botTitle: title), messageId: "\(messageId)", sentDate: Date(), kind: .audio(audio(url: URL(string: audioLink)!)),downloadURL: ""))
                notifyBool.append(is_notified)
                notifyStatus.append("sent")
                messagesTime.append(time)
                reloadAfterSending()
                
            }
            messagesCollectionView.scrollToLastItem()
            
            let serialQueue = DispatchQueue(label: "com.moodyPoster.mySerialQueue")
            serialQueue.sync {
                makeDictionaryForLocalMessageStorage(messageType: "audio", messageId: messageId, role: role, textMessage: "", index: 0, isNotified: false, messageTime: time, title: title, taskID: UserDefaults.standard.string(forKey:DefaultsKeys.taskId)!, attachment_path: audioLink, location: "", details: [String : Any](), call_logs: "", rating: 0, fare_details: [String : Any]())
            }
//            DispatchQueue.global().async {
//                makeDictionaryForLocalMessageStorage(messageType: "audio", messageId: messageId, role: role, textMessage: "", index: 0, isNotified: false, messageTime: time, title: title, taskID: UserDefaults.standard.string(forKey:DefaultsKeys.taskId)!, attachment_path: audioLink)
//            }
        }
    }
    
    //MARK: check task status and sets name of tasker on top
    func activeTaskStatus(taskerInfo: [String:Any]){
           
               if(taskerInfo["name"] as! String == ""){
                   DispatchQueue.main.async { [self] in
                       taskerName.text = NSLocalizedString("Finding Tasker", comment: "")
                       if(taskStatus == "completed" || taskStatus == "cancelled"){
                           taskCompleteOrCancelled()
                       }
                   }
               }else{
                   DispatchQueue.main.async { [self] in
                       if(taskStatus == "completed" || taskStatus == "cancelled"){
                           taskCompleteOrCancelled()
                           currentFare.isHidden = true
                       }else{

                           animationView.stop()
                           animationView.isHidden = true
                           addCallButton()
                           let name = taskerInfo["name"] as? String
                           ChatViewController.riderName = name!
                           taskerName.text = name
                           let title = UIBarButtonItem(customView: titleStackView)
                           let back = UIBarButtonItem(customView: backButton)
                           self.navigationItem.leftBarButtonItems = [back,title]
                           
                       }
                   }
               }
       }

    
    //MARK: Storing data in Background
    func StoreDataToLocalInBackground(response:[String:Any]){
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.storeMessage(localLink: "\(UserDefaults.standard.string(forKey: DefaultsKeys.taskId) ?? "po").txt", object: response)
         }
    }
    
    //MARK:add textMessage in the chat
    //. This method receives all details of message and parse text message from get conversation api / sokcet
    //. Message id is received which is saved in dict to avoid duplication in messages
    //. Text string is received to append in chat
    //. message index is received to keep record postion and status(sent/unsent) of message
    //. other useful parameters are received to append text message in chat
    //. add message to local file
    func addTextMessage(messageId:String,role:String,textMessage:String,index:Int,is_notified:Bool,time:String,title:String){

        DispatchQueue.main.async { [self] in
           // messagesDictionary["\(messageId)"] = "\(messageId)"
            messagesDictionaryText.append("\(textMessage)")
            if(index != 0){
                messagesDictionary["\(messageId)"] = "\(messageId)"
                self.messages[index] = Messgae(sender: self.checkSenderType(senderType: role, botTitle: title) as! SenderType, messageId: "\(messageId)", sentDate: Date(), kind: .text("\(String(describing: textMessage))"), downloadURL: "")
                self.messagesTime[index] = time
                self.notifyBool[index] = is_notified
                self.notifyStatus[index] = "sent"
                let indexPath = IndexPath(row: 0, section: index)
                self.messagesCollectionView.reloadItems(at: [indexPath])
                refreshOnSwipe()
                
            }else{
                self.messages.append(Messgae(sender: self.checkSenderType(senderType: role, botTitle: title) as! SenderType, messageId: "\(messageId)", sentDate: Date(), kind: .text("\(String(describing: textMessage))"), downloadURL: ""))
                self.notifyBool.append(is_notified)
                self.notifyStatus.append("sent")
                self.messagesTime.append(time)
                self.reloadAfterSending()
            }
            self.messagesCollectionView.scrollToLastItem()
        }
        
        let serialQueue = DispatchQueue(label: "com.moodyPoster.mySerialQueue")
        serialQueue.sync {
            makeDictionaryForLocalMessageStorage(messageType: "text", messageId: messageId, role: role, textMessage: textMessage, index: 0, isNotified: false, messageTime: time, title: title, taskID: UserDefaults.standard.string(forKey:DefaultsKeys.taskId)!, attachment_path: "", location: "", details: [String : Any](), call_logs: "", rating: 0, fare_details: [String : Any]())
        }
//        DispatchQueue.global().async { [self] in
//            makeDictionaryForLocalMessageStorage(messageType: "text", messageId: messageId, role: role, textMessage: textMessage, index: 0, isNotified: false, messageTime: time, title: title, taskID: UserDefaults.standard.string(forKey:DefaultsKeys.taskId)!, attachment_path: "")
//        }
    }
    
    //MARK: - return local message dictionary
    func makeDictionaryForLocalMessageStorage(messageType:String,messageId:String,role:String,textMessage:String,index:Int,isNotified:Bool,messageTime:String,title:String,taskID:String,attachment_path:String,location:String,details:[String:Any],call_logs:String,rating:Int,fare_details:[String:Any]){
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

        
        localMessagesArray.append(dictionary)
        UpdateMessageToLocal()
    }
    
    //MARK: - update message in local
    // - first get local message then update messages array then save back the messages in local
    func UpdateMessageToLocal(){
        self.fileManager = FileManager.default
        let dirPaths:NSArray = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        self.documentDir = dirPaths[0] as? NSString
        let path1 = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url1 = NSURL(fileURLWithPath: path1)
        if let pathComponent1 = url1.appendingPathComponent("\(UserDefaults.standard.string(forKey: DefaultsKeys.taskId) ?? "po").txt") {
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
                try? jsonString!.write(to: URL(fileURLWithPath: (self.documentDir!.appendingPathComponent("\(UserDefaults.standard.string(forKey: DefaultsKeys.taskId) ?? "po").txt"))), atomically: true, encoding: String.Encoding.utf8.rawValue)
            }
        }
    }
    
    
    //MARK:add image in the chat
    //. This methods receives all details of image message and parse image message from get conversation api / socket
    //. Message id is received which is saved in dict to avoid duplication in messages
    //.image data is recevied
    //. message index is received to keep record postion of message
    //. other useful parameters are received to append text message in chat
    //. add message to local file
    func addImageinChat(messageId:String,role:String,imagData:Data,index:Int,is_notified:Bool,time:String,title:String,resp:[String:Any]){
        DispatchQueue.main.async { [self] in
          //  messagesDictionary["\(messageId)"] = "\(messageId)"
            messagesDictionaryText.append("\(imagData)")
            if(index != 0){
                  messagesDictionary["\(messageId)"] = "\(messageId)"
                messages[index] = Messgae(sender: checkSenderType(senderType: role, botTitle: title), messageId: "\(messageId)", sentDate: Date(), kind: .photo(Media(image: UIImage(data: imagData)!, realImageUrl: "\(resp["attachment_path"] as! String)")), downloadURL: "")
                notifyBool[index] = is_notified
                notifyStatus[index] = "sent"
                messagesTime[index] = time
                let indexPath = IndexPath(row: 0, section: index)
                messagesCollectionView.reloadSections([indexPath.section,indexPath.section - 1])
                refreshOnSwipe()
            }else{
                
            }
            messagesCollectionView.scrollToLastItem()
            let serialQueue = DispatchQueue(label: "com.moodyPoster.mySerialQueue")
            serialQueue.sync {
                makeDictionaryForLocalMessageStorage(messageType: "image", messageId: messageId, role: role, textMessage: "", index: 0, isNotified: false, messageTime: time, title: title, taskID: UserDefaults.standard.string(forKey:DefaultsKeys.taskId)!, attachment_path: resp["attachment_path"] as? String ?? "", location: "", details: [String : Any](), call_logs: "", rating: 0, fare_details: [String : Any]())
            }
//            DispatchQueue.global().async {
//                makeDictionaryForLocalMessageStorage(messageType: "image", messageId: messageId, role: role, textMessage: "", index: 0, isNotified: false, messageTime: time, title: title, taskID: UserDefaults.standard.string(forKey:DefaultsKeys.taskId)!, attachment_path: resp["attachment_path"] as? String ?? "")
//            }
           
        }
    }
    
    //MARK: add location in chat
    //. This methods receives all details to append location message in chat
    //. parse location message view and appends to chat
    func addlocationInChat(messageId:String,role:String,location:String,index:Int,is_notified:Bool,time:String,title:String){
        let dropOff:String = location
        let latLong = dropOff.split(separator: ",")
        let dropOffLatitude = Double(latLong[0])!
        let dropOffLongitude = Double(latLong[1].split(separator: " ")[0])!
        let loc = CLLocation(latitude: dropOffLatitude, longitude: dropOffLongitude)
        
        DispatchQueue.main.async { [self] in
           // messagesDictionary["\(messageId)"] = "\(messageId)"
            messagesDictionaryText.append("\(location)")
            if(index != 0){
                messagesDictionary["\(messageId)"] = "\(messageId)"
                messages[index] = Messgae(sender: checkSenderType(senderType: role, botTitle: ""), messageId: "\(messageId)", sentDate: Date(), kind: .location(CoordinateItem(location: loc)), downloadURL: "")
                notifyBool[index] = is_notified
                notifyStatus[index] = "sent"
                messagesTime[index] = time
                let indexPath = IndexPath(row: 0, section: index)
                messagesCollectionView.reloadSections([indexPath.section,indexPath.section - 1])
                refreshOnSwipe()
            }else{
                messages.append(Messgae(sender: checkSenderType(senderType: role, botTitle: ""), messageId: "\(messageId)", sentDate: Date(), kind: .location(CoordinateItem(location: loc)), downloadURL: ""))
                notifyBool.append(is_notified)
                notifyStatus.append("sent")
                messagesTime.append(time)
                reloadAfterSending()
                
            }
            messagesCollectionView.scrollToLastItem()
            let serialQueue = DispatchQueue(label: "com.moodyPoster.mySerialQueue")
            serialQueue.sync {
                makeDictionaryForLocalMessageStorage(messageType: "poster_location", messageId: messageId, role: role, textMessage: "", index: 0, isNotified: false, messageTime: time, title: title, taskID: UserDefaults.standard.string(forKey:DefaultsKeys.taskId)!, attachment_path: "", location: location, details: [String : Any](), call_logs: "", rating: 0, fare_details: [String : Any]())
            }
        }
    }
    
    
    //MARK:add video in the chat
    //. Methods calls when video message is receieve
    func addVideoinChat(messageId:String,role:String,videoLink:String){
        DispatchQueue.main.async { [self] in
           // messagesDictionary["\(messageId)"] = "\(messageId)"
            messagesDictionaryText.append("\(videoLink)")
            messages.append(Messgae(sender: checkSenderType(senderType: role, botTitle: ""), messageId: "\(messageId)", sentDate: Date(), kind: .video(Media(imageURL: URL(string: videoLink)!, thumb: UIImage(), realImageUrl: "")), downloadURL: ""))
            notifyBool.append(false)
            reloadAfterSending()
        }
    }
    //MARK: Loader is added on chat whhile get conversation response is fetched and parsed
    func addLoaderWhileFetching(flag:Bool){
        if(flag){
            DispatchQueue.main.async { [self] in
                cancelButton.isEnabled = false
                loadingIndicator.center = CGPoint(x: self.messagesCollectionView.frame.size.width  / 2, y: self.messagesCollectionView.frame.size.height / 2)
                self.view.addSubview(loadingIndicator)
                messagesCollectionView.bringSubviewToFront(loadingIndicator)
                self.messageInputBar.sendButton.isUserInteractionEnabled = false
                loadingIndicator.hidesWhenStopped = true
                loadingIndicator.style = UIActivityIndicatorView.Style.gray
                loadingIndicator.startAnimating()
            }
        }else{
            DispatchQueue.main.async { [self] in
                loadingIndicator.stopAnimating()
                cancelButton.isEnabled = true
                self.messageInputBar.sendButton.isUserInteractionEnabled = true
                loadingIndicator.removeFromSuperview()
            }
        }
        
        
    }
}
//MARK: download images
extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}





