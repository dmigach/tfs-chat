//
//  ChatModel.swift
//  TinkoffNew
//
//  Created by Dmitry Gachkovsky on 06/11/2017.
//  Copyright © 2017 Dmitry Gachkovsky. All rights reserved.
//

import UIKit

//MARK: - Protocols
protocol IChatModel: class {
    func markChatAsRead()
    var userName: String { get }
    func getNumberOfRows() -> Int
    var hasNoMessages: Bool { get }
    weak var delegate: IChatModelDelegate? { get set }
    func send(message: String, completionHandler: (() -> Void)?)
    func getMessage(at indexPath: IndexPath) -> MessageDisplayModel
    var chatOnline: Bool { get set }
}

protocol IChatModelDelegate: class {
    var tableView: UITableView! {get set}
    func userChangedStatusTo(online: Bool)
}

//MARK: - Class
class ChatModel: IChatModel {
    
    //MARK: - Properties
    private var dataProvider: ChatDataProvider?
    weak var delegate: IChatModelDelegate? {
        didSet {
            self.dataProvider = ChatDataProvider(tableView: delegate?.tableView,
                                                 stack: self.chatStorageManager.stack,
                                                 chatID: self.chatID)
        }
    }
    var userName: String
    var hasNoMessages: Bool = false
    var chatOnline: Bool

    private let chatID: String
    private let chatStorageManager: IChatStorageManager
    private let communicationService: ICommunicationService

    
    //MARK: - Init
    init(communicationService: ICommunicationService,
         chatStoragemanager: ChatStorageManager,
         chatID: String) {
        self.chatID = chatID
        self.chatStorageManager = chatStoragemanager
        self.communicationService = communicationService
        self.userName = self.chatStorageManager.getUserName(withId: chatID)
        self.chatOnline = self.chatStorageManager.getChatOnlineStatus(withID: self.chatID)
    }
    
    func markChatAsRead() {
        chatStorageManager.markChatAsRead(chatID: chatID)
    }
    
    func send(message: String,
              completionHandler: (() -> Void)?) {
        chatStorageManager.saveOutgoingMessage(messageText: message,
                                               toUser: self.chatID,
                                               completionHandler: {})
        communicationService.sendMessage(text: message,
                                         to: self.chatID,
                                         completionHandler: { (success: Bool, error: Error?) in
            if let error = error {
                print("Error sending message: \(error)")
            } else if success {
                completionHandler?()
                print("send success")
            } else {
                print("Error sending message: unknown error")
            }
        })
    }
    
    func getNumberOfRows() -> Int {
        guard let frc = dataProvider?.fetchedResultsController,
            let section = frc.sections?.first! else {
                return 0
        }
        return section.numberOfObjects
    }
    
    func getMessage(at indexPath: IndexPath) -> MessageDisplayModel {
        if let frc = dataProvider?.fetchedResultsController {
            let message = frc.object(at: indexPath)
            let messageDisplayModel = MessageDisplayModel(withText: message.text!,
                                                          date: (message.date?.getDateForMessage())!,
                                                          type: MessageDisplayModel.MessageType(rawValue: Int(message.messageType))!)
            return messageDisplayModel
        }
        return MessageDisplayModel(withText: "Not found",
                                   date: Date().getDateForMessage(),
                                   type: .incoming)
    }
}

// MARK: - ICommunicationServiceDelegate
extension ChatModel: ICommunicationServiceDelegate {
    func lostUser(userID: String) {
        self.chatOnline = false
        self.chatStorageManager.set(onlineStatus: false,
                                    forUserWithID: userID)
        if self.chatID == userID {
            delegate?.userChangedStatusTo(online: false)
        }
    }
    
    func didFindUser(userID: String, userName: String?) {
        self.chatOnline = true
        self.chatStorageManager.set(onlineStatus: true,
                                    forUserWithID: userID)
        if self.chatID == userID {
            delegate?.userChangedStatusTo(online: true)
        }
    }
    
    func receivedMessage(text: String, fromUserID fromUser: String, toUserID toUser: String) {
        self.chatStorageManager.saveMessage(messageText: text,
                                            fromUser: fromUser,
                                            toUser: toUser,
                                            type: .incoming,
                                            completionHandler: {})
    }
}
