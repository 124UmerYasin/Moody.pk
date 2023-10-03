//
//  CustomRatingScreen.swift
//  Moody_Posterv2.0
//
//  Created by Umer yasin on 02/08/2021.
//

import Foundation
import UIKit
import MessageKit
import QuickLook

protocol ShowReceiptImages {
    func showImages(imageLink:String)
}
open class FareScreen: MessageContentCell {
   
    var contentViewAttachment: UIView!
    var stack1 : UIStackView!
    var paymentView: UIView!
    var showImageDelegate:ShowReceiptImages?

    //MARK: return the xib file view of receipt view
    func getContentView() -> UIView{
        guard let contentView = Bundle(for: type(of: self)).loadNibNamed("ReceiptView", owner: self, options: nil)?.first as? UIView else {
            return UIView()
        }
        return contentView
    }
    //MARK: setup subviews of current view.
    open override func setupSubviews() {
        super.setupSubviews()
        contentViewAttachment = getContentView()
        paymentView = contentViewAttachment.viewWithTag(786)

        messageContainerView.addSubview(contentViewAttachment)
    }
 
    //MARK: styling of a custom cell like color, etc
    public override func configure(with message: MessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        super.configure(with: message, at: indexPath, and: messagesCollectionView)
        messageContainerView.backgroundColor = UIColor(named: "MessageBackgroundColor")
    }
    
    //MARK: handle tap gesture
    open override func handleTapGesture(_ gesture: UIGestureRecognizer) {
        let touchLocation = gesture.location(in: paymentView)
        var tags = 1
        if(UserDefaults.standard.dictionary(forKey: DefaultsKeys.shoppingDetails) != nil){
            let prodDetails = UserDefaults.standard.dictionary(forKey: DefaultsKeys.shoppingDetails)!
            let proofs = prodDetails["proofs"] as! [[String:Any]]
            print(prodDetails)
            if(proofs.count > 0){
                for prof in proofs {
                    stack1 = paymentView.viewWithTag(tags) as? UIStackView
                    let start2Area = CGRect(x: stack1.frame.origin.x - 24, y: stack1.frame.origin.y - 24, width: stack1.frame.size.width, height: stack1.frame.size.height)
                    let start2Location = convert(touchLocation, to: messageContainerView)
                    if start2Area.contains(start2Location) {
                        showImageDelegate?.showImages(imageLink: prof["attachment_path"] as! String)
                    }
                    tags += tags
                }
            }
        }
    }
    
}



