//
//  QuickBloxDelegates.swift
//  Moody_Posterv2.0
//
//  Created by Syed Muhammad bin Saadat on 09/06/2021.
//

import Foundation
import UIKit
import Quickblox
import QuickbloxWebRTC
import PushKit

                    // MARK: - QBRTCClientDelegate
extension TaskCreationViewController {
    
    
    
    func call(with conferenceType: QBRTCConferenceType) {
        
        if session != nil {
            return
        }
        
        if hasConnectivity() {
            CallPermissions.check(with: conferenceType) { granted in
        
                if granted {
                    let opponentsIDs: [NSNumber] = self.dataSource.ids(forUsers: self.dataSource.selectedUsers)
                    let opponentsNames: [String] = self.dataSource.selectedUsers.compactMap({ $0.fullName ?? $0.login })
                    
                    //Create new session
                    let taskerID = UInt(UserDefaults.standard.string(forKey: DefaultsKeys.tasker_qb_id)!)! as NSNumber
                    let session = QBRTCClient.instance().createNewSession(withOpponents: [taskerID], with: conferenceType)
                    if session.id.isEmpty == false {
                        self.session = session
                        self.sessionID = session.id
                        guard let uuid = UUID(uuidString: session.id) else {
                            return
                        }
                        self.callUUID = uuid
                        let profile = Profile()
                        guard profile.isFull == true else {
                            return
                        }
                        
                        CallKitManager.instance.startCall(withUserIDs: opponentsIDs, session: session, uuid: uuid)
                        let storyboard = UIStoryboard(name: "Call", bundle: nil)
                        let callViewController = storyboard.instantiateViewController(withIdentifier: "CallViewController") as! CallViewController
                        callViewController.session = self.session
                        callViewController.usersDataSource = self.dataSource
                        callViewController.callUUID = uuid
                        callViewController.sessionConferenceType = conferenceType
                        let nav = UINavigationController(rootViewController: callViewController)
                        nav.modalTransitionStyle = .crossDissolve
                        nav.modalPresentationStyle = .fullScreen
                        self.present(nav , animated: false)
                        self.navViewController = nav
                        
                        _ = opponentsNames.joined(separator: ",")
                        let allUsersNamesString = UserDefaults.standard.string(forKey: DefaultsKeys.taskerName)
                        let arrayUserIDs = opponentsIDs.map({"\($0)"})
                        let usersIDsString = arrayUserIDs.joined(separator: ",")
                        let allUsersIDsString = UserDefaults.standard.string(forKey: DefaultsKeys.tasker_qb_id)
                        let opponentName = profile.fullName
                        let conferenceTypeString = conferenceType == .video ? "1" : "2"
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        let timeStamp = formatter.string(from: Date())
                        let payload = ["message": "\(opponentName) is calling you.",
                            "ios_voip": "1",
                            UsersConstant.voipEvent: "1",
                            "sessionID": session.id,
                            "opponentsIDs": allUsersIDsString,
                            "contactIdentifier": allUsersNamesString,
                            "conferenceType" : conferenceTypeString,
                            "timestamp" : timeStamp
                        ]
                        let data = try? JSONSerialization.data(withJSONObject: payload,
                                                               options: .prettyPrinted)
                        var message = ""
                        if let data = data {
                            message = String(data: data, encoding: .utf8) ?? ""
                        }
                        let event = QBMEvent()
                        event.notificationType = QBMNotificationType.push
                        event.usersIDs = usersIDsString
                        event.type = QBMEventType.oneShot
                        event.message = message
                        QBRequest.createEvent(event, successBlock: { response, events in
                            debugPrint("[UsersViewController] Send voip push - Success")
                        }, errorBlock: { response in
                            debugPrint("[UsersViewController] Send voip push - Error")
                        })
                    } else {
                       // SVProgressHUD.showError(withStatus: UsersAlertConstant.shouldLogin)
                    }
                }
            }
        }
    }

    
    func beginConnect() {
        DispatchQueue.main.async {
            self.isEditing = false
        }
        
    }
    
    //MARK: Method is used to login user in Qb
    func login(fullName: String, login: String, password: String = UserDefaults.standard.string(forKey: DefaultsKeys.qb_password) ?? "") {
        
        beginConnect()
        QBRequest.logIn(withUserLogin: login,
                        password: password,
                        successBlock: { [weak self] response, user in

                            user.password = password
                            user.updatedAt = Date()
                            Profile.synchronize(user)
                            
                            if user.fullName != fullName {
                                self?.updateFullName(fullName: fullName, login: login)
                            } else {
                                self?.connectToChat(user: user)
                            }
                            print("Quickblox LoggedIn Successfully")
            }, errorBlock: { response in
                Profile.clearProfile()
        })
    }
    
    //MARK: Updates User name paramters
    //. calls when user gets login
    func updateFullName(fullName: String, login: String) {
        let updateUserParameter = QBUpdateUserParameters()
        updateUserParameter.fullName = fullName
        QBRequest.updateCurrentUser(updateUserParameter, successBlock: {  [weak self] response, user in

            user.updatedAt = Date()
            Profile.update(user)
            self?.connectToChat(user: user)
            
            }, errorBlock: { response in
                //self?.handleError(response.error?.error, domain: ErrorDomain.signUp)
        })
    }
    
    //MARK: Connects QbUser
    //. if user qb password is avaialable
    //. conencts user with user qb password
    func connectToChat(user: QBUUser){
     
        if UserDefaults.standard.string(forKey: DefaultsKeys.qb_password) != nil {
            QBChat.instance.connect(withUserID: user.id, password: UserDefaults.standard.string(forKey: DefaultsKeys.qb_password)!, completion: { (error) in
                
            })
        }else{
            QBChat.instance.connect(withUserID: user.id, password: UserDefaults.standard.string(forKey: DefaultsKeys.qb_password) ?? "", completion: { (error) in
                
            })
        }
    }
    
    //MARK: Connects QbUser
    //. if user qb password is avaialable
    //. conencts user with user qb password and qbId 
    func connectToChat(success:QBChatCompletionBlock? = nil) {
        let profile = Profile()
        guard profile.isFull == true else {
            return
        }
        
        QBChat.instance.connect(withUserID: UInt(UserDefaults.standard.string(forKey: DefaultsKeys.qb_id)!)!,
                                password: UserDefaults.standard.string(forKey: DefaultsKeys.qb_password)!,
                                completion: { [weak self] error in
                                    guard self != nil else { return }
                                    if let error = error {
                                        if error._code == QBResponseStatusCode.unAuthorized.rawValue {
                                            //self.logoutAction()
                                        } else {
                                            debugPrint("[UsersViewController] login error response:\n \(error.localizedDescription)")
                                        }
                                        success?(error)
                                    } else {
                                        success?(nil)
                                        //did Login action
                                        //SVProgressHUD.dismiss()
                                    }
        })
    }
    
    
    
    //MARK: Setup timer of connecting call
    //. end call on timer
    func setupAnswerTimerWithTimeInterval(_ timeInterval: TimeInterval) {
        if self.answerTimer != nil {
            self.answerTimer?.invalidate()
            self.answerTimer = nil
        }
        
        self.answerTimer = Timer.scheduledTimer(timeInterval: timeInterval,
                                                target: self,
                                                selector: #selector(endCallByTimer),
                                                userInfo: nil,
                                                repeats: false)
    }
    
    //MARK: Invalidates timer
    private func invalidateAnswerTimer() {
        if self.answerTimer != nil {
            self.answerTimer?.invalidate()
            self.answerTimer = nil
        }
    }
    
    //MARK: Prepares ios background task
    func prepareBackgroundTask() {
       let application = UIApplication.shared
       if application.applicationState == .background && self.backgroundTask == .invalid {
           self.backgroundTask = application.beginBackgroundTask(expirationHandler: {
               application.endBackgroundTask(self.backgroundTask)
               self.backgroundTask = UIBackgroundTaskIdentifier.invalid
           })
       }
   }
    
    //MARK: Calls ends on timer
    @objc private func endCallByTimer() {
        invalidateAnswerTimer()
        
        if let endCall = CallKitManager.instance.currentCall() {
            CallKitManager.instance.endCall(with: endCall.uuid) {
                print("[UsersViewController] endCall sessionDidClose")
            }
        }
        prepareCloseCall()
    }

    func configureNavigationBar() {

        //Custom label
        var loggedString = "Logged in as "
        var roomName = ""
        var titleString = ""
        let profile = Profile()
        
        if profile.isFull == true  {
            let fullname = profile.fullName
            titleString = loggedString + fullname
            let tags = profile.tags
            if  tags?.isEmpty == false,
                let name = tags?.first {
                roomName = name
                loggedString = loggedString + fullname
                titleString = roomName + "\n" + loggedString
            }
        }
        
        let attrString = NSMutableAttributedString(string: titleString)
        let roomNameRange: NSRange = (titleString as NSString).range(of: roomName)
        attrString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 16.0), range: roomNameRange)
        
        let userNameRange: NSRange = (titleString as NSString).range(of: loggedString)
        attrString.addAttribute(.font, value: UIFont.systemFont(ofSize: 12.0), range: userNameRange)
        attrString.addAttribute(.foregroundColor, value: UIColor.gray, range: userNameRange)
        
        let titleView = UILabel(frame: CGRect.zero)
        titleView.numberOfLines = 2
        titleView.textAlignment = .center
        titleView.sizeToFit()
        //navigationItem.titleView = titleView
        //Show tool bar
        navigationController?.isToolbarHidden = false
        //Set exclusive touch for tool bar
        if let subviews = navigationController?.toolbar.subviews {
            for subview in subviews {
                subview.isExclusiveTouch = true
            }
        }
    }
    
    //MARK: Set Toolbar button Enabled
    func setupToolbarButtonsEnabled(_ enabled: Bool) {
        guard let toolbarItems = toolbarItems, toolbarItems.isEmpty == false else {
            return
        }
        for item in toolbarItems {
            item.isEnabled = enabled
        }
    }
    
    //MARK: Checks Connectivity
    func hasConnectivity() -> Bool {
        let status = Reachability.instance.networkConnectionStatus()
        guard status != NetworkConnectionStatus.notConnection else {
            showAlertView(message: UsersAlertConstant.checkInternet)
            if CallKitManager.instance.isCallStarted() == false {
                CallKitManager.instance.endCall(with: callUUID) {
                    debugPrint("[UsersViewController] endCall func hasConnectivity")
                }
            }
            return false
        }
        return true
    }
    
    //MARK: Presents alert
    //. Alert controler of OK
    func showAlertView(message: String?) {
       let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
       alertController.addAction(UIAlertAction(title: UsersAlertConstant.okAction, style: .default,
                                               handler: nil))
        alertController.view.tintColor = UIColor(named: "ButtonColor")
       present(alertController, animated: true)
   }
    
}


// MARK: - QBRTCClientDelegate
extension TaskCreationViewController {
    func session(_ session: QBRTCSession, hungUpByUser userID: NSNumber, userInfo: [String : String]? = nil) {
        if CallKitManager.instance.isCallStarted() == false,
            let sessionID = self.sessionID,
            sessionID == session.id,
            session.initiatorID == userID || isUpdatedPayload == false {
            CallKitManager.instance.endCall(with: callUUID)
            prepareCloseCall()
        }
    }
    
    func didReceiveNewSession(_ session: QBRTCSession, userInfo: [String : String]? = nil) {
        if self.session != nil {
            session.rejectCall(["reject": "busy"])
            return
        }
        invalidateAnswerTimer()
        
        self.session = session
        
        if let currentCall = CallKitManager.instance.currentCall() {
            //open by VOIP Push

            CallKitManager.instance.setupSession(session)
            if currentCall.status == .ended {
                CallKitManager.instance.setupSession(session)
                CallKitManager.instance.endCall(with: currentCall.uuid)
                session.rejectCall(["reject": "busy"])
                prepareCloseCall()
                } else {
                var opponentIDs = [session.initiatorID]
                let profile = Profile()
                guard profile.isFull == true else {
                    return
                }
                for userID in session.opponentsIDs {
                    if userID.uintValue != profile.ID {
                        opponentIDs.append(userID)
                    }
                }
                
                prepareCallerNameForOpponentIDs(opponentIDs) { (callerName) in
                    CallKitManager.instance.updateIncomingCall(withUserIDs: session.opponentsIDs,
                                                               outCallerName: callerName,
                                                               session: session,
                                                               uuid: currentCall.uuid)
                }
            }
        } else {
            //open by call
            
            if let uuid = UUID(uuidString: session.id) {
                callUUID = uuid
                sessionID = session.id
                
                var opponentIDs = [session.initiatorID]
                let profile = Profile()
                guard profile.isFull == true else {
                    return
                }
                for userID in session.opponentsIDs {
                    if userID.uintValue != profile.ID {
                        opponentIDs.append(userID)
                    }
                }
                
                prepareCallerNameForOpponentIDs(opponentIDs) { [weak self] (callerName) in
                    self?.reportIncomingCall(withUserIDs: opponentIDs,
                                             outCallerName: callerName,
                                             session: session,
                                             uuid: uuid)
                }
            }
        }
    }
    
    private func prepareCallerNameForOpponentIDs(_ opponentIDs: [NSNumber], completion: @escaping (String) -> Void)  {
        var callerName = ""
        var opponentNames = [String]()
        var newUsers = [String]()
        for userID in opponentIDs {
            
            // Getting recipient from users.
            if let user = dataSource.user(withID: userID.uintValue),
                let fullName = user.fullName {
                opponentNames.append(fullName)
            } else {
                newUsers.append(userID.stringValue)
            }
        }
        
        if newUsers.isEmpty == false {
            
            QBRequest.users(withIDs: newUsers, page: nil, successBlock: { [weak self] (respose, page, users) in
                if users.isEmpty == false {
                    self?.dataSource.update(users: users)
                    for user in users {
                        opponentNames.append(user.fullName ?? user.login ?? "")
                    }
                    callerName = opponentNames.joined(separator: ", ")
                    completion(callerName)
                }
            }) { (respose) in
                for userID in newUsers {
                    opponentNames.append(userID)
                }
                callerName = opponentNames.joined(separator: ", ")
                completion(callerName)
            }
        } else {
            callerName = opponentNames.joined(separator: ", ")
            completion(callerName)
        }
    }
    
    func makeScreenNormal(){
        tabBarController?.tabBar.isUserInteractionEnabled = true
        invalidateTimer()
        setLabelsVisibility(menuButton: false, activityLoader: true, cancelBtn: true, sendRequestBtn: true, micBtn: true, timerLabel: true, labelForInst:false, recordinglimit: true, youtubeBtn:true)
        LocationManagers.locationSharesInstance.stopLocationUpdate()
//        if ((audioRecorder?.isRecording) != nil){
//            audioRecorder.stop()
//        }
//        audioRecorder = nil
        recorder.stopRecording()
        if(UserDefaults.standard.integer(forKey: DefaultsKeys.numberOfActiveTask) > 0){
            returnTaskBtn.isHidden = false
        }else{
            returnTaskBtn.isHidden = true
        }
        
    }
    
    private func reportIncomingCall(withUserIDs userIDs: [NSNumber], outCallerName: String, session: QBRTCSession, uuid: UUID) {
        makeScreenNormal()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "removeAudioViewOnCall"), object: nil,userInfo: nil)

        if hasConnectivity() {
            CallKitManager.instance.reportIncomingCall(withUserIDs: userIDs,
                                                       outCallerName: outCallerName,
                                                       session: session,
                                                       sessionID: session.id,
                                                       sessionConferenceType: session.conferenceType,
                                                       uuid: uuid,
                                                       onAcceptAction: { [weak self] (isAccept) in
                                                        guard let self = self else {
                                                            return
                                                        }
                                                        if isAccept == true {
                                                            self.openCall(withSession: session, uuid: uuid, sessionConferenceType: session.conferenceType)
                                                        } else {
                                                            debugPrint("[UsersViewController] endCall reportIncomingCall")
                                                        }
                                                        
                }, completion: { (isOpen) in
                    debugPrint("[UsersViewController] callKit did presented")
            })
        } else {
            
        }
    }
    
    private func openCall(withSession session: QBRTCSession?, uuid: UUID, sessionConferenceType: QBRTCConferenceType) {
        if hasConnectivity() {

            if let callViewController = UIStoryboard(name: "Call", bundle: nil).instantiateViewController(withIdentifier: UsersSegueConstant.call) as? CallViewController {
                if let qbSession = session {
                    callViewController.session = qbSession
                }
                
                callViewController.usersDataSource = self.dataSource
                callViewController.callUUID = uuid
                callViewController.sessionConferenceType = sessionConferenceType
                callViewController.modalPresentationStyle = .fullScreen
                UIApplication.shared.windows.first!.rootViewController?.present(callViewController, animated: true, completion: nil)
                
            } else {
                return
            }
        } else {
            return
        }
    }
    
    func sessionDidClose(_ session: QBRTCSession) {
        if let sessionID = self.session?.id,
            sessionID == session.id {
            if let endedCall = CallKitManager.instance.currentCall() {
                CallKitManager.instance.endCall(with: endedCall.uuid) {
                    debugPrint("[UsersViewController] endCall sessionDidClose")
                }
            }
            prepareCloseCall()
        }
    }
    
    private func prepareCloseCall() {
        if ChatViewController.isScreenVisible {
            self.navigationController?.dismiss(animated: true, completion: nil)
        }else{
            UIApplication.shared.windows.first!.rootViewController?.dismiss(animated: true, completion: nil)

        }
        self.callUUID = nil
        self.session = nil
        self.sessionID = nil
        if QBChat.instance.isConnected == false {
            self.connectToChat()
        }

    }

}


extension TaskCreationViewController: PKPushRegistryDelegate {
    // MARK: - PKPushRegistryDelegate
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        guard let voipToken = registry.pushToken(for: .voIP) else {
            return
        }
        guard let deviceIdentifier = UIDevice.current.identifierForVendor?.uuidString else {
            return
        }
        let subscription = QBMSubscription()
        subscription.notificationChannel = .APNSVOIP
        subscription.deviceUDID = deviceIdentifier
        subscription.deviceToken = voipToken
        
        QBRequest.createSubscription(subscription, successBlock: { response, objects in
            debugPrint("[UsersViewController] Create Subscription request - Success")
        }, errorBlock: { response in
            debugPrint("[UsersViewController] Create Subscription request - Error")
        })
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        guard let deviceIdentifier = UIDevice.current.identifierForVendor?.uuidString else {
            return
        }
        QBRequest.unregisterSubscription(forUniqueDeviceIdentifier: deviceIdentifier, successBlock: { response in
            UIApplication.shared.unregisterForRemoteNotifications()
            debugPrint("[UsersViewController] Unregister Subscription request - Success")
        }, errorBlock: { error in
            debugPrint("[UsersViewController] Unregister Subscription request - Error")
        })
    }
    
    func pushRegistry(_ registry: PKPushRegistry,
                      didReceiveIncomingPushWith payload: PKPushPayload,
                      for type: PKPushType,
                      completion: @escaping () -> Void) {
        
        
        //in case of bad internet we check how long the VOIP Push was delivered for call(1-1)
        //if time delivery is more than “answerTimeInterval” - return
        if type == .voIP,
            payload.dictionaryPayload[UsersConstant.voipEvent] != nil {
            if let timeStampString = payload.dictionaryPayload["timestamp"] as? String,
                let opponentsIDsString = payload.dictionaryPayload["opponentsIDs"] as? String {
                let opponentsIDsArray = opponentsIDsString.components(separatedBy: ",")
                if opponentsIDsArray.count == 2 {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    if let startCallDate = formatter.date(from: timeStampString) {
                        if Date().timeIntervalSince(startCallDate) > QBRTCConfig.answerTimeInterval() {
                            debugPrint("[UsersViewController] timeIntervalSinceStartCall > QBRTCConfig.answerTimeInterval")
                            return
                        }
                    }
                }
            }
        }

        let application = UIApplication.shared
        if type == .voIP,
            payload.dictionaryPayload[UsersConstant.voipEvent] != nil,
            application.applicationState == .background {
            var opponentsIDs: [String]? = nil
            var opponentsNumberIDs: [NSNumber] = []
            var opponentsNamesString = "incoming call. Connecting..."
            var sessionID: String? = nil
            var callUUID = UUID()
            var sessionConferenceType = QBRTCConferenceType.audio
            self.isUpdatedPayload = false
            
            if let opponentsIDsString = payload.dictionaryPayload["opponentsIDs"] as? String,
                let allOpponentsNamesString = payload.dictionaryPayload["contactIdentifier"] as? String,
                let sessionIDString = payload.dictionaryPayload["sessionID"] as? String,
                let callUUIDPayload = UUID(uuidString: sessionIDString) {
                self.isUpdatedPayload = true
                self.sessionID = sessionIDString
                sessionID = sessionIDString
                callUUID = callUUIDPayload
                if let conferenceTypeString = payload.dictionaryPayload["conferenceType"] as? String {
                    sessionConferenceType = conferenceTypeString == "1" ? QBRTCConferenceType.video : QBRTCConferenceType.audio
                }
                
                let profile = Profile()
                guard profile.isFull == true else {
                    return
                }
                
                let opponentsIDsArray = opponentsIDsString.components(separatedBy: ",")
                
                var opponentsNumberIDsArray = opponentsIDsArray.compactMap({NSNumber(value: Int($0)!)})
                var allOpponentsNamesArray = allOpponentsNamesString.components(separatedBy: ",")
                for i in 0...opponentsNumberIDsArray.count - 1 {
                    if opponentsNumberIDsArray[i].uintValue == profile.ID {
                        opponentsNumberIDsArray.remove(at: i)
                        allOpponentsNamesArray.remove(at: i)
                        break
                    }
                }
                opponentsNumberIDs = opponentsNumberIDsArray
                opponentsIDs = opponentsNumberIDs.compactMap({ $0.stringValue })
                opponentsNamesString = allOpponentsNamesArray.joined(separator: ", ")
            }
            
            let fetchUsersCompletion = { [weak self] (usersIDs: [String]?) -> Void in
                if let opponentsIDs = usersIDs {
                    QBRequest.users(withIDs: opponentsIDs, page: nil, successBlock: { [weak self] (respose, page, users) in
                        if users.isEmpty == false {
                            self?.dataSource.update(users: users)
                        }
                    }) { (response) in
                        debugPrint("[UsersViewController] error fetch usersWithIDs")
                    }
                }
            }

            self.setupAnswerTimerWithTimeInterval(QBRTCConfig.answerTimeInterval())
            CallKitManager.instance.reportIncomingCall(withUserIDs: opponentsNumberIDs,
                                                       outCallerName: opponentsNamesString,
                                                       session: nil,
                                                       sessionID: sessionID,
                                                       sessionConferenceType: sessionConferenceType,
                                                       uuid: callUUID,
                                                       onAcceptAction: { [weak self] (isAccept) in
                                                        guard let self = self else {
                                                            return
                                                        }
                                                        
                                                        if let session = self.session {
                                                            if isAccept == true {
                                                                self.openCall(withSession: session,
                                                                              uuid: callUUID,
                                                                              sessionConferenceType: sessionConferenceType)
                                                                debugPrint("[UsersViewController]  onAcceptAction")
                                                            } else {
                                                                session.rejectCall(["reject": "busy"])
                                                                debugPrint("[UsersViewController] endCallAction")
                                                            }
                                                        } else {
                                                            if isAccept == true {
                                                                self.openCall(withSession: nil,
                                                                              uuid: callUUID,
                                                                              sessionConferenceType: sessionConferenceType)
                                                                debugPrint("[UsersViewController]  onAcceptAction")
                                                            } else {
                                                                
                                                                debugPrint("[UsersViewController] endCallAction")
                                                            }
                                                            self.setupAnswerTimerWithTimeInterval(UsersConstant.answerInterval)
                                                            self.prepareBackgroundTask()
                                                        }
                                                        completion()
                                                        
                }, completion: { (isOpen) in
                    self.prepareBackgroundTask()
                    self.setupAnswerTimerWithTimeInterval(QBRTCConfig.answerTimeInterval())
                    if QBChat.instance.isConnected == false {
                        self.connectToChat { (error) in
                            if error == nil {
                                fetchUsersCompletion(opponentsIDs)
                            }
                        }
                    } else {
                        fetchUsersCompletion(opponentsIDs)
                    }
                    debugPrint("[UsersViewController] callKit did presented")
            })
        }
    }
    
}
