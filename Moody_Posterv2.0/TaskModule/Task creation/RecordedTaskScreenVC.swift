//
//  RecordedTaskScreenVC.swift
//  Moody_Posterv2.0
//
//  Created by Muhammad Mobeen Rana on 02/11/2021.
//

import UIKit
import AVFoundation
import Quickblox
import QuickbloxWebRTC
import Lottie

class RecordedTaskScreenVC: UIViewController, QBRTCClientDelegate, AVAudioPlayerDelegate{
    
    //MARK: - Variables
    var player : AVAudioPlayer?
    var recordedDictionary = [String:Any]()
    var audioURL : URL?
    var timer = Timer()
    var duration = Float()
    private var animationView: AnimationView?
    
    //MARK: - IBOutlets
    @IBOutlet weak var startTimeLbl: UILabel!
    @IBOutlet weak var endTimeLbl: UILabel!
    @IBOutlet weak var playPauseBtn: UIButton!
    @IBOutlet weak var soundWavesView: UIView!
    @IBOutlet weak var sendBtnOutlet: UIButton!
    @IBOutlet weak var audioSeekBar: UIProgressView!
    @IBOutlet weak var cancelBtnOutlet: UIButton!
    @IBOutlet weak var activityLoader: UIActivityIndicatorView!
    
    //MARK: - View Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        activityLoader.isHidden = true
        audioSeekBar.progress = 0.0
        guard let url =  audioURL else {return}
        let audioAsset = AVURLAsset(url: url )
        self.duration = Float(CMTimeGetSeconds(audioAsset.duration))
        endTimeLbl.text = audioProgressTextFormat(duration)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
        giveBorderAndRadiusToButton()
        loadSoundGif()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        animationView?.removeFromSuperview()
        
    }
    //MARK: - IBActions
    @IBAction func backBtn(_ sender: Any) {
        finishAudio()
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: User Recorded Audio of task creation is played and paused here
    @IBAction func onClickPlayPauseBtn(_ sender: Any) {
        guard let url = audioURL else {return}
        if let player = player, player.isPlaying {
            audioSeekBar.progress = 0.0
            player.pause()
            animationView?.pause()
            playPauseBtn.setImage(UIImage(named: "Play-yellow"), for: .normal)
        } else {
            
            playPauseBtn.setImage(UIImage(named: "Pause-Red"), for: .normal)
            animationView?.play()
            
            do {
                timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector:
                                                #selector(audioProgress), userInfo: nil, repeats: true)
                try AVAudioSession.sharedInstance().setMode(.default)
                try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
                player = try AVAudioPlayer(contentsOf: url)
                player?.delegate = self
                player?.play()
                
            } catch  {
                print("Error Found in playing")
            }
        }
    }
    
    // MARK: cancel recorded audio and pop to homescreen
    @IBAction func cancelButton(_ sender: Any) {
        if let player = player, player.isPlaying {
            player.stop()
            stopSoundGif()
            self.navigationController?.popViewController(animated: true)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    //MARK: Send Requst to create task
    //. Api calls here and naviagtes to chatScreen
    @IBAction func sendRequestBtn(_ sender: Any) {
        activityLoader.isHidden = false
        activityLoader.startAnimating()
        makeButtonsNormal()
        
        if let player = player, player.isPlaying {
            player.stop()
            stopSoundGif()
            taskCreationAPI()
        } else {
            taskCreationAPI()
        }
    }
    
    
    func giveBorderAndRadiusToButton(){
        cancelBtnOutlet.layer.borderWidth = 1.5
        cancelBtnOutlet.layer.borderColor = UIColor(named: "AppTextColor")?.cgColor
        cancelBtnOutlet.layer.cornerRadius = 5
        sendBtnOutlet.layer.cornerRadius = 2

    }
    
    
    //MARK: - Functions
    @objc func audioProgress()  {
        
        let normalizedTime = Float(player?.currentTime as! Double / (player?.duration as! Double))
        self.audioSeekBar.progress = normalizedTime
        startTimeLbl.text = audioProgressTextFormat(Float(player?.currentTime ?? 0.0 - 1))
        
    }
    
    //MARK: Player Delegate which is call when is player is finsihed
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        startTimeLbl.text = "0:00"
        timer.invalidate()
        stopSoundGif()
        playPauseBtn.setImage(UIImage(named: "Play-yellow"), for: .normal)
        self.audioSeekBar.progress = 0.0
    }



    
    //MARK: finsishes audio if user goes back and audio is playing
    func finishAudio(){
        self.audioSeekBar.progress = 0.0
        timer.invalidate()
        player?.stop()
        stopSoundGif()
        playPauseBtn.setImage(UIImage(named: "Play-yellow"), for: .normal)
        
    }
    
    // MARK: Sets format of Player progress
    func audioProgressTextFormat(_ duration: Float) -> String {
        var retunValue = "0:00"
        if duration < 60 {
            retunValue = String(format: "0:%.02d", Int(duration.rounded(.up)))
        } else if duration < 3600 {
            retunValue = String(format: "%.02d:%.02d", Int(duration/60), Int(duration) % 60)
        } else {
            let hours = Int(duration/3600)
            let remainingMinutsInSeconds = Int(duration) - hours*3600
            retunValue = String(format: "%.02d:%.02d:%.02d", hours, Int(remainingMinutsInSeconds/60), Int(remainingMinutsInSeconds) % 60)
        }
        return retunValue
    }

    //MARK: General method makes button normal after completion of event e.g (success/failure of api)
    func makeButtonsNormal () {
        DispatchQueue.main.async { [self] in
            timer.invalidate()
            audioSeekBar.progress = 0.0
            playPauseBtn.setImage(UIImage(named: "Play-yellow"), for: .normal)
            startTimeLbl.text = "0:00"
        }
    }
    
    //MARK: Loads Sound GIF
    func loadSoundGif(){
        animationView = .init(name: "sound-waves")
        animationView!.frame = soundWavesView.bounds
        animationView!.contentMode = .scaleToFill
        animationView!.loopMode = .loop
        animationView!.animationSpeed = 2
        soundWavesView.addSubview(animationView!)
    }
    
    
    func pauseSoundGif(){
        animationView?.pause()
    }
    
    func stopSoundGif(){
        animationView!.stop()
    }
    
    //MARK: Api call to create Task
    //. on success of api Qb details are fetched from response and saved locally in userdefaults
    //. if qb login keys received logs in QB
    //. Pass task creation essential data to chat Screen and naviagtes to chat
    func taskCreationAPI(){
        cancelBtnOutlet.isUserInteractionEnabled = false
        sendBtnOutlet.isUserInteractionEnabled = false
        playPauseBtn.isUserInteractionEnabled = false
        let currentUser = sender(senderId: "Self", displayName: NSLocalizedString("Me", comment: ""))
        ApiManager.sharedInstance.apiCaller(hasBodyData: true, hasToken: true, url: ENDPOINTS.createTask, dictionary: recordedDictionary, httpMethod: "POST", token: UserDefaults.standard.string(forKey: DefaultsKeys.token) ) { [self] Result in
            switch Result{
            case .success(let resp):
                UserDefaults.standard.setValue(resp["task_id"] as! String, forKey: DefaultsKeys.taskId)
                let qbDetails = resp["quickblox_data"] as? [String:Any] ?? [String:Any]()
                
                qbDetails["qb_id"] as? Int != 0 ? UserDefaults.standard.set(qbDetails["qb_id"] as? Int ?? 0, forKey: DefaultsKeys.qb_id) : whistleWebhook.sharedInstance.FoundNillWebhooks(Endpoint: ENDPOINTS.createTask, Key: "qb_id")
                qbDetails["password"] as? String != "" ? UserDefaults.standard.set(qbDetails["password"] as? String ?? "", forKey: DefaultsKeys.qb_password) : whistleWebhook.sharedInstance.FoundNillWebhooks(Endpoint: ENDPOINTS.createTask, Key: "password")
                qbDetails["login"] as? String != "" ? UserDefaults.standard.set(qbDetails["login"] as? String ?? "", forKey: DefaultsKeys.qb_login) : whistleWebhook.sharedInstance.FoundNillWebhooks(Endpoint: ENDPOINTS.createTask, Key: "login")
                
                let isQbLogin = UserDefaults.standard.bool(forKey: DefaultsKeys.isQbLogin)
                
                if((qbDetails["login"] as? String != "") && isQbLogin == false){
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "qbLogin"), object: nil)
                }else if(isQbLogin == true) {
                    print("User Already loggedIn")
                }
                
                DispatchQueue.main.async { [self] in
                    tabBarController?.tabBar.isUserInteractionEnabled = true
                    let vc = ExtendedChat()
                    vc.hidesBottomBarWhenPushed = true
                    vc.messages.append(Messgae(sender: currentUser, messageId: "\(resp["message_id"]!)", sentDate: Date(), kind: .audio(audio(url: audioURL!)),downloadURL: ""))
                    vc.notifyBool.append(false)
                    vc.notifyStatus.append("sent")
                    vc.messagesTime.append("\(Date())")
                    vc.messagesDictionary["\(resp["message_id"]!)"] = "\(resp["message_id"]!)"
                    vc.messagesDictionaryText.append("audio")
                    LocationManagers.locationSharesInstance.stopLocationUpdate()
                  
                    //UserDefaults.standard.setValue("normal", forKey: DefaultsKeys.taskType)
                    activityLoader.stopAnimating()
                    activityLoader.isHidden = true
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            case .failure(let error):
                print(error)
                DispatchQueue.main.async {
                    makeButtonsNormal()
                    activityLoader.stopAnimating()
                    activityLoader.isHidden = true
                    playPauseBtn.isUserInteractionEnabled = true
                    cancelBtnOutlet.isUserInteractionEnabled = true
                    sendBtnOutlet.isUserInteractionEnabled = true
                    //ApiManager.sharedInstance.storeLogs(taskId: UserDefaults.standard.string(forKey: DefaultsKeys.taskId) ?? "" , message: "API Faliure: CreateTask \(ENDPOINTS.createTask)", type: "log")
                    self.presentAlert(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString( error.title, comment: ""), parentController: self)
                }
            }
        }
    }
}
