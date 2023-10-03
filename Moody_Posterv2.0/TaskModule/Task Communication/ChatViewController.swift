    //
    //  ChatViewController.swift
    //  Moody_Posterv2.0
    //
    //  Created by Umer yasin on 04/06/2021.
    //
    
    import Foundation
    import MessageKit
    import InputBarAccessoryView
    import AVFoundation
    import Quickblox
    import QuickbloxWebRTC
    import PushKit
    import CoreLocation
    import Lottie
    import Lightbox
    import KafkaRefresh

    //MARK: Protocols
    //. protocols calls on different events
    protocol RenderDelegaeChat {
        func onRenderNewChatinChat(type: [String:Any])
    }
    
    protocol addSocketMessage {
        func addSocketMessage(type: [String:Any])
    }
    
    protocol newMessage{
        func onNewMessage()
        func onInternetcoming()
        
    }

//MARK:  ChatViewControllers Extension
// - ChatLayout: Sets layout of ChatScreen
// - InputAccessoryView: views and onClick actions of chats (cameraBtn, attachmentBtn)
// - MessageDisplay: Sets View of Message cell
// - MessageStyling: Incoming/Outgoing messages postioning
// - onTapCells: Cell tap gesture implementation
// - ImageAndCameraFunctionality: Camera functionality implementation
// - FetchMessages: Get Conversation response parse logic
// - CustomAudioView: Audio Recording View implementation
// - NotificationFunction: Notification observer functions implementation
// - MessageCenter: Storing Data in local file
// - ExtendedChat
// - ChatApiCaller: Handles URLSession api calling
    
    //for handling api calling in background.
    var backgroundSessionCompletionHandler: (() -> Void)?
    
    class ChatViewController : MessagesViewController, MessagesDataSource, RenderDelegaeChat, ShowReceiptImages, addSocketMessage , newMessage, LightboxControllerPageDelegate,LightboxControllerDismissalDelegate{
        
        
        
        
        weak var task: URLSessionDownloadTask?
        
        //completion for getting data from urlswssion delegate
        var completionOfGettingData : (()->())?
        
        lazy var downloadsSession: URLSession = { [weak self] in
            let configuration = URLSessionConfiguration.background(withIdentifier:"\(UIDevice.current.identifierForVendor!.uuidString)\(NSDate())")
            configuration.timeoutIntervalForRequest = .infinity
            configuration.timeoutIntervalForResource = .infinity
            return Foundation.URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        }()
        
        // top refresh control object Initializing
        private(set) lazy var refreshControl1:UIRefreshControl = {
            let control = UIRefreshControl()
            control.addTarget(self, action: #selector(loadMoreMessages), for: .valueChanged)
            return control
        }()
        
        var SendButton:UIButton!
        
        var isMessageSend: Bool = false
        static var isScreenVisible:Bool = false
        
        static var istaskfinisherOrNot:Bool = false
        //show receipt or not
        static var showReceipt:Bool = false
        
        
        static var isFromActiveTask:Bool = true
        
        
        static var camBool = false
        var messages = [MessageType]()
        var messagesDictionary = [String : Any]()
        var messagesDictionaryText = [String]()
        
        static var messageCount:Bool = false
        static var isFromGallery:Bool = false
        
        var currentUser = sender(senderId: "Self", displayName: NSLocalizedString("Me", comment: ""))
        var otherUser = sender(senderId: "other", displayName:  NSLocalizedString("Tasker", comment: ""))
        var deo = sender(senderId: "deo", displayName:  NSLocalizedString("Moody Support", comment: ""))
        
        
        lazy var audioController = BasicAudioController(messageCollectionView: messagesCollectionView)
        var notifyStatus = [String]()
        var notifyBool = [Bool]()
        var messagesTime = [String]()
        
        //MARK: Variables for blur effect
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        var blurEffectView = UIVisualEffectView()
        let blackScreen2 = UIVisualEffectView()

        
        //MARK: Chat screen butttons
        let cameraButton = InputBarButtonItem()
        let voiceButton = InputBarButtonItem()
        let attachmentButton = InputBarButtonItem()
        let endTaskButton = InputBarButtonItem()
        let taskerLocationButton = InputBarButtonItem()
        
        //MARK: navigation bar buttons
        let taskerName = UILabel()
        let animationView = AnimationView()
        let cancelButton = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 40))
        let backButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        
        
        
        let optionsButton = UIButton(frame: CGRect(x: 0, y: 0, width: 70, height: 70))
        
        let endButton = UIButton(frame: CGRect(x: 0, y: 0, width: 70, height: 70))
        let endlable = PaddingLabel()
        
        let mapButtons = UIButton(frame: CGRect(x: 0, y: 0, width: 70, height: 70))
        let maplable = PaddingLabel()
        
        let dropOffButton = UIButton(frame: CGRect(x: 0, y: 0, width: 70, height: 70))
        let dropOffLabel = PaddingLabel()
        
        let showReceiptButton = UIButton(frame: CGRect(x: 0, y: 0, width: 70, height: 70))
        let showReceiptLabel = PaddingLabel()
        
        let customerSupportButton = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        let customerSupportLabel = PaddingLabel()
        
        
        let referenceIdButton = UIButton(frame: CGRect(x: 0, y: 0, width: 70, height: 70))
        let currentFare = UIButton(frame: CGRect(x: 0, y: 0, width: 70, height: 70))
        
        
        //Qb Call buttons
        var videoCallBtn = UIButton()
        var btnProfile = UIButton()
        
        
        var imgAndVideoData = [Data]()
        var imgData:Data?
        
        var localMessages = [String]()
        var localmessageType = [String]()
        var localIndex = [Int]()
        var localImageData = [Data]()
        var localLocation = [String]()
        var localMessageTaskId = [String]()
        
        var localMessagesArray = [[String:Any]()]
        
        
        //MARK: custom audio recording view and it timer , audio recorder
        var customView = UIView()
        var timer:Timer?
        var time:Int = 0
        
        var recorder = AKAudioRecorder.shared
        var displayLink = CADisplayLink()
        var duration : CGFloat = 0.0
        // var audioRecorder: AVAudioRecorder!
        var audioSession:AVAudioSession!
        
        var min:Int = 00
        var audioFilename:URL?
        var base64String:URL?
        
        
        var myPickerController:UIImagePickerController = UIImagePickerController()
        
        
        var fileManager : FileManager?
        var documentDir : NSString?
        var filePath : NSString?
        var docNamePath:String?
        static var id = 0
        var localLinkDoc:String?
        static var chatControllerFlag = false
        static var riderName = ""
        
        
        var gameTimer: Timer?
        
        var status = ""
        
        
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 300, height: 300))
        
        var pickupLatitude: Double = 0.0
        var pickupLongitude: Double = 0.0
        var taskerLatitude: Double = 0.0
        var taskerLongitude: Double = 0.0
        
        
        var animationTimer:Timer?
        var taskStatus:String? = "nil"
        var ticketId:String = ""
        var ticketIdShort:String = ""
        var taskType:String = ""
        
        var isFromNotification:Bool = false
        
        lazy var titleStackView: UIStackView = {

            taskerName.textColor = UIColor(named: "Green")
            taskerName.font = UIFont.boldSystemFont(ofSize: 16.0)
            taskerName.textAlignment = .left
            taskerName.text = ChatViewController.riderName.capitalized
            let subtitleLabel = UILabel()
            subtitleLabel.textColor = UIColor(named: "Green")
            subtitleLabel.font = UIFont.boldSystemFont(ofSize: 10.0)
            subtitleLabel.textAlignment = .left
            subtitleLabel.text = NSLocalizedString("Tasker's Name", comment:"")
            let stackView = UIStackView(arrangedSubviews: [taskerName, subtitleLabel])
            stackView.axis = .vertical
            return stackView
        }()
        
        var vc = UIApplication.shared.delegate as! AppDelegate
        

        var taskId : String = ""
        static var taskerDetails = [TaskerQbDetails]()
    
        
        var taskerDetails1 = [TaskerQbDetails]()
        
        //for loaoding gif in audioView
        var imageView =  UIImageView()
        
        
        let timerView = UIView()
        static var stopTimer:stopTimerP?
        var messageId: String = ""
        
        var repeatedMessage:Bool = false
        
        //MARK: calls when first time View Loads
        //. Chat Bools are set
        //. Protocol and views Delegates are set
        //. NotificationObserver are registered
        //. QbLogin Checks
        //. UI settings
        //. Establish Socket connection
        override func viewDidLoad() {
            super.viewDidLoad()
            
            setScreenBools()
            setProtocolDelegates()
            addDelegate()
            setNavigationView()
            navigationBarViews()
            registerNotifications()
            customerSupportButtonCheck()
            currentFare.addTarget(self, action: #selector(currentFareTap), for: .touchUpInside)
            checkQbLogin()
            //fetchMessageFromLocal()
            
            //Setting background color
            viewInilization()
            
            //Setting incoming messages view
            setIncomingmessageViews()
            
            //Setting bottom text view
            setupInputButton()
            
            //Setting outgoing messages view
            setoutgoingmessageViews()
            
            //Socket Connection
            SocketsManager.sharesInstance.establishSocketConnection()
            SocketsManager.sharesInstance.socket.setReconnecting(reason: "i was gone in background.")
            

        }
        //MARK: Calls just before view appears
        //. UI view settings
        //. Set Chat screen bools
        //. fetch chat conversation from local file directory
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(true)
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
            animationView.play()
            setScreenBools()
            let isNotificationImage =  fetchNotificationBadgeData()
            checkNotificationImage(notificationImage: isNotificationImage)
            customerSupportButtonCheck()
            fetchMessageFromLocal()
            messageInputBar.inputTextView.text = ""
            
        }
        
        //MARK: Calls after view has appeared
        //. Setup Audio recorder sessions
        //. read conversation api call
        //. fetch unsend messages array from local
        //. Set Refresh conrtols
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(true)
            self.becomeFirstResponder()
            setAudioSetup()
            callMessages()
            fetchUnsendMessages()
            setRefreshControls()
        }
        
        
        //MARK: Calls just after view dissappears
        //. Reset chat bools
        //. stops recorder
        //. Ui views sets
        //. Location update stops
        override func viewDidDisappear(_ animated: Bool) {
            super.viewDidDisappear(true)
            makeButtonsNormal()
            resetBools()
            self.messageInputBar.inputTextView.resignFirstResponder()
            self.audioController.stopAnyOngoingPlaying()
            stopRecorderAndTimer()
            setViewWithTag()
            invalidateAnimationTimer()
            UrduUiPostioning()
            imageView.image = nil
            LocationManagers.locationSharesInstance.stopLocationUpdate()
        }
        
        
        //MARK: Resets Bools when chat screen disappears
        func resetBools(){
            ChatViewController.isScreenVisible = false
            ChatViewController.chatControllerFlag = false
            ChatViewController.isFromActiveTask = true
            
        }
        
        //MARK: Stops recorder and timer on chat screen disappears
        func stopRecorderAndTimer(){
            recorder.stopRecording()
            time = 0
            timer?.invalidate()
            timerView.removeFromSuperview()
            ChatViewController.stopTimer?.stopTimer()
        }
        
        //MARK: Sets Ui postioning in urdu lng check
        func UrduUiPostioning(){
            if UserDefaults.standard.string(forKey: "language") == "ur-Arab-PK"{
                UIView.appearance().semanticContentAttribute = .forceRightToLeft
            }
        }
        func setViewWithTag(){
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
        //MARK: Sets Refresh Controls on swipe gesture
        func setRefreshControls(){
            //adding top refresh control to collection view
            
            messagesCollectionView.refreshControl = refreshControl1
            
            //adding bottom refresh control to collection view
            
            messagesCollectionView.bindFootRefreshHandler({
                            self.loadMoreMessages()
                        }, themeColor: UIColor.lightGray, refreshStyle: KafkaRefreshStyle.animatableRing)
        }
        
        func fetchUnsendMessages(){
            if(!ChatViewController.isFromGallery){
                fetchUnSendMessages()
            }else{
                ChatViewController.isFromGallery = false
            }
        }
        
        //MARK: set Bool to check customer icon flag
        func fetchNotificationBadgeData() -> Bool{
            let taskId = UserDefaults.standard.string(forKey: DefaultsKeys.taskId)
            let notificationBadgeData = UserDefaults.standard.dictionary(forKey: UserDefaults.standard.string(forKey: DefaultsKeys.taskId) ?? "")
            let isNotificationImage = notificationBadgeData?["\(taskId ?? "")"] as? Bool ?? false
            
            return isNotificationImage
        }
        
        func checkQbLogin(){
            if(!UserDefaults.standard.bool(forKey: DefaultsKeys.isQbLogin)){
                getQbDetailsApi()
            }
        }
        
        func setProtocolDelegates(){
            vc.delegateChat = self
            vc.newMessageDelegate = self
            vc.messageDelegate = self
            SocketsManager.sharesInstance.messageDelegate = self
        }
        
        func setScreenBools(){
            self.navigationController?.isNavigationBarHidden = false
            tabBarController?.tabBar.isHidden = true
            ChatViewController.isScreenVisible = true
            ChatViewController.chatControllerFlag = true
            
        }
        
        
        //MARK: Setting Top bar Navigation view
        func setNavigationView(){
            
            self.navigationController?.navigationBar.semanticContentAttribute = .forceLeftToRight
            UserDefaults.standard.setValue(nil, forKey: DefaultsKeys.dropOffLocation)
            if #available(iOS 13.0, *) {
                let appearance = UINavigationBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = .white
                self.navigationController?.navigationBar.standardAppearance = appearance
                self.navigationController?.navigationBar.scrollEdgeAppearance = navigationController?.navigationBar.standardAppearance
            }
        }
        
        //MARK: Setting up Audio Session
        func setAudioSetup(){
            audioSession = AVAudioSession.sharedInstance()
            do{
                try audioSession.setCategory(.playAndRecord, mode: .default)
                try audioSession.setActive(true)
                try audioSession.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
                
            }catch{
                //print"cannot record audio")
            }
        }
        
        
        //MARK:  Registering delegates
        func addDelegate(){
            messagesCollectionView.messagesDataSource = self
            messagesCollectionView.messagesLayoutDelegate = self
            messagesCollectionView.messagesDisplayDelegate = self
            messageInputBar.delegate = self
            messagesCollectionView.delegate = self
            showMessageTimestampOnSwipeLeft = false
            messagesCollectionView.messageCellDelegate = self
           
        }
        
        //MARK: Functions get call on swipe from top and bottom
        @objc func loadMoreMessages() {
            callMessages()
            //end refreshing after function call
            self.messagesCollectionView.footRefreshControl.endRefreshing()
        }
        
        
        
        func registerCustomeCells(){
            messagesCollectionView.register(CustomRatingScreen.self)
            messagesCollectionView.register(FareScreen.self)
            messagesCollectionView.register(CloseViewScreen.self)
            messagesCollectionView.register(EstimateFareScreen.self)
            messagesCollectionView.register(ReferenceScreen.self)
            messagesCollectionView.register(TaskerDetailScreen.self)
            messagesCollectionView.register(TaskStatusScreen.self)
            messagesCollectionView.register(CallLogViewScreen.self)
        }
        
        
        
        @objc func collectionViewTapped(tapGestureRecognizer: UITapGestureRecognizer) {
            makeButtonsNormal()
        }
        
        
        //MARK: Current Fare details Alert is shown
        @objc func currentFareTap(sender: UIButton!) {
            let vc = AlertService().presentFareCalculationsAlert()
            let topViewController = UIApplication.shared.windows.last?.rootViewController
            if (topViewController != nil) {
                topViewController!.present(vc, animated: true, completion: nil)
            }else{
                self.present(vc, animated: true, completion: nil)
            }
        }
        
        func loadIndicator(){
            loadingIndicator.isHidden = false
        }
                
        //MARK: Updated CurrentFare details fetched from socket emit
        @objc func addCurrentFare(_ notification:NSNotification){
            if(ChatViewController.isFromActiveTask){
                let fare = notification.userInfo as! [String:Any]
                setCurrentFareUserDefaults(response: fare)
                currentFareView(fare: fare)
            }
        }
        
        //MARK: Settting current fare details in local userdefautls
        func setCurrentFareUserDefaults(response:[String:Any]){
            let ff = response["current_fare_details"] as? [String:Any]
            if(ff != nil){
                UserDefaults.standard.setValue(ff?["base_fare"], forKey: DefaultsKeys.basefare)
                UserDefaults.standard.setValue(ff?["total_distance"], forKey: DefaultsKeys.currentTotalDistance)
                UserDefaults.standard.setValue(ff?["total_time"], forKey: DefaultsKeys.totalTime)
                UserDefaults.standard.setValue(ff?["per_minute_rate"], forKey: DefaultsKeys.ratePerMin)
                UserDefaults.standard.setValue(ff?["per_km_rate"], forKey: DefaultsKeys.ratePerKm)
            }

        }
        
        //MARK: Current Fare view insitailisation
        func currentFareView(fare:[String:Any]){
            DispatchQueue.main.async { [self] in
                
                currentFare.frame = CGRect(x: 0, y: (((UIScreen.main.bounds.height) -  messagesCollectionView.frame.height)) , width: UIScreen.main.bounds.width, height: 40)
                currentFare.backgroundColor = UIColor(named: "ButtonColor")!
                currentFare.setTitleColor(UIColor(named: "AppTextColor")!, for: .normal)
                currentFare.setTitle("Current Fare: \(fare["run_time_fare"] as? String ?? "0.0")", for: .normal)
                currentFare.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
                if taskStatus == "assigned" && taskType != "top_up" {
                    
                    self.view.addSubview(currentFare)
                    messagesCollectionView.bringSubviewToFront(currentFare)
                }
            }
        }
        
        //MARK: Chnages icon of CustomerSupport if there is new notifiaction from customer support for specific task
        @objc func changeHelpIcon(_ notification:NSNotification){
            let taskId = UserDefaults.standard.string(forKey: DefaultsKeys.taskId)
            let notificationBadgeData = UserDefaults.standard.dictionary(forKey: UserDefaults.standard.string(forKey: DefaultsKeys.taskId)!)
            
            let notificationImage = notificationBadgeData?["\(taskId ?? "")"] as? Bool ?? false
            
            if(notificationImage){
                customerSupportButton.setImage(UIImage(named: "customerSupportNotified"), for: .normal)
                UserDefaults.standard.setValue(true, forKey: DefaultsKeys.customer_support_notification)
            }else{
                customerSupportButton.setImage(UIImage(named: "chatCustomerSupport"), for: .normal)
                UserDefaults.standard.setValue(false, forKey: DefaultsKeys.customer_support_notification)
            }
        }
        
        //MARK: Remove call btns on task finish
        @objc func removeCallingBtn(_ notification:NSNotification){
            
            btnProfile.isHidden = true
            videoCallBtn.isHidden = true
            DispatchQueue.main.async { [self] in
                timerView.removeFromSuperview()
                ChatViewController.stopTimer?.stopTimer()
            }
        }
        
       
        //MARK: Fetch messages from local file
        func fetchMessageFromLocal(){
            if(ChatViewController.isFromActiveTask){
                showChat(localLink: "\(UserDefaults.standard.string(forKey: DefaultsKeys.taskId) ?? "po").txt")
                setOptionButton()
           }
        }
        
        //MARK: CustomerSupport Notified check
        func checkNotificationImage(notificationImage:Bool){
            
            if(notificationImage){
                customerSupportButton.setImage(UIImage(named: "customerSupportNotified"), for: .normal)
                UserDefaults.standard.setValue(true, forKey: DefaultsKeys.customer_support_notification)
            }else{
                customerSupportButton.setImage(UIImage(named: "chatCustomerSupport"), for: .normal)
                UserDefaults.standard.setValue(false, forKey: DefaultsKeys.customer_support_notification)
            }
            
        }
        
        //MARK: Pop's back to home screen on back/close button
        @objc func popToHome(){
            var isPoppedOut = false
            if(isFromNotification){
                setTabBar()
            }else{
                let viewControllers: [UIViewController] = self.navigationController!.viewControllers
                for aViewController in viewControllers{
                    if aViewController is RecordedTaskScreenVC {
                        isPoppedOut = true
                        self.navigationController?.popToRootViewController(animated: true)
                        return
                    }

                }
                if !isPoppedOut {
                    for aViewController in viewControllers {
                            if aViewController is TaskCreationViewController || aViewController is SelectPaymentMethodViewController || aViewController is TaskHistoryViewController || aViewController is TaskDetailViewController {
                            if(ChatViewController.istaskfinisherOrNot){
                                UserDefaults.standard.setValue("false", forKey: DefaultsKeys.isTaskerAssigned)
                                ChatViewController.istaskfinisherOrNot = false
                                CustomRatingScreen.doneReview = true
                                CustomRatingScreen.numberOfStars = 0
                            }
                            //messagesDictionary.removeAll()
                            self.navigationController?.popViewController(animated: true)
                            return
                        }
                    }
                }
               
            }
        }
        

        
        deinit {
            print("deinit called")
        }
        
        
        //MARK: Fetching Unsend messages array
        //1.setting data in local array
        //2. traversing unsend messages array and appending to chat View
        func fetchUnSendMessages(){
            
                localMessages = UserDefaults.standard.stringArray(forKey: DefaultsKeys.localMessages) ?? [String]()
                localmessageType = UserDefaults.standard.stringArray(forKey: DefaultsKeys.localmessageType) ?? [String]()
                localIndex = UserDefaults.standard.array(forKey: DefaultsKeys.localIndex) as? [Int] ?? [Int]()
                localImageData = UserDefaults.standard.array(forKey: DefaultsKeys.localImageData) as? [Data] ?? [Data]()
                localLocation = UserDefaults.standard.stringArray(forKey: DefaultsKeys.localLocation) ?? [String]()
                localMessageTaskId = UserDefaults.standard.stringArray(forKey: DefaultsKeys.localTaskId) ?? [String]()
        
                if(localMessages.count > 0){
                    for i in 0 ..< localMessages.count {
                        if(localMessageTaskId[i] == UserDefaults.standard.string(forKey: DefaultsKeys.taskId)){
                            let localMsgType = localmessageType[i]
                            switch localMsgType {
                            case "text":
                                unsendTextMessage(LocalMessage: localMessages[i] as String)
                                break
                            case "Audio":
                                unsendAudioMessage(LocalUrl: localMessages[i] as String)
                                break
                            case "image":
                                unsendImageMessage(localImage: localImageData[i])
                                break
                            case "location":
                                unsendLocationMessage(localLocation: localLocation[i])
                                break
                            default:
                                break
                            }
                        }
                    }
            }
                DispatchQueue.main.async {
                    self.messagesCollectionView.reloadDataAndKeepOffset()
                    self.messagesCollectionView.scrollToLastItem()
                }
            
            if(CheckInternet.Connection()){
                onInternetcoming()
            }
            

        }
        
        //MARK: sends unsend Text Messages
        //. Functions Gets saved localMessage String
        //. append Unsend Message and append to chat
        func unsendTextMessage(LocalMessage:String){
            messages.append(Messgae(sender: checkSenderType(senderType: "is_poster", botTitle: ""), messageId: "0", sentDate: Date(), kind: .text(LocalMessage), downloadURL: ""))
            notifyBool.append(false)
            notifyStatus.append("sending")
            messagesTime.append("\(Date())")
            
        }
        //MARK: sends unsend Audio Messages
        //. Functions Gets audio Link from local
        //. append Unsend audio Message and append to chat
        func unsendAudioMessage(LocalUrl:String){
            messages.append(Messgae(sender: checkSenderType(senderType: "is_poster", botTitle: ""), messageId: "990", sentDate: Date(), kind: .audio(audio(url: URL(string:LocalUrl)!)),downloadURL: ""))
            notifyBool.append(false)
            notifyStatus.append("sending")
            messagesTime.append("\(Date())")
        }
        
        //MARK: sends unsend Image Messages
        //. Functions Gets image data from local unsend array
        //. append Unsend image Message and append to chat
        func unsendImageMessage(localImage:Data){
            messages.append(Messgae(sender: checkSenderType(senderType: "is_poster", botTitle: ""), messageId: "xx12cd", sentDate: Date(), kind: .photo(Media(image: UIImage(data: localImage)!, realImageUrl: "")), downloadURL: ""))
            notifyBool.append(false)
            notifyStatus.append("sending")
            messagesTime.append("\(Date())")
        }
        
        //MARK: sends unsend Location Messages
        func unsendLocationMessage(localLocation:String){
            
            let dropOff:String = localLocation
            let latLong = dropOff.split(separator: ",")
            let dropOffLatitude = Double(latLong[0])!
            let dropOffLongitude = Double(latLong[1].split(separator: " ")[0])!
            let loc = CLLocation(latitude: dropOffLatitude, longitude: dropOffLongitude)
            messages.append(Messgae(sender: checkSenderType(senderType: "is_poster", botTitle: ""), messageId: "0", sentDate: Date(), kind: .location(CoordinateItem(location: loc)), downloadURL: ""))
            notifyBool.append(false)
            notifyStatus.append("sending")
            messagesTime.append("\(Date())")
        }

        

        //MARK: Calls on chat view disappear to reset notification count
        func callApiTorestNotificationCount(){
            var dict = [String:Any]()
            dict["task_id"] = UserDefaults.standard.string(forKey:DefaultsKeys.taskId)
            ApiManager.sharedInstance.apiCaller(hasBodyData: true, hasToken: true, url: ENDPOINTS.reset_notification_count_task, dictionary: dict, httpMethod: "POST", token: UserDefaults.standard.string(forKey: DefaultsKeys.token)) { Result in
                switch Result{
                case .success(_):
                    break
                case .failure(_):
                    break
                }
            }
        }
        
        
        //MARK: Registers Notification observers
        func registerNotifications(){
            
            NotificationCenter.default.addObserver(self, selector: #selector(self.taskerAssigned(_:)), name: NSNotification.Name(rawValue: "taskAssigned"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.taskFinished(_:)), name: NSNotification.Name(rawValue: "taskFinished"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.internetoffline(_:)), name: NSNotification.Name(rawValue: "checkInternetConnectionOffline"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.taskerAssignedFromSocket(_:)), name: NSNotification.Name(rawValue: "onTaskAcceptedByTasker"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(updateTaskerLocation(_:)), name: NSNotification.Name(rawValue: "onLocationUpdate"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.closeAudioIfRecording(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.reconnectSocket(_:)), name: UIApplication.willEnterForegroundNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDown(_:)), name: UIResponder.keyboardDidChangeFrameNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.submitRating(_:)), name: NSNotification.Name(rawValue: "sendRating"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.closeView(_:)), name: NSNotification.Name(rawValue: "closeChat"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.showEstimateFareXib(_:)), name: NSNotification.Name(rawValue: "estimateFare"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.addCurrentFare(_:)), name: NSNotification.Name(rawValue: "currentFare"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.changeHelpIcon(_:)), name: NSNotification.Name(rawValue: "customerSupportNotified"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.removeCallingBtn(_:)), name: NSNotification.Name(rawValue: "removingCallBtn"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.removeTimerView(_:)), name: NSNotification.Name(rawValue: "removeTimerView"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.cancelAudioView(_:)), name: NSNotification.Name(rawValue: "removeAudioViewOnCall"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.locat(_:)), name: NSNotification.Name(rawValue: "sendLoc"), object: nil)
        }
        
        
        //MARK: Function to send custom locations
        @objc func locat(_ notification:NSNotification){
            if ShareLocationViewController.send{
                ShareLocationViewController.send = false
                let m = notification.userInfo
                let p = m!["loc"] as! CLLocation
                sendLocation(message: "\(p.coordinate.latitude), \(p.coordinate.longitude)", index: 0, taskId:UserDefaults.standard.string(forKey: DefaultsKeys.taskId) ?? "")
            }
        }
        
        //MARK: Audio is cancelled whenever is been untruppted from calls etc
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
        
        //MARK: CloseView button is appended on task end
        @objc func closeView(_ notification:NSNotification){
            
            if(ChatViewController.istaskfinisherOrNot){
                UserDefaults.standard.setValue("false", forKey: DefaultsKeys.isTaskerAssigned)
                ChatViewController.istaskfinisherOrNot = false
                CustomRatingScreen.doneReview = true
                CustomRatingScreen.numberOfStars = 0
            }
            if(isFromNotification){
                setTabBar()
            }else{
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
        
        //MARK: Detects if keyboard is down
        //. sets of floating options button postioning
        @objc func keyboardDown(_ notification:NSNotification){
            if optionsButton.image(for: .normal) == UIImage(named: "dismiss") || optionsButton.image(for: .normal) == (UIImage(named: "Plus")){
                guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
                    return
                }
                let height = keyboardSize.height
                if height <= 96 {
                    UIView.animate(withDuration: 0.3) {
                        if (UIApplication.shared.windows.first!.safeAreaInsets.bottom > 0) {
                            // iPhone with notch
                            self.optionsButton.frame.origin.y = UIScreen.main.bounds.height - 170
                            self.messagesCollectionView.layoutIfNeeded()
                        }else{
                            self.optionsButton.frame.origin.y = UIScreen.main.bounds.height - 140
                            self.messagesCollectionView.layoutIfNeeded()
                        }
                        
                    }
                }else{
                    UIView.animate(withDuration: 0.3) {
                        self.optionsButton.frame.origin.y = UIScreen.main.bounds.height - CGFloat(height) - 70
                        self.messagesCollectionView.layoutIfNeeded()
                    }
                }
            }
        }
        
        func viewInilization(){
            messageInputBar.layer.shadowOpacity = 0.1
            messageInputBar.layer.shadowOffset = CGSize(width: 0, height: 0)
            messagesCollectionView.backgroundColor = UIColor(named: "MessageBackgroundColor")
            self.view.backgroundColor = .lightGray
        }
        
        //MARK: Checks if Customer suppport icon is notified
        func customerSupportButtonCheck(){
            if(UserDefaults.standard.bool(forKey: DefaultsKeys.customer_support_notification) == true) {
                
                customerSupportButton.setImage(UIImage(named: "customerSupportNotified"), for: .normal)
            }else{
                customerSupportButton.setImage(UIImage(named: "chatCustomerSupport"), for: .normal)
            }
        }
        
        
        //MARK: function call on taskerLocation emit and tasker locations/path updated on maps
        @objc func updateTaskerLocation(_ notification:NSNotification){
            let data = notification.userInfo as! [String:Any]
            var coordinate = [String]()
            data["location_logs"] as? [String] != nil ? coordinate = data["location_logs"] as! [String] : whistleWebhook.sharedInstance.FoundNillWebhooks(Endpoint: "update tasker location / onLocationUpdate", Key: "location_logs")
        }
        
        @objc func closeAudioIfRecording(_ notification:NSNotification){
            closeAudio()
        }
        func closeAudio(){
            DispatchQueue.main.async { [self] in
                self.audioController.stopAnyOngoingPlaying()
                cancelRecording()
            }
            if(ChatViewController.istaskfinisherOrNot){
                UserDefaults.standard.setValue("false", forKey: DefaultsKeys.isTaskerAssigned)
                ChatViewController.istaskfinisherOrNot = false
                CustomRatingScreen.doneReview = true
                CustomRatingScreen.numberOfStars = 0
                navigationController?.popToRootViewController(animated: true)
            }
        }
        
        //MARK: OnInternet connection methods calls and it checks local array of unsend messages and sends it
        //. Checks local array
        //. if unsend message exist it checks message type and sends it
        //. remove unsend message from array after sending
        func onInternetcoming() {
            DispatchQueue.main.async {[self] in
                if(localMessages.count > 0){
                    print("i am called \(Date())")
                    for i in 0 ..< localMessages.count {
                        if(localmessageType[i] == "text"){
                            sendMessage(message: localMessages[i],index: localIndex[i],taskId: localMessageTaskId[i])
                            removeCurrentMessage(index: i)
                            
                        }else if(localmessageType[i] == "Audio"){
                            sendAudioAPI(index: localIndex[i], audioFileNameLink: localMessages[i],taskId: localMessageTaskId[i])
                            removeCurrentMessage(index: i)
                        }else if(localmessageType[i] == "image"){
                            sendImage(imageBase64: localImageData[i], index: localIndex[i],taskId: localMessageTaskId[i])
                            removeCurrentMessage(index: i)
                        }else if(localmessageType[i] == "location"){
                            sendLocation(message: localLocation[i], index: localIndex[i],taskId: localMessageTaskId[i])
                            removeCurrentMessage(index: i)
                        }
                    }
                    
                    removeSentMessages()
                    clearUnsendMsgUserdefaults()
                }
            }
            vc.timerToSendMessages(startTimer: false)
        }
                
        //MARK: set default value to current unsend message when it is send
        func removeCurrentMessage(index:Int){
            localMessages[index] = "&"
            localmessageType[index] = "&"
            localIndex[index] = -1
            localImageData[index] = Data()
            localLocation[index] = "&"
            localMessageTaskId[index] = "&"
            isMessageSend = false
        }
        
        
        //MARK: set default value to current unsend message when it is send
        func removeSentMessages(){
            
            localMessages = localMessages.filter { $0 != "&" }
            localmessageType = localmessageType.filter { $0 != "&" }
            localImageData = localImageData.filter { $0 != Data() }
            localIndex = localIndex.filter { $0 != -1 }
            localLocation = localLocation.filter { $0 != "&" }
            localMessageTaskId = localMessageTaskId.filter { $0 != "&" }
            
            print("Local Messages Array after sending: \(localMessages)")
        }
        

        //MARK: setting userdefautls to after sending unsend message
        func clearUnsendMsgUserdefaults(){
            UserDefaults.standard.setValue(localMessages, forKey: DefaultsKeys.localMessages)
            UserDefaults.standard.setValue(localmessageType, forKey: DefaultsKeys.localmessageType)
            UserDefaults.standard.setValue(localIndex, forKey: DefaultsKeys.localIndex)
            UserDefaults.standard.setValue(localImageData, forKey: DefaultsKeys.localImageData)
            UserDefaults.standard.setValue(localLocation, forKey: DefaultsKeys.localLocation)
            UserDefaults.standard.setValue(localMessageTaskId, forKey: DefaultsKeys.localTaskId)
        }
        
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
        
        //MARK: add buttons to navigation bar
        func navigationBarViews(){
            
            setTaskerName()
            let title = UIBarButtonItem(customView: taskerName)
            let titlee = UIBarButtonItem(customView: setAnimationView())
            let customerSuppotButton = setCustomerSupportBtn()
            
            if(ChatViewController.isFromActiveTask){
                self.navigationItem.leftBarButtonItems = [setBackBtn(),title,titlee]
                self.navigationItem.rightBarButtonItems = [customerSuppotButton]
            }else{
                taskHistoryName()
            }
            if(UserDefaults.standard.bool(forKey: DefaultsKeys.customer_support_notification) == true) {
                customerSupportButton.setImage(UIImage(named: "customerSupportNotified"), for: .normal)
            }else{
                customerSupportButton.setImage(UIImage(named: "chatCustomerSupport"), for: .normal)
            }
        }
        //MARK: Set Customer Support button and its action
        func setCustomerSupportBtn() -> UIBarButtonItem{
            customerSupportButton.layer.cornerRadius = 18
            customerSupportButton.addTarget(self, action: #selector(callHelp), for: .touchUpInside)
            
            let customerSuppotButton = UIBarButtonItem(customView: customerSupportButton)
            
            return customerSuppotButton
        }
        
        func taskHistoryName(){
            let taskerName2 = UILabel()
            taskerName2.text = NSLocalizedString("Chat History", comment: "")
            taskerName2.textColor = UIColor(named: "Green")
            taskerName2.font = UIFont.boldSystemFont(ofSize: 16.0)
            let title2 = UIBarButtonItem(customView: taskerName2)
            self.navigationItem.leftBarButtonItems = [setBackBtn(), title2]
        }
        
        func setTaskerName(){
            taskerName.text = NSLocalizedString("Finding Tasker", comment: "")
            taskerName.textColor = UIColor(named: "Green")
            taskerName.font = UIFont.boldSystemFont(ofSize: 16.0)
        }
        
        func setAnimationView() -> UIView{
            animationView.animation =  Animation.named("data")
            animationView.frame = CGRect(x: -23, y: -2, width: 60, height: 45)
            animationView.contentMode = .scaleAspectFit
            animationView.backgroundColor = .clear
            animationView.loopMode = .loop
            animationView.play()
            
            let uiview = UIView(frame: animationView.frame)
            uiview.addSubview(animationView)
            
            return uiview
        }
        
        //MARK: BackBtn added in top NavigationBar
        func setBackBtn() -> UIBarButtonItem {
            
            backButton.setImage(UIImage(named: "blackBackButton"), for: .normal)
            backButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -15, bottom: 0, right: 0)
            backButton.addTarget(self, action: #selector(popToHome), for: .touchUpInside)
            let back = UIBarButtonItem(customView: backButton)
            
            return back
        }
                    
        //MARK: Parameters for cancel task added in dict
        func CancelTaskDictionary() -> [String:Any]{
            var dictionary = [String:Any]()
            dictionary["task_id"] = UserDefaults.standard.string(forKey:DefaultsKeys.taskId)
            dictionary["user_agent"] = AppPermission.getDeviceInfo()
            dictionary["platform"] = "ios"
            
            return dictionary
        }
        
        
        //MARK: Cancel task Dialog
        @objc func cancelTapped(){
            makeButtonsNormal()
            
            var titleMessage: String = ""
            var dialogMessage: String = ""
            if(CheckInternet.Connection()){
                
                
                if(taskStatus == "assigned"){
                    titleMessage = "Sure To End?"
                    dialogMessage = "Are you sure you want to end the task?"
                }else{
                    titleMessage = "Confirm Cancellation!"
                    dialogMessage = "Are you sure you want to cancel the task?"
                }
                
                let vc = AlertService().presentSimpleAlert( title: NSLocalizedString(titleMessage, comment: ""),
                                                            message: NSLocalizedString(dialogMessage, comment: ""),
                                                            image: UIImage(named: "cross")!,
                                                            yesBtnText: NSLocalizedString("Yes", comment: ""),
                                                            noBtnStr: NSLocalizedString("No", comment: "")){ [self] in
                    
                    cancelButton.isUserInteractionEnabled = false
                    addLoaderWhileFetching(flag: true)
                    ApiManager.sharedInstance.apiCaller(hasBodyData: true, hasToken: true, url: ENDPOINTS.cancelTask, dictionary: CancelTaskDictionary(), httpMethod: "POST", token: UserDefaults.standard.string(forKey: DefaultsKeys.token)) { Result in
                        switch Result{
                        case .success(_):
                            DispatchQueue.main.async {
                                optionsButton.isHidden = true
                                cancelButton.isUserInteractionEnabled = false
                                ChatViewController.istaskfinisherOrNot = true
                                addLoaderWhileFetching(flag: false)
                                callMessages()
                            }
                        case .failure(let error):
                            DispatchQueue.main.async {
                                cancelButton.isUserInteractionEnabled = true
                                addLoaderWhileFetching(flag: false)
                                self.presentAlert(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString( error.title, comment: ""), parentController: self)
                            }
                            
                            
                        }
                    }
                }
                let topViewController = UIApplication.shared.windows.last?.rootViewController
                if (topViewController != nil) {
                    topViewController!.present(vc, animated: true, completion: nil)
                }else{
                    self.present(vc, animated: true, completion: nil)
                }
            }else{
                DispatchQueue.main.async {
                    self.presentAlert(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString( "Internet Not Available. Please check your internet connection and try again.", comment: ""), parentController: self)
                }
            }
        }
        
   
        
        //MARK: adding custom cell
        //Custom Cell addition in messaages like of attachment
        override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            //adding custom cell in chat like tasker detail.etc
            //adding their data source in it.
            guard let messagesDataSource = messagesCollectionView.messagesDataSource else {
                fatalError("Ouch. nil data source for messages")
            }
            guard !isSectionReservedForTypingIndicator(indexPath.section) else {
                return super.collectionView(collectionView, cellForItemAt: indexPath)
            }
            
            let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
            if case .custom = message.kind {
                if(message.messageId == "receipt"){
                    let cell = messagesCollectionView.dequeueReusableCell(CustomRatingScreen.self, for: indexPath)
                    cell.configure(with: message, at: indexPath, and: messagesCollectionView)
                    return cell
                }else if(message.messageId == "rating"){
                    let cell = messagesCollectionView.dequeueReusableCell(FareScreen.self, for: indexPath)
                    cell.configure(with: message, at: indexPath, and: messagesCollectionView)
                    cell.showImageDelegate = self
                    return cell
                }else if(message.messageId == "closeView"){
                    let cell = messagesCollectionView.dequeueReusableCell(CloseViewScreen.self, for: indexPath)
                    cell.configure(with: message, at: indexPath, and: messagesCollectionView)
                    return cell
                }else if(message.messageId == "FareEstimate"){
                    let cell = messagesCollectionView.dequeueReusableCell(EstimateFareScreen.self, for: indexPath)
                    cell.configure(with: message, at: indexPath, and: messagesCollectionView)
                    return cell
                }else if(message.messageId == "reference"){
                    let cell = messagesCollectionView.dequeueReusableCell(ReferenceScreen.self, for: indexPath)
                    cell.configure(with: message, at: indexPath, and: messagesCollectionView)
                    return cell
                }else if(message.messageId == "TaskerDetailsView"){
                    let cell = messagesCollectionView.dequeueReusableCell(TaskerDetailScreen.self, for: indexPath)
                    cell.configure(with: message, at: indexPath, and: messagesCollectionView)
                    return cell
                }else if(message.messageId == "TaskStatusScreen"){
                    let cell = messagesCollectionView.dequeueReusableCell(TaskStatusScreen.self, for: indexPath)
                    cell.configure(with: message, at: indexPath, and: messagesCollectionView)
                    return cell
                }else if(message.messageId.contains("CallLogView")){
                    let cell = messagesCollectionView.dequeueReusableCell(CallLogViewScreen.self, for: indexPath)
                    cell.configure(with: message, at: indexPath, and: messagesCollectionView)
                    cell.cellTopLabel.height(CGFloat(0))
                    cell.cellBottomLabel.height(CGFloat(0))
                    return cell
                }
                
            }
            return super.collectionView(collectionView, cellForItemAt: indexPath)
        }
        
        //MARK: Options (+) floating BUTTON added on right corner on its action further sub list of options is been added
        func setOptionButton(){
            if (UIApplication.shared.windows.first!.safeAreaInsets.bottom > 0) {
                // for iphone with notch
                optionsButton.frame = CGRect(x: UIScreen.main.bounds.width - 70, y: UIScreen.main.bounds.height - 170, width: 70.0, height: 70.0)
                
            }else{
                optionsButton.frame = CGRect(x: UIScreen.main.bounds.width - 70, y: UIScreen.main.bounds.height - 140, width: 70.0, height: 70.0)
            }
            optionsButton.setImage(UIImage(named: "Plus"), for: .normal)
            self.view.addSubview(optionsButton)
            self.messagesCollectionView.bringSubviewToFront(optionsButton)
            optionsButton.addTarget(self, action: #selector(showOptions), for: .touchUpInside)
        }
        @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
            makeButtonsNormal()
        }
        @objc func handleTap2(_ sender: UITapGestureRecognizer? = nil) {
            makeButtonsNormal()
        }
        //MARK: Sublist of options shown on tapping option button
        @objc func showOptions(){
            self.audioController.stopAnyOngoingPlaying()
            if(ChatViewController.isFromActiveTask){
                
                //To blur effect on the back of option button
                blurEffectView = UIVisualEffectView(effect: blurEffect)
                blurEffectView.frame = view.bounds
                blurEffectView.translatesAutoresizingMaskIntoConstraints = false
                let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
                let tap2 = UITapGestureRecognizer(target: self, action: #selector(self.handleTap2(_:)))

                blurEffectView.addGestureRecognizer(tap)
                self.messagesCollectionView.addSubview(blurEffectView)
                
                let blackScreen2 = UIView(frame: self.messageInputBar.bounds)
                blackScreen2.backgroundColor=UIColor(white: 0, alpha: 0.5)
                blackScreen2.tag = 1212
                blackScreen2.addGestureRecognizer(tap2)
                self.messageInputBar.addSubview(blackScreen2)
                
                NSLayoutConstraint.activate([
                    blurEffectView.topAnchor.constraint(equalTo: view.topAnchor),
                    blurEffectView.heightAnchor.constraint(equalTo: view.heightAnchor),
                    blurEffectView.widthAnchor.constraint(equalTo: view.widthAnchor)
                ])
                
                if !(optionsButton.image(for: .normal) == UIImage(named: "dismiss")){
                    
                   LocationManagers.locationSharesInstance.startUpdatingLocations()
                   setOptionsBtnImages()
                   setOptionBtnName()
                   setOptionsBtnView()
                   addOptionsBtnToSubView()
                   setOptionsBtnConstraints()
                   setOptionsBtnTarget()
                }else{
                    LocationManagers.locationSharesInstance.stopLocationUpdate()
                    removeBlurViewFromBackground()
                    closeOptionsBtn()
                    if let viewWithTag = self.messageInputBar.viewWithTag(1212) {
                        viewWithTag.removeFromSuperview()
                    }
                }
            }
        }
        
        
        //MARK: Blur view shown when options button pressed
        func removeBlurViewFromBackground(){
            for subview in messagesCollectionView.subviews {
                if subview is UIVisualEffectView {
                    subview.removeFromSuperview()
                }
            }
            messagesCollectionView.willRemoveSubview(blurEffectView)
            if let viewWithTag = self.messageInputBar.viewWithTag(1212) {
                viewWithTag.removeFromSuperview()
            }
        }
        
        
        //MARK: Images of floating options button
        func setOptionsBtnImages(){
            
            optionsButton.setImage(UIImage(named: "dismiss"), for: .normal)
            endButton.setImage(UIImage(named: "end"), for: .normal)
            mapButtons.setImage(UIImage(named: "currentLocation"), for: .normal)
            dropOffButton.setImage(UIImage(named: "currentLocation"), for: .normal)
            showReceiptButton.setImage(UIImage(named: "receiptLogo"), for: .normal)

        }
        //MARK: Names of floating options button
        func setOptionBtnName(){
            maplable.text = NSLocalizedString("Tasker Location", comment: "")
            dropOffLabel.text = NSLocalizedString("Share Your Location", comment: "")
            showReceiptLabel.text = NSLocalizedString("See Receipts", comment: "")

           
            
            if taskStatus == "assigned" {
                endlable.text = NSLocalizedString("End Task", comment: "")
            }else{
                endlable.text = NSLocalizedString("Cancel Task", comment: "")
            }
        }
        
        func setOptionsBtnView(){
            
            maplable.backgroundColor =  UIColor(named: "FadeGreen")
            maplable.textAlignment = .center
            maplable.font = .boldSystemFont(ofSize: 17)
            maplable.textColor = UIColor(named: "GreenColor")
            
            endlable.backgroundColor = UIColor(named: "FadeGreen")
            endlable.textAlignment = .center
            endlable.font = .boldSystemFont(ofSize: 17)
            endlable.textColor = UIColor(named: "GreenColor")
            
        
            dropOffLabel.backgroundColor =  UIColor(named: "FadeGreen")
            dropOffLabel.textAlignment = .center
            dropOffLabel.font = .boldSystemFont(ofSize: 17)
            dropOffLabel.textColor = UIColor(named: "GreenColor")
            
            if taskType != "top_up"{
                showReceiptLabel.backgroundColor =  UIColor(named: "FadeGreen")
                showReceiptLabel.textAlignment = .center
                showReceiptLabel.font = .boldSystemFont(ofSize: 17)
                showReceiptLabel.textColor = UIColor(named: "GreenColor")
            }
            
        }
        
        //MARK: Add floating option button add to view
        func addOptionsBtnToSubView(){
            self.messagesCollectionView.addSubview(endButton)
            self.messagesCollectionView.addSubview(endlable)
            if taskStatus == "assigned" {
                self.messagesCollectionView.addSubview(mapButtons)
                self.messagesCollectionView.addSubview(maplable)
                if taskType != "top_up"{
                    self.messagesCollectionView.addSubview(showReceiptButton)
                    self.messagesCollectionView.addSubview(showReceiptLabel)
                }
            }
            self.messagesCollectionView.addSubview(dropOffButton)
            self.messagesCollectionView.addSubview(dropOffLabel)
            
        }
        
        //MARK: Sets floating Options constarints
        func setOptionsBtnConstraints(){
            endButton.translatesAutoresizingMaskIntoConstraints = false
            if taskStatus == "assigned" {
                mapButtons.translatesAutoresizingMaskIntoConstraints = false
                if taskType != "top_up"{
                    showReceiptButton.translatesAutoresizingMaskIntoConstraints = false

                }
            }
            dropOffButton.translatesAutoresizingMaskIntoConstraints = false
            customerSupportButton.translatesAutoresizingMaskIntoConstraints = false

            
           
            
            
            endButton.trailingAnchor.constraint(equalTo: self.optionsButton.trailingAnchor, constant: 0).isActive = true
            if taskStatus == "assigned" {
                endButton.bottomAnchor.constraint(equalTo:  self.mapButtons.topAnchor, constant: -10).isActive = true
            }else{
                endButton.bottomAnchor.constraint(equalTo:  self.dropOffButton.topAnchor, constant: -10).isActive = true
            }
            if taskStatus == "assigned" {
                
                if taskType != "top_up"{
                    showReceiptButton.trailingAnchor.constraint(equalTo: self.endButton.trailingAnchor, constant: 0).isActive = true
                    showReceiptButton.bottomAnchor.constraint(equalTo:  self.endButton.topAnchor, constant: -10).isActive = true
                }
               
                
                mapButtons.trailingAnchor.constraint(equalTo: self.optionsButton.trailingAnchor, constant: 0).isActive = true
                mapButtons.bottomAnchor.constraint(equalTo:  self.dropOffButton.topAnchor, constant: -10).isActive = true
                
            }
            
            dropOffButton.trailingAnchor.constraint(equalTo: self.optionsButton.trailingAnchor, constant: 0).isActive = true
            dropOffButton.bottomAnchor.constraint(equalTo:  self.optionsButton.topAnchor, constant: -10).isActive = true
            
            
            endlable.translatesAutoresizingMaskIntoConstraints = false
            endlable.trailingAnchor.constraint(equalTo: endButton.leadingAnchor, constant: -5).isActive = true
            endlable.centerYAnchor.constraint(equalTo: endButton.centerYAnchor).isActive = true
            endlable.paddingLeft = 15
            endlable.paddingRight = 15
            endlable.paddingTop = 7
            endlable.paddingBottom = 7
            
            
            
            if taskStatus == "assigned" {
                
                maplable.translatesAutoresizingMaskIntoConstraints = false
                maplable.trailingAnchor.constraint(equalTo: mapButtons.leadingAnchor, constant: -5).isActive = true
                maplable.centerYAnchor.constraint(equalTo: mapButtons.centerYAnchor).isActive = true
                maplable.paddingLeft = 15
                maplable.paddingRight = 15
                maplable.paddingTop = 7
                maplable.paddingBottom = 7
                
                if taskType != "top_up" {
                    showReceiptLabel.translatesAutoresizingMaskIntoConstraints = false
                    showReceiptLabel.trailingAnchor.constraint(equalTo: showReceiptButton.leadingAnchor, constant: -5).isActive = true
                    showReceiptLabel.centerYAnchor.constraint(equalTo: showReceiptButton.centerYAnchor).isActive = true
                    showReceiptLabel.paddingLeft = 15
                    showReceiptLabel.paddingRight = 15
                    showReceiptLabel.paddingTop = 7
                    showReceiptLabel.paddingBottom = 7
                }
            }
            
            dropOffLabel.translatesAutoresizingMaskIntoConstraints = false
            dropOffLabel.trailingAnchor.constraint(equalTo: dropOffButton.leadingAnchor, constant: -5).isActive = true
            dropOffLabel.centerYAnchor.constraint(equalTo: dropOffButton.centerYAnchor).isActive = true
            dropOffLabel.paddingLeft = 15
            dropOffLabel.paddingRight = 15
            dropOffLabel.paddingTop = 7
            dropOffLabel.paddingBottom = 7
        }
        
        
        //MARK: sets options btn target
        func setOptionsBtnTarget(){
            
            endButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
            if taskStatus == "assigned" {
                
                mapButtons.addTarget(self, action: #selector(onClickTaskerLocation), for: .touchUpInside)
                showReceiptButton.addTarget(self, action: #selector(onClickReceipt), for: .touchUpInside)

            }
            dropOffButton.addTarget(self, action: #selector(onClickAttachment), for: .touchUpInside)

            //customerSupportButton.addTarget(self, action: #selector(callHelp), for: .touchUpInside)
        }
        
        //MARK: Close floating button options
        func closeOptionsBtn(){
            optionsButton.setImage(UIImage(named: "Plus"), for: .normal)
            endButton.removeFromSuperview()
            endlable.removeFromSuperview()
            if taskStatus == "assigned" {
                
                maplable.removeFromSuperview()
                mapButtons.removeFromSuperview()
                if taskType != "top_up"{
                    showReceiptButton.removeFromSuperview()
                    showReceiptLabel.removeFromSuperview()
                }
                
            }
            dropOffButton.removeFromSuperview()
            dropOffLabel.removeFromSuperview()
           
        }
        
        func makeButtonsNormal(){
            LocationManagers.locationSharesInstance.stopLocationUpdate()
            removeBlurViewFromBackground()
            if(ChatViewController.isFromActiveTask){
                optionsButton.setImage(UIImage(named: "Plus"), for: .normal)
                endButton.removeFromSuperview()
                endlable.removeFromSuperview()
                if taskStatus == "assigned" {
                    
                    maplable.removeFromSuperview()
                    mapButtons.removeFromSuperview()
                    if taskType != "top_up"{
                        showReceiptButton.removeFromSuperview()
                        showReceiptLabel.removeFromSuperview()
                    }
                }
                
                dropOffButton.removeFromSuperview()
                dropOffLabel.removeFromSuperview()
               
            }
        }
        
        func invalidateAnimationTimer() {
            if self.animationTimer != nil {
                self.animationTimer!.invalidate()
                self.animationTimer = nil
            }
        }
        //MARK: opens Image Preview on PreviewController
        func showImages(imageLink:String) {
            DispatchQueue.main.async {
                let storyboard = UIStoryboard(name: "TaskCreation", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "PreviewViewController") as! PreviewViewController
                vc.modalPresentationStyle = .fullScreen
                vc.navigationController?.navigationBar.isHidden = true
                vc.localImage = false
                vc.url = URL(string: imageLink)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
        //MARK: Appends Sockets Message in chat
        //. functions gets socket data in type dictonary
        //. Matches taskId and parse response
        func addSocketMessage(type message: [String : Any]) {
            let message = message
            if(message["task_id"] as? String == UserDefaults.standard.string(forKey: DefaultsKeys.taskId)){
                DispatchQueue.global().async { [self] in
                    parseResponse(res: [message])
                }
            }
        }
        
        //MARK: onNewMessage protocol function calls getConversation Api
        func onNewMessage() {
            callMessages()
        }
        
        
        //MARK: QBDetails api call on poster's first task
        //. Poster Qb details sets to local userDefaualts
        //. Poster Qb account is logged in
        func getQbDetailsApi(){
            ApiManager.sharedInstance.apiCaller(hasBodyData: false, hasToken: true, url: ENDPOINTS.get_qb_details, httpMethod: "POST", token: UserDefaults.standard.string(forKey: DefaultsKeys.token)) { [self] Result in
                switch Result{
                case .success(let response):
                    var qbData = [String:Any]()
                    response["quickblox_data"] as? [String:Any] != nil ? qbData = response["quickblox_data"] as! [String:Any] : whistleWebhook.sharedInstance.FoundNillWebhooks(Endpoint: ENDPOINTS.get_qb_details, Key: "quickblox_data")
                    
                    if((qbData["password"] as? String != "") || (qbData["login"] as? String != "")){
                        qbData["qb_id"] as? Int != 0 ? UserDefaults.standard.set(qbData["qb_id"] as? Int ?? 0, forKey: DefaultsKeys.qb_id) : whistleWebhook.sharedInstance.FoundNillWebhooks(Endpoint: ENDPOINTS.get_qb_details, Key: "qb_id")
                        qbData["password"] as? String != "" ? UserDefaults.standard.set(qbData["password"] as? String ?? "", forKey: DefaultsKeys.qb_password) : whistleWebhook.sharedInstance.FoundNillWebhooks(Endpoint: ENDPOINTS.get_qb_details, Key: "password")
                        qbData["login"] as? String != "" ? UserDefaults.standard.set(qbData["login"] as? String ?? "", forKey: DefaultsKeys.qb_login) : whistleWebhook.sharedInstance.FoundNillWebhooks(Endpoint: ENDPOINTS.get_qb_details, Key: "login")
                        
                        if(qbData["login"] as? String != ""){
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "qbLogin"), object: nil)
                            }
                        }
                    }
                    break
                case .failure(_):
                    DispatchQueue.main.async {
                        addCallButton()
                    }
                    break
                }
            }
        }
        
        //MARK:  - called when image view controller is dismissed
        func lightboxControllerWillDismiss(_ controller: LightboxController) {
            navigationController?.popViewController(animated: true)
            navigationController?.setNavigationBarHidden(false, animated: true)
        }
        
        
        //MARK: - call when image view page or view is changed like displaying an image.
        func lightboxController(_ controller: LightboxController, didMoveToPage page: Int) {
            navigationController?.setNavigationBarHidden(true, animated: true)
            navigationController?.hidesBottomBarWhenPushed = true
        }
        
    
    }
