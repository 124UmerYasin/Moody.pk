//
//  CSMessageDisplay.swift
//  Moody_Posterv2.0
//
//  Created by Syed Muhammad bin Saadat on 07/06/2021.
//

import Foundation
import MessageKit
import InputBarAccessoryView


extension CustomerSupport : MessagesDisplayDelegate {
    
    //MARK: layout direction for custom messages.
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        return .custom { MessageContainerView in
            self.isFromCurrentSender(message: message) ? MessageContainerView.roundCorners(corners:[.topLeft,.bottomLeft,.bottomRight], radius: 10) : MessageContainerView.roundCorners(corners:[.topRight,.bottomLeft,.bottomRight], radius: 10)
        }
    }
    
    //MARK: background color of message view
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        
        let kind = messages[indexPath.section].kind
        
        switch kind{
        
        case .text(_):
            if(messages[indexPath.section].sender.senderId == "deo"){
                return UIColor(named: "GreenColor")!
            }
            else if(messages[indexPath.section].sender.senderId == "Self"){
                return UIColor(named: "Green")!
            }
            else{
                return .white
            }
            
            
        case .attributedText(_):
            
            if(messages[indexPath.section].sender.senderId == "deo"){
                return UIColor(named: "DeoBackgoundColor")!
            }
            else if(messages[indexPath.section].sender.senderId == "Self"){
                return UIColor(named: "GreenColor")!
            }
            else{
                return .white
            }
            
        case .photo(_):
            if(messages[indexPath.section].sender.senderId == "deo"){
                return UIColor(named: "MessageBack")!
            }
            if(notifyStatus[indexPath.section] == "sending"){
                return UIColor(named: "LightGray")!
                
            }else{
                return isFromCurrentSender(message: message) ? UIColor(named: "audioback")!  : UIColor(named: "graybackcolor")!
                
            }
        case .video(_):
            if(messages[indexPath.section].sender.senderId == "deo"){
                return UIColor(named: "MessageBack")!
            }
            if(notifyStatus[indexPath.section] == "sending"){
                return UIColor(named: "LightGray")!
                
            }else{
                return isFromCurrentSender(message: message) ? UIColor(named: "audioback")!  : UIColor(named: "graybackcolor")!
                
            }        case .location(_):
                if(messages[indexPath.section].sender.senderId == "deo"){
                    return UIColor(named: "MessageBack")!
                }
                return isFromCurrentSender(message: message) ? UIColor(named: "audioback")!  : UIColor(named: "graybackcolor")!
                
        case .emoji(_):
            if(messages[indexPath.section].sender.senderId == "deo"){
                return UIColor(named: "MessageBack")!
            }
            return isFromCurrentSender(message: message) ? UIColor(named: "audioback")!  : UIColor(named: "graybackcolor")!
            
        case .audio(_):
            if(messages[indexPath.section].sender.senderId == "deo"){
                return UIColor(named: "GreenColor")!
            }
            else if(messages[indexPath.section].sender.senderId == "Self"){
                return UIColor(named: "Green")!
            }
            else{
                return .white
            }
            
        case .contact(_):
            if(messages[indexPath.section].sender.senderId == "deo"){
                return UIColor(named: "MessageBack")!
            }
            return isFromCurrentSender(message: message) ? UIColor(named: "audioback")!  : UIColor(named: "graybackcolor")!
            
        case .linkPreview(_):
            if(messages[indexPath.section].sender.senderId == "deo"){
                return UIColor(named: "MessageBack")!
            }
            return isFromCurrentSender(message: message) ? UIColor(named: "audioback")!  : UIColor(named: "graybackcolor")!
            
        case .custom(_):
            if(messages[indexPath.section].sender.senderId == "deo"){
                return UIColor(named: "MessageBack")!
            }
            return isFromCurrentSender(message: message) ? UIColor(named: "audioback")!  : UIColor(named: "graybackcolor")!
            
       }
    }

    // MARK: set message avatar of sender and receiver on sender type basis.
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        
        
        if messages[indexPath.section].sender.senderId == "deo" {
            
            let avatar = Avatar(image: UIImage(named: "deo"))
            avatarView.set(avatar: avatar)
            
        }else if messages[indexPath.section].sender.senderId == "Self"{
            
            let posterName = UserDefaults.standard.string(forKey: DefaultsKeys.name)
            let avatar = Avatar(image: nil , initials: String(posterName?.first ?? "P").capitalized)
            avatarView.backgroundColor = UIColor(named: "ButtonColor")
            avatarView.set(avatar: avatar)
            
        }else{
            let taskerName = UserDefaults.standard.string(forKey: DefaultsKeys.taskerNameDetail)
            let avatar = Avatar(image: nil , initials: String(taskerName?.first ?? "T").capitalized)
            avatarView.backgroundColor = UIColor(named: "TaskerAvatarColor")
            avatarView.set(avatar: avatar)
            
        }
        
    }
    
    //MARK: change audio  tint color.
    func audioTintColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        if(messages[indexPath.section].sender.senderId == "deo"){
            return UIColor.black
        }else if(messages[indexPath.section].sender.senderId == "Self"){
            return UIColor.white
        }else{
            return UIColor.black
        }
    }
    
    //MARK: text mesage color
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        if(messages[indexPath.section].sender.senderId == "Self"){
            return UIColor.white
        }else{
            return UIColor.black
        }
    }
    
}
