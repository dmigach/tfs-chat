//
//  ChatsListDisplayModel.swift
//  TinkoffNew
//
//  Created by Dmitry Gachkovsky on 03/11/2017.
//  Copyright © 2017 Dmitry Gachkovsky. All rights reserved.
//

import Foundation

class ChatDisplayModel {
    
    let chatID: String
    var isOnline = true
    let userName: String

    var hasUnreadMessages = true
    private(set) var messages = [MessageDisplayModel]()
    
    var lastMessageDate: String? {
        return messages.last?.date
    }
    
    init(chatID: String, userName: String) {
        self.chatID = chatID
        self.userName = userName
    }
    
    func appendMessage(_ message: MessageDisplayModel) {
        messages.append(message)
    }
}
