//
//  ChatsListStorageManager.swift
//  TinkoffNew
//
//  Created by Dmitry Gachkovsky on 13/11/2017.
//  Copyright © 2017 Dmitry Gachkovsky. All rights reserved.
//

import Foundation

protocol IChatsListStorageManager {
    var stack: ICoreDataStack { get set }
    func saveChat(withUser userID: String, userName: String?)
    func changeChatStatusToOffline(withUser userID: String)
    func saveMessage(messageText: String,
                     fromUser: String,
                     toUser: String,
                     completionHandler: @escaping () -> () )
}

class ChatsListStorageManager: IChatsListStorageManager {
    var stack: ICoreDataStack
    
    init(coreDataStack: ICoreDataStack) {
        self.stack = coreDataStack
    }
    
    public func saveChat(withUser userID: String, userName: String?) {
        guard let context = stack.saveContext else {
            assertionFailure("Save context in core data stack is nil")
            return
        }
        
        guard let user = User.findOrInsertUser(with: userID, into: context),
            let chat = Chat.findOrInsertChat(withID: userID, into: context) else {
                return
        }
        
        user.isOnline = true
        if let name = userName {
            user.name = name
        }
        
        if user.chat == nil {
            user.chat = chat
        }
        
        user.chat?.isOnline = true
        context.perform {
            self.stack.performSave(context: context, completionHandler: { success in
                guard success else {
                    assertionFailure("Chat was not saved, core data error")
                    return
                }
            })
        }
    }
    
    public func changeChatStatusToOffline(withUser userID: String) {
        guard let context = self.stack.saveContext else {
            assertionFailure("Save context in core data stack is nil")
            return
        }
        guard let user = User.findOrInsertUser(with: userID, into: context),
            let chat = Chat.findOrInsertChat(withID: userID, into: context) else {
                assertionFailure("Can't find user with given id")
                return
        }
        
        user.isOnline = false
        chat.isOnline = false
        
        context.perform {
            self.stack.performSave(context: context, completionHandler: { success in
                guard success else {
                    assertionFailure()
                    return
                }
            })
        }
    }
    
    func saveMessage(messageText: String,
                     fromUser: String,
                     toUser: String,
                     completionHandler: @escaping () -> () ) {
        
        let messageUserID = toUser
        let senderID = messageUserID == fromUser ? toUser : fromUser
        
        guard let context = stack.saveContext else {
            assertionFailure("Save context not found")
            return
        }
        
        let messageID = fromUser + toUser + "\(Date.timeIntervalSinceReferenceDate)"
        guard let sender = User.findOrInsertUser(with: fromUser, into: context),
            let message = Message.insertMessage(withID: messageID, into: context),
            let chat = Chat.findOrInsertChat(withID: senderID, into: context) else {
                return
        }
        
        message.inChat = chat
        message.sender = sender
        message.lastInChat = chat
        message.text = messageText
        
        chat.hasUnreadMessages = fromUser != messageUserID

        context.perform {
            self.stack.performSave(context: context, completionHandler: { success in
                guard success else {
                    assertionFailure()
                    return
                }
                completionHandler()
            })
        }
    }
}
