//
//  ChatsListDisplayModel.swift
//  TinkoffNew
//
//  Created by Dmitry Gachkovsky on 03/11/2017.
//  Copyright © 2017 Dmitry Gachkovsky. All rights reserved.
//

import Foundation

class ChatDisplayModel {
    
    enum State {
        case read
        case unread
    }
    
    var isOnline = true
    let userName: String
    let messageID: String

    private(set) var hasUnreadMessages = true
    private(set) var messages = [MessageDisplayModel]()
    
    var lastMessageDate: String? {
        return messages.last?.date
    }
    
    init(messageID: String, userName: String) {
        self.messageID = messageID
        self.userName = userName
    }
    
    func appendMessage(_ message: MessageDisplayModel) {
        messages.append(message)
    }
    
    func setState(_ state: State) {
        switch state {
        case .read:
            hasUnreadMessages = false
        case .unread:
            hasUnreadMessages = true
        }
    }
}
