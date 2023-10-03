//
//  ExtendedChat.swift
//  Moody_Posterv2.0
//
//  Created by Umer yasin on 16/10/2021.
//

import Foundation
import MessageKit
import InputBarAccessoryView



class ExtendedChat : ChatViewController {
    
    override func viewDidLoad() {
        messagesCollectionView = MessagesCollectionView(frame: .zero, collectionViewLayout: MyCustomMessagesFlowLayout())
        registerCustomeCells()

        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
    }
    
    
}
