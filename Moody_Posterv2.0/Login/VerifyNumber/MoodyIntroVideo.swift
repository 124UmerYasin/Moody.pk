//
//  MoodyIntroVideo.swift
//  Moody_Posterv2.0
//
//  Created by Muhammad Mobeen Rana on 17/11/2021.
//

import Foundation
import UIKit
import AVKit

class MoodyIntroVidoViewController : UIViewController {
    
    //MARK: - Variables
    let videoController = AVPlayerViewController()
    var videoplayer = AVPlayer()
    var isFromHome =  false
    
    //MARK: - IBOutlets
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var IntroSkipBtn: UIButton!
   
   
    //MARK: - View Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        playVideo()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        playVideo()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    //MARK: - Video Player plays video from local from local saved
    //. Fetch Path of local video from resources
    //. set player controller specs
    //. plays video
    //. add skip button after 5 sec
    func playVideo(){
    
        guard let path = Bundle.main.path(forResource: "Moody-intro-Video", ofType: "mp4") else { return }
        let videoURL = NSURL(fileURLWithPath: path)
        videoplayer =  AVPlayer(url: videoURL as URL)
        videoController.view.frame = videoView.layer.bounds
        videoController.player = videoplayer
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: videoController.player?.currentItem)
        videoController.showsPlaybackControls = false
        videoController.entersFullScreenWhenPlaybackBegins = true
        videoController.videoGravity = AVLayerVideoGravity.resizeAspect
        self.videoView.addSubview(videoController.view)
        videoplayer.play()
        self.tabBarController?.tabBar.isHidden = true
        
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [self] in
                let firstLogin = DefaultsKeys.firstLogin
                let btn = UIButton()
                btn.setTitle("Skip", for: UIControl.State.normal)
                btn.backgroundColor = UIColor.gray
                btn.layer.cornerRadius = 5
                btn.sizeToFit()
                btn.frame =  CGRect(x: UIScreen.main.bounds.width - 80, y: UIScreen.main.bounds.height - 180, width: 60, height: 30)
                btn.addTarget(self, action: #selector(skipButtonTapped), for: .touchUpInside)
                if(firstLogin != true){
                    self.videoController.contentOverlayView?.addSubview(btn)
                    btn.semanticContentAttribute = UIApplication.shared
                        .userInterfaceLayoutDirection == .rightToLeft ? .forceLeftToRight : .forceRightToLeft
                }
                
            }
    }
    
    //MARK: Intro Video Skipped
    //. If intro video is played from home it pops to homescreen
    //. if it plays after login it setup homeScreen
    @objc func skipButtonTapped() {
        if isFromHome{
            self.navigationController?.popViewController(animated: true)
        } else {
            videoplayer.pause()
            videoController.removeFromParent()
            setTabBar()
        }
    }

    //MARK: Delegate which detects when video is finsished
    @objc func playerDidFinishPlaying(note: NSNotification) {
        
        if isFromHome{
            self.navigationController?.popViewController(animated: true)
        } else {
            videoplayer.pause()
            videoController.removeFromParent()
            setTabBar()
        }
}

    //MARK: Skips Video
    @IBAction func onClickSkipButton(_ sender: Any) {
        self.videoController.dismiss(animated: true)
        self.navigationController?.popViewController(animated: true)
    }
}
