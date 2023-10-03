//
//  TaskHistoryCell.swift
//  Moody_Posterv2.0
//
//  Created by Syed Muhammad bin Saadat on 04/06/2021.
//

import Foundation
import UIKit
import AVFoundation
import Lottie


class TaskHistoryCell: UITableViewCell, AVAudioPlayerDelegate {
    
    
    //MARK: Outlets
    @IBOutlet weak var mainOuterView: UIView!
    @IBOutlet weak var notificationImage: UIImageView!
    @IBOutlet weak var countLbl: UILabel!
    @IBOutlet weak var audioPlayPauseBtn: UIButton!
    @IBOutlet weak var viewDetailsBtn: UIButton!
    @IBOutlet weak var audioTime: UILabel!
    @IBOutlet weak var audioSeekBar: UIProgressView!
    @IBOutlet var statusBtn: UIButton!
    @IBOutlet var Date: UILabel!
    @IBOutlet var Fare: UILabel!
    @IBOutlet var taskTypeLabel: UILabel!
    @IBOutlet var taskTypeImage: UIImageView!
    @IBOutlet weak var separetorView: UIView!
    @IBOutlet weak var topUpTaskLbl: UILabel!
    
    let animationView = AnimationView()
    
    
    //MARK: Variables
    var audioTimer:Double = 0.0
    var taskID:String = ""
    var taskType:String = ""
    var audioPath:String = ""
    var selectedMonth: Int = 0
    var navigationController: UINavigationController!
    var discount:String = ""
    var status:String = ""
    var taskDetails = [String:Any]()
    
     
    
    
    
    var downloadDelay: Double = 0.0
    var audioPlayer: AVAudioPlayer?
    var audioMessage:String?
    var isPlaying:Bool = false
    var timer:Timer?
    
    
    var fileManager : FileManager?
    var documentDir : NSString?
    var filePath : NSString?
    
    var playButtonTapped : (()->())?
    
    var hour = 0
    var min = 0
    var sec = 0
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.stopAudio(_:)), name: NSNotification.Name(rawValue: "goingOutFromHistory"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.stopAudio(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        notificationImage.isUserInteractionEnabled = true
        notificationImage.addGestureRecognizer(tapGestureRecognizer)
        
        audioSeekBar.progress = 0.0
        timer?.invalidate()

        UIProgressView.appearance().semanticContentAttribute = .forceLeftToRight
        self.audioSeekBar.progress = 0.0
        countLbl.layer.cornerRadius = 7.5

        let image = UIImage(named: "audioPlay")?.withRenderingMode(.alwaysTemplate)
        audioPlayPauseBtn.setImage(image, for: .normal)
        audioPlayPauseBtn.tintColor = UIColor.black
        mainOuterView.layer.borderWidth = 1
        mainOuterView.layer.borderColor = UIColor.gray.cgColor
        mainOuterView.layer.cornerRadius = 5
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if(statusBtn.titleLabel?.text == "Completed" || statusBtn.titleLabel?.text == "Cancelled" || statusBtn.titleLabel?.text == "مکمل" || statusBtn.titleLabel?.text == "منسوخ"){
            Fare.isHidden = false
        }else{
        }
    
        mainOuterView.layer.borderWidth = 1
        mainOuterView.layer.borderColor = UIColor.gray.cgColor
        mainOuterView.layer.cornerRadius = 5
        
    }
    
    
    //MARK: Naviagtes to Chat
    //. By tapping on notification badge image it navigates to chat
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer){
        playButtonTapped?()
        if(statusBtn.titleLabel?.text == "Completed" || statusBtn.titleLabel?.text == "Cancelled" || statusBtn.titleLabel?.text == "مکمل" || statusBtn.titleLabel?.text == "منسوخ"){
            ChatViewController.isFromActiveTask = false
        }else{ 
            ChatViewController.isFromActiveTask = true
       }
        
        finishAudio()
        UserDefaults.standard.setValue(taskID, forKey: DefaultsKeys.taskId)
        let vc = ExtendedChat()
        vc.hidesBottomBarWhenPushed = true
        vc.status = status
        self.navigationController?.pushViewController(vc, animated: true)
        
       
    }
    
    //MARK: Navigate to taskHistory details or for active task it takes to chat
    //. Checks task status and than navigates to respective screen
    @IBAction func viewDetailsBtnPressed(_ sender: Any) {
        playButtonTapped?()
        finishAudio()
        if(statusBtn.titleLabel?.text == "Completed" || statusBtn.titleLabel?.text == "Cancelled" || statusBtn.titleLabel?.text == "مکمل" || statusBtn.titleLabel?.text == "منسوخ"){
            if(status == "due_payment"){
                UserDefaults.standard.setValue(taskID, forKey: DefaultsKeys.taskId)
                ChatViewController.isFromActiveTask = true
                let vc = ExtendedChat()
                vc.hidesBottomBarWhenPushed = true
                vc.status = status
                self.navigationController?.pushViewController(vc, animated: true)
            }else{
                let storyboard = UIStoryboard(name: "TaskHistory", bundle:  nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "TaskDetailViewController") as! TaskDetailViewController
                vc.taskID = self.taskID
                vc.taskType = self.taskType
                vc.discount = self.discount
                vc.selectedMonth = self.selectedMonth
                self.navigationController?.pushViewController(vc, animated: true)
            }

        }else{
            UserDefaults.standard.setValue(taskID, forKey: DefaultsKeys.taskId)
            ChatViewController.isFromActiveTask = true
            let vc = ExtendedChat()
            vc.hidesBottomBarWhenPushed = true
            vc.status = status
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    //MARK: methods calls when leaving from history and stops playing audio
    @objc func stopAudio(_ notification:NSNotification){
        if isPlaying{
            finishAudio()
        }
    }
    
    //MARK: Play/Pause task history audio
    //. Checks if audio is already playing
    //. Audio Session instance is created
    //. audio is converted into data and passed to player
    @IBAction func playButtonPressed(_ sender: Any) {
        
        playButtonTapped?()
        if !isPlaying{
            let url = URL(string: audioPath)
            
            DispatchQueue.main.async { [self] in
                let image = UIImage(named: "downloadImg")
                audioPlayPauseBtn.setImage(image, for: .normal)
            }
                var recordingSession: AVAudioSession!
                recordingSession = AVAudioSession.sharedInstance()
                do{
                    try recordingSession.setCategory(.playAndRecord, mode: .default)
                    try recordingSession.setActive(true)
                    try recordingSession.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
                }catch{
                    //print"cannot record audio")
                }
                
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.10) { [self] in
                
                guard let polo = try? Data(contentsOf: url!) else{
                    //print("cannot convert to data ")
                    return
                }
                guard let player = try? AVAudioPlayer(data: polo) else {
                    //print("Failed to create audio player for URL: \(item.url)")
                    return
                }
                
                isPlaying = true
                audioPlayer = player
                audioPlayer?.delegate = self
                audioPlayer?.play()
                audioPlayer?.volume = 1.0
                timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector:
                                                #selector(audioProgress), userInfo: nil, repeats: true)
                let image = UIImage(named: "audioPause")?.withRenderingMode(.alwaysTemplate)
                audioPlayPauseBtn.setImage(image, for: .normal)
                audioPlayPauseBtn.tintColor = UIColor.black
            }
        }else{
            
            self.audioSeekBar.progress = 0.0
            audioTime.text = "00:00"
            timer?.invalidate()
            audioPlayer?.pause()
            let image = UIImage(named: "audioPlay")?.withRenderingMode(.alwaysTemplate)
            audioPlayPauseBtn.setImage(image, for: .normal)
            audioPlayPauseBtn.tintColor = UIColor.black
            isPlaying = false
        }
    }
            

    //MARK: Audio seek bar progress update
    @objc func audioProgress()  {
        let normalizedTime = Float(audioPlayer!.currentTime / (audioPlayer?.duration as! Double))
        audioTime.text = audioProgressTextFormat(Float(audioPlayer?.currentTime ?? 0.0 - 1))
        self.audioSeekBar.progress = normalizedTime
    }
    
    
    //MARK: Audio Seekbar updateFormat
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
    
    
    //MARK: Delegate method calls when player finishes playing audio
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        timer?.invalidate()
        let image = UIImage(named: "audioPlay")?.withRenderingMode(.alwaysTemplate)
        audioPlayPauseBtn.setImage(image, for: .normal)
        audioPlayPauseBtn.tintColor = UIColor.black
        isPlaying = false
        self.audioSeekBar.progress = 0.0
        audioTime.text = "00:00"
    }
    
    //MARK: Method calls when needs to reset audio timer, seekbar and image
    func finishAudio(){
        self.audioSeekBar.progress = 0.0
        timer?.invalidate()
        audioPlayer?.pause()
        let image = UIImage(named: "audioPlay")?.withRenderingMode(.alwaysTemplate)
        audioPlayPauseBtn.setImage(image, for: .normal)
        audioPlayPauseBtn.tintColor = UIColor.black
        isPlaying = false
        audioTime.text = "00:00"
    }
}

//MARK: Set background colour.
extension UITableViewCell {
    func setTransparent(color: UIColor) {
        let bgView: UIView = UIView()
        bgView.backgroundColor = color
        self.layer.cornerRadius = 8.0
        self.backgroundView = bgView
        self.backgroundColor = color
        self.layer.backgroundColor = UIColor.clear.cgColor
        self.contentView.backgroundColor = UIColor.clear
        
        self.layer.shadowOffset = CGSize(width: 0,height: 0)
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.2
    }
}

