//
//  CustomRatingScreen.swift
//  Moody_Posterv2.0
//
//  Created by Umer yasin on 02/08/2021.
//

import Foundation
import UIKit
import MessageKit
import QuickLook
import AVFoundation

//content view for a custom cell loaded through a nib file
open class CustomRatingScreen: MessageContentCell , AVAudioPlayerDelegate{
   
    var contentViewAttachment: UIView!
    var star1 :UIButton!
    var star2 : UIButton!
    var star3 :UIButton!
    var star4 : UIButton!
    var star5 :UIButton!
    var playPause : UIButton!
    var audioPlay:UIImage!
    var audioPause:UIImage!
    var isAudioPlaying:Bool = false
    var seekBar:UIProgressView!
    var timerLabel:UILabel!
    
    var min:Int = 0
    var sec:Int = 1
    
    var audioPlayer: AVAudioPlayer?
    var audioMessage:String?
    var isPlaying:Bool = false
    var timer:Timer?
    var btnImage:UIImage!
    var btnImage2:UIImage!
    
    var activityLoader:UIActivityIndicatorView!
    
    static var doneReview:Bool = true
    static var numberOfStars:Int = 0

    //MARK: return xib file view of rating screen
    func getContentView() -> UIView{
        guard let contentView = Bundle(for: type(of: self)).loadNibNamed("Rating", owner: self, options: nil)?.first as? UIView else {
            return UIView()
        }
        return contentView
    }
    
    //MARK: setting up subviews of a views
    //getting their action view outlets using tags.
    open override func setupSubviews() {
        super.setupSubviews()
        contentViewAttachment = getContentView()
        messageContainerView.addSubview(contentViewAttachment)
        playPause = contentViewAttachment.viewWithTag(6) as? UIButton
        star1 = contentViewAttachment.viewWithTag(1) as? UIButton
        star2 = contentViewAttachment.viewWithTag(2) as? UIButton
        star3 = contentViewAttachment.viewWithTag(3) as? UIButton
        star4 = contentViewAttachment.viewWithTag(4) as? UIButton
        star5 = contentViewAttachment.viewWithTag(5) as? UIButton
        audioPlay = UIImage(named: "audioPlay")?.withRenderingMode(.alwaysTemplate)
        audioPause = UIImage(named: "audioPause")?.withRenderingMode(.alwaysTemplate)
        seekBar = contentViewAttachment.viewWithTag(90) as? UIProgressView
        timerLabel = contentViewAttachment.viewWithTag(80) as? UILabel
        btnImage = UIImage(named: "Star")
        btnImage2 = UIImage(named: "StarDull")
        activityLoader = contentViewAttachment.viewWithTag(9009) as? UIActivityIndicatorView
        activityLoader.isHidden = true
        
        if #available(iOS 13.0, *) {
            audioPlay?.withTintColor(UIColor(named: "ButtonColor")!)
            audioPause?.withTintColor(UIColor(named: "ButtonColor")!)
        } else {
        }
        CheckpreviousStars()
    }
 
    //MARK: checking how many previous stars are given before.
    func CheckpreviousStars(){
        if(CustomRatingScreen.numberOfStars > 0){
            if(CustomRatingScreen.numberOfStars == 1){
                star1.setImage(btnImage, for: .normal)
            }
            if(CustomRatingScreen.numberOfStars == 2){
                star1.setImage(btnImage, for: .normal)
                star2.setImage(btnImage, for: .normal)
            }
            if(CustomRatingScreen.numberOfStars == 3){
                star1.setImage(btnImage, for: .normal)
                star2.setImage(btnImage, for: .normal)
                star3.setImage(btnImage, for: .normal)
            }
            if(CustomRatingScreen.numberOfStars == 4){
                star1.setImage(btnImage, for: .normal)
                star2.setImage(btnImage, for: .normal)
                star3.setImage(btnImage, for: .normal)
                star4.setImage(btnImage, for: .normal)
            }
            if(CustomRatingScreen.numberOfStars == 5){
                star1.setImage(btnImage, for: .normal)
                star2.setImage(btnImage, for: .normal)
                star3.setImage(btnImage, for: .normal)
                star4.setImage(btnImage, for: .normal)
                star5.setImage(btnImage, for: .normal)
            }
        }else{
            removeAllStars()
        }
    }
    
    
    //MARK: configuring custom cells styling.
    public override func configure(with message: MessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        super.configure(with: message, at: indexPath, and: messagesCollectionView)
        NotificationCenter.default.addObserver(self, selector: #selector(self.ratingCallBack(_:)), name: NSNotification.Name(rawValue: "ratingCallBack"), object: nil)

        messageContainerView.backgroundColor = UIColor(named: "MessageBackgroundColor")
        playPause.setImage(audioPlay, for: .normal)
        seekBar.progress = 0.0
    }
    
    //MARK:  delegate called when audio play finishes playinh audio.
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        timer?.invalidate()
        playPause.setImage(audioPlay, for: .normal)
        isPlaying = false
        self.seekBar.progress = 0.0
        sec = 1
        min = 0
    }
    
    //MARK:  update audio progress after each second.
    @objc func audioProgress()  {
        
        let normalizedTime = Float((self.audioPlayer?.currentTime)! / (self.audioPlayer?.duration as! Double))
        self.seekBar.progress = normalizedTime
        timerLabel.text = (NSString(format: "%0.2d:%0.2d",min,sec)) as String
        sec = sec + 1
        if(sec > 60){
            sec = 0
            min = min + 1
        }
    }
    
    //MARK: handle tap gesture.
    open override func handleTapGesture(_ gesture: UIGestureRecognizer) {
        let touchLocation = gesture.location(in: self)
       
        let playButtonTouchArea = CGRect(x: playPause.frame.origin.x, y: playPause.frame.origin.y, width: playPause.frame.size.width, height: playPause.frame.size.height)
        let translateTouchLocation = convert(touchLocation, to: messageContainerView)
        if playButtonTouchArea.contains(translateTouchLocation) {
            if !isPlaying{
                DispatchQueue.main.async { [self] in
                    activityLoader.isHidden = false
                    activityLoader.startAnimating()
                    playPause.isHidden = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) { [self] in
                    seekBar.progress = 0
                    //let url = URL(string: UserDefaults.standard.string(forKey: DefaultsKeys.feedBackAudio)!)!
                    let url = Bundle.main.url(forResource: "rating_and_review", withExtension: "mp3")!

                    guard let data = try? Data(contentsOf: url) else{
                        return
                    }
                    do {
                        audioPlayer = try AVAudioPlayer(data: data)
                        audioPlayer?.volume = 1.0
                        var recordingSession: AVAudioSession!
                        recordingSession = AVAudioSession.sharedInstance()
                        do{
                            try recordingSession.setCategory(.playAndRecord, mode: .default)
                            try recordingSession.setActive(true)
                            try recordingSession.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
                        }catch{
                            //print"cannot record audio")
                        }
                        audioPlayer!.play()
                        audioPlayer?.delegate = self
                        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(audioProgress), userInfo: nil, repeats: true)
                        activityLoader.isHidden = true
                        activityLoader.stopAnimating()
                        playPause.isHidden = false
                    } catch {
                        // couldn't load file
                    }
                   
                    playPause.setImage(audioPause, for: .normal)
                    isPlaying = true
                }
            }
            else{
                
                audioPlayer?.pause()
                playPause.setImage(audioPlay, for: .normal)
                timer?.invalidate()
                isPlaying = false
                sec = 1
                min = 0
                
            }

        }
        
        let start1Area = CGRect(x: star1.frame.origin.x, y: star1.frame.origin.y, width: star1.frame.size.width, height: star1.frame.size.height)
        let start1Location = convert(touchLocation, to: messageContainerView)
        if start1Area.contains(start1Location) {
            if CustomRatingScreen.doneReview{
                CustomRatingScreen.doneReview = false
                removeAllStars()
                star1.setImage(btnImage, for: .normal)
                CustomRatingScreen.numberOfStars = 1
                callRating(stars: "1")
            }
            
        }
        
        let start2Area = CGRect(x: star2.frame.origin.x, y: star2.frame.origin.y, width: star2.frame.size.width, height: star2.frame.size.height)
        let start2Location = convert(touchLocation, to: messageContainerView)
        if start2Area.contains(start2Location) {
            if CustomRatingScreen.doneReview{
            CustomRatingScreen.doneReview = false
            removeAllStars()
            star1.setImage(btnImage, for: .normal)
            star2.setImage(btnImage, for: .normal)
            CustomRatingScreen.numberOfStars = 2
            callRating(stars: "2")
            }

        }
        
        let start3Area = CGRect(x: star3.frame.origin.x, y: star3.frame.origin.y, width: star3.frame.size.width, height: star3.frame.size.height)
        let start3Location = convert(touchLocation, to: messageContainerView)
        if start3Area.contains(start3Location) {
            if CustomRatingScreen.doneReview{
            CustomRatingScreen.doneReview = false
            removeAllStars()
            star1.setImage(btnImage, for: .normal)
            star2.setImage(btnImage, for: .normal)
            star3.setImage(btnImage, for: .normal)
            CustomRatingScreen.numberOfStars = 3
            callRating(stars: "3")
            }

        }
        let start4Area = CGRect(x: star4.frame.origin.x, y: star4.frame.origin.y, width: star4.frame.size.width, height: star4.frame.size.height)
        let start4Location = convert(touchLocation, to: messageContainerView)
        if start4Area.contains(start4Location) {
            if CustomRatingScreen.doneReview{
            CustomRatingScreen.doneReview = false
            removeAllStars()
            star1.setImage(btnImage, for: .normal)
            star2.setImage(btnImage, for: .normal)
            star3.setImage(btnImage, for: .normal)
            star4.setImage(btnImage, for: .normal)
            CustomRatingScreen.numberOfStars = 4
            callRating(stars: "4")
            }
        }
        
        let start5Area = CGRect(x: star5.frame.origin.x, y: star5.frame.origin.y, width: star5.frame.size.width, height: star5.frame.size.height)
        let start5Location = convert(touchLocation, to: messageContainerView)
        if start5Area.contains(start5Location) {
            if CustomRatingScreen.doneReview{
            CustomRatingScreen.doneReview = false
            removeAllStars()
            star1.setImage(btnImage, for: .normal)
            star2.setImage(btnImage, for: .normal)
            star3.setImage(btnImage, for: .normal)
            star4.setImage(btnImage, for: .normal)
            star5.setImage(btnImage, for: .normal)
            CustomRatingScreen.numberOfStars = 5
            callRating(stars: "5")
            }
        }
    }
    
    func removeAllStars(){
        star1.setImage(btnImage2, for: .normal)
        star2.setImage(btnImage2, for: .normal)
        star3.setImage(btnImage2, for: .normal)
        star4.setImage(btnImage2, for: .normal)
        star5.setImage(btnImage2, for: .normal)
    }
    
    func disableStarsAfterRating(){
        star1.isEnabled = false
        star2.isEnabled = false
        star3.isEnabled = false
        star4.isEnabled = false
        star5.isEnabled = false
        
    }
    
    func callRating(stars:String){
        //disableStarsAfterRating()
        CustomRatingScreen.doneReview = true
        var dict = [String:Any]()
        dict["rating"] = stars
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "sendRating"), object: nil,userInfo: dict)
        
    }
    
    @objc func ratingCallBack(_ notification:NSNotification){
        DispatchQueue.main.async { [self] in
            let temp = notification.userInfo as! [String:Any]
            let status = temp["status"] as! String
            if(status == "success"){
                
                ChatViewController.istaskfinisherOrNot = true

                
            }else if(status == "faliure"){
                star1.isEnabled = true
                star2.isEnabled = true
                star3.isEnabled = true
                star4.isEnabled = true
                star5.isEnabled = true
                removeAllStars()
                CustomRatingScreen.doneReview = true
                
            }
        }

    }
    
}



//MARK: delegate and data source for a custom cell
open class MyCustomMessagesFlowLayout: MessagesCollectionViewFlowLayout {
    lazy open var customMessageSizeCalculator = CustomMessageSizeCalculator(layout: self)
    
    override open func cellSizeCalculatorForItem(at indexPath: IndexPath) -> CellSizeCalculator {
        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
        if case .custom = message.kind {
            if(message.messageId == "closeView"){
                customMessageSizeCalculator.incomingAvatarPosition = .init(horizontal: .cellLeading, vertical: .messageTop)
                customMessageSizeCalculator.incomingAvatarSize = CGSize(width: 0, height: 0)
            }else if(message.messageId == "reference"){
                customMessageSizeCalculator.incomingAvatarPosition = .init(horizontal: .cellLeading, vertical: .messageTop)
                customMessageSizeCalculator.incomingAvatarSize = CGSize(width: UIScreen.main.bounds.width / 4, height: 0)
            }else if(message.messageId == "TaskStatusScreen"){
                customMessageSizeCalculator.incomingAvatarPosition = .init(horizontal: .cellLeading, vertical: .messageTop)
                customMessageSizeCalculator.incomingAvatarSize = CGSize(width: 35, height: 0)
            }else if(message.messageId.contains("CallLogView")){
                customMessageSizeCalculator.incomingAvatarPosition = .init(horizontal: .cellLeading, vertical: .messageTop)
                customMessageSizeCalculator.incomingAvatarSize = CGSize(width: 40, height: 0)
            }else{
                customMessageSizeCalculator.incomingAvatarPosition = .init(horizontal: .cellLeading, vertical: .messageTop)
                customMessageSizeCalculator.incomingAvatarSize = CGSize(width: 40, height: 40)
            }
            return customMessageSizeCalculator
        }
        return super.cellSizeCalculatorForItem(at: indexPath);
    }
    
}

//MARK: custom cell size calculatoe width and height
open class CustomMessageSizeCalculator: MessageSizeCalculator {
    open override func messageContainerSize(for message: MessageType) -> CGSize {
         //TODO - Customize to size your content appropriately. This just returns a constant size.
        if(message.messageId == "FareEstimate"){
            return CGSize(width: UIScreen.main.bounds.width, height: 55)
        }else if(message.messageId == "closeView"){
            return CGSize(width: UIScreen.main.bounds.width, height: 65)
        }else if(message.messageId == "rating"){
            if(UserDefaults.standard.dictionary(forKey: DefaultsKeys.shoppingDetails) != nil){
                let prodDetails = UserDefaults.standard.dictionary(forKey: DefaultsKeys.shoppingDetails)!
                let proofs = prodDetails["proofs"] as! [[String:Any]]
                let heightt = (proofs.count * 48) + 300 + 24
                let ht = Int(heightt)
                return CGSize(width: 310, height: ht)
            }else{
                return CGSize(width: UIScreen.main.bounds.width, height: 300)
            }
        }else if(message.messageId == "reference"){
            return CGSize(width: UIScreen.main.bounds.width, height: 30)
        }else if(message.messageId == "TaskerDetailsView"){
            return CGSize(width: UIScreen.main.bounds.width, height: 120)
        }else if(message.messageId == "TaskStatusScreen"){
            return CGSize(width: UIScreen.main.bounds.width, height: 50)
        }else if(message.messageId.contains("CallLogView")){
            return CGSize(width: 280, height: 40)
         }else{
            return CGSize(width: UIScreen.main.bounds.width, height: 160)
        }
        
        
        
        
    }
}



