//
//  MessageDisplay.swift
//  Moody_Posterv2.0
//
//  Created by Umer yasin on 05/06/2021.
//

import Foundation
import MessageKit
import InputBarAccessoryView


extension ChatViewController : MessagesDisplayDelegate {
    
    //MARK: Styling of Message container
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        return .custom { MessageContainerView in
            self.isFromCurrentSender(message: message) ? MessageContainerView.roundCorners(corners:[.topLeft,.bottomLeft,.bottomRight], radius: 10) : MessageContainerView.roundCorners(corners:[.topRight,.bottomLeft,.bottomRight], radius: 10)
        }
    }
    
    //MARK: Background color of message view
    //. Receives MessageType,index of Message and messageCollectionView
    //. Color of every message respect of MessageType
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {

        let kind = messages[indexPath.section].kind

        switch kind{

        case .text(_):
            if(messages[indexPath.section].sender.senderId == "deo"){
                return UIColor(named: "ButtonColor")!
            }
            else if(messages[indexPath.section].sender.senderId == "Self"){
                return UIColor(named: "Green")!
            }
            else{
                return .white
            }
    

        case .attributedText(_):
            
            if(messages[indexPath.section].sender.senderId == "deo"){
                return UIColor(named: "ButtonColor")!
            }
            else if(messages[indexPath.section].sender.senderId == "Self"){
                return UIColor(named: "Green")!
            }
            else{
                return .white
            }

        case .photo(_):
            if(messages[indexPath.section].sender.senderId == "deo"){
                return UIColor.white
            }
            if(notifyStatus[indexPath.section] == "sending"){
                return UIColor.white

            }else{
                return UIColor.white

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

    
    //MARK: AvatarView is set on basis on senderId receieved in method
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
            avatarView.backgroundColor = UIColor(named: "ButtonColor")
            avatarView.set(avatar: avatar)
            
        }

    }

    
    //MARK: text mesage color set on basis of senderId
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        
        if(messages[indexPath.section].sender.senderId == "deo" || messages[indexPath.section].sender.senderId == "other"){
            return UIColor.black
        }else{
            return UIColor.white
        }
        
    }
    
    
    //MARK: Audio tint color set on basis of senderId
    func audioTintColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        if(messages[indexPath.section].sender.senderId == "deo" || messages[indexPath.section].sender.senderId == "Self"){
            return UIColor.black
        }else{
            return UIColor.black
        }
    }

}

extension UIView {
   func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}

