//
//  SocketManager.swift
//  Moody_Posterv2.0
//
//  Created by Umer yasin on 08/06/2021.
//

import Foundation
import SocketIO


class SocketsManager{
    
    
    //MARK: SocketManager instance and SocketUrls of (dev,stagging,production)
    static var sharesInstance = SocketsManager()
    
    var messageID: String = ""
    var csMessageID: String = ""
    static var taskAcceptedBool = false
    static var messageReceivedBool = false
    
    
    //MARK: Protocol Delegates used in socket manager
    var messageDelegate:addSocketMessage?
    var messageDelegatecs:addSocketMessagecs?

    
    
    let manager = SocketManager(socketURL: URL(string: Constants.socketUrl)!,config: [.log(true), .compress,.secure(true),.forceWebsockets(true),.reconnects(true),.forceNew(true)])
    
    
    var socket:SocketIOClient!
    var name: String?
    var resetAck: SocketAckEmitter?
    var socketConnectionStatus:SocketIOStatus!
    static var appProtocol:String = ""
    
    

    //MARK: Method which is call to establish socket connection
    //.creates socket instance
    //.on socket status it call socket connect method
    //.removes pervious socket handlers and add new handlers
    func establishSocketConnection(){
        
        socket = manager.defaultSocket
        socketConnectionStatus = socket.status
        switch socket.status {
        case .notConnected:
            SocketsManager.appProtocol = "http"
            socket.connect(withPayload: ["token":UserDefaults.standard.string(forKey: DefaultsKeys.token)!,"user_id":UserDefaults.standard.string(forKey: DefaultsKeys.posterId)!,"role":"is_poster"])
        case .disconnected:
            SocketsManager.appProtocol = "http"
            socket.connect(withPayload: ["token":UserDefaults.standard.string(forKey: DefaultsKeys.token)!,"user_id":UserDefaults.standard.string(forKey: DefaultsKeys.posterId)!,"role":"is_poster"])
        case .connecting:
            SocketsManager.appProtocol = "http"
            socket.connect(withPayload: ["token":UserDefaults.standard.string(forKey: DefaultsKeys.token)!,"user_id":UserDefaults.standard.string(forKey: DefaultsKeys.posterId)!,"role":"is_poster"])
        case .connected:
            SocketsManager.appProtocol = "Socket"
            break
        }
        socket.removeAllHandlers()
        addHandlers()
    }
    
    //MARK: It handles all emits recieves from Node server
    //. Emits are handled here
    func addHandlers() {
        socket.on("connection") { data, ack in
            //printdata)
            return
        }
        
        //MARK: onUserUpdate emit
        //. updates in wallet
        //. updates user rating.
        socket.on("onUserUpdate") { data, ack in
            let temp = data[0] as! [String:Any]
            ack.with(["emit_name":"onUserUpdate","token":UserDefaults.standard.string(forKey: DefaultsKeys.token)!,"user_id":UserDefaults.standard.string(forKey: DefaultsKeys.posterId)!,"role":"is_poster"])
            UserDefaults.standard.setValue(temp["poster_rating"], forKey: DefaultsKeys.poster_rating)
            UserDefaults.standard.setValue(temp["wallet_balance"], forKey: DefaultsKeys.wallet_balance)
            UserDefaults.standard.setValue(temp["promo_balance"], forKey: DefaultsKeys.promo_balance)
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "walletUpdate"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "promoBalance"), object: nil)
            return
        }
        
        //MARK: onTaskAccepted emit
        //. emit is received when tasker accept users task
        //. Notification is post to make changes in chat screen
        socket.on("onTaskAccepted") { data, ack in
                let temp = data[0] as! [String:Any]
                print("Temp:\(temp)")
                print("Tasker Assigned by socket")
                UserDefaults.standard.setValue(temp["qb_id"] as? Int ?? nil, forKey: DefaultsKeys.tasker_qb_id)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "onTaskAcceptedByTasker"), object: nil, userInfo: temp)
            return
        }
        
        //MARK: onNewMessage emit
        //. on every new message of task emit is received
        //. data is fetched and on role check and protocol delegate is called which appends message in chat
        socket.on("onNewMessage") { [self] data, ack in
            SocketsManager.taskAcceptedBool = true
            let messages = data[0] as! [String: Any]
            print("onNewMessage \(messages)")
            let role = messages["role"] as! String
            if role == "is_tasker" || role == "is_deo" || role == "poster_bot" {
                if(messageID != messages["message_id"] as! String){
                    messageDelegate?.addSocketMessage(type: messages)

                }
                messageID = messages["message_id"] as! String
            }else if(role == "is_admin"){
                if(csMessageID != messages["message_id"] as! String){
                    messageDelegatecs?.addSocketMessagecs(type: messages)

                }
                csMessageID = messages["message_id"] as! String
            }
        }
            
        //MARK: onPosterBotMessage emit
        //. posterBot messages is appened by calling protocol delegate method
        socket.on("onPosterBotMessage") { [self] data, ack in
            let messages = data[0] as! [String: Any]
            print("onPosterBotMessage \(messages)")
            let role = messages["role"] as! String
            if role == "poster_bot" {
                if(messageID != messages["message_id"] as! String){
                    messageDelegate?.addSocketMessage(type: messages)

                }
                messageID = messages["message_id"] as! String
            }
        }
        
        //MARK: onLocationLogs emit
        //. tasker updated location is updated in this emit
        //. Notification is post to update tasker marker postion in Map
        socket.on("onLocationLogs") { data, ack in
            let temp = data[0] as! [String:Any]
            if(temp["task_id"] as? String == UserDefaults.standard.string(forKey: DefaultsKeys.taskId)){
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "onLocationUpdate"), object: nil, userInfo: temp)
            }
            return
        }
        
        //MARK: onTaskCancelled emit
        //. when task is cancelled Notifiaction is post to make changes in chat screen
        socket.on("onTaskCancelled") { data, ack in
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "onTaskCancelled"), object: nil)
            return
        }
        
        //MARK: onQbData emit
        socket.on("onQbData") { data, ack in
          
            ack.with(["emit_name":"onQbData","token":UserDefaults.standard.string(forKey: DefaultsKeys.token)!,"user_id":UserDefaults.standard.string(forKey: DefaultsKeys.posterId)!,"role":"is_poster","task_id":UserDefaults.standard.string(forKey: DefaultsKeys.taskId)])
        }
        
        //MARK: onRunTimeFare emit
        //. updates runtime fare of task
        //. Notification is post to chat screen to update Current fare
        socket.on("onRunTimeFare") { data, ack in
            let temp = data[0] as! [String:Any]
            print("onRunTimeFare \(temp)")
            if(temp["task_id"] as? String == UserDefaults.standard.string(forKey: DefaultsKeys.taskId)){
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "currentFare"), object: nil,userInfo: temp)
            }
        }
        
        //MARK: onTicketUpdate emit
        //. receive when there is update on customer support
        //. Notification is post to customer support
        socket.on("onTicketUpdate") { data, ack in
            let temp = data[0] as! [String:Any]
            
            let notificationBadge = temp["poster_active_ticket"] as? Bool ?? false
            UserDefaults.standard.setValue(notificationBadge, forKey: DefaultsKeys.helpBadge)
            print("onTicketUpdate \(temp)")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateTickStatus"), object: nil,userInfo: temp)
        }
        
        //MARK: onPosterNotificationUpdate emit
        socket.on("onPosterNotificationUpdate") { data, ack in
            let temp = data[0] as! [String:Any]
            print("onPosterNotificationUpdate \(temp)")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateHistoryData"), object: nil,userInfo: temp)
        }
    }
}
