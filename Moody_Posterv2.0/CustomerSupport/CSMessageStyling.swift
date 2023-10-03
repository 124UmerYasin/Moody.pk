//
//  CSMessageStyling.swift
//  Moody_Posterv2.0
//
//  Created by Syed Muhammad bin Saadat on 07/06/2021.
//

import Foundation
import MessageKit
import InputBarAccessoryView

extension CustomerSupport{
    
    //MARK: setting up incoming message styling
    func setIncomingmessageViews(){
        messagesCollectionView.messagesCollectionViewFlowLayout.setMessageIncomingMessagePadding(UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0))
        
        messagesCollectionView.messagesCollectionViewFlowLayout.setMessageIncomingAccessoryViewPadding(HorizontalEdgeInsets.init(left: 8, right: 8))
        
        //Date
        messagesCollectionView.messagesCollectionViewFlowLayout.setMessageIncomingMessageBottomLabelAlignment(.init(textAlignment: .left, textInsets: UIEdgeInsets(top: 4, left: 60, bottom: 0, right: 0)))
        
        
        //Avatar
        messagesCollectionView.messagesCollectionViewFlowLayout.setMessageIncomingAvatarSize(CGSize(width: 40.0, height: 40.0))
        
        messagesCollectionView.messagesCollectionViewFlowLayout.setMessageIncomingAvatarPosition(AvatarPosition(horizontal: .cellLeading, vertical: .messageTop))
        
    }
    
    //MARK: setting up outgoing message styling
    func setoutgoingmessageViews(){
        
        messagesCollectionView.messagesCollectionViewFlowLayout.setMessageOutgoingMessagePadding(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8))
        
        messagesCollectionView.messagesCollectionViewFlowLayout.setMessageOutgoingAccessoryViewPadding(HorizontalEdgeInsets.init(left: 8, right: 8))

        //Date
        messagesCollectionView.messagesCollectionViewFlowLayout.setMessageOutgoingMessageBottomLabelAlignment(.init(textAlignment: .right, textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 60)))
        
        
        //Avatar
        messagesCollectionView.messagesCollectionViewFlowLayout.setMessageOutgoingAvatarSize(CGSize(width: 40.0, height: 40.0))
        
        messagesCollectionView.messagesCollectionViewFlowLayout.setMessageOutgoingAvatarPosition(AvatarPosition(horizontal: .cellTrailing, vertical: .messageTop))
        
    }
    
    //MARK: Message bottom label configuration function
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        var nowTime = messagesTime[indexPath.section]
        if(nowTime.count > 11){
            let date = NSDate()
            let formatter = DateFormatter()
            formatter.dateFormat = "hh:mm a"
            let time = formatter.string(from: date as Date)
            nowTime = time
        }
        if(notifyStatus[indexPath.section] == "sending"){
            return NSAttributedString(string:nowTime + " ⏱", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.gray])
        }else{
            if(isFromCurrentSender(message: message)){
                let fullString = NSMutableAttributedString(string: nowTime + "  ",attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.gray])
                let image1Attachment = NSTextAttachment()
                if #available(iOS 13.0, *) {
                    image1Attachment.image = UIImage(named: "double")?.withTintColor(UIColor.gray)
                } else {
                    image1Attachment.image = UIImage(named: "double")
                }
                let image1String = NSAttributedString(attachment: image1Attachment)
                fullString.append(image1String)
                return fullString
            }else{
                return NSAttributedString(string:nowTime, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.gray])
            }
        }
    }
    
    //MARK: display user name of each message
//    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
//        let name = message.sender.displayName
//        return NSAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.gray])
//    }
    
    //MARK: date label of messages
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
//        if indexPath.section == 0 {
//            return NSAttributedString(string: MessageKitDateFormatter.shared.string(from: message.sentDate), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 13), NSAttributedString.Key.foregroundColor: UIColor.gray])
//        }
        return nil
    }
    
    //MARK: resize images
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }

    //MARK: emable detect urls in chat
    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        return [.url,.phoneNumber,.address]
    }
    
    //MARK: method is use to underline the url in message
    //. Method recieves detector in which it detects url
    func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedString.Key : Any] {
        switch detector{
        
        case .address:
            if message.sender.senderId == "other"{
                return [.foregroundColor: UIColor.black,.underlineStyle:1]

            }else{
                return [.foregroundColor: UIColor.white,.underlineStyle:1]

            }
        case .date:
            break
        case .phoneNumber:
            if message.sender.senderId == "other"{
                return [.foregroundColor: UIColor.black,.underlineStyle:1]

            }else{
                return [.foregroundColor: UIColor.white,.underlineStyle:1]

            }
        case .url:
            if message.sender.senderId == "other"{
                return [.foregroundColor: UIColor.black,.underlineStyle:1]

            }else{
                return [.foregroundColor: UIColor.white,.underlineStyle:1]

            }
        case .transitInformation:
            break
        case .custom(_):
            break
        }
        return [.foregroundColor: UIColor.red]
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
