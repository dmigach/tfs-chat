//
//  ChatsListModel.swift
//  TinkoffNew
//
//  Created by Dmitry Gachkovsky on 03/11/2017.
//  Copyright © 2017 Dmitry Gachkovsky. All rights reserved.
//

import Foundation


//MARK: - Protocols
protocol IChatListModelDelegate: class {
    func setup(dataSource: [ChatDisplayModel])
}

protocol IChatListModel: class {
    func relaunchCommunication()
    weak var delegate: IChatListModelDelegate? { get set }
}

//MARK: - ChatsListModel
class ChatsListModel: IChatListModel {
    
    weak var delegate: IChatListModelDelegate?
    
    private static let defaultUserName = "Stranger"
    private let communicationService: ICommunicationService
    
    private var chats: [ChatDisplayModel] = [] {
        didSet {
            delegate?.setup(dataSource: chats)
        }
    }
    
    init(communicationService: ICommunicationService) {
        self.communicationService = communicationService
    }
    
    func relaunchCommunication() {
        communicationService.delegate = self
    }
}

//MARK: - ICommunicationServiceDelegate
extension ChatsListModel: ICommunicationServiceDelegate {
    
    func foundUser(userID: String, userName: String?) {
        if let exsistedChat = getChatWithUser(with: userID) {
            exsistedChat.isOnline = true
            delegate?.setup(dataSource: chats)
        } else {
            let newChat = ChatDisplayModel(messageID: userID,
                                           userName: userName ?? ChatsListModel.defaultUserName)
            chats.append(newChat)
        }
    }
    
    func lostUser(userID: String) {
        guard let exsistedChat = getChatWithUser(with: userID) else {
            return
        }
        exsistedChat.isOnline = false
        delegate?.setup(dataSource: chats)
    }
    
    func receivedMessage(text: String, fromUserID: String, toUserID: String) {
        guard let exsistedChat = getChatWithUser(with: fromUserID) else {
//            assertionFailure("received message from unknown user")
            return
        }
        let receivedMessage = MessageDisplayModel(withText: text, date: Date().getDateForMessage(), type: .incoming)
        exsistedChat.appendMessage(receivedMessage)
        exsistedChat.setState(.unread)
        delegate?.setup(dataSource: chats)
    }
    
    private func getChatWithUser(with userID: String) -> ChatDisplayModel? {
        return chats.filter {$0.messageID == userID}.first
    }
}
