//
//  ChatLayout.swift
//  Moody_Posterv2.0
//
//  Created by Umer yasin on 05/06/2021.
//

import Foundation
import MessageKit
import InputBarAccessoryView


extension ChatViewController : MessagesLayoutDelegate {
        
    //MARK: Sets cells top label height
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if(indexPath.section == 0){
            return 45
        }
        return 0
    }
    
    //MARK: Sets cells bottom label height
    func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 0
    }
    
    //MARK: Sets cells top label height 
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if(messages[indexPath.section].sender.senderId == "deo"){
            return 30
        }else{
            return 20
        }
    }
    
    //MARK: message container bottom label height
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 20
    }
    
    //MARK: calculates size of cell of given message type
    func customCellSizeCalculator(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CellSizeCalculator {
        return CellSizeCalculator()
    }
}
