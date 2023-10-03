//
//  ShowRatingScreen.swift
//  Moody_Posterv2.0
//
//  Created by Umer yasin on 07/06/2021.
//

import Foundation
import UIKit



extension ChatViewController{
    
    //MARK: On task complete method gets call
    //. View changes in chat
    @objc func taskFinished(_ notification:NSNotification){
        DispatchQueue.main.async {
            self.messageInputBar.resignFirstResponder()
        }
        DispatchQueue.main.async { [self] in
            timerView.removeFromSuperview()
            ChatViewController.stopTimer?.stopTimer()
        }
        self.audioController.stopAnyOngoingPlaying()
        ChatViewController.istaskfinisherOrNot = true
    }
    

    //MARK: current Fare View is shown
    @objc func showEstimateFareXib(_ notification:NSNotification){
        DispatchQueue.main.async { [self] in
            messages.append((Messgae(sender: deo, messageId: "FareEstimate",sentDate: Date(), kind:.custom(EstimateFareScreen.self), downloadURL: "")))
            notifyBool.append(true)
            notifyStatus.append("sent")
            messagesTime.append("")
            reloadAfterSending()
            messagesCollectionView.scrollToLastItem()
        }
    }
        
    //MARK: Task Rating submit 
    @objc func submitRating(_ notification:NSNotification){
        let message = notification.userInfo as! [String:Any]
        var dictionary = [String:Any]()
        dictionary["task_id"] = UserDefaults.standard.string(forKey:DefaultsKeys.taskId)
        dictionary["tasker_rating"] = Double(message["rating"] as! String)
        dictionary["user_agent"] = AppPermission.getDeviceInfo()
        dictionary["platform"] = "ios"
        
        var dict = [String:Any]()

        if(CheckInternet.Connection()){
            addLoaderWhileFetching(flag: true)
            ApiManager.sharedInstance.apiCaller(hasBodyData: true, hasToken: true, url: ENDPOINTS.task_ratings, dictionary: dictionary, httpMethod: "POST", token: UserDefaults.standard.string(forKey: DefaultsKeys.token)) { [self] Result in
                switch Result{
                case .success(_):
                    dict["status"] = "success"
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ratingCallBack"), object: nil,userInfo: dict)
                    DispatchQueue.main.async {
                        addLoaderWhileFetching(flag: false)
                        self.inputAccessoryView?.isHidden = false
                        messageInputBar.inputTextView.text = ""
                        messageInputBar.inputTextView.resignFirstResponder()
                    }

                case .failure(let error):
                    DispatchQueue.main.async {
                        if(error.title.contains("Review already provided")){
                            dict["status"] = "faliure"
                        }else{
                            dict["status"] = "faliure"
                        }
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ratingCallBack"), object: nil,userInfo: dict)
                        self.presentAlert(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString( error.title, comment: ""), parentController: self)
                        addLoaderWhileFetching(flag: false)
                    }
                   
                }
            }
        }else{
            dict["status"] = "faliure"
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ratingCallBack"), object: nil,userInfo: dict)
            self.presentAlert(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString( "Internet Not Available. Please check your internet connection and try again.", comment: ""), parentController: self)
            addLoaderWhileFetching(flag: false)
        }
        
    }
    
    @objc func showToast(_ notification:NSNotification){
        
        UIPasteboard.general.string = UserDefaults.standard.string(forKey: DefaultsKeys.referenceId)
        DispatchQueue.main.async {
            self.showToast(message: NSLocalizedString("Reference code copied", comment: ""), font: .systemFont(ofSize: 17.0))
        }
    }
}
