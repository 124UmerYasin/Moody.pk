//
//  CustomerSupport.swift
//  Moody_Posterv2.0
//
//  Created by Syed Muhammad bin Saadat on 07/06/2021.
//

import Foundation
import UIKit
import MessageKit
import InputBarAccessoryView
import AVFoundation
import ReplayKit
import MobileCoreServices
import Lightbox


//MARK: protocol for re rendering chat of new chat in same view.
protocol RenderDelegate {
    func onRenderNewChat(type: [String:Any])
}

//MARK: protocol for adding new message in chat.
protocol addSocketMessagecs {
    func addSocketMessagecs(type: [String:Any])
}

//MARK: protocol for adding new socket message.
protocol newMessageCS{
    func onNewMessagecs()

}

class CustomerSupport: MessagesViewController, MessagesDataSource , RenderDelegate, addSocketMessagecs,newMessageCS,LightboxControllerPageDelegate,LightboxControllerDismissalDelegate{
   
    
    
    

    static var isScreenVisible:Bool = false
    
    var messageList = [[String:Any]]()
    var messages = [MessageType]()
    var messagesDictionary = [String : Any]()
    var messagesDictionaryText = [String]()
    var ticketDictionary = [String : Any]()
    static var camBool = false
    var ticket_id = String()
    var ticketIdForChat = String()
    var status = Bool()
    var ticketStatus = "open"
    var smallTicketId = ""

    let currentUser = sender(senderId: "Self", displayName: NSLocalizedString("Me", comment: ""))
    let otherUser = sender(senderId: "other", displayName:  NSLocalizedString("Tasker", comment: ""))
    let deo = sender(senderId: "deo", displayName:  NSLocalizedString("Customer Support", comment: ""))
    
    lazy var audioController = BasicAudioController(messageCollectionView: messagesCollectionView)
    var notifyStatus = [String]()
    var notifyBool = [Bool]()
    var messagesTime = [String]()
    static var customerSupportChatFlag = false
   
    
    //MARK:Chat screen butttons
    let cameraButton = InputBarButtonItem()
    let voiceButton = InputBarButtonItem()
    let attachmentButton = InputBarButtonItem()
    let endTaskButton = InputBarButtonItem()
    let taskerLocationButton = InputBarButtonItem()
    let chronometerButton = InputBarButtonItem()
    
    var SendButton:UIButton!
    
    //MARK: navigation bar buttons
   // let btnMenu = UIBarButtonItem(image:#imageLiteral(resourceName: "menu-black"), style: .plain, target: self, action: #selector(btnMenuAction))
    let taskerName = UILabel()
    let cancelButton = UIButton(frame: CGRect(x: 0, y: 0, width: 72, height: 28))
    
    var imgAndVideoData = [Data]()
    var imgData:Data?
    
    var localMessages = [String]()
    var localmessageType = [String]()
    var localIndex = [Int]()
    var localImageData = [Data]()
    
    
    //MARK: custom audio recording view and it timer , audio recorder
    var customView = UIView()
    var timer:Timer?
    var time:Int = 0
    var audioRecorder: AVAudioRecorder!
    var audioSession:AVAudioSession!
    var min:Int = 00
    var audioFilename:URL?
    var base64String:URL?
    
    var fileManager : FileManager?
    var documentDir : NSString?
    var filePath : NSString?
    var docNamePath:String?
    static var id = 0
    var localLinkDoc:String?
    
    
    var myPickerController:UIImagePickerController = UIImagePickerController()
    let endQueryBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
    let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 300, height: 300))
    
    let backButton1 =  UIButton(frame: CGRect(x: -10, y: 0, width: 70, height: 60))
    var back = UIBarButtonItem()
    var back1 = UIBarButtonItem()
    var isFromNotification:Bool = false
    
    let vc = UIApplication.shared.delegate as! AppDelegate

    
    var recorder = AKAudioRecorder.shared
    var displayLink = CADisplayLink()
    var duration : CGFloat = 0.0
    var imageView =  UIImageView()

    weak var task: URLSessionDownloadTask?
    var backgroundSessionCompletionHandler: (() -> Void)?
    lazy var downloadsSession: URLSession = { [weak self] in
        let configuration = URLSessionConfiguration.background(withIdentifier:"\(UIDevice.current.identifierForVendor!.uuidString)\(NSDate())")
        configuration.timeoutIntervalForRequest = .infinity
        configuration.timeoutIntervalForResource = .infinity
        return Foundation.URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()
    
    //MARK: calls when first time View Loads
    //. Set NavigationBar Apperance
    //. Set Protocols Delegates
    //. Establish Socket Connection
    //. set CustomerSupport View Delegates
    //. Register NotifactionObservers
    //. SetNavigationBar btn
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUiBarAppearance()
        setProtocolDelegates()
        
        navigationController?.isNavigationBarHidden = false
        CustomerSupport.customerSupportChatFlag = true
        UserDefaults.standard.setValue(ticket_id, forKey: DefaultsKeys.ticketId)
        messagesDictionary.removeAll()
        setAudioSession()
        viewInilization()
        setChatViewDelegates()
        registerNotifications()
        SocketsManager.sharesInstance.establishSocketConnection()
        SocketsManager.sharesInstance.socket.setReconnecting(reason: "i was gone in background.")
        tabBarController?.tabBar.isHidden = true
        
        if(!UserDefaults.standard.bool(forKey: DefaultsKeys.isfromChatOrNot)){
            setupNavigationBarBtn()
        }
    }
    
    //MARK: Calls when view appears
    //. Sets bool
    //. Sets Navigationbar/TabBar visibility
    //. Sets navigationBar Button
    //. Set customerSupport screen delegates
    //. Set Customer Support Dict
    //. RegisterNotifaction Observers
    //. Show chat from local directory
    override func viewWillAppear(_ animated: Bool) {
        imageView.image = nil
        vc.delegate = self
        UserDefaults.standard.setValue(ticket_id, forKey: DefaultsKeys.ticketId)
        self.tabBarController?.tabBar.isHidden = true
        navigationController?.isNavigationBarHidden = false
        CustomerSupport.isScreenVisible = true
        CustomerSupport.customerSupportChatFlag = true
        
        if(!UserDefaults.standard.bool(forKey: DefaultsKeys.isfromChatOrNot)){
            setupNavigationBarBtn()
        }
        
        setCustomerSupportDict()
        setChatViewDelegates()
        setIncomingmessageViews()
        setoutgoingmessageViews()
        setupInputButton()
        setTitleOfEndQueryBtn()
        registerNotifications()
        showChat(localLink: ticket_id)
        
    }
    
    //MARK: Calls when all view is loaded
    //. query api calls
    override func viewDidAppear(_ animated: Bool) {
        createQuery()
    }
    
    //MARK: Calls after view disappers
    //. Stop onGoingCall
    //. Set bools
    //. Invalidates timer
    //. Removes Tag
    override func viewDidDisappear(_ animated: Bool) {
        closeAudio()
        UserDefaults.standard.setValue(false, forKey: DefaultsKeys.customer_support_notification)
        UserDefaults.standard.setValue(false, forKey: DefaultsKeys.isfromChatOrNot)
        UserDefaults.standard.setValue(nil, forKey: DefaultsKeys.ticketId)
        
        CustomerSupport.customerSupportChatFlag = false
        CustomerSupport.isScreenVisible = false
        self.audioController.stopAnyOngoingPlaying()
        recorder.stopRecording()
        time = 0
        timer?.invalidate()
        imageView.image = nil
        removeTags()
        
    }
    


    
    //MARK: Sets bool to update customer support if icon has badge in chat
    func setCustomerSupportDict(){
        
        let taskId = UserDefaults.standard.string(forKey: DefaultsKeys.taskId)
        let dictionary = [
            taskId: false,
        ] as? [String : Bool]
        UserDefaults.standard.setValue(dictionary, forKey: taskId ?? "")
    }
    
    
    //MARK: Removes view from superView
    func removeTags(){
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
    }

    //MARK: Sets protocol delegates 
    func setProtocolDelegates(){
        SocketsManager.sharesInstance.messageDelegatecs = self
        vc.newCSMessageDelegate = self
        vc.messageDelegatecs = self
    }
    
    //MARK: set up chat background color.
    func viewInilization(){
        messagesCollectionView.backgroundColor = UIColor(named: "MessageBackgroundColor")
        self.view.backgroundColor = .lightGray
        
    }
    //MARK: local notification registeration
    func registerNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.fetchMessageFromSocket(_:)), name: NSNotification.Name(rawValue: "CSnewMessage"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.newMessageFromCs(_:)), name: NSNotification.Name(rawValue: "newMessageCs"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.closeAudioIfRecording(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.fetchMessages(_:)), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateTick(_:)), name: NSNotification.Name(rawValue: "updateTickStatus"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.cancelAudioView(_:)), name: NSNotification.Name(rawValue: "removeAudioViewOnCall"), object: nil)


    }
    
    //MARK: Sets Audio Session of recorder
    func setAudioSession(){
        audioSession = AVAudioSession.sharedInstance()
        do{
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
            try audioSession.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)

        }catch{
            print("cannot record audio")
        }
    }
    
    //MARK: Sets NavigationBar/TabBar appearnace on ios version check
    func setUiBarAppearance(){
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white
            self.navigationController?.navigationBar.standardAppearance = appearance
            self.navigationController?.navigationBar.scrollEdgeAppearance = navigationController?.navigationBar.standardAppearance
            
            let appearance2 = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white
            self.tabBarController?.tabBar.standardAppearance = appearance2
            
        } else {
            // Fallback on earlier versions
        }
    }
    
    //MARK: objc function called when canel is pressed on audio view.
    @objc func cancelAudioView(_ notification:NSNotification){
        self.audioController.stopAnyOngoingPlaying()
        recorder.stopRecording()

        time = 0
        timer?.invalidate()
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
    }
    
    //MARK: objc function callet when ticket status button is presses
    // - if query is closed it will open it and vice versa.

    @objc func updateTick(_ notification:NSNotification){
        let ticket = notification.userInfo as! [String:Any]
        let statuss = ticket["status"] as! String
        if statuss == "open" {
            status = true
            endQueryBtn.setTitle(NSLocalizedString("Close Ticket", comment: ""), for: .normal)
            endQueryBtn.backgroundColor = .clear
            endQueryBtn.setTitleColor(UIColor.red, for: .normal)
            endQueryBtn.layer.borderColor = UIColor.red.cgColor
            
            
        } else {
            status = false
            endQueryBtn.setTitle(NSLocalizedString("Re-Open Ticket", comment: ""), for: .normal)
            endQueryBtn.backgroundColor = #colorLiteral(red: 1, green: 0.7529411765, blue: 0.262745098, alpha: 1)
            endQueryBtn.layer.borderColor = #colorLiteral(red: 1, green: 0.7529411765, blue: 0.262745098, alpha: 1)
            endQueryBtn.setTitleColor(UIColor.black, for: .normal)
        }
    }
    
    //MARK: protocol function implemnetation on to re-render new chat.
   
    func onRenderNewChat(type: [String : Any]) {
        ticket_id =  type["ticket_id"] as! String
        UserDefaults.standard.setValue(ticket_id, forKey: DefaultsKeys.ticketId)
        messagesDictionary = [String : Any]()
        messages.removeAll()
        notifyBool.removeAll()
        notifyStatus.removeAll()
        messagesTime.removeAll()
        messagesCollectionView.reloadDataAndKeepOffset()
        showChat(localLink: type["ticket_id"] as! String)
        createQuery()
    }
    
    //MARK: fetch messages from server and store in array messages of message type
    @objc func fetchMessages(_ notification:NSNotification){
        SocketsManager.sharesInstance.establishSocketConnection()
        SocketsManager.sharesInstance.socket.setReconnecting(reason: "i was gone in background.")
        createQuery()
    }
    
    //MARK: objc function called to stop audio when view is disapperaing,
    @objc func closeAudioIfRecording(_ notification:NSNotification){
        closeAudio()
    }
    //MARK: objc function called to stop audio when view is disapperaing,
    func closeAudio(){
        DispatchQueue.main.async { [self] in
            self.audioController.stopAnyOngoingPlaying()
            time = 0
            timer?.invalidate()
            if let viewWithTag = self.view.viewWithTag(121) {
                viewWithTag.removeFromSuperview()
            }else{
                print("No! SOME ERROR OCCUR WHILE removing subview")
            }
            if let viewWithTag = self.messageInputBar.viewWithTag(1212) {
                viewWithTag.removeFromSuperview()
            }else{
                print("No! SOME ERROR OCCUR WHILE removing subview")
            }
        }
    }
    
    //MARK: objc function called add message in chat from socket emmit.
    @objc func fetchMessageFromSocket(_ notification:NSNotification){
        let message = notification.userInfo as! [String:Any]
        if(UserDefaults.standard.string(forKey: DefaultsKeys.ticketId) == message["ticket_id"] as? String){
            parseChatResponse(res: [message])
        }
    }

    //MARK: to call all quesry message
    @objc func newMessageFromCs(_ notification:NSNotification){
        createQuery()
    }
    
    //MARK: message kit delegates steup.
    func setChatViewDelegates(){
        
        messageInputBar.layer.shadowOpacity = 0.3
        messageInputBar.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        messagesCollectionView.delegate = self
        showMessageTimestampOnSwipeLeft = false
        messagesCollectionView.messageCellDelegate = self
        
    }
    
    //MARK: Initilizing the navigation bar
    func setupNavigationBarBtn(){
        let backButton =  UIButton(frame: CGRect(x:0, y: 0, width: 30, height: 60))
        backButton.setImage(UIImage(named: "blackBackButton"), for: .normal)
        backButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        backButton.addTarget(self, action: #selector(backActionForSupport), for: .touchUpInside)
        back = UIBarButtonItem(customView: backButton)
        
        backButton1.setTitle("Ticket #\(ticketIdForChat)", for: .normal)
        backButton1.setTitleColor(UIColor.black, for: .normal)
        back1 = UIBarButtonItem(customView: backButton1)
        
        self.navigationItem.leftBarButtonItems = [back,back1]
        
        let newQuery = setEndQueryBtn()
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.rightBarButtonItems = [newQuery]
        
    }
    

    
    //MARK: Setup navigation bar title
    func setNevTitleBtn()-> UIBarButtonItem{
        
        let homeTitle = UILabel()
        homeTitle.attributedText = NSAttributedString(string:  NSLocalizedString("Customer Support", comment: ""), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17.0)])
        return UIBarButtonItem(customView: homeTitle)
        
    }
    

    
    //MARK: add end query to navigation bar
    func setTitleOfEndQueryBtn(){
        DispatchQueue.main.async { [self] in
            if status == true {
                endQueryBtn.setTitle(NSLocalizedString("Close Ticket", comment: ""), for: .normal)
                endQueryBtn.backgroundColor = .clear
                endQueryBtn.setTitleColor(UIColor.red, for: .normal)
                endQueryBtn.layer.borderColor = UIColor.red.cgColor
                

            } else {
                endQueryBtn.setTitle(NSLocalizedString("Re-Open Ticket", comment: ""), for: .normal)
                endQueryBtn.backgroundColor = #colorLiteral(red: 1, green: 0.7529411765, blue: 0.262745098, alpha: 1)
                endQueryBtn.layer.borderColor = #colorLiteral(red: 1, green: 0.7529411765, blue: 0.262745098, alpha: 1)
                endQueryBtn.setTitleColor(UIColor.black, for: .normal)
            }
        }
    }
    
    //MARK: end and reopen button function
    // - return button
    func setEndQueryBtn() -> UIBarButtonItem{
        endQueryBtn.titleLabel?.font = .systemFont(ofSize: 12)
        endQueryBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 2)
        endQueryBtn.frame.size.width = 100
        endQueryBtn.layer.cornerRadius = 1
        endQueryBtn.layer.borderWidth = 1
        endQueryBtn.addTarget(self, action: #selector(endQuery), for: .touchUpInside)
        let endQuery = UIBarButtonItem(customView: endQueryBtn)
        return endQuery
        
    }
    
    //MARK: dialog box appear for confermation to open and close query.
    @objc func endQuery(){
        
        
        var alertString = "Are you sure you want to close query?"
        // create the alert
        if status == true {
            alertString = "Are you sure you want to Close query"
        }
        else {
            alertString = "Are you sure you want to Open query"
        }
        let alert = UIAlertController(title: NSLocalizedString("Confirmation", comment: ""), message: NSLocalizedString(alertString, comment: ""), preferredStyle: UIAlertController.Style.alert)
        alert.message = NSLocalizedString(alertString, comment: "")
        // add an action (Yes)
        alert.view.tintColor = UIColor(named: "ButtonColor")
        alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: UIAlertAction.Style.default, handler: { _ in
            self.changeStatusApi()
        }))
        // add an action (No)
        alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: ""), style: UIAlertAction.Style.default, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }

    //MARK: api call to change ticket status.
    func changeStatusApi(){
            
            self.addLoaderWhileFetching(flag: true)
            ApiManager.sharedInstance.apiCaller(hasBodyData: true, hasToken: true, url: ENDPOINTS.changeTicketStatus, dictionary: createTicketIdDict(), httpMethod: "POST", token: UserDefaults.standard.string(forKey: DefaultsKeys.token)) { [self] Result in
                switch Result{
                case .success(_):
                    DispatchQueue.main.async {
                        if status == true {
                            status = false
                            endQueryBtn.setTitle(NSLocalizedString("Re-Open Ticket", comment: ""), for: .normal)
                            endQueryBtn.backgroundColor = #colorLiteral(red: 1, green: 0.7529411765, blue: 0.262745098, alpha: 1)
                            endQueryBtn.layer.borderColor = #colorLiteral(red: 1, green: 0.7529411765, blue: 0.262745098, alpha: 1)
                            endQueryBtn.setTitleColor(UIColor.black, for: .normal)
                            
                            if(isFromNotification){
                               // setTabBar()
                                self.navigationController!.popToRootViewController(animated: true)

                            }else{
                                let viewControllers: [UIViewController] = self.navigationController!.viewControllers
                                for vc in viewControllers {
                                    if vc is MoodyHelpViewController || vc is ChatViewController {
                                        self.navigationController!.popToViewController(vc, animated: true)
                                    }
                                }
                            }
                        }
                        else{
                            status = true
                            endQueryBtn.setTitle(NSLocalizedString("Close Ticket", comment: ""), for: .normal)
                            endQueryBtn.backgroundColor = .clear
                            endQueryBtn.setTitleColor(UIColor.red, for: .normal)
                            endQueryBtn.layer.borderColor = UIColor.red.cgColor
                        }

                        addLoaderWhileFetching(flag: false)
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        addLoaderWhileFetching(flag: false)
                        self.presentAlert(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString( error.title, comment: ""), parentController: self)
                    }
                }
            }
    }
    
    //MARK: create dictionary for changing ticket status
    // . return json type dictionary which is needed for calling api to change ticket status.
    func createTicketIdDict() -> [String:Any]{
        var ticket_status = String()
        if status == true{
            ticket_status = "closed"
        }else{
            ticket_status = "open"
        }
        ticketDictionary["ticket_id"] = ticket_id
        ticketDictionary["status"] = ticket_status
        return ticketDictionary
       }
    
    func createQuery(){
        var dict = [String:Any]()
        dict["ticket_id"] = ticket_id
        
        addLoaderWhileFetching(flag: true)
        let req = setRequestHeader(hasBodyData: true, hasToken: true, endpoint: ENDPOINTS.readTicketConversation, httpMethod: "POST",dictionary: dict ,token: UserDefaults.standard.string(forKey: DefaultsKeys.token))
        task = downloadsSession.downloadTask(with: req)
        task?.resume()
    }
    
    //MARK: add first text message in chat.
    func addInitialText(){
        
        DispatchQueue.main.async { [self] in
            messages.append(Messgae(sender: deo, messageId: "23", sentDate: Date(), kind: .text(NSLocalizedString("Dear customer, How can we help you?", comment: "")), downloadURL: ""))
            notifyBool.append(false)
            notifyStatus.append("sent")
            messagesTime.append("\(Date())")
            reloadAfterSending()
        }
        
    }
    
    //MARK: this function determine and return the send type
    func checkSenderType(senderType:String) -> SenderType{
        
        if(senderType == "is_poster"){
            return currentUser
        }else{
            return deo
        }
    }
    
    //MARK: function used to parse response obtain from socket or read comversation api.
    // . based on type append different message and types in chat.
    func parseChatResponse(res: [[String:Any]]){
        
        if(res.first != nil){
            for resp in res {
                var repeatedMessage:Bool = false
                let messageId: String = resp["message_id"] as! String
                DispatchQueue.main.async { [self] in
                    repeatedMessage = messagesDictionary[messageId] == nil ? false : true
                    if(!repeatedMessage){
                        messagesDictionary["\(messageId)"] = "\(messageId)"

                            if(((resp["message_type"]) as? String) == "audio"){
                                addAudioMessageinChat(messageId: (resp["message_id"] as! String), role: resp["role"] as! String, audioLink: resp["attachment_path"] as! String, index: 0,is_notified: resp["is_notified"] as! Bool,time: resp["message_time"] as! String)
                            } else if (((resp["message_type"]) as? String) == "text"){

                                addTextMessage(messageId: "\(resp["message_id"] as! String)", role: "\(resp["role"] as! String)", textMessage: "\(resp["text_message"] as! String)", index: 0,is_notified: resp["is_notified"] as! Bool,time: resp["message_time"] as! String)
                                
                            } else if (((resp["message_type"]) as? String) == "image"){
                                let p = resp["attachment_path"] as? String
                                var index = -1
                                if (p != nil){
                                    DispatchQueue.main.async { [self] in
                                        messagesDictionary["\(messageId)"] = "\(messageId)"
                                        messagesDictionaryText.append("\(resp["thumbnail_attachment_path"] as? String ?? resp["attachment_path"] as! String)")
                                        messages.append(Messgae(sender: checkSenderType(senderType: resp["role"] as! String), messageId: resp["message_id"] as! String, sentDate: Date(), kind: .photo(Media(imageURL: URL(string: resp["thumbnail_attachment_path"] as? String ?? resp["attachment_path"] as! String)!, thumb: UIImage(named: "load")!, realImageUrl: "")), downloadURL: ""))
                                            notifyBool.append(resp["is_notified"] as! Bool)
                                            notifyStatus.append("sent")
                                            messagesTime.append(resp["message_time"] as! String)
                                            reloadAfterSending()
                                        messagesCollectionView.scrollToLastItem()
                                        index = messages.count - 1
                                        if( index != -1){
                                            DispatchQueue.global().async { [self] in
                                                let link = URL(string: resp["thumbnail_attachment_path"] as? String ?? resp["attachment_path"] as! String)
                                                guard let data = try? Data(contentsOf: link!) else{
                                                    return
                                                }
                                                messages[index] = Messgae(sender: checkSenderType(senderType: resp["role"] as! String), messageId: resp["message_id"] as! String, sentDate: Date(), kind: .photo(Media(image: UIImage(data: data)!, realImageUrl: "")), downloadURL: "")
                                                notifyBool[index] = resp["is_notified"] as! Bool
                                                notifyStatus[index] = "sent"
                                                messagesTime[index] = resp["message_time"] as! String
                                                let indexPath = IndexPath(row: 0, section: index)
                                                DispatchQueue.main.async {
                                                    messagesCollectionView.reloadSections([indexPath.section,indexPath.section - 1])
                                                }
                                            }
                                        }
                                    }
                                    
                                }
                            }
                        
                    }
                }
            }
        }
        addLoaderWhileFetching(flag: false)
    }
    
    //MARK: download image in local if found then show else download and save to local then show.
    func imageStorageAndSendMessage(localLink:String,messageID:String,type:String,is_notified:Bool,time:String,imagePathLink:String){
        
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
                    addImageinChat(messageId: messageID, role: type, imagData: imgData, index: 0,is_notified:is_notified,time: time)

                }
            } else {
                let link = URL(string: imagePathLink)
                guard let data = try? Data(contentsOf: link!) else{
                    return
                }
                saveImageToLocalStorage(localPath: localLink, base64Data: data)
                addImageinChat(messageId: messageID, role: type, imagData: data, index: 0,is_notified:is_notified,time: time)
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
    
    //MARK: add audioMessage in the chat
    func addAudioMessageinChat(messageId:String,role:String,audioLink:String,index:Int,is_notified:Bool,time:String){
        DispatchQueue.main.async { [self] in
            messagesDictionary["\(messageId)"] = "\(messageId)"
            messagesDictionaryText.append("\(audioLink)")
            if(index != 0){
                messages[index] = Messgae(sender: checkSenderType(senderType: role), messageId: "\(messageId)", sentDate: Date(), kind: .audio(audio(url: URL(string: audioLink)!)),downloadURL: "")
                notifyBool[index] = is_notified
                notifyStatus[index] = "sent"
                messagesTime[index] = time
                let indexPath = IndexPath(row: 0, section: index)
                messagesCollectionView.reloadItems(at: [indexPath])
            } else {
                messages.append(Messgae(sender: checkSenderType(senderType: role), messageId: "\(messageId)", sentDate: Date(), kind: .audio(audio(url: URL(string: audioLink)!)),downloadURL: ""))
                notifyBool.append(is_notified)
                notifyStatus.append("sent")
                messagesTime.append(time)
                reloadAfterSending()
            }
            messagesCollectionView.scrollToLastItem()

        }
    }
    
    
    //MARK: add textMessage in the chat
    func addTextMessage(messageId:String,role:String,textMessage:String,index:Int,is_notified:Bool,time:String){
        DispatchQueue.main.async { [self] in
            messagesDictionary["\(messageId)"] = "\(messageId)"
            messagesDictionaryText.append("\(textMessage)")
                if(index != 0){
                    messagesTime[index] = time
                    messages[index] = Messgae(sender: checkSenderType(senderType: role), messageId: "\(messageId)", sentDate: Date(), kind: .text("\(String(describing: textMessage))"), downloadURL: "")
                    notifyBool[index] = is_notified
                    notifyStatus[index] = "sent"
                    let indexPath = IndexPath(row: 0, section: index)
                    messagesCollectionView.reloadItems(at: [indexPath])
                }else{
                    messages.append(Messgae(sender: checkSenderType(senderType: role), messageId: "\(messageId)", sentDate: Date(), kind: .text("\(String(describing: textMessage))"), downloadURL: ""))
                    notifyBool.append(is_notified)
                    notifyStatus.append("sent")
                    messagesTime.append(time)
                    reloadAfterSending()
                }
                messagesCollectionView.scrollToLastItem()
            }
    }
    
    //    //MARK: add image in the chat
    func addImageinChat(messageId:String,role:String,imagData:Data,index:Int,is_notified:Bool,time:String){
        DispatchQueue.main.async { [self] in
            messagesDictionary["\(messageId)"] = "\(messageId)"
            messagesDictionaryText.append("\(imagData)")
            if(index != 0){
                messages[index] = Messgae(sender: checkSenderType(senderType: role), messageId: "\(messageId)", sentDate: Date(), kind: .photo(Media(image: UIImage(data: imagData)!, realImageUrl: "")), downloadURL: "")
                notifyBool[index] = is_notified
                notifyStatus[index] = "sent"
                messagesTime[index] = time
                let indexPath = IndexPath(row: 0, section: index)
                messagesCollectionView.reloadSections([indexPath.section,indexPath.section - 1])
                
            }else{
                messages.append(Messgae(sender: checkSenderType(senderType: role), messageId: "\(messageId)", sentDate: Date(), kind: .photo(Media(image: UIImage(data: imagData)!, realImageUrl: "")), downloadURL: ""))
                notifyBool.append(is_notified)
                notifyStatus.append("sent")
                messagesTime.append(time)
                reloadAfterSending()
               
            }
            messagesCollectionView.scrollToLastItem()
        }
    }
    
    //MARK: add video in the chat
    func addVideoinChat(messageId:String,role:String,videoLink:String){
        DispatchQueue.main.async { [self] in
            messagesDictionary["\(messageId)"] = "\(messageId)"
            messagesDictionaryText.append("\(videoLink)")
            messages.append(Messgae(sender: checkSenderType(senderType: role), messageId: "\(messageId)", sentDate: Date(), kind: .video(Media(imageURL: URL(string: videoLink)!, thumb: UIImage(), realImageUrl: "")), downloadURL: ""))
            notifyBool.append(false)
            reloadAfterSending()
        }
    }
    
    
    //MARK: download audio in local if found then show else download and save to local then show.
    func fileStorageAndSendMessage(localLink:String,messageID:String,type:String,is_notified:Bool,time:String,audioLinkPath:String){
        
        fileManager = FileManager.default
        let dirPaths:NSArray = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        documentDir = dirPaths[0] as? NSString
        let path1 = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url1 = NSURL(fileURLWithPath: path1)
        
        if let pathComponent1 = url1.appendingPathComponent(localLink) {
            let filePath1 = pathComponent1.path
            let fileManager1 = FileManager.default
            if fileManager1.fileExists(atPath: filePath1) {
                addAudioMessageinChat(messageId: "\(messageID)", role: type, audioLink: pathComponent1.absoluteString, index: 0,is_notified: is_notified,time: time)
            } else {
                let link = URL(string: audioLinkPath)
                guard let data = try? Data(contentsOf: link!) else{
                    return
                }
                saveToLocalStorage(localPath: localLink, base64Data: data.base64EncodedString())
                addAudioMessageinChat(messageId: "\(messageID)", role: type, audioLink: pathComponent1.absoluteString, index: 0,is_notified: is_notified,time: time)
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
    
    
    //MARK: return current sender in chat for message placement on left or right.
    func currentSender() -> SenderType {
        return currentUser
    }
    
    
    //MARK: delegate to return data for each section
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    
    //MARK: return total number or chat rows
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    //MARK: called when click on back button
    // set base view controller
    @objc func backActionForSupport(){
        if(isFromNotification){
           // setTabBar()
            self.navigationController!.popToRootViewController(animated: true)

        }else{
            let viewControllers: [UIViewController] = self.navigationController!.viewControllers
            for vc in viewControllers {
                if vc is MoodyHelpViewController || vc is ChatViewController {
                    self.navigationController!.popToViewController(vc, animated: true)
                }
            }
        }
        
    }
    
    //MARK: add message in chat come from socket.
    func addSocketMessagecs(type: [String : Any]) {
        let message = type
        if(UserDefaults.standard.string(forKey: DefaultsKeys.ticketId) == message["ticket_id"] as? String){
            parseChatResponse(res: [message])
        }
    }
    
    func onNewMessagecs() {
        createQuery()
    }
    
    //MARK: delegate method called when image preview controller got dismissed
    func lightboxControllerWillDismiss(_ controller: LightboxController) {
        print("doen")
    }
    //MARK: delegate method called when image preview controller changes images
    func lightboxController(_ controller: LightboxController, didMoveToPage page: Int) {
        print("yes")
    }
}
//MARK: Extension for calling get ticket conversation in background.

extension CustomerSupport : URLSessionDelegate,URLSessionDownloadDelegate {
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async { [self] in
            if let completionHandler = backgroundSessionCompletionHandler {
                backgroundSessionCompletionHandler = nil
                completionHandler()
            }
        }
    }
    
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
      if error?.localizedDescription == "The request timed out." {
        DispatchQueue.main.async { [self] in
            addLoaderWhileFetching(flag: false)
            whistleWebhook.sharedInstance.APIFaliureWebhooks(Endpoint: "readTicketConversation", response: "\(String(describing: error?.localizedDescription))", body: [:])
          }
      }

    }
    private func URLSession(session: URLSession, didBecomeInvalidWithError error: NSError?) {
        addLoaderWhileFetching(flag: false)
        whistleWebhook.sharedInstance.APIFaliureWebhooks(Endpoint: "readTicketConversation", response: "\(String(describing: error?.localizedDescription))", body: [:])


      }


    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,didFinishDownloadingTo location: URL) {
        do {
            let data = try Data(contentsOf: location)
            let statusCode = Int((downloadTask.response as? HTTPURLResponse)?.statusCode ?? 0)
            let responseJSON:[String:Any]
            do{
                responseJSON = try JSONSerialization.jsonObject(with: data, options: []) as! [String : Any]
                if(statusCode == STATUSCODES.SUCCESSFULL.rawValue || statusCode == STATUSCODES.CREATED_SUCCESSFULLY.rawValue){
                    let response:[String:Any] = responseJSON["data"] as! [String : Any]
                    storeMessageInLocal(localLink: ticket_id, object: response)
                   
                }else{
                    addLoaderWhileFetching(flag: false)
                    whistleWebhook.sharedInstance.APIFaliureWebhooks(Endpoint: "readTicketConversation", response: "\(responseJSON)", body: [:])

                }
            }catch{
                addLoaderWhileFetching(flag: false)
                whistleWebhook.sharedInstance.APIFaliureWebhooks(Endpoint: "readTicketConversation", response: "error occur while parsing response", body: [:])

            }
        }catch {
            addLoaderWhileFetching(flag: false)
            whistleWebhook.sharedInstance.APIFaliureWebhooks(Endpoint: "readTicketConversation", response: "Json error\(error.localizedDescription)", body: [:])

            print("Json error\(error.localizedDescription)")
        }
    }
    
    
    
    //MARK: Create Request header for every network call
    func setRequestHeader(hasBodyData: Bool, hasToken: Bool, endpoint: String, httpMethod: String, dictionary: [String:Any]? = nil, token: String? = nil) -> URLRequest {
        
        URLCache.shared.removeAllCachedResponses()
        let url = URL(string: endpoint)!
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.setValue(Strings.APPLICATION_JSON, forHTTPHeaderField: Strings.CONTENT_TYPE)
        
        if hasToken{
            request.setValue(token ?? "", forHTTPHeaderField: "token")
        }
        if hasBodyData{
            let jsonData = try! JSONSerialization.data(withJSONObject: dictionary as Any, options: .prettyPrinted)
            request.httpBody = jsonData
        }
        return request
    }
}
