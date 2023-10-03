//
//  TaskStatusScreen.swift
//  Moody_Posterv2.0
//
//  Created by Umer yasin on 06/08/2021.
//

import Foundation
import UIKit
import MessageKit
import QuickLook

//content view for a custom cell loaded through a nib file
open class TaskStatusScreen: MessageContentCell {
   
    var contentViewAttachment: UIView!

    //MARK: return view of xib file
    func getContentView() -> UIView{
        guard let contentView = Bundle(for: type(of: self)).loadNibNamed("TaskStatusView", owner: self, options: nil)?.first as? UIView else {
            return UIView()
        }
        return contentView
    }
    
    //MARK: setting up subviews
    open override func setupSubviews() {
        super.setupSubviews()
        contentViewAttachment = getContentView()
        messageContainerView.addSubview(contentViewAttachment)
    }
 

    //MARK: configure custom styling
    public override func configure(with message: MessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        super.configure(with: message, at: indexPath, and: messagesCollectionView)
        messageContainerView.backgroundColor = UIColor(named: "MessageBackgroundColor")
    }
    
    open override func handleTapGesture(_ gesture: UIGestureRecognizer) {
        //print"UIOP")
    
    }
    
}

