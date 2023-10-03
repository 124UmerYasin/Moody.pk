//
//  TaskCreationViewController.swift
//  Moody_Posterv2.0
//
//  Created by Umer yasin on 04/06/2021.
//

import UIKit
import CoreLocation
import AVKit
import AVFoundation
import Quickblox
import QuickbloxWebRTC
import PushKit
import FirebaseCrashlytics
import Lottie
import SDWebImage


protocol navigationToScreens{
    func navigateToChat(data: [String : Any])
    func navigateToBalance()
    func naviagateToHistory()
    func navigateaToCustomerSupport(data:[String:Any])
}


class TaskCreationViewController: UIViewController,navigationToScreens,QBRTCClientDelegate {
    
    //MARK: Outlets
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var labelForInstruction: UILabel!
    @IBOutlet weak var micButton: UIButton!
    @IBOutlet weak var youtubeButton: UIButton!
    
    @IBOutlet weak var activityLoader: UIActivityIndicatorView!
    @IBOutlet weak var videoLoader: UIActivityIndicatorView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var cancelButtonWidth: NSLayoutConstraint!
    
    
    @IBOutlet weak var sendRequestButton: UIButton!
    @IBOutlet weak var sendRequestWidth: NSLayoutConstraint!
    
    @IBOutlet weak var menuButton: UIButton!
    
    @IBOutlet weak var recordingTimerLabel: UILabel!
    
    @IBOutlet weak var playVideoView: UIView!
    
    @IBOutlet weak var videoSkipBtn: UIButton!
    @IBOutlet weak var videoView: UIView!
    
    @IBOutlet weak var videoPauseBtn: UIButton!
    
    @IBOutlet weak var micImageView: UIImageView!
    
    @IBOutlet weak var maxSecondsLbl: UILabel!
    @IBOutlet weak var returnTaskBtn: UIButton!
    @IBOutlet weak var negativeBalanceView: UIView!
    
    //MARK: Recorder variables
    var recorder = AKAudioRecorder.shared
    var displayLink = CADisplayLink()
    var duration : CGFloat = 30.0
    
    var timer:Timer?
    var time:Int = 00
    var min:Int = 00
    let controller = AVPlayerViewController()
    
    var player = AVPlayer()
    
    var playPauseCheck: Bool = false
    
    //MARK: local unsend messages arrays
    var localMessages = [String]()
    var localmessageType = [String]()
    var localIndex = [Int]()
    var localImageData = [Data]()
    var localLocation = [String]()
    var localMessageTaskId = [String]()
    var newAnimationView: AnimationView?
    
    
    //MARK: QuickBlox Variables
    lazy var dataSource: UsersDataSource = {
        let dataSource = UsersDataSource()
        return dataSource
    }()
    var sessionID: String?
    weak var session: QBRTCSession?
    var voipRegistry: PKPushRegistry = PKPushRegistry(queue: DispatchQueue.main)
    var callUUID: UUID?
    
    
    lazy var navViewController: UINavigationController = {
        let navViewController = UINavigationController()
        return navViewController
        
    }()
    private var animationView: AnimationView?
    var answerTimer: Timer?
    
    var isUpdatedPayload = true
    
    lazy var backgroundTask: UIBackgroundTaskIdentifier = {
        let backgroundTask = UIBackgroundTaskIdentifier.invalid
        return backgroundTask
    }()
    
    
    let vc = UIApplication.shared.delegate as! AppDelegate
    
    //MARK: URL Session variables for background api calling.
    weak var task: URLSessionDownloadTask?
    var backgroundSessionCompletionHandler: (() -> Void)?
    lazy var downloadsSession: URLSession = { [weak self] in
        let configuration = URLSessionConfiguration.background(withIdentifier:"\(UIDevice.current.identifierForVendor!.uuidString)\(NSDate())")
        configuration.timeoutIntervalForRequest = .infinity
        configuration.timeoutIntervalForResource = .infinity
        return Foundation.URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()
    
    
    //MARK: calls when first time View Loads
    //. Ui styling
    //. Navigation bar styling
    //. Establish socket connection
    //. constants Api call
    //. Logs in QbUser
    //. User Balance check to show negative balance bar on top
    //. swipe gesture added
    override func viewDidLoad() {
        super.viewDidLoad()
        getActiveTask()
        setNavigationBarAppearance()
        DefaultsKeys.firstLogin = false
        vc.navigation = self
        registerNotification()
        getConstants()
        SocketsManager.sharesInstance.establishSocketConnection()
        addShadowAndWidth()
        addShadowToButtons()
        hideViewWhenScreenLoads()
        cancelBtnStyle()
        checkCurrentLanguage()
        setViews()
        checkUserBalance()
        loginQuickBlox()
        addSwipeGestures()
        
    }
    
    //MARK: Calls just before view appears
    //. get active task count
    //. Ui setting and styling
    //. get Constants from api
    //. Establish Connection and reconnection
    override func viewWillAppear(_ animated: Bool) {
        getActiveTask()
        returnTaskBtnStyle()
        getConstants()
        setVisibility()
        addShadowAndWidth()
        addShadowToButtons()
        hideViewWhenScreenLoads()
        loadMicRecorderGif()
        setProfileImage()
        checkCurrentLanguage()
        setMicBtnImage()
        checkUserBalance()
        labelInstructionStyling()
        loadVideoGif()
        playAnimation()
        SocketsManager.sharesInstance.establishSocketConnection()
        SocketsManager.sharesInstance.socket.setReconnecting(reason: "i was gone in background.")
    }
    
    
    //MARK: Calls just before view is about to dissappear
    //. Stops timer and recording
    //. setLabels visibility
    //. setTimer duration to 30 sec
    override func viewWillDisappear(_ animated: Bool) {
        tabBarController?.tabBar.isUserInteractionEnabled = true
        invalidateTimer()
        recorder.stopRecording()
        setLabelsVisibility(menuButton: false, activityLoader: true, cancelBtn: true, sendRequestBtn: true, micBtn: true, timerLabel: true, labelForInst:false, recordinglimit: true, youtubeBtn:false)
        duration = 30
    }
    
    //MARK: Calls just after view dissappear
    //. stops and Remove animation from super view
    override func viewDidDisappear(_ animated: Bool) {
        animationView?.stop()
        animationView?.removeFromSuperview()
    }
    
    
    
    //MARK: set Label Instruction Styling on check of urdu
    func labelInstructionStyling(){
        //line spacing for urdu language in home screen label "labelForInstruction"
        if UserDefaults.standard.string(forKey: "language") == "ur-Arab-PK"{
            setTextWithLineSpacing(label: labelForInstruction, text: labelForInstruction.text ?? "Found Nill at Home screen", lineSpacing: 14)
            labelForInstruction.textAlignment = .center
        }
    }
    
    //MARK: Sets MicBtn Image
    func setMicBtnImage(){
        micButton.setImage(UIImage(named: "microphone_large"), for: .normal)
        micButton.backgroundColor =  UIColor(named: "AccentColor")
    }
    
    //MARK: Sets Profile Image
    func setProfileImage(){
        if(UserDefaults.standard.bool(forKey: DefaultsKeys.helpBadge)){
            tabBarController?.tabBar.items![3].image = UIImage(named:"profileBadge")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
            
        }else{
            tabBarController?.tabBar.items![3].image = UIImage(named:"profileNew")
        }
    }
    
    //MARK: Sets visibility of labels/btns of view
    func setVisibility(){
        labelForInstruction.isHidden = false
        view.isExclusiveTouch = true
        micButton.isUserInteractionEnabled = true
        self.navigationController?.navigationBar.isHidden = true
        youtubeButton.isUserInteractionEnabled = true
        videoView.isHidden = false
        returnTaskBtn.isEnabled = true
        tabBarController?.tabBar.isHidden = false
       
        self.navigationController?.isNavigationBarHidden = true
    }
    //MARK: styles return task
    func returnTaskBtnStyle(){
        
        returnTaskBtn.layer.borderWidth = 2.0
        returnTaskBtn.layer.borderColor = UIColor.darkGray.cgColor
        returnTaskBtn.layer.borderWidth = 1.0
        returnTaskBtn.layer.borderColor = UIColor.gray.cgColor
    }
    
    //MARK: Setting UI views
    func setViews(){
        recordingTimerLabel.textColor = UIColor(named: "AppTextColor")!
        micButton.setImage(UIImage(named: "microphone_large"), for: .normal)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    //MARK: Sets cancelBtn Styling
    func cancelBtnStyle(){
        cancelButton.layer.borderWidth = 2
        cancelButton.layer.borderColor = UIColor(named: "AppTextColor")?.cgColor
    }
    
    //MARK: - qbLogin
    func loginQuickBlox(){
        if(UserDefaults.standard.string(forKey: DefaultsKeys.qb_login) != nil){
            loginQb()
        }
    }
    
    //MARK: - check if user balance is less then zero
    // - if >0 show view else hide.
    func checkUserBalance(){
        if(UserDefaults.standard.integer(forKey: DefaultsKeys.wallet_balance) < 0){
            DispatchQueue.main.async { [self] in
                negativeBalanceView.isHidden = false
            }
            
        }else{
            DispatchQueue.main.async { [self] in
                negativeBalanceView.isHidden = true
            }
        }
    }
    
    //MARK: - current Language check
    // - check if language is urdu or english and make string according to that
    func checkCurrentLanguage(){
        if UserDefaults.standard.string(forKey: "language") != "ur-Arab-PK"{
            setHomeAttributedString()
        }else{
            
            labelForInstruction.text = NSLocalizedString("Tap Mic, and start \n recording your task.", comment: "")
        }
    }
    
    //MARK: - navigation bar appearance
    func setNavigationBarAppearance(){
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
            
        }
    }
    

    
    //MARK: Registering Notification Observers and their respected Functions
    func registerNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.onClickNewMessageNotification(_:)), name: NSNotification.Name(rawValue: "navigateToChat"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onClickWallet(_:)), name: NSNotification.Name(rawValue: "navigateToBalance"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.navigateToHistory(_:)), name: NSNotification.Name(rawValue: "navigateToHistory"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.navigateToCustomerSupport(_:)), name: NSNotification.Name(rawValue: "navigateToCustomerSupport"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.navigateToCustomerSupportHelp(_:)), name: NSNotification.Name(rawValue: "navigateToCustomerSupportHelp"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateTickStatus(_:)), name: NSNotification.Name(rawValue: "updateTickStatus"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.makeCall(_:)), name: NSNotification.Name(rawValue: "makeCall"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.closeAudio(_:)), name: NSNotification.Name(rawValue: "removeAudioViewOnCallHome"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.loginQbFromChat(_:)), name: NSNotification.Name(rawValue: "qbLogin"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.animationPlay(_:)), name: UIApplication.willEnterForegroundNotification, object: nil)
        
    }
    //MARK: HomeScreen Mic Text and its attribute
    func setHomeAttributedString(){
        
        let myString:NSString = "Tap Mic, and start \n recording your task."
        var myMutableString = NSMutableAttributedString()
        
        let attrs = [NSAttributedString.Key.font : UIFont(name:"Gilroy-SemiBold", size: 22) ?? .boldSystemFont(ofSize: 18)]
        
        myMutableString = NSMutableAttributedString(string: myString as String, attributes: attrs)
        myMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(named: "lightGray-1") as Any, range: NSRange(location:9,length:32))
        
        labelForInstruction.attributedText = myMutableString
        
    }
    
    //MARK: HomeScreen Time Text and its attribute
    func setTimeAttributedString(){
        
        //Attribute String for Max 30 seconds Label
        let timeString:NSString = "Max 30 seconds."
        var timeMutableString = NSMutableAttributedString()
        
        let attrs = [NSAttributedString.Key.font : UIFont(name:"Gilroy-SemiBold", size: 16) ?? .boldSystemFont(ofSize: 16)]
        
        timeMutableString = NSMutableAttributedString(string: timeString as String, attributes: attrs)
        timeMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(named: "lightGray-1") as Any, range: NSRange(location:0,length:3))
        
        maxSecondsLbl.attributedText = timeMutableString
        
    }
    

    //MARK: function to give send and cancel button shadow and width according to screen.
    func addShadowAndWidth(){
        sendRequestWidth.constant = UIScreen.main.bounds.width/2 - 20
        cancelButtonWidth.constant = UIScreen.main.bounds.width/2 - 70
    }
    
    //MARK: Borders to ActiveTask Button
    func giveColorToViewBorder(activeTaskBtn : UIButton) {
        activeTaskBtn.layer.borderWidth = 2
        activeTaskBtn.layer.borderColor = UIColor(named: "MoodyGray") as! CGColor
    }
    @objc func animationPlay(_ notification:NSNotification){
        animationView?.play()
    }
    
    //MARK: Loads GIF of play intro video
    func loadVideoGif(){
        if UserDefaults.standard.string(forKey: "language") != "ur-Arab-PK"{
            animationView = .init(name: "playVideo")
        }else{
            print("playvideo in urdu")
            animationView = .init(name: "playvideourdu")
        }
        
        animationView!.frame = videoView.bounds
        animationView!.contentMode = .scaleToFill
        animationView!.loopMode = .loop
        animationView!.animationSpeed = 1
        videoView.addSubview(animationView!)
    }
    
    func playAnimation(){
        animationView?.play()
    }
    
    //MARK: Clears all files from directory
    //. checks if any file exist than clear from directory (when there is no running task)
    func clearAllFiles() {
        
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsUrl,
                                                                       includingPropertiesForKeys: nil,
                                                                       options: .skipsHiddenFiles)
            for fileURL in fileURLs {
                try FileManager.default.removeItem(at: fileURL)
                print("File Deleted")
            }
        } catch  { print(error) }
    }
    
    //MARK: Add Shadow To Buttons
    func addShadowToButtons(){
        addShadow(button: micButton)
    }
    
    //MARK: removes shadow from button
    func removeShadowOfButton(button:UIButton){
        button.layer.shadowOpacity = 0.0
        button.layer.shadowOffset = CGSize(width: 0, height: 0)
    }
    
    //MARK: adding shadow to mic,send requessr and caccel button and also to menu button.
    func addShadow(button:UIButton){
        button.layer.shadowOpacity = 0.8
        button.layer.shadowOffset = CGSize(width: 3, height: 3)
    }
    
    //MARK: hide or show Initial Views when screen is loaded.
    func hideViewWhenScreenLoads(){
        DispatchQueue.main.async { [self] in
            sendRequestButton.isHidden = true
            cancelButton.isHidden = true
            activityLoader.isHidden = true
            recordingTimerLabel.isHidden = true
        }
    }
    //MARK: View ActiveTask button appears when 1 or more task is running. Navigate to chat for 1 task else for multiple task running to Task History
    @IBAction func returnToTaskDidTap(_ sender: Any) {
        
        if(UserDefaults.standard.integer(forKey: DefaultsKeys.numberOfActiveTask) == 1){
            
            activityLoader.isHidden = false
            activityLoader.startAnimating()
            returnTaskBtn.isEnabled = false
            
            if(UserDefaults.standard.string(forKey: DefaultsKeys.taskId) != nil && UserDefaults.standard.string(forKey: DefaultsKeys.taskId) != ""){
                activityLoader.isHidden = true
                activityLoader.stopAnimating()
                returnTaskBtn.isEnabled = true
                ChatViewController.isFromActiveTask = true
                let vc = ExtendedChat()
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            }else{
                tabBarController?.selectedIndex = 1
            }
            print("Task 1")
        }else{
            tabBarController?.selectedIndex = 1
        }
    }
    
    
    
    //MARK: Button pressed after user completes it recording and task is been created which navigates to RecordedTask Screen
    @IBAction func onClickSendRequest(_ sender: Any) {
    
        cancelButton.isUserInteractionEnabled = false
        youtubeButton.isUserInteractionEnabled = false
        videoView.isHidden = false
        
        if(CheckInternet.Connection()){
            setLabelsVisibility(menuButton: true, activityLoader: false, cancelBtn: true, sendRequestBtn: true, micBtn: false, timerLabel: true, labelForInst:false, recordinglimit:true, youtubeBtn:false)
            recorder.stopRecording()
            duration = 30
            finishRecording(success: true)
        }else{
            DispatchQueue.main.async { [self] in
                cancelButton.isUserInteractionEnabled = true
                youtubeButton.isUserInteractionEnabled = true
                videoView.isHidden = false
                self.presentAlert(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString( "Internet Not Available. Please check your internet connection and try again.", comment: ""), parentController: self)
                invalidateTimer()
                recorder.stopRecording()
            }
        }
    }
    //MARK: Invalidate timer calculating recording time.
    func invalidateTimer(){
        setHelpLable(isRecording: false)
        micImageView.image = nil
        timer?.invalidate()
        time = 0
        min = 0
        timer = nil
    }
    
    
    
    //MARK: Alters visibility and userInteractions of buttons and labels.
    func setLabelsVisibility(menuButton: Bool, activityLoader: Bool, cancelBtn: Bool, sendRequestBtn:Bool, micBtn: Bool, timerLabel: Bool,labelForInst:Bool, recordinglimit:Bool, youtubeBtn: Bool){
        DispatchQueue.main.async { [self] in
            cancelButton.isHidden = cancelBtn
            cancelButton.isUserInteractionEnabled = true
            // self.menuButton.isHidden = menuButton
            self.activityLoader.isHidden = activityLoader
            sendRequestButton.isHidden = sendRequestBtn
            labelForInstruction.isHidden = labelForInst
            maxSecondsLbl.isHidden = recordinglimit
            youtubeButton.isHidden = youtubeBtn
            sendRequestButton.alpha = 0.5
            
            self.micButton.isEnabled = micBtn
            recordingTimerLabel.isHidden = timerLabel
            recordingTimerLabel.text = ""
            
            
        }
    }
    
    //MARK: If user cancels while recording task
    //. invalidates timer
    //. Visibility sets of home screen buttons
    //. Stops taking updated location of user
    //. Stops Recorder
    @IBAction func onClickCancel(_ sender: Any) {
        
        tabBarController?.tabBar.isUserInteractionEnabled = true
        invalidateTimer()
        setLabelsVisibility(menuButton: false, activityLoader: true, cancelBtn: true, sendRequestBtn: true, micBtn: true, timerLabel: true, labelForInst:false, recordinglimit: true, youtubeBtn:false)
        LocationManagers.locationSharesInstance.stopLocationUpdate()
        micButton.isUserInteractionEnabled = true
        youtubeButton.isHidden = false
        videoView.isHidden = false

        recorder.stopRecording()
        duration = 30
        
        if(UserDefaults.standard.integer(forKey: DefaultsKeys.numberOfActiveTask) > 0){
            returnTaskBtn.isHidden = false
        }else{
            returnTaskBtn.isHidden = true
        }
    }
    
    //MARK: IntroVideo is Played
    @IBAction func youtubeBtnPressed(_ sender: Any) {
        playMoodyIntroVideo()
    }
    
    //MARK: Navigates to intro video controller
    func playMoodyIntroVideo() {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "MoodyIntroVidoViewController") as! MoodyIntroVidoViewController
        nextViewController.isFromHome = true
        nextViewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    //MARK: skipBtn Tapped on Intro video
    @objc func skipButtonTapped(){
        self.controller.dismiss(animated: true)
        
    }
    
    //MARK: delegate called when video is finished
    @objc func playerDidFinishPlaying(note: NSNotification) {
        self.controller.dismiss(animated: true)
    }
    //MARK: get contant api called
    //. Constants values are saved
    func getConstants(){
        
        let req = setRequestHeader(hasBodyData: false, hasToken: true, endpoint: ENDPOINTS.getConstants, httpMethod: "POST", token: UserDefaults.standard.string(forKey: DefaultsKeys.token))
        task = downloadsSession.downloadTask(with: req)
        task?.resume()

    }
    
    //MARK: GetActiveTask Api Call
    //. returns active task count
    //. on basis of count active task button is shown
    //. Tasker QB data is cleared from local array of userdefault if no task is active
    func getActiveTask(){
        var dict = [String:Any]()
        dict["user_role"] = "is_poster"
        dict["user_agent"] = AppPermission.getDeviceInfo()
        dict["platform"] = "ios"
        ApiManager.sharedInstance.apiCaller(hasBodyData: true, hasToken: true, url: ENDPOINTS.get_active_task_details, dictionary: dict, httpMethod: "POST", token: UserDefaults.standard.string(forKey: DefaultsKeys.token)) { [self] Result in
            switch Result{
            
            case .success(let response):
                response["active_tasks_count"] as? Int != nil ? UserDefaults.standard.setValue(response["active_tasks_count"] as? Int ?? "", forKey: DefaultsKeys.numberOfActiveTask) :whistleWebhook.sharedInstance.FoundNillWebhooks(Endpoint: ENDPOINTS.getConstants, Key: "active_tasks_count")
                if(UserDefaults.standard.integer(forKey: DefaultsKeys.numberOfActiveTask) > 0) && !recorder.isRecording{
                    DispatchQueue.main.async { [self] in
                        returnTaskBtn.isHidden = false
                    }
                }else{
                    DispatchQueue.main.async { [self] in
                        returnTaskBtn.isHidden = true
                        clearQbData()
                        if !recorder.isRecording{
                            clearAllFiles()
                        }
                        CheckUpdate.shared.showUpdate(withConfirmation: true)
                        SDImageCache.shared.clearMemory()
                        SDImageCache.shared.clearDisk()
                    }
                }
            case .failure(_):
                break
            }
        }
    }
    
    
    
    //MARK: Clears Tasker QbDetails from local Array of userdefaults
    func clearQbData(){
        let data = UserDefaults.standard.value(forKey: DefaultsKeys.taskerDetails) as? Data ?? nil
        if(data != nil){
            var taskerQb = try? PropertyListDecoder().decode(Array<TaskerQbDetails>.self, from: data!)
            if(taskerQb!.count > 0){
                taskerQb?.removeAll()
                UserDefaults.standard.set(nil, forKey:DefaultsKeys.taskerDetails)
            }
        }
    }
    
    //MARK: To cancel Negative Balance view on top of HomeScreen
    @IBAction func onClickCancelnegView(_ sender: Any) {
        DispatchQueue.main.async { [self] in
            negativeBalanceView.isHidden = true
        }
    }
    
    
    //MARK: Naviagtes to ChatScreen of Active Task
    func navigateToChat(data: [String : Any]) {
        let vcc = tabBarController?.selectedViewController as! UINavigationController
        vcc.popToRootViewController(animated: false)
        let taskId = data
        UserDefaults.standard.setValue(taskId["task_id"], forKey: DefaultsKeys.taskId)
        let vc = ExtendedChat()
        //        vc.messagesDictionary.removeAll()
        vc.taskId = taskId["task_id"] as? String ?? ""
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
        tabBarController?.selectedIndex = 0
    }
    
    //MARK: Selects Wallet from bottom tabbar
    func navigateToBalance() {
        let vc = tabBarController?.selectedViewController as! UINavigationController
        vc.popToRootViewController(animated: false)
        tabBarController?.selectedIndex = 2
    }
    
    //MARK: Selects History from bottom tabbar
    func naviagateToHistory() {
        let vc = tabBarController?.selectedViewController as! UINavigationController
        vc.popToRootViewController(animated: false)
        tabBarController?.selectedIndex = 1
    }
    
    //MARK: Navigates to CustomerSupport
    func navigateaToCustomerSupport(data: [String : Any]) {
        let vcc = tabBarController?.selectedViewController as! UINavigationController
        vcc.popToRootViewController(animated: false)
        let taskId = data
        UserDefaults.standard.setValue(false, forKey: DefaultsKeys.customer_support_notification)
        UserDefaults.standard.setValue(false, forKey: DefaultsKeys.isfromChatOrNot)
        let vc = CustomerSupport()
        vc.hidesBottomBarWhenPushed = true
        vc.ticket_id = taskId["ticket_id"] as! String
        vc.isFromNotification = true
        vc.status = true
        self.navigationController?.pushViewController(vc, animated: false)
        tabBarController?.selectedIndex = 0
    }
    
    //MARK: QBcall observer function to make call
    @objc func  makeCall(_ notification:NSNotification){
        let message = notification.userInfo as! [String:Any]
        if message["type"] as! String == "audio" {
            makeAudioCall()
        }else{
            makeVideoCall()
        }
    }
    
    //MARK: Sign in to Quickblox
    @objc func loginQbFromChat(_ notification:NSNotification){
        
        print("First time user qb Login")
        QBRTCClient.instance().add(self)
        login(fullName: "Moody-Poster", login: UserDefaults.standard.string(forKey: DefaultsKeys.qb_login) ?? "")
        DispatchQueue.main.async { [weak self] in
            self?.setupToolbarButtonsEnabled(false)
        }
        voipRegistry.delegate = self
        voipRegistry.desiredPushTypes = Set<PKPushType>([.voIP])
        UserDefaults.standard.setValue(true, forKey: DefaultsKeys.isQbLogin)
    }
    
    
    //MARK: Sign in to Quickblox
    func loginQb(){
        
        print("existing user Logging in")
        QBRTCClient.instance().add(self)
        login(fullName: "Moody-Poster", login: UserDefaults.standard.string(forKey: DefaultsKeys.qb_login) ?? "")
        DispatchQueue.main.async { [self] in
            self.setupToolbarButtonsEnabled(false)
        }
        voipRegistry.delegate = self
        voipRegistry.desiredPushTypes = Set<PKPushType>([.voIP])
        UserDefaults.standard.setValue(true, forKey: DefaultsKeys.isQbLogin)
        
    }
    
    
    //MARK: set audio call log Api call
    func makeAudioCall(){
        
        if(CheckInternet.Connection()){
            var dict = [String:Any]()
            dict["task_id"] = UserDefaults.standard.string(forKey:DefaultsKeys.taskId)
            ApiManager.sharedInstance.apiCaller(hasBodyData: true, hasToken: true, url: ENDPOINTS.set_call_log, dictionary: dict, httpMethod: "POST", token: UserDefaults.standard.string(forKey: DefaultsKeys.token)) { Result in
                switch Result{
                case .success(_):
                    break
                case .failure(_):
                    break
                }
            }
            
            session = nil
            if(UserDefaults.standard.string(forKey: DefaultsKeys.tasker_qb_id) != nil){
                self.call(with: QBRTCConferenceType.audio)
            }
        }else{
            self.presentAlert(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString( "Internet Not Available. Please check your internet connection and try again.", comment: ""), parentController: self)
        }
    }
    
    //MARK: set video call log Api call
    func makeVideoCall(){
        if(CheckInternet.Connection()){
            var dict = [String:Any]()
            dict["task_id"] = UserDefaults.standard.string(forKey:DefaultsKeys.taskId)
            ApiManager.sharedInstance.apiCaller(hasBodyData: true, hasToken: true, url: ENDPOINTS.set_call_log, dictionary: dict, httpMethod: "POST", token: UserDefaults.standard.string(forKey: DefaultsKeys.token)) { Result in
                switch Result{
                case .success(_):
                    break
                case .failure(_):
                    break
                }
            }
            
            session = nil
            
            if(UserDefaults.standard.string(forKey: DefaultsKeys.tasker_qb_id) != nil){
                self.call(with: QBRTCConferenceType.video)
            }
            else{
                self.presentAlert(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString( "error.title", comment: ""), parentController: self)
            }
        }else{
            self.presentAlert(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString( "Internet Not Available. Please check your internet connection and try again.", comment: ""), parentController: self)
        }
        
        
    }
    
    
    //MARK: Functions calls when there is any call received on homescreen
    //. invalidates timer
    //. stops recorder
    //. set visbility of labels and buttons
    @objc func  closeAudio(_ notification:NSNotification){
        tabBarController?.tabBar.isUserInteractionEnabled = true
        invalidateTimer()
        setLabelsVisibility(menuButton: false, activityLoader: true, cancelBtn: true, sendRequestBtn: true, micBtn: true, timerLabel: true, labelForInst:false, recordinglimit: true, youtubeBtn:false)
        LocationManagers.locationSharesInstance.stopLocationUpdate()
        recorder.stopRecording()
        
        if(UserDefaults.standard.integer(forKey: DefaultsKeys.numberOfActiveTask) > 0){
            returnTaskBtn.isHidden = false
        }else{
            returnTaskBtn.isHidden = true
        }
    }
}

