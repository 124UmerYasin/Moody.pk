//
//  NotificationCenter.swift
//  Moody_Posterv2.0
//
//  Created by Umer Yasin on 05/06/2021.
//

import Foundation


extension Notification.Name {
    
    //MARK: Notification Observers Name are set here
    static let controllerDidTap = Notification.Name("controllerDidTap")
    static let logoutDidTap = Notification.Name("logoutDidTap")
    static let helpDidTap = Notification.Name("helpDidTap")
    
    
    static let cancelledByDeo = Notification.Name("cancelledByDeo")
    static let taskAssigned = Notification.Name("taskAssigned")
    static let taskFinished = Notification.Name("taskFinished")
    static let newMessage = Notification.Name("newMessage")
    
    static let checkInternetConnectionOnline = Notification.Name("checkInternetConnectionOnline")
    static let checkInternetConnectionOffline = Notification.Name("checkInternetConnectionOffline")


    static let onTaskAcceptedByTasker = Notification.Name("onTaskAcceptedByTasker")
    static let readConversation = Notification.Name("readConversation")
    static let onTaskEndedFromTasker = Notification.Name("onTaskEndedFromTasker")
    static let onLocationUpdate = Notification.Name("onLocationUpdate")
    static let onTaskCancelled = Notification.Name("onTaskCancelled")
    static let newMessageCs = Notification.Name("newMessageCs")
    static let CSnewMessage = Notification.Name("CSnewMessage")


    static let checkPermissions = Notification.Name("checkPermissions")
    
    static let closeSideMenu = Notification.Name("closeSideMenu")
    static let sendRating = Notification.Name("sendRating")

    static let ratingCallBack = Notification.Name("ratingCallBack")

    static let closeChat = Notification.Name("closeChat")
    static let estimateFare = Notification.Name("estimateFare")

    
    static let switchCamera = Notification.Name("switchCamera")
    static let showToast = Notification.Name("showToast")

    static let walletUpdate = Notification.Name("walletUpdate")
    static let promoBalance = Notification.Name("promoBalance")

    static let currentFare = Notification.Name("currentFare")
    
    static let customerSupportNotified = Notification.Name("customerSupportNotified")
    
    static let reloadViewAftercancelTask = Notification.Name("reloadViewAftercancelTask")


    static let navigateToChat = Notification.Name("navigateToChat")
    static let navigateToBalance = Notification.Name("navigateToBalance")
    static let navigateToHistory = Notification.Name("navigateToHistory")
    static let navigateToCustomerSupport = Notification.Name("navigateToCustomerSupport")
    static let navigateToCustomerSupportHelp = Notification.Name("navigateToCustomerSupportHelp")
    static let updateHistoryData = Notification.Name("updateHistoryData")
    
    

    
    static let removingCallBtn = Notification.Name("removingCallBtn")
    static let updateTickStatus = Notification.Name("updateTickStatus")

    static let updateCustomerConversationofNewTicket = Notification.Name("updateCustomerConversationofNewTicket")
    static let updateChatonversationofNewChat = Notification.Name("updateChatonversationofNewChat")
    
    static let goingOutFromHistory = Notification.Name("goingOutFromHistory")

    static let makeCall = Notification.Name("makeCall")
    static let removeTimerView = Notification.Name("removeTimerView")
    
    static let removeAudioViewOnCall = Notification.Name("removeAudioViewOnCall")
    static let removeAudioViewOnCallHome = Notification.Name("removeAudioViewOnCallHome")
    static let qbLogin = Notification.Name("qbLogin")
    static let sendLoc = Notification.Name("sendLoc")

    static let recallNotifications = Notification.Name("recallNotifications")

    

}
