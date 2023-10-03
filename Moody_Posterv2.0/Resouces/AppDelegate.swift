//
//  AppDelegate.swift
//  Moody_Posterv2.0
//op
//

import UIKit
import CoreData
import GoogleMaps
import Firebase
import Network
import FirebaseMessaging
import Quickblox
import QuickbloxWebRTC
import SVProgressHUD
import PushKit
import CallKit
//import FacebookCore
import GooglePlaces
import UserNotifications


//MARK: Methods handles crash Reporting
//. It sends stackTrace of crashes to Whistle
func storeStackTrace() {
    
    NSSetUncaughtExceptionHandler { exception in
    
        var new:String = ""
        for exp in exception.callStackSymbols{
            new.append("\(exp)\n")
        }
        
        let dict = ["device_name": UIDevice.current.name,
                    "Date": "\(Date())",
                    "event-type": "Exception",
                    "device-info": AppPermission.getDeviceInfo(),
                    "Backtrace": "\(new)",
                    "Application": "Moody Poster",
                    "Version": Constants.app_version
        ] as [String : Any]
    
        whistleWebhook.sharedInstance.errorLogsToWhistle(sendBodyData: dict)
    }
    
    
    signal(SIGTRAP){ exp in
        if(!AppDelegate.sigtrapBool){
            
            var new:String = ""
            for thr in Thread.callStackSymbols{
                new.append("\(thr)\n")
            }
            
            let dict = ["device_name": UIDevice.current.name,
                        "Date": "\(Date())",
                        "event-type": "SIGTRAP",
                        "device-info": AppPermission.getDeviceInfo(),
                        "Backtrace": "\(new)",
                        "Application": "Moody Poster",
                        "Version": Constants.app_version
            ] as [String : Any]
            UserDefaults.standard.setValue(dict, forKey: DefaultsKeys.errorReport)
            whistleWebhook.sharedInstance.errorLogsToWhistle(sendBodyData: dict)
            AppDelegate.sigtrapBool = true
        }
    }
    
    signal(SIGILL) { s in
        
        if(!AppDelegate.sigillBool){
            let standardError = FileHandle.standardError
            var new:String = ""
            for thr in Thread.callStackSymbols{
                new.append("\(thr)\n")
            }
            
            let dict = ["device_name": UIDevice.current.name,
                        "event-type": "SIGILL",
                        "device-info": AppPermission.getDeviceInfo(),
                        "Backtrace": "\(new)",
                        "Date": "\(Date())",
                        "Application": "Moody Poster",
                        "Version": Constants.app_version
            ] as [String : Any]
            UserDefaults.standard.setValue(dict, forKey: DefaultsKeys.errorReport)
            whistleWebhook.sharedInstance.errorLogsToWhistle(sendBodyData: dict)
            AppDelegate.sigillBool = true
        }
    }
    
    signal(SIGABRT) { s in
        
        var new:String = ""
        for thr in Thread.callStackSymbols{
            new.append("\(thr)\n")
        }
        
        let dict = ["device_name": UIDevice.current.name,
                    "Date": "\(Date())",
                    "event-type": "SIGABRT",
                    "device-info": AppPermission.getDeviceInfo(),
                    "Backtrace": "\(new)",
                    "Application": "Moody Poster",
                    "Version": Constants.app_version
        ] as [String : Any]
        UserDefaults.standard.setValue(dict, forKey: DefaultsKeys.errorReport)
        whistleWebhook.sharedInstance.errorLogsToWhistle(sendBodyData: dict)
    }
    
    signal(SIGKILL) { s in
        
        var new:String = ""
        for thr in Thread.callStackSymbols{
            new.append("\(thr)\n")
        }
        
        let dict = ["device_name": UIDevice.current.name,
                    "Date": "\(Date())",
                    "event-type": "SIGKILL",
                    "device-info": AppPermission.getDeviceInfo(),
                    "Backtrace": "\(new)",
                    "Application": "Moody Poster",
                    "Version": Constants.app_version
        ] as [String : Any]
        UserDefaults.standard.setValue(dict, forKey: DefaultsKeys.errorReport)
        whistleWebhook.sharedInstance.errorLogsToWhistle(sendBodyData: dict)
    }
    
    signal(SIGQUIT) { s in
        
        var new:String = ""
        for thr in Thread.callStackSymbols{
            new.append("\(thr)\n")
        }
        
        let dict = ["device_name": UIDevice.current.name,
                    "Date": "\(Date())",
                    "event-type": "SIGQUIT",
                    "device-info": AppPermission.getDeviceInfo(),
                    "Backtrace": "\(new)",
                    "Application": "Moody Poster",
                    "Version": Constants.app_version
        ] as [String : Any]
        UserDefaults.standard.setValue(dict, forKey: DefaultsKeys.errorReport)
        whistleWebhook.sharedInstance.errorLogsToWhistle(sendBodyData: dict)
    }
    
    signal(EXC_RESOURCE) { s in
        
        if(!AppDelegate.exc_resourceBool){
            var new:String = ""
            for thr in Thread.callStackSymbols{
                new.append("\(thr)\n")
            }
            
            let dict = ["device_name": UIDevice.current.name,
                        "Date": "\(Date())",
                        "event-type": "EXC_RESOURCE",
                        "device-info": AppPermission.getDeviceInfo(),
                        "Backtrace": "\(new)",
                        "Application": "Moody Poster",
                        "Version": Constants.app_version
            ] as [String : Any]
            UserDefaults.standard.setValue(dict, forKey: DefaultsKeys.errorReport)
            whistleWebhook.sharedInstance.errorLogsToWhistle(sendBodyData: dict)
            AppDelegate.exc_resourceBool = true
        }
    }
    
}

@available(iOS 10.0, *)
@main
class AppDelegate: UIResponder, UIApplicationDelegate, CXCallObserverDelegate {
    
    var timer: Timer?
    
    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"
    let monitor = NWPathMonitor()
    static var sigtrapBool:Bool = false
    static var sigillBool:Bool = false
    static var exc_resourceBool:Bool = false
    
    var delegate:RenderDelegate?
    var delegateChat:RenderDelegaeChat?
    
    var newMessageDelegate:newMessage?
    var newCSMessageDelegate:newMessageCS?
    
    var navigation:navigationToScreens?
    
    var messageDelegate:addSocketMessage?
    var messageDelegatecs:addSocketMessagecs?
    
    
    var fileManager : FileManager?
    var documentDir : NSString?
    var filePath : NSString?
    var docNamePath:String?

    
    var deviceToken : Data?
    var isCalling = false {
        didSet {
            if UIApplication.shared.applicationState == .background,
               isCalling == false, CallKitManager.instance.isHasSession() {
                disconnect()
            }
        }
    }
    
    var callObserver:CXCallObserver?
    var taskerDetails1 = [TaskerQbDetails]()
    
    
    
    
    //MARK: for handling api calling in background.
    var backgroundSessionCompletionHandler: (() -> Void)?

    //MARK: handleEventsForBackgroundURLSession
    func application(_ application: UIApplication,
                       handleEventsForBackgroundURLSession handleEventsForBackgroundURLSessionidentifier: String,
                       completionHandler: @escaping () -> Void) {
        backgroundSessionCompletionHandler = completionHandler
      }
    
    
    
    func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "removeAudioViewOnCall"), object: nil,userInfo: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "removeAudioViewOnCallHome"), object: nil,userInfo: nil)
        
    }
    
    //MARK: calls just before app Launches
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        Messaging.messaging().delegate = self
        // [END set_messaging_delegate]
        // Register for remote notifications. This shows a permission dialog on first run, to
        // show the dialog at a more appropriate time move this registration accordingly.
        // [START register_for_notifications]
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        // [END register_for_notifications]
        if #available(iOS 13, *) {
            if UserDefaults.standard.string(forKey: DefaultsKeys.token) != nil{
                window = UIWindow(frame: UIScreen.main.bounds)
                let discoverVC = HomeContainer() as UIViewController
                let navigationController = UINavigationController(rootViewController: discoverVC)
                navigationController.navigationBar.isTranslucent = false
                self.window?.rootViewController = navigationController
                self.window?.makeKeyAndVisible()
            }else{
                let Storyborad = UIStoryboard(name: "Main", bundle: nil)
                let nav1 = UINavigationController()
                let InitialViewController = Storyborad.instantiateViewController(withIdentifier: "ViewController")
                nav1.navigationBar.isHidden = true
                nav1.viewControllers = [InitialViewController]
                self.window?.rootViewController = nav1
                self.window?.makeKeyAndVisible()
            }
        } else {
            if UserDefaults.standard.string(forKey: DefaultsKeys.token) != nil{
                setTabBarRoot()
            }else{
                let Storyborad = UIStoryboard(name: "Main", bundle: nil)
                let nav1 = UINavigationController()
                let InitialViewController = Storyborad.instantiateViewController(withIdentifier: "ViewController")
                nav1.navigationBar.isHidden = true
                nav1.viewControllers = [InitialViewController]
                self.window?.rootViewController = nav1
                self.window?.makeKeyAndVisible()
            }
            
        }
        registerNotification()
        
        return true
    }
    
    //MARK: calls after before app finishes Launching
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        NotificationCenter.default.addObserver(self, selector: #selector(recallNotifications(_:)), name: NSNotification.Name(rawValue: "recallNotifications"), object: nil)
        callObserver = CXCallObserver()
        callObserver?.setDelegate(self, queue:  nil)
        
        UserDefaults.standard.setValue(false, forKey: DefaultsKeys.isfromChatOrNot)
        storeStackTrace()
        setupQuickBlox()
        setLanguage()
        
        if(UserDefaults.standard.object(forKey: DefaultsKeys.errorReport) != nil){
            whistleWebhook.sharedInstance.errorLogsToWhistle(sendBodyData: UserDefaults.standard.object(forKey: DefaultsKeys.errorReport) as! [String : Any])
        }
        
        LocationManagers.locationSharesInstance.requestPermissionofLocation()
        GMSServices.provideAPIKey("AIzaSyDBDl0O01DZ1ilFPZtJd5xibKzk5sAnyt0")
        GMSPlacesClient.provideAPIKey("AIzaSyDBDl0O01DZ1ilFPZtJd5xibKzk5sAnyt0")
        
        FirebaseApp.configure()
        
        monitor.pathUpdateHandler = { [self] path in
            if path.status == .satisfied {
                if (UserDefaults.standard.string(forKey: DefaultsKeys.token) != nil){
                    SocketsManager.sharesInstance.establishSocketConnection()
                    SocketsManager.sharesInstance.socket.setReconnecting(reason: "i was gone in background.")

                }
                NotificationCenter.default.post(name: .checkInternetConnectionOnline, object: nil)
                newMessageDelegate?.onInternetcoming()
                
            } else{
                NotificationCenter.default.post(name: .checkInternetConnectionOffline, object: nil)
            }
        }
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
        
        // [START set_messaging_delegate]
        Messaging.messaging().delegate = self
        // [END set_messaging_delegate]
        // Register for remote notifications. This shows a permission dialog on first run, to
        // show the dialog at a more appropriate time move this registration accordingly.
        // [START register_for_notifications]
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        // [END register_for_notifications]
        if #available(iOS 13, *) {
            if UserDefaults.standard.string(forKey: DefaultsKeys.token) != nil{
                window = UIWindow(frame: UIScreen.main.bounds)
                let discoverVC = HomeContainer() as UIViewController
                let navigationController = UINavigationController(rootViewController: discoverVC)
                navigationController.navigationBar.isTranslucent = false
                self.window?.rootViewController = navigationController
                self.window?.makeKeyAndVisible()
            }else{
                let Storyborad = UIStoryboard(name: "Main", bundle: nil)
                let nav1 = UINavigationController()
                let InitialViewController = Storyborad.instantiateViewController(withIdentifier: "ViewController")
                nav1.navigationBar.isHidden = true
                nav1.viewControllers = [InitialViewController]
                self.window?.rootViewController = nav1
                self.window?.makeKeyAndVisible()
            }
        } else {
            if UserDefaults.standard.string(forKey: DefaultsKeys.token) != nil{
                setTabBarRoot()
            }else{
                let Storyborad = UIStoryboard(name: "Main", bundle: nil)
                let nav1 = UINavigationController()
                let InitialViewController = Storyborad.instantiateViewController(withIdentifier: "ViewController")
                nav1.navigationBar.isHidden = true
                nav1.viewControllers = [InitialViewController]
                self.window?.rootViewController = nav1
                self.window?.makeKeyAndVisible()
            }
            
        }
        // UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        registerNotification()
        return true
    }
    
  
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        SocketsManager.sharesInstance.establishSocketConnection()
        if(ChatViewController.istaskfinisherOrNot){
            UserDefaults.standard.setValue("false", forKey: DefaultsKeys.isTaskerAssigned)
        }
    }
    
    
    //MARK: Sets Homescreen TabBar as root ViewController
    func setTabBarRoot(){
        var images : [String]!
        images = ["homeNew", "historyNew",  "WalletNew", "profileNew"]
        
        let tabBarVC = UITabBarController()
        tabBarVC.view.backgroundColor = .white
        
        let profileVC = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "ProfileViewController")
        profileVC.title = NSLocalizedString("Profile", comment: "")
        
        let homeVC = UIStoryboard(name: "TaskCreation", bundle: nil).instantiateViewController(withIdentifier: "TaskCreationViewController")
        homeVC.title =  NSLocalizedString("Home", comment: "")
        
        let  historyVC = UIStoryboard(name: "TaskHistory", bundle: nil).instantiateViewController(withIdentifier: "TaskHistoryViewController")
        historyVC.title =  NSLocalizedString("Task History", comment: "")
        
        let accountVC  = UIStoryboard(name: "MoodyAccount", bundle: nil).instantiateViewController(withIdentifier: "SelectPaymentMethodViewController")
        accountVC.title = NSLocalizedString("Wallet", comment: "")
        
        let controllers = [homeVC, historyVC ,accountVC,profileVC]
        
        tabBarVC.viewControllers = controllers.map { UINavigationController(rootViewController: $0)}
        tabBarVC.tabBar.isTranslucent = false
        tabBarVC.tabBar.tintColor = UIColor(named: "GreenColor")
        
        tabBarVC.tabBar.contentMode = .left
        tabBarVC.tabBar.semanticContentAttribute = .forceLeftToRight
        
        let item = tabBarVC.tabBar.items
        for x in 0..<item!.count {
            item![x].image = UIImage(named: images[x])
        }
        tabBarVC.modalPresentationStyle = .fullScreen
        
        window = UIWindow(frame: UIScreen.main.bounds)
        let discoverVC = tabBarVC
        discoverVC.modalPresentationStyle = .fullScreen
        let navigationController = UINavigationController(rootViewController: discoverVC)
        tabBarVC.selectedIndex = 0
        navigationController.navigationBar.isHidden = true
        self.window?.rootViewController = navigationController
        self.window?.makeKeyAndVisible()
    }
    
    
    //MARK: SetLng from UserDefault when app launches
    func setLanguage(){
        
        if UserDefaults.standard.string(forKey: "language") != nil{
            if UserDefaults.standard.string(forKey: "language") == "ur-Arab-PK"{
                Strings.selectedLang = "urdu"
                Bundle.setLanguage("ur-Arab-PK")
                UserDefaults.standard.setValue("ur-Arab-PK", forKey: "language")
            }else{
                Strings.selectedLang = "eng"
                Bundle.setLanguage("Base")
                UserDefaults.standard.setValue("Base", forKey: "language")
            }
        }
        
    }
    
    //MARK: Method call just before app gets terminated
    func applicationWillTerminate(_ application: UIApplication) {
        disconnect()
        LocationManagers.locationSharesInstance.locationManager?.stopUpdatingLocation()
        LocationManagers.locationSharesInstance.locationManager?.stopMonitoringSignificantLocationChanges()
        LocationManagers.locationSharesInstance.locationManager?.stopUpdatingHeading()
        LocationManagers.locationSharesInstance.locationManager?.stopMonitoringVisits()
        LocationManagers.locationSharesInstance.locationManager?.allowsBackgroundLocationUpdates = false
        if(ChatViewController.istaskfinisherOrNot){
            UserDefaults.standard.setValue("false", forKey: DefaultsKeys.isTaskerAssigned)
            CustomRatingScreen.numberOfStars = 0
        }
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    
    }
    
    
    
    //MARK: Sets Qb Setting constants on app launch
    func setupQuickBlox(){
        
        QBSettings.applicationID = CredentialsConstant.applicationID
        QBSettings.authKey = CredentialsConstant.authKey
        QBSettings.authSecret = CredentialsConstant.authSecret
        QBSettings.accountKey = CredentialsConstant.accountKey
        QBSettings.autoReconnectEnabled = true
        QBSettings.logLevel = QBLogLevel.nothing
        QBSettings.disableXMPPLogging()
        QBSettings.disableFileLogging()
        QBRTCConfig.setLogLevel(QBRTCLogLevel.nothing)
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.clear)
        QBRTCClient.initializeRTC()
        
        
        
    }
    
    //MARK: Method call just before app will enter foreground
    func applicationWillEnterForeground(_ application: UIApplication) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "checkPermissions"), object: nil, userInfo: nil)
        if(UserDefaults.standard.string(forKey: DefaultsKeys.token) != nil){
            SocketsManager.sharesInstance.establishSocketConnection()
            SocketsManager.sharesInstance.socket.setReconnecting(reason: "i was gone in background.")
            if(ChatViewController.istaskfinisherOrNot){
                //                UserDefaults.standard.setValue(nil, forKey: DefaultsKeys.taskId)
                UserDefaults.standard.setValue("false", forKey: DefaultsKeys.isTaskerAssigned)
            }
        }
    }
    
    //MARK: - Connect/Disconnect
    func connect(completion: QBChatCompletionBlock? = nil) {
        let currentUser = Profile()
        
        guard currentUser.isFull == true else {
            completion?(NSError(domain: LoginConstant.chatServiceDomain,
                                code: LoginConstant.errorDomaimCode,
                                userInfo: [
                                    NSLocalizedDescriptionKey: "Please enter your login and username."
                                ]))
            return
        }
        if QBChat.instance.isConnected == true {
            completion?(nil)
        } else {
            QBSettings.autoReconnectEnabled = true
            QBChat.instance.connect(withUserID: currentUser.ID, password: currentUser.password, completion: completion)
        }
    }
    
    func disconnect(completion: QBChatCompletionBlock? = nil) {
        QBChat.instance.disconnect(completionBlock: completion)
    }
    
    
    func getCurrentViewController() -> UIViewController? {
        
        if let rootController = UIApplication.shared.keyWindow?.rootViewController {
            var currentController: UIViewController! = rootController
            while (currentController.presentedViewController != nil) {
                currentController = currentController.presentedViewController
            }
            return currentController
        }
        return nil
    }
    
    // MARK: UISceneSession Lifecycle
    
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    
    //MARK: Silent Notification with completion handler on background
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            //print"Message ID: \(messageID)")
        }
    }
    
    //MARK: Called for silent Notification. All Notification operations are handled here
    //. Every Notification are received here and on there type operations are handled
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            //print"Message ID: \(messageID)")
        }
        
        let userInfo = userInfo
        let taskId = userInfo["task_id"] as? String ?? ""
        let activeTask = userInfo["active_tasks_count"] as? Int ?? 0
        UserDefaults.standard.setValue(activeTask, forKey: DefaultsKeys.numberOfActiveTask)
        if(userInfo["type"] as! String == Strings.task_cancelled){
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [self] in
                newMessageDelegate?.onNewMessage()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "removingCallBtn"), object: nil)
            }
            UserDefaults.standard.setValue(nil, forKey: DefaultsKeys.userImg)
        }
        else if(userInfo["type"] as! String == Strings.tasker_assigned){
            
            let taskerInfo = userInfo as! [String:Any]
            setTaskerQbDetails(userInfo: taskerInfo)
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [self] in
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "taskAssigned"), object: nil, userInfo: userInfo)
                newMessageDelegate?.onNewMessage()
            }
            
        }
        else if(userInfo["type"] as! String == Strings.task_completed){
            let completedTaskId = userInfo["task_id"]!
            UserDefaults.standard.setValue(completedTaskId, forKey: DefaultsKeys.completedTaskId)

            if(userInfo["task_id"] as? String == UserDefaults.standard.string(forKey: DefaultsKeys.taskId)){
               
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [self] in
                    newMessageDelegate?.onNewMessage()
                    if ChatViewController.isScreenVisible && (userInfo["task_id"] as? String == UserDefaults.standard.string(forKey: DefaultsKeys.taskId)){
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "removingCallBtn"), object: nil)
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "taskFinished"), object: nil)
                    }
                }
            }
            
            let data = UserDefaults.standard.value(forKey: DefaultsKeys.taskerDetails) as? Data ?? nil
            let taskId = UserDefaults.standard.string(forKey: (DefaultsKeys.completedTaskId)) ??  UserDefaults.standard.string(forKey: DefaultsKeys.taskId)!
            
            if(data != nil){
                var taskerQb = try? PropertyListDecoder().decode(Array<TaskerQbDetails>.self, from: data!)
                var index = 0
                if(taskerQb!.count > 0){
                    for arr in taskerQb! {
                        print("Task Id : \(arr.taskId)")
                        if arr.taskId == taskId {
                            taskerQb?.remove(at: index)
                           // ChatViewController.taskerDetails.remove(at: index)
                            print("Removed")
                            break
                        }
                        index = index + 1
                    }
                }

                UserDefaults.standard.set(try? PropertyListEncoder().encode(taskerQb), forKey:DefaultsKeys.taskerDetails)
                
            }
        }else if(userInfo["type"] as! String == Strings.new_message && ChatViewController.isScreenVisible){
            var msg = [String:Any]()
            let messages = userInfo["message_obj"] as! String
            let data = Data(messages.utf8)
            do{
                msg = try (JSONSerialization.jsonObject(with: data, options: []) as? [String:Any])!

            }catch{
                msg = [String:Any]()
            }
            messageDelegate?.addSocketMessage(type: msg)
        }else if(userInfo["type"] as! String == Strings.new_message && !ChatViewController.isScreenVisible){
        
            var msg = [String:Any]()
            let messages = userInfo["message_obj"] as! String
            let data = Data(messages.utf8)
            do{
                msg = try (JSONSerialization.jsonObject(with: data, options: []) as? [String:Any])!

            }catch{
                msg = [String:Any]()
            }
            let taskId = userInfo["task_id"]
            let localLink =  taskId as! String
            
            fetchFromLocalFile(localLink: localLink, data: msg)
            
        }
        else if(userInfo["type"] as! String == Strings.new_message_cs){
            if(CustomerSupport.customerSupportChatFlag){
                var msg = [String:Any]()
                let messages = userInfo["message_obj"] as! String
                let data = Data(messages.utf8)
                do{
                    msg = try (JSONSerialization.jsonObject(with: data, options: []) as? [String:Any])!

                }catch{
                    msg = [String:Any]()
                }
                messageDelegatecs?.addSocketMessagecs(type: msg)
            }else if(taskId == UserDefaults.standard.string(forKey: DefaultsKeys.taskId)){
                
                let dictionary = [
                    taskId: true,
                ] as [String : Bool]
                
                UserDefaults.standard.setValue(dictionary, forKey: taskId)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "customerSupportNotified"), object: nil)
            }else{
                
                let dictionary = [
                    taskId: true,
                ] as [String : Bool]
                UserDefaults.standard.setValue(dictionary, forKey: taskId)
                
            }
            
        }else if(userInfo["type"] as! String == Strings.task_customer_support){
            if(CustomerSupport.customerSupportChatFlag){
                var msg = [String:Any]()
                let messages = userInfo["message_obj"] as! String
                let data = Data(messages.utf8)
                do{
                    msg = try (JSONSerialization.jsonObject(with: data, options: []) as? [String:Any])!

                }catch{
                    msg = [String:Any]()
                }
                messageDelegatecs?.addSocketMessagecs(type: msg)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
               // self.newCSMessageDelegate?.onNewMessagecs()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "customerSupportNotified"), object: nil)
            }
        }else if(userInfo["type"] as! String == Strings.new_message_deo){
            newMessageDelegate?.onNewMessage()
        }else if(userInfo["type"] as! String == Strings.fare_estimation){
            newMessageDelegate?.onNewMessage()
        }else if(userInfo["type"] as! String == Strings.wallet_balance){
            UserDefaults.standard.setValue(userInfo["wallet_balance"], forKey: DefaultsKeys.wallet_balance)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "walletUpdate"), object: nil)
            
            UserDefaults.standard.setValue(userInfo["promo_balance"], forKey: DefaultsKeys.promo_balance)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "promoBalance"), object: nil)
            
        }else if(userInfo["type"] as! String == Strings.wallet_balance_update){
            UserDefaults.standard.setValue(userInfo["wallet_balance"], forKey: DefaultsKeys.wallet_balance)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "walletUpdate"), object: nil)
            
            UserDefaults.standard.setValue(userInfo["promo_balance"], forKey: DefaultsKeys.promo_balance)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "promoBalance"), object: nil)
            
        }else if(userInfo["type"] as! String == Strings.promo_code){
            UserDefaults.standard.setValue(userInfo["wallet_balance"], forKey: DefaultsKeys.wallet_balance)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "walletUpdate"), object: nil)
            
            UserDefaults.standard.setValue(userInfo["promo_balance"], forKey: DefaultsKeys.promo_balance)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "promoBalance"), object: nil)
        }else if(userInfo["type"] as! String == Strings.drop_off_location){
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [self] in
                newMessageDelegate?.onNewMessage()
            }
        }else if(userInfo["type"] as! String == Strings.qb_call){
            UserDefaults.standard.setValue(userInfo["task_id"], forKey: DefaultsKeys.taskIdInCall)
        }
        else if(userInfo["type"] as! String == Strings.previous_poster_device_token){
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "logoutDidTap"), object: nil,userInfo: ["storyboard": "Main", "vc": "LogoutVC"])
        }
        completionHandler(UIBackgroundFetchResult.newData)
    }
    // [END receive_message]
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        //print"Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
    // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
    //MARK: the FCM registration token.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        //print"APNs token retrieved: \(deviceToken)")
        
        // With swizzling disabled you must set the APNs token here.
        Messaging.messaging().apnsToken = deviceToken
        guard let identifierForVendor = UIDevice.current.identifierForVendor else {
            return
        }
        let deviceIdentifier = identifierForVendor.uuidString
        let subscription = QBMSubscription()
        subscription.notificationChannel = .APNS
        subscription.deviceUDID = deviceIdentifier
        subscription.deviceToken = deviceToken
        self.deviceToken = deviceToken
        QBRequest.createSubscription(subscription, successBlock: { (response, objects) in
        }, errorBlock: { (response) in
            debugPrint("[AppDelegate] createSubscription error: \(String(describing: response.error))")
        })
        
    }
    
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Moody_Posterv2_0")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    //MARK: Tasker QbDetails are set when tasker assigned notification is received
    func setTaskerQbDetails(userInfo:[String:Any]){
        UserDefaults.standard.setValue(userInfo["tasker_qb_id"] as? Int ?? nil, forKey: DefaultsKeys.tasker_qb_id)
        
        let nameTasker = userInfo["tasker_name"] as! String
        let taskerId = userInfo["tasker_qb_id"] as! String
        let taskerImageUrl = userInfo["tasker_profile_picture"] as! String
        let taskId = userInfo["task_id"] as! String
        setTaskerDetails(id: taskerId, name: nameTasker, imageUrl: taskerImageUrl, taskId: taskId)
    }
    
    //MARK: Sets Tasker QbDetails in local araay of userdefaults
    func setTaskerDetails(id:String, name:String, imageUrl:String, taskId : String ){
        
        var qbFlag: Bool = false
        let obj = TaskerQbDetails(id: id, imageUrl: imageUrl, name: name, taskID: taskId)
        
        taskerDetails1.append(obj)
        
        guard let data = UserDefaults.standard.value(forKey: DefaultsKeys.taskerDetails) as? Data else {
            UserDefaults.standard.set(try? PropertyListEncoder().encode(taskerDetails1), forKey:DefaultsKeys.taskerDetails)
            return
        }
        
        var taskerQb = try? PropertyListDecoder().decode(Array<TaskerQbDetails>.self, from: data)
        for i in taskerQb! {
            if(i.taskId == taskId){
                qbFlag = true
            }
        }
        if(!qbFlag){
            taskerQb?.append(obj)
            UserDefaults.standard.set(try? PropertyListEncoder().encode(taskerQb), forKey:DefaultsKeys.taskerDetails)
        }
        
        
       }
    
    
    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    
}

// [START ios_10_message_handling]
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    //MARK: Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // [START_EXCLUDE]
        // print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            //print"Message ID: \(messageID)")
        }
        // [END_EXCLUDE]
        // print full message.
        
        if userInfo["type"] as! String == Strings.new_message {
            let taskId = userInfo["task_id"] as! String
            if (UserDefaults.standard.string(forKey: DefaultsKeys.taskId) == taskId) && (ChatViewController.chatControllerFlag) {
                completionHandler([])
            }else{
                completionHandler([[.alert, .sound]])
            }
        }
        else if userInfo["type"] as! String == Strings.new_message_cs {
            let taskId = userInfo["task_id"] as? String ?? nil
            
            if (UserDefaults.standard.string(forKey: DefaultsKeys.taskId) == taskId) && (CustomerSupport.customerSupportChatFlag && userInfo["ticket_id"] as? String == UserDefaults.standard.string(forKey: DefaultsKeys.ticketId)) {
                completionHandler([])
            }else  if(taskId == nil && CustomerSupport.customerSupportChatFlag) && (userInfo["ticket_id"] as? String == (UserDefaults.standard.string(forKey: DefaultsKeys.ticketId))) {
                completionHandler([])
                
            }else{
                completionHandler([[.alert, .sound]])
                
            }
        } else if userInfo["type"] as! String == Strings.qb_call {
            
            completionHandler([])
        }
        else{
            completionHandler([[.alert, .sound]])
            
        }
    }
    
    
    
    
    //MARK: Called when notification is tapped
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        let payload = response.notification.request.content.userInfo as! [String:Any]
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [self] in
            navigateToVc(payload: payload)
        }
    }
    
    //MARK: Method use to Navigate on tapping Notification
    //. On notifaction type app is naviagted to respected screens
    func navigateToVc(payload:[String:Any]){
        let state = UIApplication.shared.applicationState
        if(payload["type"] as! String == Strings.new_message || payload["type"] as! String == Strings.task_annotated || payload["type"] as! String == Strings.tasker_arrived || payload["type"] as! String == Strings.tasker_assigned || payload["type"] as! String ==  Strings.drop_off_location){
            var mc = [String:Any]()
            mc["task_id"] = payload["task_id"] as! String
            if state == .background || state == .active {
                if !ChatViewController.isScreenVisible {
                    navigation?.navigateToChat(data: mc)
                }else if (ChatViewController.isScreenVisible && payload["task_id"] as? String != UserDefaults.standard.string(forKey: DefaultsKeys.taskId) ){
                    delegateChat?.onRenderNewChatinChat(type: mc)
                }else{
                    //newMessageDelegate?.onNewMessage()
                }
            }else{
                if #available(iOS 13, *) {
                    if !ChatViewController.isScreenVisible {
                        navigation?.navigateToChat(data: mc)
                    }else if (ChatViewController.isScreenVisible && payload["task_id"] as? String != UserDefaults.standard.string(forKey: DefaultsKeys.taskId) ){
                        delegateChat?.onRenderNewChatinChat(type: mc)
                    }else{
                        //newMessageDelegate?.onNewMessage()
                    }
                }else{
                    let vc = ExtendedChat()
                    vc.hidesBottomBarWhenPushed = true
                    vc.isFromNotification = true
                    UserDefaults.standard.setValue(mc["task_id"], forKey: DefaultsKeys.taskId)
                    setViewofCustomerSupportAndChat(vc: vc)
                }
            }
            
        }
        //MARK: Navigate to wallet on Notification Tap
        if(payload["type"] as! String == Strings.wallet_balance_update || payload["type"] as! String == Strings.transaction_verified || payload["type"] as! String == Strings.transaction_declined || payload["type"] as! String == Strings.promo_balance) {
            if state == .background || state == .active {
                navigation?.navigateToBalance()
            }else{
                if #available(iOS 13, *) {
                    navigation?.navigateToBalance()
                }else{
                    setView(val: 1)
                }
            }
        }
        //MARK: Navigate to history on notification Tap
        if(payload["type"] as! String == Strings.task_completed || payload["type"] as! String == Strings.task_cancelled){
            if state == .background || state == .active {
                navigation?.naviagateToHistory()
            }else{
                if #available(iOS 13, *) {
                    navigation?.naviagateToHistory()
                }else{
                    setView(val: 2)
                }
            }
        }
        //MARK: Navigate to customer Support
        if(payload["type"] as! String == Strings.new_message_cs ||  payload["type"] as! String == Strings.task_customer_support){
            
            var mc = [String:Any]()
            
            if(payload["task_id"] as? String != nil){
                mc["task_id"] = payload["task_id"] as! String
                mc["ticket_id"] = payload["ticket_id"] as! String
                if state == .background || state == .active {
                    if !CustomerSupport.isScreenVisible {
                        navigation?.navigateaToCustomerSupport(data: mc)
                    } else if (CustomerSupport.isScreenVisible && payload["ticket_id"] as? String != UserDefaults.standard.string(forKey: DefaultsKeys.ticketId) ){
                        delegate?.onRenderNewChat(type: mc)
                        
                    }else{
                        newCSMessageDelegate?.onNewMessagecs()
                    }
                }else{
                    if #available(iOS 13, *) {
                        if !CustomerSupport.isScreenVisible{
                            navigation?.navigateaToCustomerSupport(data: mc)
                        }else if (CustomerSupport.isScreenVisible && payload["ticket_id"] as? String != UserDefaults.standard.string(forKey: DefaultsKeys.ticketId) ){
                            delegate?.onRenderNewChat(type: mc)
                            
                        }else{
                            newCSMessageDelegate?.onNewMessagecs()
                        }
                    }else{
                        UserDefaults.standard.setValue(false, forKey: DefaultsKeys.customer_support_notification)
                        UserDefaults.standard.setValue(false, forKey: DefaultsKeys.isfromChatOrNot)
                        let vc = CustomerSupport()
                        vc.hidesBottomBarWhenPushed = true
                        vc.isFromNotification = true
                        vc.ticket_id = mc["ticket_id"] as! String
                        setViewofCustomerSupportAndChat(vc: vc)
                    }
                }
            }else{
                mc["ticket_id"] = payload["ticket_id"] as! String
                if state == .background || state == .active {
                    if !CustomerSupport.isScreenVisible {
                        navigation?.navigateaToCustomerSupport(data: mc)
                    } else if (CustomerSupport.isScreenVisible && payload["ticket_id"] as? String != UserDefaults.standard.string(forKey: DefaultsKeys.ticketId) ){
                        delegate?.onRenderNewChat(type: mc)
                    }else{
                        newCSMessageDelegate?.onNewMessagecs()
                    }
                    
                }else{
                    if #available(iOS 13, *) {
                        if !CustomerSupport.isScreenVisible{
                            navigation?.navigateaToCustomerSupport(data: mc)
                        }else if (CustomerSupport.isScreenVisible && payload["ticket_id"] as? String != UserDefaults.standard.string(forKey: DefaultsKeys.ticketId) ){
                            delegate?.onRenderNewChat(type: mc)
                            
                        }else{
                            newCSMessageDelegate?.onNewMessagecs()
                        }
                    }else{
                        UserDefaults.standard.setValue(false, forKey: DefaultsKeys.customer_support_notification)
                        UserDefaults.standard.setValue(false, forKey: DefaultsKeys.isfromChatOrNot)
                        let vc = CustomerSupport()
                        vc.hidesBottomBarWhenPushed = true
                        vc.isFromNotification = true
                        vc.ticket_id = mc["ticket_id"] as! String
                        setViewofCustomerSupportAndChat(vc: vc)
                    }
                }
            }
            
            
        }
    }
    
    func setTabBarRoot1(vc:UIViewController){
        let m = self.window?.rootViewController as! UINavigationController
        m.navigationBar.isHidden = true
        m.pushViewController(vc, animated: true)
    }
    //MARK: set views on base of notifications on ios 12
    func setView(val:Int){
        var images : [String]!
        images = ["homeNew", "historyNew",  "WalletNew", "profileNew"]
        
        let tabBarVC = UITabBarController()
        tabBarVC.view.backgroundColor = .white
        
        let profileVC = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "ProfileViewController")
        profileVC.title = NSLocalizedString("Profile", comment: "")
        
        let homeVC = UIStoryboard(name: "TaskCreation", bundle: nil).instantiateViewController(withIdentifier: "TaskCreationViewController")
        homeVC.title =  NSLocalizedString("Home", comment: "")
        
        let  historyVC = UIStoryboard(name: "TaskHistory", bundle: nil).instantiateViewController(withIdentifier: "TaskHistoryViewController")
        historyVC.title =  NSLocalizedString("Task History", comment: "")
        
        let accountVC  = UIStoryboard(name: "MoodyAccount", bundle: nil).instantiateViewController(withIdentifier: "SelectPaymentMethodViewController")
        accountVC.title = NSLocalizedString("Wallet", comment: "")
        
        let controllers = [homeVC, historyVC ,accountVC,profileVC]
        
        tabBarVC.viewControllers = controllers.map { UINavigationController(rootViewController: $0)}
        tabBarVC.tabBar.isTranslucent = false
        tabBarVC.tabBar.tintColor = UIColor(named: "GreenColor")
        
        tabBarVC.tabBar.contentMode = .left
        tabBarVC.tabBar.semanticContentAttribute = .forceLeftToRight
        
        let item = tabBarVC.tabBar.items
        for x in 0..<item!.count {
            item![x].image = UIImage(named: images[x])
        }
        tabBarVC.modalPresentationStyle = .fullScreen
        
        window = UIWindow(frame: UIScreen.main.bounds)
        let discoverVC = tabBarVC
        discoverVC.modalPresentationStyle = .fullScreen
        let navigationController = UINavigationController(rootViewController: discoverVC)
        if(val == 1){
            tabBarVC.selectedIndex = 2
        }else if(val == 2){
            tabBarVC.selectedIndex = 1
        }
        self.window?.rootViewController = navigationController
        self.window?.makeKeyAndVisible()
    }
    
    //MARK: navigtae to customer support from notifications and chat
    func setViewofCustomerSupportAndChat(vc:UIViewController){
        var images : [String]!
        images = ["homeNew", "historyNew",  "WalletNew", "profileNew"]
        
        let tabBarVC = UITabBarController()
        tabBarVC.view.backgroundColor = .white
        
        let profileVC = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "ProfileViewController")
        profileVC.title = NSLocalizedString("Profile", comment: "")
        
        let homeVC = UIStoryboard(name: "TaskCreation", bundle: nil).instantiateViewController(withIdentifier: "TaskCreationViewController")
        homeVC.title =  NSLocalizedString("Home", comment: "")
        
        let  historyVC = UIStoryboard(name: "TaskHistory", bundle: nil).instantiateViewController(withIdentifier: "TaskHistoryViewController")
        historyVC.title =  NSLocalizedString("Task History", comment: "")
        
        let accountVC  = UIStoryboard(name: "MoodyAccount", bundle: nil).instantiateViewController(withIdentifier: "SelectPaymentMethodViewController")
        accountVC.title = NSLocalizedString("Wallet", comment: "")
        
        let controllers = [homeVC, historyVC ,accountVC,profileVC]
        
        tabBarVC.viewControllers = controllers.map { UINavigationController(rootViewController: $0)}
        tabBarVC.tabBar.isTranslucent = false
        tabBarVC.tabBar.tintColor = UIColor(named: "GreenColor")
        
        tabBarVC.tabBar.contentMode = .left
        tabBarVC.tabBar.semanticContentAttribute = .forceLeftToRight
        tabBarVC.navigationController?.navigationBar.isHidden = true
        let item = tabBarVC.tabBar.items
        for x in 0..<item!.count {
            item![x].image = UIImage(named: images[x])
        }
        tabBarVC.modalPresentationStyle = .fullScreen
        
        window = UIWindow(frame: UIScreen.main.bounds)
        let discoverVC = tabBarVC
        discoverVC.modalPresentationStyle = .fullScreen
        let navigationController = UINavigationController(rootViewController: discoverVC)
        navigationController.navigationBar.isHidden = true
        self.window?.rootViewController = navigationController
        self.window?.makeKeyAndVisible()
        navigationController.pushViewController(vc, animated: true)
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse) {
        let userInfo = response.notification.request.content.userInfo
        
        ////ApiManager.sharedInstance.storeLogs(taskId: UserDefaults.standard.string(forKey: defaultsKeys.chatid)! , message: "Notification Received in background: \(userInfo["body"] ?? "")")
        // [START_EXCLUDE]
        // print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            //print"Message ID: \(messageID)")
        }
        // [END_EXCLUDE]
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // print full message.taskcr
        //print"2: \(userInfo)")
    }
    
}
// [END ios_10_message_handling]


extension AppDelegate : MessagingDelegate {
    // [START refresh_token]
    
    //MARK: calls when FCM token is registered
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        //print"Firebase registration token: \(String(describing: fcmToken))")
        
        
        let dataDict:[String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
        
        VerifyNumber.deveiceToken = fcmToken!
        
        var dict = [String:Any]()
        dict["device_token"] = fcmToken!
        dict["platform"] = "ios"
        dict["user_agent"] = AppPermission.getDeviceInfo()
        
        if(UserDefaults.standard.string(forKey: DefaultsKeys.token) != nil){
            ApiManager.sharedInstance.apiCaller(hasBodyData: true, hasToken: true, url: ENDPOINTS.update_fcm_token, dictionary: dict, httpMethod: "POST", token: UserDefaults.standard.string(forKey: DefaultsKeys.token)) { Result in
                switch Result{
                case .success(_):
                    break
                case .failure(_):
                    break
                }
            }
        }
        
    }
    // [END refresh_token]
    
}
struct LoginConstant {
    static let notSatisfyingDeviceToken = "Invalid parameter not satisfying: deviceToken != nil"
    static let enterToChat = NSLocalizedString("Enter to Video Chat", comment: "")
    static let fullNameDidChange = NSLocalizedString("Full Name Did Change", comment: "")
    static let login = NSLocalizedString("Login", comment: "")
    static let checkInternet = NSLocalizedString("Please check your Internet connection", comment: "")
    static let enterUsername = NSLocalizedString("Please enter your login and Display Name.", comment: "")
    static let shouldContainAlphanumeric = NSLocalizedString("Field should contain alphanumeric characters only in a range 3 to 20. The first character must be a letter.", comment: "")
    static let shouldContainAlphanumericWithoutSpace = NSLocalizedString("Field should contain alphanumeric characters only in a range 8 to 15, without space. The first character must be a letter.", comment: "")
    static let showUsers = "ShowUsersViewController"
    static let defaultPassword = "quickblox"
    static let infoSegue = "ShowInfoScreen"
    static let chatServiceDomain = "com.q-municate.chatservice"
    static let errorDomaimCode = -1000
}
/// method 1

extension AppDelegate {
    //MARK: step 2 for deep linking Capture link from Browser pasteBoard
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool{
        if let incomingURL = userActivity.webpageURL{
            
            print("Incoming URL link is \(incomingURL)")
            
        }
        return false
    }
    //MARK: Checks upcoming Dynamic URL
    func application(_ application: UIApplication, continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if let incomingURL = userActivity.webpageURL{
            
            print("Incoming URL link is \(incomingURL)")
            
            let dict = ["func name" : "continue userActivity",
                        "Incoming URL link is": "\(incomingURL)" ] as [String : Any]
            let linkHandled = DynamicLinks.dynamicLinks().handleUniversalLink(incomingURL) { (dynamiclink, error) in
                guard error == nil else{
                    print("Error is \(String(describing: error?.localizedDescription))")
                    let dict = ["func name" : "continue userActivity",
                                "Error is ": "\(String(describing: error?.localizedDescription))" ] as [String : Any]
                    
                    whistleWebhook.sharedInstance.errorLogsToWhistle(sendBodyData: dict)
                    return
                }
                if let dynamicLink = dynamiclink{
                    self.handleIncomingDynamicLink(dynamiclink!)
                    print("Error is \(String(describing: error?.localizedDescription))")
                    let dict = ["func name" : "continue userActivity",
                                "dynamicLink": "\(String(describing: dynamiclink))" ] as [String : Any]
                    
                }
            }
            if linkHandled{
                return true
            }
            else{
                // do other things with incoming url
                return false
            }
        }
        return false
    }
    //MARK: step 3 Handling for deep linking (Checks if refer code exist)
    func handleIncomingDynamicLink(_ dynamicLink: DynamicLink){
        
        guard let url = dynamicLink.url else{
            
            let dict = ["func name" : "handleIncomingDynamicLink",
                        "url": "\(String(describing: dynamicLink.url))" ] as [String : Any]
            
            //whistleWebhook.sharedInstance.errorLogsToWhistle(sendBodyData: dict)
            print("No dynamicLink URL")
            
            return
        }
        
        let dict = ["func name" : "handleIncomingDynamicLink",
                    "url": "\(dynamicLink.url)" ] as [String : Any]
        
        //whistleWebhook.sharedInstance.errorLogsToWhistle(sendBodyData: dict)
        
        print("Your Incoming link parameters are \(url.absoluteString)")
        guard (dynamicLink.matchType == .unique || dynamicLink.matchType == .default)
        else{
            print("Not a strong matchType to continue")
            return
        }
        //MARK: parse the link parameter (Extracting Parameters in dynamic link)
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems =  components.queryItems else{return}
        if components.path == "/refer"{
            let dict = ["func name" : "handleIncomingDynamicLink",
                        "components.path": "\(components.path)" ] as [String : Any]
            
            whistleWebhook.sharedInstance.errorLogsToWhistle(sendBodyData: dict)
            if let referCodeItem = queryItems.first(where: {$0.name == "referCode"}){
                guard let refCode = referCodeItem.value else{return}
                UserDefaults.standard.setValue(refCode, forKey: "refCode")
                var dictionary = [String:Any]()
                if refCode != ""{
                    print(UserDefaults.standard.string(forKey: "refCode")!)
                    dictionary["invite_code"] = refCode
                    validatePromoCode(dictionary: dictionary)
                }
            }
        }else {
            let dict = ["func name" : "handleIncomingDynamicLink",
                        "components.path": "nil" ] as [String : Any]
            
            whistleWebhook.sharedInstance.errorLogsToWhistle(sendBodyData: dict)
        }
    }
    //MARK: step 4 for deep linking
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        print("I have recieved a url through custom scheme \(url.absoluteString)")
        UserDefaults.standard.setValue(url.absoluteString, forKey: "dymanicUrl")
        if let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url){
            self.handleIncomingDynamicLink(dynamicLink)
            
            let dict = ["func name" : "open url",
                        "dynamicLink": "\(dynamicLink)" ] as [String : Any]
            
           // whistleWebhook.sharedInstance.errorLogsToWhistle(sendBodyData: dict)
            return true
        }
        else{
            
            let dict = ["func name" : "open url",
                        "dynamicLink": "not found"] as [String : Any]
            
           // whistleWebhook.sharedInstance.errorLogsToWhistle(sendBodyData: dict)
            return false
        }
    }
    //MARK: Sending promo code
    func validatePromoCode(dictionary : [String:Any]){
        let dict = ["func name" : "validatePromoCode Called"] as [String : Any]
        
        whistleWebhook.sharedInstance.errorLogsToWhistle(sendBodyData: dict)
        
        ApiManager.sharedInstance.apiCaller(hasBodyData: true, hasToken: true, url: ENDPOINTS.validateInviteCode, dictionary: dictionary, httpMethod: Constants.httpMethod, token: UserDefaults.standard.string(forKey: DefaultsKeys.token)) { [self] (result) in
            
            switch result {
            case .success(let response):
                let dict = ["func name" : "validatePromoCode Called",
                            " success response": "\(response)"] as [String : Any]
                
                whistleWebhook.sharedInstance.errorLogsToWhistle(sendBodyData: dict)
                
                print("Successs")
            case .failure(let error):
                
                let dict = ["func name" : "validatePromoCode Called",
                            " error response": "\(error.localizedDescription)"] as [String : Any]
                
                whistleWebhook.sharedInstance.errorLogsToWhistle(sendBodyData: dict)
                print("Failure")
                break
            }
        }
    }
    //MARK: Unsend Message Timer
    //. receives bool which checks timer bool and internet and calls protocol delegate message to chat
    //. which try to sent unsend message in chat
    func timerToSendMessages(startTimer:Bool){
        if(startTimer){
            if timer == nil {
                timer = Timer.scheduledTimer(withTimeInterval: 15, repeats: false) { [self] timer in
                    print("timer start")
                    if(CheckInternet.Connection()){
                        newMessageDelegate?.onInternetcoming()
                    }
                }
            }
        }else{
            if timer != nil {
                print("timer stop")

                timer?.invalidate()
                timer = nil
            }
        }
       
    }
    
    //MARK: Notification permission is set here
    func registerNotification(){
        let userNotificationCenter = UNUserNotificationCenter.current()
        userNotificationCenter.delegate = self
        let options : UNAuthorizationOptions = [.alert,.sound]
        userNotificationCenter.requestAuthorization(options: options) { isGranted, error in
            if !isGranted {
                print("permission not granted")
            }else{
                print("permission granted")
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
    
    
    //MARK: delegate method of protocol
    @objc func recallNotifications(_ notification:NSNotification){
        registerNotification()
      
    }
}
