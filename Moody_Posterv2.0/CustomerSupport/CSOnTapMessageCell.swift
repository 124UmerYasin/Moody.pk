//
//  CSonTapMessagesCell.swift
//  Moody_Posterv2.0
//
//  Created by Syed Muhammad bin Saadat on 07/06/2021.
//

import Foundation
import MessageKit
import InputBarAccessoryView
import AVKit
import AVFoundation
import QuickLook
import Lightbox


extension CustomerSupport : MessageCellDelegate{

    
    //MARK: configure audio cell for sending in messages
    func configureAudioCell(_ cell: AudioMessageCell, message: MessageType) {
        audioController.configureAudioCell(cell, message: message)
        if message.sender.senderId == "Self" {
            cell.activityIndicatorView.color = .white
        }else{
            cell.activityIndicatorView.color = .black

        }
    }
    
    //MARK: detect press on a text messages
    func didTapMessage(in cell: MessageCollectionViewCell) {
        guard messagesCollectionView.indexPath(for: cell) != nil else{
            return
        }
        //printindexPath.section)
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
        present(controller, animated: true, completion: nil)
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
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
    }
    
    //MARK: delegate methods of messagekit
    func didTapCellTopLabel(in cell: MessageCollectionViewCell) {
        //print"Top cell label tapped")
    }
    
    //MARK:
    func didTapCellBottomLabel(in cell: MessageCollectionViewCell) {
        //print"Bottom cell label tapped")
    }
    
    //MARK:
    func didTapMessageTopLabel(in cell: MessageCollectionViewCell) {
        //print"Top message label tapped")
    }
    
    //MARK:
    func didTapMessageBottomLabel(in cell: MessageCollectionViewCell) {
        //print"Bottom label tapped")
    }
    
    //MARK: delegate methods of messagekit to check audio button is tapped .
    func didTapPlayButton(in cell: AudioMessageCell) {
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
        func didStartAudio(in cell: AudioMessageCell) {
            //print"Did start playing audio sound")
        }
        func didPauseAudio(in cell: AudioMessageCell) {
            //print"Did pause audio sound")
        }
        func didStopAudio(in cell: AudioMessageCell) {
            //print"Did stop audio sound")
        }
        func didTapAccessoryView(in cell: MessageCollectionViewCell) {
            //print"Accessory view tapped")
        }
    }
}
