//
//  CSChatLayout.swift
//  Moody_Posterv2.0
//
//  Created by Syed Muhammad bin Saadat on 07/06/2021.
//

import Foundation
import MessageKit
import InputBarAccessoryView


extension CustomerSupport : MessagesLayoutDelegate {
    
    //MARK: adjust cell top label height.
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if(indexPath.section == 0){
            return 20
        }
        return 0
    }
    
    //MARK: adjust cell bottom label height.
    func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 0
    }
    
    //MARK: adjust message top label height.

    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if(messages[indexPath.section].sender.senderId == "deo"){
            return 30
        }else{
            return 20
        }
    }
    
    //MARK: adjust message bottom label height.

    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 20
    }
    
    //MARK: check custom cell size and throw error if invalid.

    func customCellSizeCalculator(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CellSizeCalculator {
        fatalError("Must return a CellSizeCalculator for MessageKind.custom(Any?)")
    }
}
