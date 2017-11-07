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
    var hasNoMessages: Bool { get }
    func send(message: String,
              completionHandler: (() -> Void)?)
    weak var delegate: IChatModelDelegate? { get set }

}

protocol IChatModelDelegate: class {
    func setup(dataSource: [MessageDisplayModel])
    func userChangedStatusTo(online: Bool)
}

//MARK: - Class
class ChatModel: IChatModel {
    
    //MARK: - Properties
    weak var delegate: IChatModelDelegate?
    
    var userName: String {
        return chat.userName
    }
    
    var hasNoMessages: Bool {
        return chat.messages.isEmpty
    }
    
    private let chat: ChatDisplayModel
    private let communicationService: ICommunicationService
    
    //MARK: - Init
    init(communicationService: ICommunicationService,
         chat: ChatDisplayModel) {
        self.chat = chat
        self.communicationService = communicationService
    }
    
    func markChatAsRead() {
        chat.setState(.read)
    }
    
    func send(message: String,
              completionHandler: (() -> Void)?) {
        communicationService.sendMessage(text: message,
                                         to: chat.messageID) { [unowned self] (success: Bool, error: Error?) in
            if error == nil {
                if success {
                    let sentMessage = MessageDisplayModel(withText: message, date: Date().getDateForMessage(), type: .outgoing)
                    self.chat.appendMessage(sentMessage)
                } else {
                    assertionFailure("Error seding message")
                }
            }
            completionHandler?()
            self.delegate?.setup(dataSource: self.chat.messages)
        }
    }
}

// MARK: - ICommunicationServiceDelegate
extension ChatModel: ICommunicationServiceDelegate {
    func lostUser(userID: String) {
        if chat.messageID == userID {
            delegate?.userChangedStatusTo(online: false)
        }
    }
    
    func didFindUser(userID: String, userName: String?) {
        if chat.messageID == userID {
            delegate?.userChangedStatusTo(online: true)
        }
    }
    
    func receivedMessage(text: String, fromUserID fromUser: String, toUserID toUser: String) {
        if chat.messageID == fromUser {
            chat.appendMessage(MessageDisplayModel(withText: text, date: Date().getDateForMessage(), type: .incoming))
            delegate?.setup(dataSource: chat.messages)
        }
    }
}
