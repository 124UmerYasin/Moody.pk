//
//  CustomAudioView.swift
//  Moody_Posterv2.0
//
//  Created by Umer yasin on 07/06/2021.
//

import MessageKit
import Foundation
import UIKit
import AVKit
import QuickLook
import MobileCoreServices
import CoreLocation

extension ChatViewController : AVAudioRecorderDelegate{
    static var count = 0


    //MARK: set up black subview when options button is selected
    func setUpBlackBackSubView(){
        //balck view for screen
        let blackScreen = UIView(frame: self.view.bounds)
        blackScreen.backgroundColor=UIColor(white: 0, alpha: 0.5)
        blackScreen.tag = 121
        self.view.addSubview(blackScreen)
        //black view for accessory view
        let blackScreen2 = UIView(frame: self.messageInputBar.bounds)
        blackScreen2.backgroundColor=UIColor(white: 0, alpha: 0.5)
        blackScreen2.tag = 1212
        self.messageInputBar.addSubview(blackScreen2)
        //getting custom view for recording
        blackScreen.addSubview(customView)
    }
    
    //MARK:  setup buttons and views for custom audio recording
    func setUpButtonsAndViews(){
        SendButton = (customView.viewWithTag(1)) as? UIButton
        let CancelButton = (customView.viewWithTag(2)) as! UIButton
        //let previewButton = (customView.viewWithTag(5)) as! UIButton
        imageView = (customView.viewWithTag(3)) as! UIImageView

        imageView.loadGif(name: "audio")
        audioViewContraints(customView: customView)

        SendButton.addTarget(self, action: #selector(self.directSend), for: .touchUpInside)
        CancelButton.addTarget(self, action: #selector(self.cancelRecording), for: .touchUpInside)
        //previewButton.addTarget(self, action: #selector(self.finishRecording), for: .touchUpInside)
        
    }
    
    //MARK: Audio custom view constraints are set 
    //. recevies view for audio
    //. constraints sets for audio view
    func audioViewContraints(customView:UIView){
       customaudioViewStyling()
        if #available(iOS 13.0, *) {
            let horizontalConstraint = NSLayoutConstraint(item: customView, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0)
            let verticalConstraint = NSLayoutConstraint(item: customView, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0)
            let widthConstraint = NSLayoutConstraint(item: customView, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: UIScreen.main.bounds.width - 72)
            let heightConstraint = NSLayoutConstraint(item: customView, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 170)
            self.view.addConstraints([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
        } else {
            customView.center = CGPoint(x: self.messagesCollectionView.frame.size.width  / 2, y: self.messagesCollectionView.frame.size.height / 2)
        }
        
    }
    
    //MARK: Custom audio view styling
    func customaudioViewStyling(){
        customView.translatesAutoresizingMaskIntoConstraints = false
        customView.clipsToBounds = true
        customView.layer.shadowColor = UIColor.black.cgColor
        customView.layer.shadowOffset = CGSize(width: 0,height: 0)
        customView.layer.shadowOpacity = 3.0
        customView.layer.cornerRadius = 8.0
    }
    
    //MARK: load and get custom recording view
    func getContentView() -> UIView{
        guard let contentView = Bundle(for: type(of: self)).loadNibNamed("AudioTableViewCell", owner: self, options: nil)?.first as? UIView else {
            return UIView()
        }
        return contentView
    }
        
    //MARK: called when audio is directly send without preview.
    //. calls SendAudio Api
    @objc func directSend(){
        voiceButton.isUserInteractionEnabled = true
        imageView.image = nil
        stopTimerAndRecrdingSession()
        sendAudioAPI(index: 0, audioFileNameLink: "\(recorder.audioFilename?.absoluteString ?? "")", taskId:UserDefaults.standard.string(forKey: DefaultsKeys.taskId) ?? "")
        
        cancelRecording()
    }
    

    //MARK: stop and invalidate audio timer and recording session
    func stopTimerAndRecrdingSession(){
        imageView.image = nil
        timer?.invalidate()
        recorder.stopRecording()
        duration = 0.0
        base64String = recorder.audioFilename?.absoluteURL

    }
    //MARK: Check media type
    //. receives String off attachment
    //. extracts path extension and return it type 
    func mimeTypeForPath(path: String) -> String {
        let url = NSURL(fileURLWithPath: path)
        let pathExtension = url.pathExtension
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension! as NSString, nil)?.takeRetainedValue() {
            if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                return mimetype as String
            }
        }
        return "application"
    }
    
    //MARK: dictionary making for audio api
    func createAudioDictionary(audiofileName:String,taskId:String) -> [String:Any]{
        var dictionary = [String:Any]()
        dictionary["task_id"] = taskId
        dictionary["audio_message"] = try! Data(contentsOf:URL(string: audiofileName)!).base64EncodedString()
        dictionary["extension"] = "m4a"
        dictionary["user_agent"] = AppPermission.getDeviceInfo()
        dictionary["platform"] = "ios"
        
        return dictionary
    }
    
    //MARK: send audio to server through api
    func sendAudioAPI(index:Int,audioFileNameLink:String,taskId:String){
        //if internet is avalianble add images locally and maintain its data and state
        //if index is not zero add image in chat and get its index then call api after 200 response of api that saved index is releaded and change message
        //state from sending to sent.
        // if api faliure add locally and retry after internet connection becomes stable or comes in chat view
            var indexqw = index
                if(index != 0){
                    indexqw = index
                }else{
                    indexqw = addAudioMessageIninChat(audioLink: "\(recorder.audioFilename?.absoluteString ?? "")")
                }
            if CheckInternet.Connection() {
                ApiManager.sharedInstance.apiCaller(hasBodyData: true, hasToken: true, url: ENDPOINTS.send_message, dictionary: createAudioDictionary(audiofileName: audioFileNameLink,taskId: taskId), httpMethod: "POST", token: UserDefaults.standard.string(forKey: DefaultsKeys.token)) { [self] Result in
                    switch Result {
                    case .success(let response):
                        if(ChatViewController.isScreenVisible && UserDefaults.standard.string(forKey: DefaultsKeys.taskId) == taskId){
                            addAudioMessageinChat(messageId: "\(response["message_id"] as! String)", role: "is_poster", audioLink: audioFileNameLink, index: indexqw,is_notified: false,time: "\(response["message_time"] as! String)", title: "")
                        }
                        
                        break
                    case .failure(_):
                        addMessageLocally(message: "\(recorder.audioFilename!.absoluteString)", type: "Audio", index: indexqw, localImage: Data(), location: "")
                        break
                    }
                }
            }else{
                addMessageLocally(message: "\(recorder.audioFilename!.absoluteString)", type: "Audio", index: indexqw, localImage: Data(), location: "")
            }
        

    }
    
    //MARK: add audio messages in chat screen and waiting for
    func addAudioMessageIninChat(audioLink:String) -> Int{
        messages.append(Messgae(sender: checkSenderType(senderType: "is_poster", botTitle: ""), messageId: "990", sentDate: Date(), kind: .audio(audio(url: URL(string: audioLink)!)),downloadURL: ""))
        notifyBool.append(false)
        notifyStatus.append("sending")
        messagesTime.append("\(Date())")
        DispatchQueue.main.async { [self] in
            reloadAfterSending()
        }
        return messages.count - 1
    }
    
    //MARK: audio recorder delegate to check when recording is stopped
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
    }
    
    //MARK:get directory path to save/retrive audio message
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    //MARK:cancel recording
    @objc func cancelRecording(){
        voiceButton.isUserInteractionEnabled = true

        imageView.image = nil
        recorder.stopRecording()
        duration = 0.0
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
}




