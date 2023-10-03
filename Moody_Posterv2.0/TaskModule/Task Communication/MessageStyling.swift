//
//  MessageStyling.swift
//  Moody_Posterv2.0
//
//  Created by Umer yasin on 05/06/2021.
//

import Foundation
import MessageKit
import InputBarAccessoryView

extension ChatViewController{
    
    //MARK: setting up incoming message styling
    //. Sets messageView postioning
    //. Sets date postion in messageContainer
    //. Sets Avatar postion in messageContainer
    func setIncomingmessageViews(){
        
        messagesCollectionView.messagesCollectionViewFlowLayout.setMessageIncomingMessagePadding(UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0))
        
        messagesCollectionView.messagesCollectionViewFlowLayout.setMessageIncomingAccessoryViewPadding(HorizontalEdgeInsets.init(left: 8, right: 8))

        //Date
        messagesCollectionView.messagesCollectionViewFlowLayout.setMessageIncomingMessageBottomLabelAlignment(.init(textAlignment: .left, textInsets: UIEdgeInsets(top: 4, left: 40, bottom: 0, right: 0)))
        //Avatar
        messagesCollectionView.messagesCollectionViewFlowLayout.setMessageIncomingAvatarSize(CGSize(width: 40.0, height: 40.0))
        
        messagesCollectionView.messagesCollectionViewFlowLayout.setMessageIncomingAvatarPosition(AvatarPosition(horizontal: .cellLeading, vertical: .messageTop))
        
        
    }
    
    //MARK: setting up outgoing message styling
    //. Sets messageView postioning
    //. Sets date postion in messageContainer
    //. Sets Avatar postion in messageContainer
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
    // . sets time
    // . set clock if message is sending
    // . double tick if message is sent
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
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        
        return NSAttributedString(string: " "+name, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.gray])
    }
    
    //MARK: chenge color when notify support button is pressed
    func changeViewofAccessoryView(nibName:String,indexPath:IndexPath,accessoryView:UIView){
        accessoryView.subviews.forEach { $0.removeFromSuperview() }
        guard let contentView = Bundle(for: type(of: self)).loadNibNamed("\(nibName)", owner: self, options: nil)?.first as? UIView else {
            return
        }
        if(notifyBool[indexPath.section]){
            let imageview = contentView.viewWithTag(99) as? UIImageView ?? UIImageView()
            imageview.image = UIImage(named: "accessoryviewcolor")
            let lbl = contentView.viewWithTag(777) as? UILabel ?? UIImageView()
            lbl.isHidden = true
        }
        accessoryView.addSubview(contentView)
    }
    
    
    //MARK: Methods receives Image and CGSize to rize it
    // . ratio is calculated of orignal and target image size
    // . new size is set through formula
    // . new size image is created and returned in method
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

    
    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        return [.url,.phoneNumber,.address]
    }
    
    //MARK: method is use to underline the url in message
    //. Method recieves detector in which it detects url
    func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedString.Key : Any] {
        switch detector{
        
        case .address:
            break
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
}
