//
//  InputAccessoryView.swift
//  Moody_Posterv2.0
//
//  Created by Umer yasin on 05/06/2021.
//

import Foundation
import InputBarAccessoryView
import CoreLocation


extension ChatViewController : InputBarAccessoryViewDelegate{
    
    
    //MARK: Text Input send button press
    //. sendMesage method call
    //. trimmed text and taskId sent to sendMessage function
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        sendMessage(message: trimmed,index: 0, taskId: UserDefaults.standard.string(forKey: DefaultsKeys.taskId) ?? "")
        inputBar.inputTextView.text = ""
    }
    
    //MARK: create send message dictionary
    func creatSendMessageDictionary(message: String, taskId:String)->[String:Any]{
        var dictionary = [String:Any]()
        dictionary["task_id"] = taskId
        dictionary["text_message"] = message
        dictionary["user_agent"] = AppPermission.getDeviceInfo()
        dictionary["platform"] = "ios"
        return dictionary
    }
    
    //MARK: Send Message function
    func sendMessage(message: String,index:Int, taskId:String){
        //if internet is avalianble add images locally and maintain its data and state
        //if index is not zero add image in chat and get its index then call api after 200 response of api that saved index is releaded and change message
        //state from sending to sent.
        // if api faliure add locally and retry after internet connection becomes stable or comes in chat view
        var indexqw = index
        if(index != 0){
            indexqw = index
        }else{
            indexqw = addinChat(message: message)
        }
        if CheckInternet.Connection() {
           
            ApiManager.sharedInstance.apiCaller(hasBodyData: true, hasToken: true, url: ENDPOINTS.send_message, dictionary: creatSendMessageDictionary(message: message,taskId: taskId), httpMethod: "POST", token: UserDefaults.standard.string(forKey: DefaultsKeys.token)) { [self] Result in
                switch Result{
                case .success(let response):
                    
                    isMessageSend = true
                    if(ChatViewController.isScreenVisible && UserDefaults.standard.string(forKey: DefaultsKeys.taskId) == taskId){
                        
                        addTextMessage(messageId: "\(response["message_id"] as! String)", role: "is_poster", textMessage: message,index: indexqw,is_notified: false,time: "\(response["message_time"] as! String)", title: "")
                    }
                    
                    let hideMessageView = response["send_message"] as? Bool ?? true
                    
                    if(!hideMessageView){
                        DispatchQueue.main.async {
                            messageInputBar.isHidden = true
                            dismissKeyboard()
                        }
                    }
                    
                    break
                case .failure(_):
                    isMessageSend = false
                    addMessageLocally(message: message, type: "text", index: indexqw, localImage: Data(), location: "")
                    DispatchQueue.main.async {
                        self.showToast(message: NSLocalizedString("Message not Send please Try again Later", comment: ""), font: UIFont.boldSystemFont(ofSize: 17))
                    }
                    
                    break
                }
            }
        }else {
            addMessageLocally(message: message, type: "text", index: indexqw, localImage: Data(), location: "")
        }
        
    }
    

    
    //MARK: add messages in chat screen and waiting for
    func addinChat(message:String) -> Int{
        messages.append(Messgae(sender: checkSenderType(senderType: "is_poster", botTitle: ""), messageId: "0", sentDate: Date(), kind: .text("\(String(describing: message))"), downloadURL: ""))
        notifyBool.append(false)
        notifyStatus.append("sending")
        messagesTime.append("\(Date())")
        DispatchQueue.main.async { [self] in
            reloadAfterSending()
        }
        return messages.count - 1
    }
    
    //MARK: add text Message in Local Storage
    func addMessageLocally(message:String,type:String,index:Int,localImage:Data, location:String){
        localMessages.append(message)
        localmessageType.append(type)
        localIndex.append(index)
        localImageData.append(localImage)
        localLocation.append(location)
        localMessageTaskId.append(UserDefaults.standard.string(forKey: DefaultsKeys.taskId)!)
        
        
        UserDefaults.standard.setValue(localMessages, forKey: DefaultsKeys.localMessages)
        UserDefaults.standard.setValue(localmessageType, forKey: DefaultsKeys.localmessageType)
        UserDefaults.standard.setValue(localIndex, forKey: DefaultsKeys.localIndex)
        UserDefaults.standard.setValue(localImageData, forKey: DefaultsKeys.localImageData)
        UserDefaults.standard.setValue(localLocation, forKey: DefaultsKeys.localLocation)
        UserDefaults.standard.setValue(localMessageTaskId, forKey: DefaultsKeys.localTaskId)
        

    }
    
    func reloadAfterSending(){
        messagesCollectionView.scrollToLastItem(animated: true)
        messagesCollectionView.performBatchUpdates({
            messagesCollectionView.insertSections([messages.count - 1])
            if messages.count >= 2 {
                messagesCollectionView.reloadSections([messages.count - 2])
            }
        }, completion: { [weak self] _ in
            if self?.isLastSectionVisible() == true {
                self?.messagesCollectionView.scrollToLastItem(animated: true)
            }
        })
    }
    
    func isLastSectionVisible() -> Bool {
        
        guard !messages.isEmpty else { return false }
        
        let lastIndexPath = IndexPath(item: 0, section: messages.count - 1)
        
        return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
    }
    
    
    
    //MARK: scrolls to last in chat
    func inputBar(_ inputBar: InputBarAccessoryView, didChangeIntrinsicContentTo size: CGSize) {
        messagesCollectionView.scrollToLastItem()
    }
    
    
    //MARK: Delegate method detects change in text inputBar
    //. if count is 0 all input are setup
    //. if count not 0 make input button hide and change in views
    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
        if(inputBar.inputTextView.text.count == 0){
            setupInputButton()
        }else{
            messageInputBar.sendButton.isHidden = false
            messageInputBar.rightStackView.isHidden = false
            messageInputBar.setRightStackViewWidthConstant(to: 40, animated: true)
            setSendBtn()
            messageInputBar.setStackViewItems([messageInputBar.sendButton], forStack: .right, animated: true)
        }
        
        
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, didSwipeTextViewWith gesture: UISwipeGestureRecognizer) {
        //print"4")
        
    }
    
    
    
    //MARK: bottom stack custom buttons setup and also their on click actions.
    func setupInputButton() {
        
        createButton(buttonName: cameraButton,
                     widths: 40,
                     heights: 40,
                     backgroundColor: UIColor(named: "MessageBackgroundColor")!,
                     title: "",
                     titleColor: .clear,
                     isHidden: false,
                     action: #selector(onclickCameraButton),
                     backgroundImage: UIImage(named: "camera")!,
                     cornerRadius: 10,
                     leftMargin: 0)
        
        createButton(buttonName: attachmentButton,
                     widths: 40,
                     heights: 40,
                     backgroundColor: UIColor(named: "MessageBackgroundColor")!,
                     title: "",
                     titleColor: .clear,
                     isHidden: false,
                     action: #selector(onClickAttachment),
                     backgroundImage: UIImage(named: "attachment")!,
                     cornerRadius: 0,
                     leftMargin: 0)
        
        
        createButton(buttonName: voiceButton,
                     widths: 40,
                     heights: 40,
                     backgroundColor: UIColor(named: "MessageBackgroundColor")!,
                     title: "",
                     titleColor: .clear,
                     isHidden: false,
                     action: #selector(onclickAudioRecordingButton),
                     backgroundImage: UIImage(named: "micc")!,
                     cornerRadius: 0,
                     leftMargin: 0)
        

        setupInputBar()
    }
    
    //MARK: setupInput bar
    func setupInputBar(){
        
        setSendBtn()
        messageInputBar.setRightStackViewWidthConstant(to: 100, animated: false)
        
        messageInputBar.rightStackView.contentMode = .left
        messageInputBar.rightStackView.semanticContentAttribute = .forceLeftToRight
        
        messageInputBar.setStackViewItems([voiceButton,cameraButton,messageInputBar.sendButton], forStack: .right, animated: false) // setting up right stack

        messageInputBar.inputTextView.placeholder = NSLocalizedString("Type your message here", comment: "") // message input bar placeholder
        messageInputBar.inputTextView.textAlignment = .left
            
        messageInputBar.middleContentViewPadding.top = 10
        messageInputBar.inputTextView.centerYAnchor.constraint(equalTo: self.messageInputBar.middleContentView!.centerYAnchor).isActive = true
        
        
        messageInputBar.middleContentView?.backgroundColor = UIColor(named: "MessageBackgroundColor")!
        messageInputBar.middleContentViewPadding.right = -1
        messageInputBar.middleContentView?.layer.cornerRadius = 4
        
    }
    
    
    //MARK: Sets send button in input text view to send message
    func setSendBtn(){
        messageInputBar.sendButton.setImage(UIImage(named: "send"), for: .normal)
        messageInputBar.sendButton.setTitle("", for: .normal)
        messageInputBar.sendButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: -8)
        var buttonSize = CGSize()
        buttonSize.width = CGFloat(35)
        buttonSize.height = CGFloat(50)
        
        messageInputBar.sendButton.setSize(buttonSize, animated: false)
    }
    
    //MARK: create buttons
    func createButton(buttonName:InputBarButtonItem,widths:Float,heights:Float,backgroundColor:UIColor,title:String,titleColor:UIColor,isHidden:Bool,action:Selector,backgroundImage:UIImage,cornerRadius:CGFloat,leftMargin:CGFloat){
        
        var buttonSize = CGSize()
        buttonSize.width = CGFloat(widths)
        buttonSize.height = CGFloat(heights)
        buttonName.setSize(buttonSize, animated: false)
        buttonName.backgroundColor = backgroundColor
        buttonName.setTitle(title, for: .normal)
        buttonName.setTitleColor(UIColor.white, for: .normal)
        buttonName.contentHorizontalAlignment = .center
        buttonName.contentEdgeInsets = UIEdgeInsets(top: 0, left: leftMargin, bottom: 0, right: 0)
        buttonName.isHidden = isHidden
        buttonName.setImage(backgroundImage, for: .normal)
        buttonName.addTarget(self, action: action, for: .touchUpInside)
        
    }
    
    //MARK: onClick to camera button in inputBar
    //. Opens actionsheet to choose gallery/camera
    @objc func onclickCameraButton(){
        cameraButton.isUserInteractionEnabled = false
        makeButtonsNormal()
        self.audioController.stopAnyOngoingPlaying()
        self.messageInputBar.inputTextView.resignFirstResponder()
        self.presentInputActionSheet()
    }
    
    //MARK: onClick to audio button in inputBar
    //. opens recorder view
    //. starts recording
    @objc func onclickAudioRecordingButton(){
        voiceButton.isUserInteractionEnabled = false
        makeButtonsNormal()
        self.audioController.stopAnyOngoingPlaying()
        self.messageInputBar.inputTextView.resignFirstResponder()
        if recorder.isRecording{
            
        } else{
            recorder.record()
            setTimerAndAddAudioView()
        }
    }
    
    //MARK: Sets Timer of recorder
    func setTimerAndAddAudioView(){
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateDuration), userInfo: nil, repeats: true)
        
        customView = self.getContentView()
        setUpBlackBackSubView()
        setUpButtonsAndViews()
        
    }
    
    //MARK: Starts updating timer of recorder
    //. enables send button after 1 sec
    //. send audio directly/ after 60 sec audio sends automaticvally
    //. stops recorder after sending
    @objc func updateDuration() {
        
        if recorder.isRecording && !recorder.isPlaying{
            duration += 1
            let AudioTImer = (customView.viewWithTag(7)) as! UILabel
            //timer for audio length
        
                
                if(Int(duration) > 1){
                    SendButton.isEnabled = true
                }
                if(Int(duration) > 9){
                    AudioTImer.text = "\(min):\(Int(duration))"
                }else{
                    AudioTImer.text = "\(min):0\(Int(duration))"
                }
                if(Int(duration) > 58){
                    directSend()
                    timer?.invalidate()
                    recorder.stopRecording()
                    duration = 0.0
                }
        }else{
            timer?.invalidate()
            duration = 0.0
        }
        //timer for audio length
    }
    
    
//MARK: TaskerLocation button in option list naviagtes to maps with updated tasker location
    @objc func onClickTaskerLocation(){
        if(CheckInternet.Connection()){
            makeButtonsNormal()
            taskerLocationButton.isEnabled = false
            self.audioController.stopAnyOngoingPlaying()
            addLoaderWhileFetching(flag: true)
            getTaskLocationsAPICall()

        }else{
            DispatchQueue.main.async { [self] in
                makeButtonsNormal()
                taskerLocationButton.isEnabled = true
                presentAlert(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString( "Please check your internet connection and try again.", comment: ""), parentController: self)
            }
        }
    }
    
    
    //MARK:  For sending your current location
    //. Share location alert popup
    //. get updated location from LocationManager
    //. Sends location coordinates
    @objc func onClickAttachment(){
        
        let ocl = LocationManagers.locationSharesInstance.getUpdatedLocation()
        
        makeButtonsNormal()
        self.audioController.stopAnyOngoingPlaying()
        let vc = AlertService().presentSimpleAlert( title: NSLocalizedString("Share Location!", comment: ""),
                                                    message: NSLocalizedString("Are you sure want to share location.", comment: ""),
                                                    image: UIImage(named: "dropoff")!,
                                                    yesBtnText: NSLocalizedString("share", comment: ""),
                                                    noBtnStr: NSLocalizedString("Back", comment: "")){ [self] in
            
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                if(ocl.coordinate.latitude == 0.0 || ocl.coordinate.longitude == 0.0){
                    let ocl = LocationManagers.locationSharesInstance.getUpdatedLocation()
                    
                    sendLocation(message: "\(ocl.coordinate.latitude), \(ocl.coordinate.longitude)", index: 0, taskId:UserDefaults.standard.string(forKey: DefaultsKeys.taskId) ?? "")
                }else{
                    sendLocation(message: "\(ocl.coordinate.latitude), \(ocl.coordinate.longitude)", index: 0, taskId:UserDefaults.standard.string(forKey: DefaultsKeys.taskId) ?? "")
                }
            }
        }
        let topViewController = UIApplication.shared.windows.last?.rootViewController
        if (topViewController != nil) {
            topViewController!.present(vc, animated: true, completion: nil)
        }else{
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    //MARK:  see Receipts
    //. seee if tasker has uploaded any receipt or not
    @objc func onClickReceipt(){
        
        var dict = [String:Any]()
        dict["task_id"] = UserDefaults.standard.string(forKey:DefaultsKeys.taskId)
        makeButtonsNormal()
        ApiManager.sharedInstance.apiCaller(hasBodyData: true, hasToken: true, url: ENDPOINTS.get_task_product_receipts, dictionary: dict, httpMethod: "POST", token: UserDefaults.standard.string(forKey: DefaultsKeys.token)) { Result in
            switch Result {
            case .success(let resp):
                if resp["task_product_receipts"] != nil {
                    let productReceipts = resp["task_product_receipts"] as? [String:Any] ?? nil
                    if productReceipts != nil {
                        DispatchQueue.main.async {
                            let storyBoard = UIStoryboard(name: "TaskCreation", bundle:nil)
                            let vc = storyBoard.instantiateViewController(withIdentifier: "ShowProductReceiptViewController") as! ShowProductReceiptViewController
                            vc.productReceipts = productReceipts!["proofs"] as! [[String:Any]]
                            vc.totalAmount = String(productReceipts!["total_amount"] as? Int ?? 0)
                            vc.hidesBottomBarWhenPushed = true
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    }else{
                        self.presentAlert(title: "No Product Receipt", message: NSLocalizedString("No Product Receipt added by Tasker.", comment: ""), parentController: self)
                    }
                }
            case .failure(_):
                break
            }
        }
    }
    
    //MARK: create send message dictionary
    func createLocationDictionary(message:String,taskId:String)->[String:Any]{
        var dictionary = [String:Any]()
        dictionary["task_id"] = taskId
        dictionary["poster_location"] = message
        dictionary["user_agent"] = AppPermission.getDeviceInfo()
        dictionary["platform"] = "ios"
        return dictionary
    }
    
    //MARK: Send Message function
    func sendLocation(message: String,index:Int,taskId:String){
        //if internet is avalianble add images locally and maintain its data and state
        //if index is not zero add image in chat and get its index then call api after 200 response of api that saved index is releaded and change message
        //state from sending to sent.
        // if api faliure add locally and retry after internet connection becomes stable or comes in chat view
        DispatchQueue.global().async { [self] in

        var indexqw = index
        if(index != 0){
            indexqw = index
        }else{
            indexqw = addinChatLocation(message: message)
        }
        if CheckInternet.Connection() {

            ApiManager.sharedInstance.apiCaller(hasBodyData: true, hasToken: true, url: ENDPOINTS.send_message, dictionary: createLocationDictionary(message: message,taskId: taskId), httpMethod: "POST", token: UserDefaults.standard.string(forKey: DefaultsKeys.token)) { [self] Result in
                switch Result{
                case .success(let response):
                    
                    if(ChatViewController.isScreenVisible && UserDefaults.standard.string(forKey: DefaultsKeys.taskId) == taskId){
                        addlocationInChat(messageId: "\(response["message_id"] as! String)", role: "is_poster", location: message, index: indexqw, is_notified: false, time: "\(response["message_time"] as! String)", title: "")
                    }
                   
                    LocationManagers.locationSharesInstance.stopLocationUpdate()
                    break
                case .failure(_):
                    addMessageLocally(message: message, type: "location", index: indexqw, localImage: Data(), location: message)
                    DispatchQueue.main.async {
                        self.showToast(message: NSLocalizedString("Message not Send please Try again Later", comment: ""), font: UIFont.boldSystemFont(ofSize: 17))
                    }
                    break
                }
            }
        } else {
            addMessageLocally(message: message, type: "location", index: indexqw, localImage: Data(), location: message)
        }
        }
    }
    
    //MARK: add messages in chat screen and waiting for
    func addinChatLocation(message:String) -> Int{
        let dropOff:String = message
        let latLong = dropOff.split(separator: ",")
        let dropOffLatitude = Double(latLong[0])!
        let dropOffLongitude = Double(latLong[1].split(separator: " ")[0])!
        let loc = CLLocation(latitude: dropOffLatitude, longitude: dropOffLongitude)
        messages.append(Messgae(sender: checkSenderType(senderType: "is_poster", botTitle: ""), messageId: "0", sentDate: Date(), kind: .location(CoordinateItem(location: loc)), downloadURL: ""))
        notifyBool.append(false)
        notifyStatus.append("sending")
        messagesTime.append("\(Date())")
        DispatchQueue.main.async { [self] in
            reloadAfterSending()
        }
        return messages.count - 1
    }
    
}

