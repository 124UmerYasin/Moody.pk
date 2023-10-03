//
//  NotificationFunctions.swift
//  Moody_Posterv2.0
//
//  Created by Umer yasin on 07/06/2021.
//

import Foundation
import UIKit
import Quickblox
import QuickbloxWebRTC
import MessageKit


extension ChatViewController{
    
    // MARK:- Method is called on Tasker Assigned Notification
    //. View changes in chat
    @objc func taskerAssigned(_ notification:NSNotification){
        animationView.stop()
        animationView.isHidden = true
        status = "assigned"
        DispatchQueue.main.async { [self] in
            timerView.removeFromSuperview()
            ChatViewController.stopTimer?.stopTimer()
        }
    }
    
    //MARK: Method is called when emit is recevied of tasker Assigned
    //. Notification Observer passed data of emitt in method
    //. Tasker QbDetails are fetched and details get saved in local userDefaults
    //. View change in chat
    @objc func taskerAssignedFromSocket(_ notification:NSNotification){
        
        let taskerDetails = notification.userInfo as! [String:Any]
        setTaskerQbDetails(userInfo: taskerDetails)
        DispatchQueue.main.async { [self] in
            timerView.removeFromSuperview()
            ChatViewController.stopTimer?.stopTimer()
        }
    }
    


    //MARK: adding a call button after accepting a task in chat screen
    //. Constranits are set of TopBar of chat (calling btns, support button)
    func addCallButton(){
        if(ChatViewController.isFromActiveTask){
            btnProfile = UIButton(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
            if let myImage = UIImage(named: "Phone") {
                let tintableImage = myImage.withRenderingMode(.alwaysTemplate)
                btnProfile.setImage(tintableImage, for: .normal)

            }
           btnProfile.tintColor =  UIColor(named: "Green")
            btnProfile.layer.cornerRadius = 18
            btnProfile.addTarget(self, action: #selector(makeAudioCall), for: .touchUpInside)
            
            
            videoCallBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
            if let myImage = UIImage(named: "video") {
                let tintableImage = myImage.withRenderingMode(.alwaysTemplate)
                videoCallBtn.setImage(tintableImage, for: .normal)

            }
            videoCallBtn.tintColor =  UIColor(named: "Green")
            videoCallBtn.layer.cornerRadius = 18
            videoCallBtn.addTarget(self, action: #selector(makeVideoCall), for: .touchUpInside)
            

            if(UserDefaults.standard.bool(forKey: DefaultsKeys.customer_support_notification) == true) {

                customerSupportButton.setImage(UIImage(named: "customerSupportNotified"), for: .normal)
            }else{
                customerSupportButton.setImage(UIImage(named: "chatCustomerSupport"), for: .normal)
            }

            customerSupportButton.layer.cornerRadius = 18
            customerSupportButton.addTarget(self, action: #selector(callHelp), for: .touchUpInside)

            
            let settingsButton = UIBarButtonItem(customView: btnProfile)
            let videoCallButton = UIBarButtonItem(customView: videoCallBtn)
            let customerSuppotButton = UIBarButtonItem(customView: customerSupportButton)

            self.navigationItem.rightBarButtonItems = []
            
            if(UserDefaults.standard.string(forKey: DefaultsKeys.qb_id) != nil && UserDefaults.standard.string(forKey: DefaultsKeys.qb_password) != nil && UserDefaults.standard.string(forKey: DefaultsKeys.qb_login) != nil && UserDefaults.standard.string(forKey: DefaultsKeys.tasker_qb_id) != nil){
                
                self.navigationItem.rightBarButtonItems = [settingsButton, videoCallButton,customerSuppotButton]
            }else{
                self.navigationItem.rightBarButtonItems = [customerSuppotButton]

            }
            settingsButton.tintColor = .red
        }
    
    }
    
   //MARK: Methods gets called when user initiate call
   //. audio call type is set
   //. makeCall Notification is post to notify qbcall functions
   //. View changes in chat screen
    @objc func makeAudioCall(){
        DispatchQueue.main.async { [self] in
            timerView.removeFromSuperview()
            ChatViewController.stopTimer?.stopTimer()
        }
        btnProfile.isUserInteractionEnabled = false
        var temp = [String:Any]()
        temp["type"] = "audio"
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "makeCall"), object: nil,userInfo: temp)
        btnProfile.isUserInteractionEnabled = true
    }
    
    //MARK: Methods gets called when user initiate call
    //. video call type is set
    //. makeCall Notification is post to notify qbcall functions
    //. View changes in chat screen
    @objc func makeVideoCall(){
        removeBlurViewFromBackground()
        DispatchQueue.main.async { [self] in
            timerView.removeFromSuperview()
            ChatViewController.stopTimer?.stopTimer()
        }
        videoCallBtn.isUserInteractionEnabled = false
        var temp = [String:Any]()
        temp["type"] = "video"
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "makeCall"), object: nil,userInfo: temp)
        videoCallBtn.isUserInteractionEnabled = true

    }

    //MARK: Naviagte to customer support for that specific task
    //. checks ticketId status if it is already open or not
    //. customer support chat is open
    @objc func callHelp(){
        makeButtonsNormal()
        if(CheckInternet.Connection()){
            DispatchQueue.main.async { [self] in
                timerView.removeFromSuperview()
                ChatViewController.stopTimer?.stopTimer()
            }
            if(ticketId != ""){
                let vc = CustomerSupport()
                vc.hidesBottomBarWhenPushed = true
                vc.ticket_id = ticketId
                vc.status = true
                UserDefaults.standard.setValue(false, forKey: DefaultsKeys.customer_support_notification)
                self.navigationController?.pushViewController(vc, animated: true)
            }else{
                ApiManager.sharedInstance.apiCaller(hasBodyData: true, hasToken: true, url: ENDPOINTS.createTicket, dictionary: createTicketDict(), httpMethod: "POST", token: UserDefaults.standard.string(forKey: DefaultsKeys.token)) { [self] (Result) in
                    print(Result)
                    switch Result{
                    case .success(let response):
                        
                        if response["_id"] as? String != nil  {
                            DispatchQueue.main.async { [self] in
                                let vc = CustomerSupport()
                                vc.hidesBottomBarWhenPushed = true
                                ticketId = response["_id"] as! String
                                vc.ticket_id = response["_id"] as! String
                                vc.ticketIdForChat = response["ticket_id"] as! String
                                vc.status = true
                                UserDefaults.standard.setValue(false, forKey: DefaultsKeys.customer_support_notification)
                                self.navigationController?.pushViewController(vc, animated: true)
                        }
                        
                        }
                    case .failure(let error):
                        
                        DispatchQueue.main.async {
                            self.presentAlert(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString( error.title, comment: ""), parentController: self)
                        }
                    }
                }
            }
            
        }else{
            self.presentAlert(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString( "Internet Not Available. Please check your internet connection and try again.", comment: ""), parentController: self)
        }        
    }
    
    //MARK: Creates Dict for ticket
    //. returns dictonary
    func createTicketDict() -> [String:Any]{
        var dictionary = [String:Any]()
        dictionary["task_id"] = UserDefaults.standard.string(forKey:DefaultsKeys.taskId)
        return dictionary
    }

  

    
    //MARK: Removes TimerView
    //. On tasker Assign this Method is called to remove finding tasker view
    @objc func removeTimerView(_ notification:NSNotification){
        DispatchQueue.main.async { [self] in
            timerView.removeFromSuperview()
        }
    }
    
    
    //MARK: This methods is called when user open MapViewController for tasker Location
    //. display_location_logs api is called
    //. task details are fetched from response (e.g pickup coordinates, tasker current location)
    //. details are saved into local userdefaults
    func getTaskLocationsAPICall(){

        var dictionary = [String:Any]()
        dictionary["task_id"] = UserDefaults.standard.string(forKey: DefaultsKeys.taskId)
        dictionary["user_agent"] = AppPermission.getDeviceInfo()
        dictionary["platform"] = "ios"
        
        ApiManager.sharedInstance.apiCaller(hasBodyData: true, hasToken: true, url: ENDPOINTS.getLocationLogs, dictionary: dictionary, httpMethod: "POST", token: UserDefaults.standard.string(forKey: DefaultsKeys.token)) { [self] (Results) in

                switch Results{
                case .success(let response):
                    
                        let pickupCoordinates = response["pickup_location"] as! String
                        let pickupLatLong = pickupCoordinates.split(separator: ",")
                        let pickupTaskerLat = Double(pickupLatLong[0])!
                        let pickupTaskerLong = Double(pickupLatLong[1].split(separator: " ")[0])!
    
                        
                        UserDefaults.standard.setValue(pickupTaskerLat, forKey: (DefaultsKeys.pickup_location_latitude))
                        UserDefaults.standard.setValue(pickupTaskerLong, forKey: (DefaultsKeys.pickup_location_longitude))
                        
                        let taskerCoordinates = response["tasker_coordinates"] as! String
                        let taskerLatLong = taskerCoordinates.split(separator: ",")
                        let taskerLat = Double(taskerLatLong[0])!
                        let taskerLong = Double(taskerLatLong[1].split(separator: " ")[0])!
            
                        
                        UserDefaults.standard.setValue(taskerLong, forKey: (DefaultsKeys.tasker_location_longitude))
                        UserDefaults.standard.setValue(taskerLat, forKey: (DefaultsKeys.tasker_location_latitude))
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
                        taskerLocationButton.isEnabled = true
                        addLoaderWhileFetching(flag: false)
                        self.makeButtonsNormal()
                        let storyBoard = UIStoryboard(name: "TaskMap", bundle:nil)
                        let vc = storyBoard.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
                        vc.updatedTime = response["last_location_time"] as! String
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                        
                case .failure(let error):
                    DispatchQueue.main.async { [self] in
                        taskerLocationButton.isEnabled = true
                        addLoaderWhileFetching(flag: false)
                        presentAlert(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString( error.title, comment: ""), parentController: self)
                    }
                }
        }

    }
    
    
    
    
    //MARK: Render New chat
    //. Method is called when user is already in chat tap to different on going task chat Notification
    //. It replaces taskId, removes pervious arrays and render chat of that task
    func onRenderNewChatinChat(type: [String : Any]) {
        
        self.audioController.stopAnyOngoingPlaying()
        if let viewWithTag = self.view.viewWithTag(121) {
            viewWithTag.removeFromSuperview()
        }else{
            //print"No! SOME ERROR OCCUR WHILE removing subview")
        }
        if let viewWithTag = self.messageInputBar.viewWithTag(1212) {
            viewWithTag.removeFromSuperview()
        }else{
            //print"No! SOME ERROR OCCUR WHILE removing subview")
        }
        
        let taskId =  type["task_id"] as! String
        UserDefaults.standard.setValue(taskId, forKey: DefaultsKeys.taskId)
        messagesDictionary.removeAll()
        localMessagesArray.removeAll()
        messages.removeAll()
        notifyBool = [Bool]()
        notifyStatus = [String]()
        messagesTime = [String]()
        messagesCollectionView.reloadData()
        if !ChatViewController.isFromActiveTask {
            ChatViewController.isFromActiveTask = true
            setOptionButton()
            optionsButton.isHidden = false
            addCallButton()
        }
        callMessages()

        

    }

}
