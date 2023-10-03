//
//  CallViewController.swift
//  Moody_Posterv2.0
//
//  Created by Syed Muhammad bin Saadat on 09/06/2021.
//

import UIKit
import Quickblox
import QuickbloxWebRTC
import SVProgressHUD
import Lottie

enum CallViewControllerState : Int {
    case disconnected
    case connecting
    case connected
    case disconnecting
}

struct CallStateConstant {
    static let disconnected = "Disconnected"
    static let connecting = "Connecting..."
    static let connected = "Connected"
    static let disconnecting = "Disconnecting..."
}

struct CallConstant {
    static let opponentCollectionViewCellIdentifier = "OpponentCollectionViewCellIdentifier"
    static let unknownUserLabel = "Unknown user"
    static let sharingViewControllerIdentifier = "SharingViewController"
    static let refreshTimeInterval: TimeInterval = 1.0
    
    static let memoryWarning = NSLocalizedString("MEMORY WARNING: leaving out of call. Please, reduce the quality of the video settings", comment: "")
    static let sessionDidClose = NSLocalizedString("Session did close due to time out", comment: "")
}

class CallViewController: UIViewController, UICollectionViewDelegateFlowLayout {
    //MARK: - IBOutlets
    @IBOutlet private weak var opponentsCollectionView: UICollectionView!
    @IBOutlet private weak var toolbar: ToolBar!
    
    //MARK: - Properties
    weak var usersDataSource: UsersDataSource?
    
    //MARK: - Internal Properties
    private var timeDuration: TimeInterval = 0.0
    
    private var callTimer: Timer?
    private var beepTimer: Timer?
    
    var networkTimer:Timer?

    //MARK: time
    var time = String()
    //MARK: Camera
    var session: QBRTCSession?
    
    var sessionConferenceType: QBRTCConferenceType = QBRTCConferenceType.audio
    var callUUID: UUID?
    lazy private var cameraCapture: QBRTCCameraCapture = {
        let settings = Settings()
        let cameraCapture = QBRTCCameraCapture(videoFormat: settings.videoFormat,
                                               position: settings.preferredCameraPostion)
        cameraCapture.startSession(nil)
        return cameraCapture
    }()
    
    //MARK: Containers
    private var users = [User]()
    private var videoViews = [UInt: UIView]()
    private var statsUserID: UInt?
    private var disconnectedUsers = [UInt]()
    
    //MARK: Views
    lazy private var dynamicButton: CustomButton = {
        let dynamicButton = ButtonsFactory.dynamicEnable()
        return dynamicButton
    }()
    
    lazy private var audioEnabled: CustomButton = {
        let audioEnabled = ButtonsFactory.audioEnable()
        return audioEnabled
    }()
    
    private var localVideoView: LocalVideoView?
    
    lazy private var statsView: StatsView = {
        let statsView = StatsView()
        return statsView
    }()
    
    private lazy var statsItem = UIBarButtonItem(title: "Stats",
                                                 style: .plain,
                                                 target: self,
                                                 action: #selector(updateStatsView))
    
    
    //MARK: States
    private var shouldGetStats = false
    private var didStartPlayAndRecord = false
    private var muteVideo = false {
        didSet {
            session?.localMediaStream.videoTrack.isEnabled = !muteVideo
        }
    }
    
    //MARK: new Layout outlets
    @IBOutlet var micBtn: UIButton!
    @IBOutlet var audioVideoBtn: UIButton!
    @IBOutlet var userPicture: UIImageView!
    @IBOutlet var backgroundView: UIView!
    @IBOutlet var userVideo: UIView!
    @IBOutlet var callerNameLabel: UILabel!
    @IBOutlet var callTimerLabel: UILabel!
    @IBOutlet var videoCallTimerView: UIView!
    @IBOutlet var videoCallRecordTimer: UILabel!
    @IBOutlet weak var hangUpOutlet: UIButton!
    @IBOutlet weak var userProfileGif: UIImageView!
    @IBOutlet weak var cameraFlip: UIButton!
    
    @IBOutlet weak var statusLabelOpp: UILabel!
    @IBOutlet weak var oppColl: UICollectionView!
    
    @IBOutlet weak var stackViewForButtons: UIStackView!
    weak var delegate: LocalVideoViewDelegate?
    private var animationView: AnimationView?
    
    //MARK: Checks call state
    private var state = CallViewControllerState.connected {
        didSet {
            switch state {
            case .disconnected:
                title = CallStateConstant.disconnected
            case .connecting:
                title = CallStateConstant.connecting
            case .connected:
                title = CallStateConstant.connected
            case .disconnecting:
                title = CallStateConstant.disconnecting
            }
        }
    }
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        videoCallRecordTimer.text = "00:00"
        getTime()
        
        guard let callingID = session?.initiatorID else {return}
        let callerID = "\(callingID)"
        
        let taskId = UserDefaults.standard.string(forKey: (DefaultsKeys.taskIdInCall)) ??  UserDefaults.standard.string(forKey: DefaultsKeys.taskId)!
        

        let data = UserDefaults.standard.value(forKey: DefaultsKeys.taskerDetails) as? Data ?? nil
        
        if(data != nil){
            let taskerQb = try? PropertyListDecoder().decode(Array<TaskerQbDetails>.self, from: data!)
            for arr in taskerQb! {
                if (arr.taskId == taskId){
                        //Name
                        if arr.taskerName != ""{
                            callerNameLabel.text =  arr.taskerName
                        } else {
                            callerNameLabel.text =  "Moody Tasker"
                        }
                        
                        //Image
                        if(arr.taskImageUrl != ""){
                            let link = URL(string: arr.taskImageUrl)
                            DispatchQueue.main.async { [self] in
                                guard let data = try? Data(contentsOf: link!) else {return}
                                userPicture.image = UIImage(data: data)
                            }
                            break
                            
                        } else {
                            self.userPicture.image = UIImage(named: "person2")
                        }
                }
        }
        }else{
            self.userPicture.image = UIImage(named: "person2")
            callerNameLabel.text = "Moody Tasker"
        }
            
           
        
        QBRTCAudioSession.instance().addDelegate(self)
        
        if self.session != nil {
            QBRTCClient.instance().add(self as QBRTCClientDelegate)
        } else {
            CallKitManager.instance.delegate = self
        }
        
        let profile = Profile()
        let conferenceType = self.session != nil ? self.session?.conferenceType : sessionConferenceType
        micBtn.setImage(UIImage(named: "micBtnNew"), for: .normal)

        if conferenceType == .video{
            
            callTimerLabel.isHidden = true
            userVideo.isHidden = true
            videoCallTimerView.isHidden = true
            audioVideoBtn.setImage(UIImage(named: "videoBtn"), for: .normal)
            cameraFlip.isHidden = false

        }
        else if conferenceType == .audio{
            
            userVideo.isHidden = true
            videoCallTimerView.isHidden = true
            cameraFlip.isHidden = true
            audioVideoBtn.setImage(UIImage(named: "speakerIcon"), for: .normal)
        }
        
        guard profile.isFull == true, let currentConferenceUser = Profile.currentUser() else {
            return
        }
        
        
        if conferenceType == .video {
            #if targetEnvironment(simulator)
            // Simulator
            #else
            // Device
            cameraCapture.startSession(nil)
            session?.localMediaStream.videoTrack.videoCapture = cameraCapture
            
            #endif
        }
        DispatchQueue.main.async { [self] in
            configureGUI()
        }
        
        
        
        opponentsCollectionView.collectionViewLayout = OpponentsFlowLayout()
        opponentsCollectionView.backgroundColor = UIColor(red: 0.1465,
                                                          green: 0.1465,
                                                          blue: 0.1465,
                                                          alpha: 1.0)
        view.backgroundColor = opponentsCollectionView.backgroundColor
        
        users.insert(currentConferenceUser, at: 0)
        title = CallStateConstant.connecting
        
        if let session = self.session {
            setupSession(session)
        }
        
        self.navigationController?.navigationBar.isHidden = true
        startNetworkCheckTimer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //MARK: - Reachability
        let updateConnectionStatus: ((_ status: NetworkConnectionStatus) -> Void)? = { [weak self] status in
            let notConnection = status == .notConnection
            if notConnection == true {
            }
        }
        loadCallingGif()
        animationView!.play()
        Reachability.instance.networkStatusBlock = { status in
            updateConnectionStatus?(status)
        }
        
        if cameraCapture.hasStarted == false {
            cameraCapture.startSession(nil)
        }
        DispatchQueue.main.async { [self] in
            session?.localMediaStream.videoTrack.videoCapture = cameraCapture
            reloadContent()
        }
       
    }
    
    
    func getTime(){
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        state = CallViewControllerState.disconnecting
        cancelCallAlertWith(CallConstant.memoryWarning)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        stopNetworkCheckTimer()
        animationView?.stop()
        UserDefaults.standard.setValue(nil, forKey: DefaultsKeys.taskIdInCall)
        userProfileGif.removeFromSuperview()
    }
    
    //MARK: calling fetch messages after regular interval and also its stop timer function
    @objc func checkNetworkSpeed(){
        let  networkStrength = getNetworkStrength()
        
        if networkStrength == 3 || networkStrength == 4{
            
        }else if networkStrength == 2 || networkStrength == 1{
            self.showToast(message: NSLocalizedString("Poor Internet connection.", comment: ""), font: UIFont.boldSystemFont(ofSize: 17))
        }else if(!CheckInternet.Connection()){
            self.showToast(message: NSLocalizedString("No Internet Available.", comment: ""), font: UIFont.boldSystemFont(ofSize: 17))
        }
    }
  
    func startNetworkCheckTimer(){
        guard networkTimer == nil else { return }
        networkTimer =  Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.checkNetworkSpeed), userInfo: nil, repeats: true)
    }
    
    func stopNetworkCheckTimer() {
        networkTimer?.invalidate()
        networkTimer = nil
    }
    
    //MARK:  Setup
    private func setupSession(_ session: QBRTCSession) {
        if session.conferenceType != sessionConferenceType {
            toolbar.removeAllButtons()
            toolbar.updateItems()
            configureGUI()
        }
        
        if session.conferenceType == .video {
            #if targetEnvironment(simulator)
            // Simulator
            #else
            // Device
            
            if cameraCapture.hasStarted == false {
                cameraCapture.startSession(nil)
            }
            session.localMediaStream.videoTrack.videoCapture = cameraCapture
            #endif
        }

        if session.opponentsIDs.isEmpty == false {
            let isInitiator = users[0].userID == session.initiatorID.uintValue
            if isInitiator == true {
                let audioSession = QBRTCAudioSession.instance()
                audioSession.useManualAudio = true
                audioSession.isAudioEnabled = true
                // disabling audio unit for local mic recording in recorder to enable it later
                session.recorder?.isLocalAudioEnabled = false
                if audioSession.isInitialized == false {
                    audioSession.initialize { configuration in
                        // adding blutetooth support
                        configuration.categoryOptions.insert(.allowBluetooth)
                        configuration.categoryOptions.insert(.allowBluetoothA2DP)
                        configuration.categoryOptions.insert(.duckOthers)
                        // adding airplay support
                        configuration.categoryOptions.insert(.allowAirPlay)
                        if session.conferenceType == .video {
                            // setting mode to video chat to enable airplay audio and speaker only
                            configuration.mode = AVAudioSession.Mode.videoChat.rawValue
                        } else if session.conferenceType == .audio {
                            // setting mode to video chat to enable airplay audio and speaker only
                            configuration.mode = AVAudioSession.Mode.voiceChat.rawValue
                        }
                    }
                }
                startCall()
                CallKitManager.instance.updateCall(with: callUUID, connectingAt: Date())
                
            } else {
                acceptCall()
            }
        }
    }
    
    private func configureGUI() {
        // when conferenceType is nil, it means that user connected to the session as a listener
        guard let conferenceType = self.session != nil ? self.session?.conferenceType : sessionConferenceType else {return}
        
        switch conferenceType {
        case .video:
//            toolbar.add(ButtonsFactory.videoEnable(), action: { [weak self] sender in
//                if let muteVideo = self?.muteVideo {
//                    self?.muteVideo = !muteVideo
//                    self?.localVideoView?.isHidden = !muteVideo
//                }
//            })
        break
        case .audio:
            if UIDevice.current.userInterfaceIdiom == .phone {
                QBRTCAudioSession.instance().currentAudioDevice = .receiver
                dynamicButton.pressed = false
                
                toolbar.add(dynamicButton, action: { sender in
                    let previousDevice = QBRTCAudioSession.instance().currentAudioDevice
                    let device = previousDevice == .speaker ? QBRTCAudioDevice.receiver : QBRTCAudioDevice.speaker
                    QBRTCAudioSession.instance().currentAudioDevice = device
                })
            }
        }
        
        session?.localMediaStream.audioTrack.isEnabled = true;
        toolbar.add(audioEnabled, action: { [weak self] sender in
            guard let self = self else {return}
            
            if let muteAudio = self.session?.localMediaStream.audioTrack.isEnabled {
                self.session?.localMediaStream.audioTrack.isEnabled = !muteAudio
            }
        })
        
        CallKitManager.instance.onMicrophoneMuteAction = { [weak self] in
            guard let self = self else {return}
            self.audioEnabled.pressed = !self.audioEnabled.pressed
        }
        
        toolbar.add(ButtonsFactory.decline(), action: { [weak self] sender in
            self?.session?.hangUp(["hangup": "hang up"])
        })
        
        toolbar.updateItems()
        
        let mask: UIView.AutoresizingMask = [.flexibleWidth,
                                             .flexibleHeight,
                                             .flexibleLeftMargin,
                                             .flexibleRightMargin,
                                             .flexibleTopMargin,
                                             .flexibleBottomMargin]
        
        // stats view
        statsView.frame = view.bounds
        statsView.autoresizingMask = mask
        statsView.isHidden = true
        statsView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(updateStatsState)))
        view.addSubview(statsView)
        
        // add button to enable stats view
        state = .connecting
    }
    
    // MARK: Transition to size
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { [weak self] context in
            self?.reloadContent()
        })
    }
    
    // MARK: - Actions
    func startCall() {
        //Begin play calling sound
        beepTimer = Timer.scheduledTimer(timeInterval: QBRTCConfig.dialingTimeInterval(),
                                         target: self,
                                         selector: #selector(playCallingSound(_:)),
                                         userInfo: nil, repeats: true)
        playCallingSound(nil)
        //Start call
        let userInfo = ["name": "aamna", "url": "http.quickblox.com", "param": "\"1,2,3,4\""]
        
        
        let taskId = UserDefaults.standard.string(forKey: DefaultsKeys.taskId)
        

        let data = UserDefaults.standard.value(forKey: DefaultsKeys.taskerDetails) as? Data ?? nil
        
        if(data != nil){
            let taskerQb = try? PropertyListDecoder().decode(Array<TaskerQbDetails>.self, from: data!)
            for arr in taskerQb! {
                if (arr.taskId == taskId){
                        //Name
                        if arr.taskerName != ""{
                            callerNameLabel.text =  arr.taskerName
                        } else {
                            callerNameLabel.text =  "Moody Tasker"
                        }
                        
                        //Image
                        if(arr.taskImageUrl != ""){
                            let link = URL(string: arr.taskImageUrl)
                            DispatchQueue.main.async { [self] in
                                guard let data = try? Data(contentsOf: link!) else {return}
                                userPicture.image = UIImage(data: data)
                            }
                            break
                            
                        } else {
                            self.userPicture.image = UIImage(named: "person2")
                        }
                }
        }
        }else{
            self.userPicture.image = UIImage(named: "person2")
            callerNameLabel.text = "Moody Tasker"
        }
        session?.startCall(userInfo)
    }
    
    func acceptCall() {
        SoundProvider.stopSound()
        //Accept call
        let userInfo = ["acceptCall": "userInfo"]
        session?.acceptCall(userInfo)
    }
     
    @IBAction func hangUpBtn(_ sender: Any) {
        
        if session?.state != .connected{
            let message = "Call Missed by Tasker at \(time)"
            sendMessage(message: message)
            self.hangUpOutlet.isUserInteractionEnabled = false
        }
        
        closeCall()
    }
    
    @IBAction func onclickFlip(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "switchCamera"), object: nil)
    }
    private func closeCall() {
        
        CallKitManager.instance.endCall(with: callUUID)
        cameraCapture.stopSession(nil)
        let userInfo = ["key":"value"] // optional
        self.session?.hangUp(userInfo)

        // and release session instance
        self.session = nil
        
        let audioSession = QBRTCAudioSession.instance()
        if audioSession.isActive == true,
            audioSession.audioSessionIsActivatedOutside(AVAudioSession.sharedInstance()) == false {
            debugPrint("[CallViewController] Deinitializing QBRTCAudioSession.")
            audioSession.setActive(false)
        }
        
        if let beepTimer = beepTimer {
            beepTimer.invalidate()
            self.beepTimer = nil
            SoundProvider.stopSound()
        }
        
        if let callTimer = callTimer {
            callTimer.invalidate()
            self.callTimer = nil
        }
        
        toolbar.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.5) {
            self.toolbar.alpha = 0.4
        }
        state = .disconnected
        title = "End - \(string(withTimeDuration: timeDuration))"
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func updateStatsView() {
        shouldGetStats = !shouldGetStats
        statsView.isHidden = !statsView.isHidden
    }
    
    @objc func updateStatsState() {
        updateStatsView()
    }
    
    
    
    //MARK: - Internal Methods
    private func zoomUser(userID: UInt) {
        statsUserID = userID
        reloadContent()
        navigationItem.rightBarButtonItem = statsItem
    }
    
    private func unzoomUser() {
        statsUserID = nil
        reloadContent()
        navigationItem.rightBarButtonItem = nil
    }
    
    private func userView(userID: UInt) -> UIView? {
        
        let profile = Profile()
        let conferenceType = self.session != nil ? self.session?.conferenceType : sessionConferenceType
        if profile.isFull == true, profile.ID == userID,
            conferenceType == QBRTCConferenceType.video {
            
            if cameraCapture.hasStarted == false {
                cameraCapture.startSession(nil)
                session?.localMediaStream.videoTrack.videoCapture = cameraCapture
            }
            //Local preview
            if let result = videoViews[userID] as? LocalVideoView {
                return result
            } else {
                let previewLayer = cameraCapture.previewLayer
                let localVideoView = LocalVideoView(previewlayer: previewLayer)
                videoViews[userID] = localVideoView
                
                localVideoView.delegate = self
                self.localVideoView = localVideoView
                localVideoView.layer.borderWidth = 2
                localVideoView.layer.borderColor = UIColor.white.cgColor
                localVideoView.layer.cornerRadius = 5
                localVideoView.layer.masksToBounds = true
                return localVideoView
            }
            
        } else if let remoteVideoTraсk = session?.remoteVideoTrack(withUserID: NSNumber(value: userID)) {
            if var result = videoViews[userID] as? QBRTCRemoteVideoView {
                result = QBRTCRemoteVideoView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
                result.setVideoTrack(remoteVideoTraсk)
                return result
            } else {
                //Opponents
                let remoteVideoView = QBRTCRemoteVideoView(frame: CGRect(x: 2.0, y: 2.0, width: 2.0, height: 2.0))
                remoteVideoView.videoGravity = AVLayerVideoGravity.resizeAspect.rawValue
                videoViews[userID] = remoteVideoView
                remoteVideoView.setVideoTrack(remoteVideoTraсk)
                
                return remoteVideoView
            }
        }
        return nil
    }
    
    private func userCell(userID: UInt) -> UserCell? {
       guard let indexPath = userIndexPath(userID: userID),
        let cell = opponentsCollectionView.cellForItem(at: indexPath) as? UserCell  else {
            return nil
        }
        return cell
    }
    
    private func createConferenceUser(userID: UInt) -> User? {
        guard let usersDataSource = self.usersDataSource,
            let user = usersDataSource.user(withID: userID) else {
                return nil
        }
        return User(user: user)
    }
    
    private func userIndexPath(userID: UInt) -> IndexPath? {
        guard let index = users.index(where: { $0.userID == userID }), index != NSNotFound else {
//            return IndexPath(row: 0, section: 0)
            return nil
        }
        return IndexPath(row: index, section: 0)
    }
    
    func reloadContent() {
        videoViews.values.forEach{ $0.removeFromSuperview() }
        opponentsCollectionView.reloadData()
    }
    
    func loadCallingGif(){
        animationView = .init(name: "Calling-Gif")
        animationView!.frame = userProfileGif.bounds
        animationView!.contentMode = .scaleAspectFill
        animationView!.loopMode = .loop
        animationView!.animationSpeed = 1
        userProfileGif.addSubview(animationView!)
        print("Calling gif has been loaded and added to subview")
    }

    // MARK: - Helpers
    private func cancelCallAlertWith(_ title: String) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: NSLocalizedString("Dismin", comment: ""), style: .cancel) { (action) in
            self.closeCall()
        }
        alert.view.tintColor = UIColor(named: "ButtonColor")
        alert.addAction(cancelAction)
        present(alert, animated: false) {
        }
    }
    
    // MARK: - Timers actions
    @objc func playCallingSound(_ sender: Any?) {
        SoundProvider.playSound(type: .calling)
    }
    
    @objc func refreshCallTime(_ sender: Timer?) {
        timeDuration += CallConstant.refreshTimeInterval
        title = "Call time - \(string(withTimeDuration: timeDuration))"
        callTimerLabel.text = "\(string(withTimeDuration: timeDuration))"
        videoCallRecordTimer.text = "\(string(withTimeDuration: timeDuration))"
    }
    
    func string(withTimeDuration timeDuration: TimeInterval) -> String {
        let hours = Int(timeDuration / 3600)
        let minutes = Int(timeDuration / 60)
        let seconds = Int(timeDuration) % 60
        
        var timeStr = ""
        if hours > 0 {
            let minutes = Int((timeDuration - Double(3600 * hours)) / 60);
            timeStr = "\(hours):\(minutes):\(seconds)"
        } else {
            if (seconds < 10) {
                timeStr = "\(minutes):0\(seconds)"
            } else {
                timeStr = "\(minutes):\(seconds)"
            }
        }
        return timeStr
    }
    
    @IBAction func muteCallBtn(_ sender: Any) {
       
        if let muteAudio = self.session?.localMediaStream.audioTrack.isEnabled {
            self.session?.localMediaStream.audioTrack.isEnabled = !muteAudio
            if micBtn.currentImage == UIImage(named: "micBtnNew") {
                micBtn.setImage(UIImage(named: "micMuteBtn"), for: .normal)
            }
            else{
                micBtn.setImage(UIImage(named: "micBtnNew"), for: .normal)
            }
        }
        
    }
    
    @IBAction func switchSpeakerBtn(_ sender: Any) {
    
        let conferenceType = self.session != nil ? self.session?.conferenceType : sessionConferenceType
        if conferenceType == QBRTCConferenceType.audio {
            
            let previousDevice = QBRTCAudioSession.instance().currentAudioDevice
            let device = previousDevice == .speaker ? QBRTCAudioDevice.receiver : QBRTCAudioDevice.speaker
            if audioVideoBtn.currentImage == UIImage(named: "speakerIcon") {
                audioVideoBtn.setImage(UIImage(named: "loudSpeakerIcon"), for: .normal)
            }
            else{
                audioVideoBtn.setImage(UIImage(named: "speakerIcon"), for: .normal)
            }
            QBRTCAudioSession.instance().currentAudioDevice = device
            
            
        }
        else if conferenceType == QBRTCConferenceType.video {
            
            DispatchQueue.main.async { [weak self] in
                if let muteVideo = self?.muteVideo {
                    self?.muteVideo = !muteVideo
                    self?.localVideoView?.isHidden = !muteVideo
                }
                if self!.audioVideoBtn.currentImage == UIImage(named: "videoBtn") {
                    self!.audioVideoBtn.setImage(UIImage(named: "videoDisableBtn"), for: .normal)
                }
                else{
                    self!.audioVideoBtn.setImage(UIImage(named: "videoBtn"), for: .normal)
                }
            
            }
        }
        
    }
        
}

extension CallViewController: LocalVideoViewDelegate {
    // MARK: LocalVideoViewDelegate
    func localVideoView(_ localVideoView: LocalVideoView, pressedSwitchButton sender: UIButton?) {
        let newPosition: AVCaptureDevice.Position = cameraCapture.position == .back ? .front : .back
        guard cameraCapture.hasCamera(for: newPosition) == true else {
            return
        }
        let animation = CATransition()
        animation.duration = 0.75
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.type = CATransitionType(rawValue: "oglFlip")
        animation.subtype = cameraCapture.position == .back ? .fromLeft : .fromRight
        
        localVideoView.superview?.layer.add(animation, forKey: nil)
        cameraCapture.position = newPosition
    }
    
}

extension CallViewController: QBRTCAudioSessionDelegate {
    //MARK: QBRTCAudioSessionDelegate
    func audioSession(_ audioSession: QBRTCAudioSession, didChangeCurrentAudioDevice updatedAudioDevice: QBRTCAudioDevice) {
        let isSpeaker = updatedAudioDevice == .speaker
        dynamicButton.pressed = isSpeaker
    }
}

// MARK: QBRTCClientDelegate
extension CallViewController: QBRTCClientDelegate {
    
    func session(_ session: QBRTCBaseSession, disconnectedFromUser userID: NSNumber) {
        guard let qbSession = session as? QBRTCSession,
            qbSession == self.session,
            let opponentsIDsCount = self.session?.opponentsIDs.count  else {
                return
        }
        if opponentsIDsCount == 1 {
            closeCall()
        } else {
            if disconnectedUsers.contains(userID.uintValue) == false {
                disconnectedUsers.append(userID.uintValue)
            }
            if disconnectedUsers.count == opponentsIDsCount {
                closeCall()
            }
        }
    }
    
    
    func session(_ session: QBRTCSession, userDidNotRespond userID: NSNumber) {
        print("User did not respond to the call")
        
        if session.initiatorID.stringValue == UserDefaults.standard.string(forKey: DefaultsKeys.qb_id){
            let message = "Call Missed by Tasker at \(time)"
            sendMessage(message: message)
        }
        
        
        
    }
    
    func session(_ session: QBRTCSession, rejectedByUser userID: NSNumber, userInfo: [String : String]? = nil) {
        if session == self.session, session.opponentsIDs.count == 1 {
            let message = "Call Rejected by Tasker at \(time)"
            sendMessage(message: message)
            closeCall()
        }
    }
    
    func session(_ session: QBRTCSession, hungUpByUser userID: NSNumber, userInfo: [String : String]? = nil) {
        if session == self.session, session.opponentsIDs.count == 1 {
           // let message = "Call Accepted at \(time)"
           // sendMessage(message: message)

            closeCall()
        }
    }
    
    func session(_ session: QBRTCBaseSession, updatedStatsReport report: QBRTCStatsReport, forUserID userID: NSNumber) {
        guard let qbSession = session as? QBRTCSession,
            qbSession == self.session else {
                return
        }
        
        var existingUser: User?
        if let user = users.filter({ $0.userID == userID.uintValue }).first {
            existingUser = user
        }
        
        let profile = Profile()
        let isInitiator = profile.ID == qbSession.initiatorID.uintValue
        if isInitiator == false && existingUser == nil {
            if let user = createConferenceUser(userID: userID.uintValue) {
                self.users.insert(user, at: 0)
                reloadContent()
            } else {
                usersDataSource?.loadUser(userID.uintValue, completion: { [weak self] (user) in
                    if let user = self?.createConferenceUser(userID: userID.uintValue) {
                        self?.users.insert(user, at: 0)
                        self?.reloadContent()
                    }
                })
            }
        }
        
        guard let user = users.filter({ $0.userID == userID.uintValue }).first else {
            return
        }
        
        if user.connectionState == .connected,
            report.videoReceivedBitrateTracker.bitrate > 0.0 {
            user.bitrate = report.videoReceivedBitrateTracker.bitrate
            
           if let userIndexPath = self.userIndexPath(userID: user.userID),
            let cell = self.opponentsCollectionView.cellForItem(at: userIndexPath) as? UserCell {
                cell.bitrate = user.bitrate
            }
        }
        
        guard let selectedUserID = statsUserID,
            selectedUserID == userID.uintValue,
            shouldGetStats == true else {
                return
        }
        let result = report.statsString()
        statsView.updateStats(result)
    }
    
    /**
     *  Called in case when connection state changed
     */
    func session(_ session: QBRTCBaseSession, connectionClosedForUser userID: NSNumber) {
        guard let qbSession = session as? QBRTCSession,
            qbSession == self.session else {
                return
        }
        // remove user from the collection
        if statsUserID == userID.uintValue {
            unzoomUser()
        }
        
        guard let index = users.firstIndex(where: { $0.userID == userID.uintValue }) else {
            return
        }
        let user = users[index]
        if user.connectionState == .connected {
            return
        }
        
        user.bitrate = 0.0
        
        if let videoView = videoViews[userID.uintValue] as? QBRTCRemoteVideoView {
            videoView.removeFromSuperview()
            videoViews.removeValue(forKey: userID.uintValue)
            let remoteVideoView = QBRTCRemoteVideoView(frame: CGRect(x: 2.0, y: 2.0, width: 2.0, height: 2.0))
            remoteVideoView.videoGravity = AVLayerVideoGravity.resizeAspectFill.rawValue
            videoViews[userID.uintValue] = remoteVideoView
        }
        reloadContent()
    }
    
    /**
     *  Called in case when connection state changed
     */
    func session(_ session: QBRTCBaseSession, didChange state: QBRTCConnectionState, forUser userID: NSNumber) {
        guard let qbSession = session as? QBRTCSession,
            qbSession == self.session,
            let opponentsIDsCount = self.session?.opponentsIDs.count  else {
                return
        }
        
        if let index = users.firstIndex(where: { $0.userID == userID.uintValue }) {
            let user = users[index]
            if user.connectionState != .hangUp {
                user.connectionState = state
            }
           if let userIndexPath = self.userIndexPath(userID:userID.uintValue),
            let cell = self.opponentsCollectionView.cellForItem(at: userIndexPath) as? UserCell {
                cell.connectionState = user.connectionState
            }
        } else {
            if let user = createConferenceUser(userID: userID.uintValue) {
                user.connectionState = state
                if user.connectionState == .connected {
                    self.users.insert(user, at: 0)
                    reloadContent()
                }
            } else {
                usersDataSource?.loadUser(userID.uintValue, completion: { [weak self] (user) in
                    if let user = self?.createConferenceUser(userID: userID.uintValue) {
                        user.connectionState = state
                        if user.connectionState == .connected {
                            self?.users.insert(user, at: 0)
                            self?.reloadContent()
                        }
                    }
                })
            }
        }
        
        let profile = Profile()
        if profile.ID == userID.uintValue {
            return
        }
        if state == .disconnected ||
            state == .hangUp ||
            state == .rejected ||
            state == .closed ||
            state == .failed {
            if opponentsIDsCount == 1 {
                closeCall()
            } else {
                if disconnectedUsers.contains(userID.uintValue) == false {
                    disconnectedUsers.append(userID.uintValue)
                }
                if disconnectedUsers.count == opponentsIDsCount {
                    closeCall()
                }
            }
        }
    }
    
    /**
     *  Called in case when receive remote video track from opponent
     */
    func session(_ session: QBRTCBaseSession,
                 receivedRemoteVideoTrack videoTrack: QBRTCVideoTrack,
                 fromUser userID: NSNumber) {
        guard let qbSession = session as? QBRTCSession,
            qbSession == self.session else {
                return
        }
        reloadContent()
    }
    
    /**
     *  Called in case when connection is established with opponent
     */
    func session(_ session: QBRTCBaseSession, connectedToUser userID: NSNumber) {
        
       // let message = "Call Accepted at \(time)"
       // sendMessage(message: message)
        guard let qbSession = session as? QBRTCSession,
            qbSession == self.session else {
                return
        }
        
        if let beepTimer = beepTimer {
            beepTimer.invalidate()
            self.beepTimer = nil
            SoundProvider.stopSound()
        }
        
        if callTimer == nil {
            let profile = Profile()
            if profile.isFull == true,
                self.session?.initiatorID.uintValue == profile.ID {
                CallKitManager.instance.updateCall(with: callUUID, connectedAt: Date())
            }
            
            callTimer = Timer.scheduledTimer(timeInterval: CallConstant.refreshTimeInterval,
                                             target: self,
                                             selector: #selector(refreshCallTime(_:)),
                                             userInfo: nil,
                                             repeats: true)
        }
    }
    
    func sessionDidClose(_ session: QBRTCSession) {
        if let sessionID = self.session?.id,
            sessionID == session.id {
            closeCall()
        }
    }
}

extension CallViewController: UICollectionViewDataSource {
    // MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let conferenceType = self.session != nil ? self.session?.conferenceType : sessionConferenceType
        if conferenceType == QBRTCConferenceType.audio {
            //return users.count
            return 1
        } else {
            return statsUserID != nil ? 1 : users.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CallConstant.opponentCollectionViewCellIdentifier,
                                                            for: indexPath) as? UserCell else {
                                                                return UICollectionViewCell()
        }
        
        var index = indexPath.row
        let conferenceType = self.session != nil ? self.session?.conferenceType : sessionConferenceType
        if conferenceType == QBRTCConferenceType.video {
            if let selectedUserID = statsUserID,
                let selectedIndexPath = userIndexPath(userID: selectedUserID) {
                index = selectedIndexPath.row
            }
        }
        
        let user = users[index]
        let userID = NSNumber(value: user.userID)
        
        if let audioTrack = session?.remoteAudioTrack(withUserID: userID) {
            cell.muteButton.isSelected = !audioTrack.isEnabled
        }
        
        cell.didPressMuteButton = { [weak self] isMuted in
            let audioTrack = self?.session?.remoteAudioTrack(withUserID: userID)
            audioTrack?.isEnabled = !isMuted
        }
        
        cell.videoView = userView(userID: user.userID)
              
        if let view = cell.videoView {
            userVideo.insertSubview(view, at: 0)
            
            view.translatesAutoresizingMaskIntoConstraints = false
            view.leftAnchor.constraint(equalTo: userVideo.leftAnchor).isActive = true
            view.rightAnchor.constraint(equalTo: userVideo.rightAnchor).isActive = true
            view.topAnchor.constraint(equalTo: userVideo.topAnchor).isActive = true
            view.bottomAnchor.constraint(equalTo: userVideo.bottomAnchor).isActive = true
        }
        
        cell.name = ""
        cell.connectionState = .unknown
        guard let currentUser = QBSession.current.currentUser, user.userID != currentUser.id else {
            return cell
        }
        
        if let view = cell.videoView {
            backgroundView.insertSubview(view, at: 0)
            
            userVideo.isHidden = false
            videoCallRecordTimer.isHidden = false
            videoCallTimerView.isHidden = false
            cameraFlip.isHidden = false
            userProfileGif.isHidden = true

            view.translatesAutoresizingMaskIntoConstraints = false
            view.leftAnchor.constraint(equalTo: backgroundView.leftAnchor).isActive = true
            view.rightAnchor.constraint(equalTo: backgroundView.rightAnchor).isActive = true
            view.topAnchor.constraint(equalTo: backgroundView.topAnchor).isActive = true
            view.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor).isActive = true
        }
        
        if conferenceType == .video{
            userPicture.isHidden = true
            callerNameLabel.isHidden = true
            cameraFlip.isHidden = false

        }
        
        if user.bitrate > 0.0 {
            cell.bitrate = user.bitrate
        }
        cell.connectionState = user.connectionState
//        let title = "Moody Tasker"
//        cell.name = title
//        callerNameLabel.text = title
        
        return cell
    }
    
    func getNetworkStrength() -> Int? {
        
        let application = UIApplication.shared
        var statusBarView = UIView()
        var foregroundView = UIView()
        
        if #available(iOS 13.0, *) {
            if let statusBarManager = UIApplication.shared.keyWindow?.windowScene?.statusBarManager,
               let localStatusBar = statusBarManager.value(forKey: "createLocalStatusBar") as? NSObject,
               let statusBar = localStatusBar.value(forKey: "statusBar") as? NSObject,
               let _statusBar = statusBar.value(forKey: "_statusBar") as? UIView,
               let currentData = _statusBar.value(forKey: "currentData")  as? NSObject,
               let celluar = currentData.value(forKey: "cellularEntry") as? NSObject,
               let wifi = currentData.value(forKey: "wifiEntry") as? NSObject{
                
                if wifi.value(forKey: "displayValue") as? Int != 0{
                    return wifi.value(forKey: "displayValue") as? Int
                    
                }else if celluar.value(forKey: "displayValue") as? Int != 0{
                    return celluar.value(forKey: "displayValue") as? Int
                }else{
                    return nil
                }
            } else {
                return nil
            }
        } else {
            
            statusBarView = application.value(forKey: "statusBar") as! UIView
            foregroundView = statusBarView.value(forKey: "foregroundView") as! UIView
        }
        
        let foregroundViewSubviews = foregroundView.subviews
        var dataNetworkItemView:UIView!
        
        for subview in foregroundViewSubviews {
            if subview.isKind(of: NSClassFromString("UIStatusBarSignalStrengthItemView")!) {
                dataNetworkItemView = subview
                break
            } else {
                return 0 //NO SERVICE
            }
        }
        
        return dataNetworkItemView.value(forKey: "signalStrengthBars") as? Int
    }
    
}

extension CallViewController: UICollectionViewDelegate {
    // MARK: UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        guard let currentUserID = session?.currentUserID,
            user.userID != currentUserID.uintValue else {
                return
        }
        guard let session = session else {
            return
        }
        if session.conferenceType == QBRTCConferenceType.audio {
            // just show stats on click if in audio call
            statsUserID = user.userID
            updateStatsView()
        } else {
            if statsUserID == nil {
                if user.connectionState == .connected {
                    zoomUser(userID: user.userID)
                }
            } else {
                unzoomUser()
            }
        }
    }
}

extension CallViewController: CallKitManagerDelegate {
    func callKitManager(_ callKitManager: CallKitManager, didUpdateSession session: QBRTCSession) {
        if self.session == nil {
            QBRTCClient.instance().add(self as QBRTCClientDelegate)
//          QBRTCAudioSession.instance().addDelegate(self)
            CallKitManager.instance.delegate = nil
            self.session = session
            setupSession(session)
        }
    }
}



extension CallViewController{
    func creatSendMessageDictionary(message: String)->[String:Any]{
          var dictionary = [String:Any]()
          dictionary["task_id"] = UserDefaults.standard.string(forKey:DefaultsKeys.taskId)
          dictionary["call_logs"] = message
          dictionary["user_agent"] = AppPermission.getDeviceInfo()
          dictionary["platform"] = "ios"
          return dictionary
      }
    
    func sendMessage(message: String){
      
        if CheckInternet.Connection() {
            ApiManager.sharedInstance.apiCaller(hasBodyData: true, hasToken: true, url: ENDPOINTS.send_message, dictionary: creatSendMessageDictionary(message: message), httpMethod: "POST", token: UserDefaults.standard.string(forKey: DefaultsKeys.token)) { Result in
                switch Result{
                case .success(_):
                    print("Call log appended")

                    break
                case .failure(_):                    //printerror)
                    
                    break
                }
            }
        }
    }
}
