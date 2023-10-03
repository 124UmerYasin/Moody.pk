//
//  onTapMessageCells.swift
//  Moody_Posterv2.0
//
//  Created by Umer yasin on 05/06/2021.
//

import Foundation
import MessageKit
import InputBarAccessoryView
import AVKit
import AVFoundation
import QuickLook
import Lightbox

extension ChatViewController : MessageCellDelegate{
    
    func didTapBackground(in cell: MessageCollectionViewCell) {
        makeButtonsNormal()
    }
    
    //MARK: configure audio cell for sending in messages
    //. sets audio cell views
    func configureAudioCell(_ cell: AudioMessageCell, message: MessageType) {
        audioController.configureAudioCell(cell, message: message)
        if(isFromCurrentSender(message: message)){
            cell.durationLabel.textColor = .white
            cell.progressView.tintColor = .white
            cell.playButton.imageView?.tintColor = .white
        }
        if message.sender.senderId == "Self" {
            cell.activityIndicatorView.color = .white
        }else{
            cell.activityIndicatorView.color = .black

        }
       
    }
    
  
    //MARK: detect press on a text messages
    //. In case of location message location opens on map
    func didTapMessage(in cell: MessageCollectionViewCell) {
        makeButtonsNormal()
        guard let indexPath = messagesCollectionView.indexPath(for: cell)else{
            return
        }
        let kind = messages[indexPath.section].kind
        switch kind {
        case .text(_):
            break
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(let po):
            if(CheckInternet.Connection()){
                self.audioController.stopAnyOngoingPlaying()
                if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)){
                    let vc = "\(po.location.coordinate.latitude), \(po.location.coordinate.longitude)"
                    let latLongString = vc.components(separatedBy: ", ")
                    let lat = latLongString[0]
                    let long = latLongString[1]
                    let latitude: Double = Double(lat)!
                    let longitude: Double = Double(long)!
                    
                                    
                    UIApplication.shared.open(URL(string:"comgooglemaps://?center=\(latitude),\(longitude)&zoom=14&views=traffic&q=\(latitude),\(longitude)")!, options: [:], completionHandler: nil)

                    
                } else {
                    let alert = UIAlertController(title: NSLocalizedString("Google Maps Not Found", comment: ""), message: NSLocalizedString("Please go to app store and download google maps.", comment: ""), preferredStyle: .alert)
                    alert.view.tintColor = UIColor(named: "TaskerAvatarColor")
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { action in
                                                    switch action.style{
                                                    case .default:
                                                        if let url = URL(string: "https://itunes.apple.com/in/app/googlemaps/id585027354?mt=8") {
                                                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                                        }
                                                    case .cancel:
                                                        break
                                                    case .destructive:
                                                        break
                                                    @unknown default:
                                                        fatalError()
                                                    }}))
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { action in
                                                    switch action.style{
                                                    case .default:
                                                        self.dismiss(animated: true, completion: nil)
                                                    case .cancel:
                                                        break
                                                    case .destructive:
                                                        break
                                                    @unknown default:
                                                        fatalError()
                                                    }}))
                    self.present(alert, animated: true, completion: nil)
                }
            }else{
                self.presentAlert(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString( "Internet Not Available. Please check your internet connection and try again.", comment: ""), parentController: self)

            }
            break
        case .emoji(_):
            break
        case .audio(_):
            tapAction(indexPath: indexPath)
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break

        }
    }
    
    //MARK: make navigation Controller
    func navigateToScreen(vc:UIViewController){
        self.navigationController?.navigationBar.tintColor = .black
        navigationItem.title = " "
        self.navigationController?.navigationBar.layer.shadowOpacity = 0.4
        self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 2, height: 2)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: preview Image
    func previewImage(message:MediaItem){
        var images = [LightboxImage(image: UIImage())]
        if message.orignalImage != "" {
             images = [LightboxImage(imageURL: URL(string: message.orignalImage)!)]
        }else{
            images = [LightboxImage(image: message.image!)]
        }
        let controller = LightboxController(images: images)
        // Set delegates.
        controller.pageDelegate = self
        controller.dismissalDelegate = self
        // Use dynamic background.
        controller.dynamicBackground = true
        // Present your controller.
        controller.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    //MARK: Play Video
    func playVideo(message:MediaItem){
        let videoURL = message.url
        let player = AVPlayer(url: videoURL!)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }
    
    //MARK: detect tap on image to show image or video respectively as in message
    func didTapImage(in cell: MessageCollectionViewCell) {
        makeButtonsNormal()
        guard let indexPath = messagesCollectionView.indexPath(for: cell)else{
            return
        }
        let kind = messages[indexPath.section].kind
        switch kind {
        case .photo(let message):
            previewImage(message: message)
            
            break
        case .video(let message):
            playVideo(message: message)
            break
        case .text(_):
            break
        case .attributedText(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            //print"fd")
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
    
        }
    }
    
    func tapAction(indexPath:IndexPath){
        makeButtonsNormal()
        guard let messagesDataSource = messagesCollectionView.messagesDataSource else {
            //fatalError(MessageKitError.nilMessagesDataSource)
            return
        }
    }
    

    
    
                    //MARK: On Tap anywhere on cell it makes options button normal
    
    func didTapCellTopLabel(in cell: MessageCollectionViewCell) {
        makeButtonsNormal()
    }
    
    func didTapCellBottomLabel(in cell: MessageCollectionViewCell) {
        makeButtonsNormal()
    }
    
    func didTapMessageTopLabel(in cell: MessageCollectionViewCell) {
        makeButtonsNormal()
    }
    
    func didTapMessageBottomLabel(in cell: MessageCollectionViewCell) {
        makeButtonsNormal()
    }
    
    //MARK: Plays/Pause/Stop audioMessage
    //. Checks audio states
    func didTapPlayButton(in cell: AudioMessageCell) {
        makeButtonsNormal()
        guard let indexPath = messagesCollectionView.indexPath(for: cell),
              let message = messagesCollectionView.messagesDataSource?.messageForItem(at: indexPath, in: messagesCollectionView) else {
            //print"Failed to identify message when audio cell receive tap gesture")
            return
        }
        guard audioController.state != .stopped else {
            // There is no audio sound playing - prepare to start playing for given audio message
            audioController.playSound(for: message, in: cell)
            return
        }
        if audioController.playingMessage?.messageId == message.messageId {
            // tap occur in the current cell that is playing audio sound
            if audioController.state == .playing {
                audioController.pauseSound(for: message, in: cell)
            } else {
                audioController.resumeSound()
            }
        } else {
            // tap occur in a difference cell that the one is currently playing sound. First stop currently playing and start the sound for given message
            audioController.stopAnyOngoingPlaying()
            audioController.playSound(for: message, in: cell)
        }
        
    }
    func didStartAudio(in cell: AudioMessageCell) {
        //print"Did start playing audio sound")
    }
    func didPauseAudio(in cell: AudioMessageCell) {
        //print"Did pause audio sound")
    }
    func didStopAudio(in cell: AudioMessageCell) {
        //print"Did stop audio sound")
    }
    
    //MARK: on click urls

    func didSelectURL(_ url: URL) {
    
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
        
    }
    
    //MARK: on tap phone number in  message make a call
    func didSelectPhoneNumber(_ phoneNumber: String) {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(URL(string: "tel://\(phoneNumber)")!, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(URL(string: "tel://\(phoneNumber)")!)
        }
    }
    
}
