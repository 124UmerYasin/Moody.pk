//
//  InputAccessoryView.swift
//  Moody_Posterv2.0
//
//

import Foundation
import InputBarAccessoryView


extension CustomerSupport : InputBarAccessoryViewDelegate{
    
    //MARK: send message in chat on click send button
    // .trim empty spaces.
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        sendMessage(message: trimmed,index: 0)
        inputBar.inputTextView.text = ""
    }
    
    //MARK: create send message dictionary
    func creatSendMessageDictionary(message: String)->[String:Any]{
        var dictionary = [String:Any]()
        dictionary["ticket_id"] = ticket_id
        dictionary["text_message"] = message
        dictionary["user_agent"] = AppPermission.getDeviceInfo()
        dictionary["platform"] = "ios"
        return dictionary
    }
    
    //MARK: Send Message function
    func sendMessage(message: String,index:Int){
        var indexqw = index
            if(index != 0){
                indexqw = index
            }else{
                indexqw = addinChat(message: message)
            }
        if CheckInternet.Connection() {
            
            ApiManager.sharedInstance.apiCaller(hasBodyData: true, hasToken: true, url: ENDPOINTS.sendTicketMessage, dictionary: creatSendMessageDictionary(message: message), httpMethod: "POST", token: UserDefaults.standard.string(forKey: DefaultsKeys.token)) { [self] Result in
                switch Result{
                case .success(let response):
                    addTextMessage(messageId: "\(response["message_id"] as! String)", role: "is_poster", textMessage: message,index: indexqw,is_notified: false,time: "\(response["message_time"] as! String)")
                    break
                case .failure(let error):
                    DispatchQueue.main.async {
                        presentAlert(title: NSLocalizedString("Message Sending Failed", comment: ""), message: NSLocalizedString( error.title, comment: ""), parentController: self)
                    }
                    break
                }
            }
        } else {
            addMessageLocally(message: message, type: "text", index: indexqw, localImage: Data())
        }
    }
    
    //MARK: add messages in chat screen and waiting for
    func addinChat(message:String) -> Int{
        messages.append(Messgae(sender: checkSenderType(senderType: "is_poster"), messageId: "0", sentDate: Date(), kind: .text("\(String(describing: message))"), downloadURL: ""))
        notifyBool.append(false)
        notifyStatus.append("sending")
        messagesTime.append("\(Date())")
        DispatchQueue.main.async { [self] in
            reloadAfterSending()
        }
        return messages.count - 1
    }
    
    //MARK: add text Message in Local Storage
    func addMessageLocally(message:String,type:String,index:Int,localImage:Data){
        localMessages.append(message)
        localmessageType.append(type)
        localIndex.append(index)
        localImageData.append(localImage)
    }
    
    //MARK: reload the chat view last two messages to display the latest messages.
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
    
    //MARK: return bool if the last section of chat is visible or not.
    func isLastSectionVisible() -> Bool {
        
        guard !messages.isEmpty else { return false }
        
        let lastIndexPath = IndexPath(item: 0, section: messages.count - 1)
        
        return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
    }
    
    //MARK: notifies when size of input bar is changes.
    func inputBar(_ inputBar: InputBarAccessoryView, didChangeIntrinsicContentTo size: CGSize) {
        print("2")
    }
    
    //MARK: notifies when the characters count in text field is changing or not in input bar view.
    // - on the basis of the we show and hide audio and gallery button.
    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
        if(inputBar.inputTextView.text.count == 0){
            setupInputButton()
        }else{
            messageInputBar.sendButton.isHidden = false
            messageInputBar.rightStackView.isHidden = false
            messageInputBar.setRightStackViewWidthConstant(to: 70, animated: true)
            setSendBtn()
            //messageInputBar.setRightStackViewWidthConstant(to: 40, animated: true)
            messageInputBar.setStackViewItems([messageInputBar.sendButton], forStack: .right, animated: true) // setting up stack
        }

    }
    
    //MARK: delegate method of InputBarAccessoryView to get any gesture event.
    func inputBar(_ inputBar: InputBarAccessoryView, didSwipeTextViewWith gesture: UISwipeGestureRecognizer) {
        print("4")

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
                     action: #selector(onclickCameraButton),
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
        messageInputBar.setRightStackViewWidthConstant(to: 134, animated: false)
        messageInputBar.rightStackView.contentMode = .left
        messageInputBar.rightStackView.semanticContentAttribute = .forceLeftToRight
        
        messageInputBar.setStackViewItems([voiceButton,cameraButton,messageInputBar.sendButton], forStack: .right, animated: false) // setting up right stack

        messageInputBar.inputTextView.placeholder = NSLocalizedString("Type Here", comment: "") // message input bar placeholder
        messageInputBar.inputTextView.textAlignment = .left
            
        messageInputBar.middleContentViewPadding.top = 10
        messageInputBar.inputTextView.centerYAnchor.constraint(equalTo: self.messageInputBar.middleContentView!.centerYAnchor).isActive = true
        
        messageInputBar.middleContentView?.backgroundColor = UIColor(named: "MessageBackgroundColor")!
        messageInputBar.middleContentViewPadding.right = -1
        messageInputBar.middleContentView?.layer.cornerRadius = 4
        
    }
    
    //MARK: create buttons
    func createButton(buttonName:InputBarButtonItem,widths:Float,heights:Float,backgroundColor:UIColor,title:String,titleColor:UIColor,isHidden:Bool,action:Selector,backgroundImage:UIImage,cornerRadius:CGFloat,leftMargin:CGFloat){
        
        var buttonSize = CGSize()
        buttonSize.width = CGFloat(widths)
        buttonSize.height = CGFloat(heights)
        buttonName.setSize(buttonSize, animated: false)
        buttonName.backgroundColor = backgroundColor
        buttonName.setTitle(title, for: .normal)
        buttonName.contentHorizontalAlignment = .center
        buttonName.contentEdgeInsets = UIEdgeInsets(top: 0, left: leftMargin, bottom: 0, right: 0)
        buttonName.isHidden = isHidden
        buttonName.setImage(backgroundImage, for: .normal)
        buttonName.addTarget(self, action: action, for: .touchUpInside)
        
    }
    
    //MARK: congigure send button sizes and text.
    func setSendBtn(){
        messageInputBar.sendButton.setImage(UIImage(named: "send"), for: .normal)
        messageInputBar.sendButton.setTitle("", for: .normal)
        messageInputBar.sendButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        var buttonSize = CGSize()
        buttonSize.width = CGFloat(50)
        buttonSize.height = CGFloat(50)
        
        messageInputBar.sendButton.setSize(buttonSize, animated: false)
    }
    
 
    // MARK: on click fucntion of camera button
    @objc func onclickCameraButton(){
        self.audioController.stopAnyOngoingPlaying()
        self.messageInputBar.inputTextView.resignFirstResponder()
        self.presentInputActionSheet()
    }
    @objc func onClickEndTaskButton(){}
    
    //MARK: on click event of audio button to start recording.
    @objc func onclickAudioRecordingButton(){
        self.audioController.stopAnyOngoingPlaying()
        self.messageInputBar.inputTextView.resignFirstResponder()
        if recorder.isRecording{
            
        } else{
            recorder.record()
            setTimerAndAddAudioView()
        }
    }
    
    // MARK: start timer for audio recorder and setup audio views.
    func setTimerAndAddAudioView(){
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateDuration), userInfo: nil, repeats: true)
        
        customView = self.getContentView()
        setUpBlackBackSubView()
        setUpButtonsAndViews()
        
    }
    
    //MARK: update audio timer
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
    @objc func onClickTaskerLocation(){}
    @objc func onClickChronometer(){}
    
    // MARK: add loader when loading chat.
    func addLoaderWhileFetching(flag:Bool){
        if(flag){
            DispatchQueue.main.async { [self] in
                cancelButton.isEnabled = false
                loadingIndicator.center = CGPoint(x: self.messagesCollectionView.frame.size.width  / 2, y: self.messagesCollectionView.frame.size.height / 2)
                self.messagesCollectionView.addSubview(loadingIndicator)
              //  self.messageInputBar.isUserInteractionEnabled = false
             
                //self.navigationController?.navigationBar.isUserInteractionEnabled = false
                loadingIndicator.hidesWhenStopped = true
                loadingIndicator.style = UIActivityIndicatorView.Style.gray
                loadingIndicator.startAnimating()
            }
        }else{
            DispatchQueue.main.async { [self] in
                loadingIndicator.stopAnimating()
                cancelButton.isEnabled = true
                self.messageInputBar.isUserInteractionEnabled = true
                //self.navigationController?.navigationBar.isUserInteractionEnabled = true
                loadingIndicator.removeFromSuperview()
            }
        }

    }
    
}
