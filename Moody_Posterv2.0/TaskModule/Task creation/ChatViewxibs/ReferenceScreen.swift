//
//  ReferenceScreen.swift
//  Moody_Posterv2.0
//
//  Created by mujtaba Hassan on 11/08/2021.
//

import Foundation
import UIKit
import MessageKit
import QuickLook

//content view for a custom cell loaded through a nib file

open class ReferenceScreen: MessageContentCell {
   
    var contentViewAttachment: UIView!

    var button:UIButton!
    
    //MARK: return the xib view of ReferenceIdView
    func getContentView() -> UIView{
        guard let contentView = Bundle(for: type(of: self)).loadNibNamed("ReferenceIdView", owner: self, options: nil)?.first as? UIView else {
            return UIView()
        }
        return contentView
    }
    
    //MARK: setting up subviews
    open override func setupSubviews() {
        super.setupSubviews()
        contentViewAttachment = getContentView()
        //contentViewAttachment.centerVertically() = messageContainerView.center
        messageContainerView.addSubview(contentViewAttachment)
        messageContainerView.centerHorizontally()
        messageContainerView.centerVertically()

        button = contentViewAttachment.viewWithTag(1122) as? UIButton

    }
 
    
    //MARK: configuring custom cell styling.
    public override func configure(with message: MessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        super.configure(with: message, at: indexPath, and: messagesCollectionView)
        messageContainerView.backgroundColor = UIColor(named: "MessageBackgroundColor")
    }
    
    //MARK: handle tap gestues.
    open override func handleTapGesture(_ gesture: UIGestureRecognizer) {
        let touchLocation = gesture.location(in: self)
        let start1Area = CGRect(x: button.frame.origin.x, y: button.frame.origin.y, width: button.frame.size.width, height: button.frame.size.height)
        let start1Location = convert(touchLocation, to: messageContainerView)
        if start1Area.contains(start1Location) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showToast"), object: nil)
        }
    
    }
}
