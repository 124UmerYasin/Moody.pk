//
//  CloseViewScreen.swift
//  Moody_Posterv2.0
//
//  Created by Umer yasin on 04/08/2021.
//

import Foundation
import UIKit
import MessageKit
import QuickLook

//MARK: Content view for a custom cell loaded through a nib file
open class CloseViewScreen: MessageContentCell {
   
    //MARK: Variables
    var contentViewAttachment: UIView!
    var closeButton:UIButton!
    
    func getContentView() -> UIView{
        guard let contentView = Bundle(for: type(of: self)).loadNibNamed("closeView", owner: self, options: nil)?.first as? UIView else {
            return UIView()
        }
        return contentView
    }
    
    //MARK: View is setup
    //. close button tag is set
    open override func setupSubviews() {
        super.setupSubviews()
        contentViewAttachment = getContentView()
        messageContainerView.addSubview(contentViewAttachment)
        closeButton = contentViewAttachment.viewWithTag(222333) as? UIButton

    }
 
    
    
    //MARK: - for styling of custom cell.
    public override func configure(with message: MessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        super.configure(with: message, at: indexPath, and: messagesCollectionView)
        messageContainerView.backgroundColor = UIColor(named: "MessageBackgroundColor")
    }
    
    //MARK: Handles tap gesture of close button
    open override func handleTapGesture(_ gesture: UIGestureRecognizer) {
        let touchLocation = gesture.location(in: self)
        let start1Area = CGRect(x: closeButton.frame.origin.x, y: closeButton.frame.origin.y, width: closeButton.frame.size.width, height: closeButton.frame.size.height)
        let start1Location = convert(touchLocation, to: messageContainerView)
        if start1Area.contains(start1Location) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "closeChat"), object: nil)
        }
    }
   
}
