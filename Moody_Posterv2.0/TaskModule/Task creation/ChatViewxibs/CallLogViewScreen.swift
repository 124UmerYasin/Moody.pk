//
//  CallLogViewScreen.swift
//  Moody_Posterv2.0
//
//  Created by Muhammad Mobeen Rana on 07/10/2021.
//

import Foundation
import UIKit
import MessageKit
import QuickLook

//content view for a custom cell loaded through a nib file
open class CallLogViewScreen: MessageContentCell {
   
    var contentViewAttachment: UIView!
    
    var callLogImage : UIImageView!
    var callLogLabel : UILabel!
    
    //MARK:  return custom xib view of callLogView
    func getContentView() -> UIView{
        guard let contentView = Bundle(for: type(of: self)).loadNibNamed("CallLogView", owner: self, options: nil)?.first as? UIView else {
            return UIView()
        }
        return contentView
    }
    
    //MARK: setting up subviews
    open override func setupSubviews() {
        super.setupSubviews()
        contentViewAttachment = getContentView()
        messageContainerView.addSubview(contentViewAttachment)
        callLogLabel = contentViewAttachment.viewWithTag(34) as? UILabel
        callLogImage = contentViewAttachment.viewWithTag(1234) as? UIImageView
    }
 
    //MARK: configure styling of custom cell
    
    public override func configure(with message: MessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        super.configure(with: message, at: indexPath, and: messagesCollectionView)
        messageContainerView.backgroundColor = UIColor(named: "MessageBackgroundColor")
        let message = message.messageId.split(separator: "-")
        
        callLogLabel.text = "\(message[1])"
        if message[1].contains("Accepted"){
            callLogImage.image = UIImage(named: "callongoing")
        }else if message[1].contains("Rejected"){
            callLogImage.image = UIImage(named: "callreject")
        }else if message[1].contains("Missed"){
            callLogImage.image = UIImage(named: "callmissed")

        }
        
    }
    
    open override func handleTapGesture(_ gesture: UIGestureRecognizer) {
    }
   
}



