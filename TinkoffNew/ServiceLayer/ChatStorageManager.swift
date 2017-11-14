//
//  ChatStorageManager.swift
//  TinkoffNew
//
//  Created by Dmitry Gachkovsky on 14/11/2017.
//  Copyright © 2017 Dmitry Gachkovsky. All rights reserved.
//

import Foundation

protocol IChatStorageManager {
    func getUserName(withId userID: String) -> String
    func saveOutgoingMessage(messageText: String,
                             toUser: String,
                             completionHandler: @escaping () -> () )
    func saveMessage(messageText: String,
                     fromUser: String,
                     toUser: String,
                     type: MessageDisplayModel.MessageType,
                     completionHandler: @escaping () -> () )
    func markChatAsRead(chatID: String)
    func set(onlineStatus status: Bool, forUserWithID userID: String)
    var stack: ICoreDataStack { get set }
    func getChatOnlineStatus(withID ID: String) -> Bool
}

class ChatStorageManager: IChatStorageManager {
    var stack: ICoreDataStack
    
    init(coreDataStack: ICoreDataStack) {
        self.stack = coreDataStack
    }
    
    func getUserName(withId userID: String) -> String {
        guard let context = stack.saveContext else {
            assertionFailure("Save context in core data stack is nil")
            return "Stranger"
        }
        
        guard let user = User.findOrInsertUser(with: userID, into: context) else {
            assertionFailure("Can't find user with given id")
            return "Stranger"
        }
        return user.name ?? "Stranger"
    }
    
    func getChatOnlineStatus(withID ID: String) -> Bool {
        guard let context = stack.saveContext else {
            assertionFailure("Save context in core data stack is nil")
            return false
        }
        
        guard let chat = Chat.findOrInsertChat(withID: ID, into: context) else {
            return false
        }
        
        return chat.isOnline
    }
    
    private func getMyID() -> String {
        guard let context = stack.saveContext,
            let appUser = AppUser.findOrInsertAppUser(into: context),
            let currentUserID = appUser.currentUser?.userID else {
                assertionFailure()
                return UUID().uuidString
        }
        return currentUserID
    }
    
    func saveOutgoingMessage(messageText: String,
                             toUser: String,
                             completionHandler: @escaping () -> () ) {
        let myID = getMyID()
        self.saveMessage(messageText: messageText,
                         fromUser: myID,
                         toUser: toUser,
                         type: .outgoing,
                         completionHandler: {})
    }
    
    func saveMessage(messageText: String,
                     fromUser: String,
                     toUser: String,
                     type: MessageDisplayModel.MessageType,
                     completionHandler: @escaping () -> () ) {
        
        let myID = getMyID()
        let senderID = myID == fromUser ? toUser : fromUser
        
        guard let context = stack.saveContext else {
            assertionFailure("Save context not found")
            return
        }
        
        let messageID = fromUser + toUser + "\(Date.timeIntervalSinceReferenceDate)"
        guard let sender = User.findOrInsertUser(with: fromUser, into: context),
            let message = Message.insertMessage(withID: messageID, into: context),
            let chat = Chat.findOrInsertChat(withID: senderID, into: context) else {
                assertionFailure()
                return
        }
        
        message.inChat = chat
        message.sender = sender
        message.lastInChat = chat
        message.text = messageText
        chat.hasUnreadMessages = fromUser != myID
        message.messageType = Int16(type.rawValue)
        
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
    
    func markChatAsRead(chatID: String) {
        guard let context = self.stack.saveContext else {
            assertionFailure("Save context is broken")
            return
        }
        context.perform {
            let chat = Chat.findOrInsertChat(withID: chatID, into: context)
            chat?.hasUnreadMessages = false
            self.stack.performSave(context: context, completionHandler: {_ in })
        }
    }
    
    func set(onlineStatus status: Bool, forUserWithID userID: String) {
        guard let context = self.stack.saveContext else {
            assertionFailure("Can't get core data context")
            return
        }
        context.perform {
            let user = User.findOrInsertUser(with: userID, into: context)
            user?.isOnline = status
            let chat = Chat.findOrInsertChat(withID: userID, into: context)
            chat?.isOnline = status
            self.stack.performSave(context: context, completionHandler: {_ in })
        }
    }
}
