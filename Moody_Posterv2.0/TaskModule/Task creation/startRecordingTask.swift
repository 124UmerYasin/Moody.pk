//
//  startRecordingTask.swift
//  Moody_Posterv2.0
//
//  Created by Umer yasin on 04/06/2021.
//

import Foundation
import AVKit
import AVFoundation
import CoreLocation

extension TaskCreationViewController : AVAudioRecorderDelegate{
    static var count = 0
    
    
    //MARK: OnClick Mic it starts recording for task
    //. Premissions checks
    //. Start Recording
    //. View changes
    @IBAction func onClickMicTap(_ sender: Any) {
        if(CheckInternet.Connection()){
            
            DispatchQueue.main.async {
            
                self.youtubeButton.isHidden = true
                self.videoView.isHidden = true
                self.tabBarController?.tabBar.isUserInteractionEnabled = false
                self.checkMicrophoneAccess { [self] (granted) in
                    if granted{
                        if CLLocationManager.locationServicesEnabled() {
                            switch CLLocationManager.authorizationStatus() {
                            case .notDetermined, .restricted, .denied:
                                settingsCustomAlert(title: "Location Permission")
                            case .authorizedAlways, .authorizedWhenInUse:
                                DispatchQueue.main.async{ [self] in
                                    self.setHelpLable(isRecording: true)
                                    returnTaskBtn.isHidden = true
                                    sendRequestButton.isUserInteractionEnabled = false
                                    micButton.isUserInteractionEnabled = false
                                    if recorder.isRecording{
                                    } else{
                                        recorder.record()
                                        setTimer()
                                    }
                                    setLabelsVisibility(menuButton: true, activityLoader: true, cancelBtn: false, sendRequestBtn: false, micBtn: false, timerLabel: false, labelForInst: true, recordinglimit: false,youtubeBtn:true)
                                }
                            @unknown default:
                                break
                            }
                        } else {
                            settingsCustomAlert(title: "Location Permission")
                        }
                    }
                }
            }
            
        }else{
            youtubeButton.isHidden = false
            videoView.isHidden = false
            DispatchQueue.main.async {
                self.presentAlert(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString( "Internet Not Available. Please check your internet connection and try again.", comment: ""), parentController: self)
            }
        }
    }
    
    //MARK: Recording Timer is set here
    //. timer starts
    func setTimer(){
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateDuration), userInfo: nil, repeats: true)
        
    }
    
    //MARK: Updates duration of timer
    //. updates timer seconds
    //. start updating user location
    //. on basis of time recorder button get enable
    //. finishes recording after 30 seconds
    @objc func updateDuration() {
        
        DispatchQueue.main.async {
            LocationManagers.locationSharesInstance.startUpdatingLocations()
        }
        if recorder.isRecording && !recorder.isPlaying{
            duration -= 1
            self.recordingTimerLabel.alpha = 1
            self.recordingTimerLabel.text = duration.timeStringFormatter
           // print("Recorder : \(recorder.getCurrentTime())")
            print("Recorder : \(duration.timeStringFormatter)")
            if duration == 25 {
                sendRequestButton.isUserInteractionEnabled = true
                self.sendRequestButton.alpha = 1
                print("Recorder is 25 : \(duration.timeStringFormatter)")

            }else {
                print("Recorder is not 25 : \(duration.timeStringFormatter)")
            }
            if(duration < 1){
                timer?.invalidate()
                recorder.stopRecording()
                duration = 30
              finishRecording(success: true)
 

          }
        }else{
            timer?.invalidate()
            duration = 30
            self.recordingTimerLabel.alpha = 0
            self.recordingTimerLabel.text = "0:00"
            youtubeButton.isHidden = false
            videoView.isHidden = false
        }
    }
    

    //MARK: audio recorder delegate to check when recording is stopped
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
    //MARK: get directory path to save/retrive audio message
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    //MARK: finish audio recording
    @objc func finishRecording(success: Bool) {
        finishAudioRecording()
        self.activityLoader.isHidden = false
        self.activityLoader.startAnimating()
        invalidateTimer()
        setLabelsVisibility(menuButton: true, activityLoader: false, cancelBtn: true, sendRequestBtn: true, micBtn: false, timerLabel: true, labelForInst: false, recordinglimit: true, youtubeBtn:false)
        let storyBoard : UIStoryboard = UIStoryboard(name: "TaskCreation", bundle:nil)
        let nextVC = storyBoard.instantiateViewController(withIdentifier: "RecordedTaskScreenVC") as! RecordedTaskScreenVC
        nextVC.recordedDictionary = createTaskDictionar()
        nextVC.audioURL = URL(string: self.recorder.audioFilename?.absoluteString ?? "")
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    //MARK: invalidating timer and recording session
    func finishAudioRecording(){
        timer?.invalidate()
        timer = nil
        time = 0
        min = 0
       
        TaskCreationViewController.count = TaskCreationViewController.count + 1
    }
    
    //MARK: set text and its attributes
    //. receives bool of its recording
    //. sets text, attributes and localise it
    func setHelpLable(isRecording: Bool){
        if isRecording{
            if UserDefaults.standard.string(forKey: "language") != "ur-Arab-PK"{
                setAttributedString()
            }else{
                labelForInstruction.text = NSLocalizedString("Maximum Limit of Voice Message is 30 Seconds", comment: "")
            }
            
            tabBarController?.tabBar.isHidden = true
            micButton.isHidden = true
            micImageView.isHidden = false
            newAnimationView?.play()
        }else{
            if UserDefaults.standard.string(forKey: "language") != "ur-Arab-PK"{
                setHomeAttributedString()
            }else{
                labelForInstruction.text = NSLocalizedString("Tap Mic, and start \n recording your task.", comment: "")
            }
            newAnimationView?.stop()
            micButton.isHidden = false
            micImageView.isHidden = true
            micButton.setImage(UIImage(named: "microphone_large"), for: .normal)
            tabBarController?.tabBar.isHidden = false
        }
        
    }
    
    //MARK: Sets Attribute of String
    func setAttributedString(){
        let myString:NSString = "Maximum Limit of Voice Message is 30 Seconds"
        var myMutableString = NSMutableAttributedString()
        
        let attrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 18)]
        
        myMutableString = NSMutableAttributedString(string: myString as String, attributes: attrs)
        myMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(named: "lightGray-1") as Any, range: NSRange(location:0,length:33))
        
        labelForInstruction.attributedText = myMutableString
    }
    
    //MARK: GIF of recording task
    func loadMicRecorderGif(){
        newAnimationView = .init(name: "Mic-Recording")
        newAnimationView!.frame = micImageView.bounds
        newAnimationView!.contentMode = .scaleToFill
        newAnimationView!.loopMode = .loop
        newAnimationView!.animationSpeed = 1
        micImageView.addSubview(newAnimationView!)

    }
    
}
