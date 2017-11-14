//
//  ChatsListModel.swift
//  TinkoffNew
//
//  Created by Dmitry Gachkovsky on 03/11/2017.
//  Copyright © 2017 Dmitry Gachkovsky. All rights reserved.
//

import Foundation
import UIKit

//MARK: - Protocols
protocol IChatsListModelDelegate: class {
    var tableView: UITableView! {get set}
}

protocol IChatListModel: class {
    func relaunchCommunication()
    func getNumberOfSections() -> Int
    func getNumberOfRowsIn(section: Int) -> Int
    func getTitleForSection(section: Int) -> String?
    weak var delegate: IChatsListModelDelegate? { get set }
    func getChat(at indexPath: IndexPath) -> ChatsListCellDisplayModel
}

struct ChatsListCellDisplayModel {
    var date: Date?
    var name: String?
    var chatID: String?
    var message: String?
    var online: Bool = false
    var hasUnreadMessages: Bool = false
}

extension ChatsListCellDisplayModel {
    func configureChatCell(cell: ChatCell) {
        cell.name = self.name
        cell.online = self.online
        cell.message = self.message
        cell.date = self.date?.getDateForMessage()
        cell.hasUnreadMessages = self.hasUnreadMessages
    }
}

//MARK: - ChatsListModel
class ChatsListModel: IChatListModel {
    
    private var dataProvider: ChatsListDataProvider?
    weak var delegate: IChatsListModelDelegate? {
        didSet {
            self.dataProvider = ChatsListDataProvider(tableView: delegate?.tableView,
                                                      stack: self.chatsListStorageManager.stack)
        }
    }
    let chatsListStorageManager: ChatsListStorageManager
    
    private static let defaultUserName = "Stranger"
    private let communicationService: ICommunicationService

    init(communicationService: ICommunicationService,
         chatsListStorageManager: ChatsListStorageManager) {
        self.communicationService = communicationService
        self.chatsListStorageManager = chatsListStorageManager
    }
    
    func relaunchCommunication() {
        communicationService.delegate = self
    }
    
    func getNumberOfSections() -> Int {
        guard let frc = dataProvider?.fetchedResultsController,
            let sectionsCount = frc.sections?.count else {
                return 0
        }
        return sectionsCount
    }
    
    func getNumberOfRowsIn(section: Int) -> Int {
        guard let frc = dataProvider?.fetchedResultsController,
            let sections = frc.sections else {
                return 0
        }
        return sections[section].numberOfObjects
    }
    
    func getChat(at indexPath: IndexPath) -> ChatsListCellDisplayModel {
        if let frc = dataProvider?.fetchedResultsController {
            let chat = frc.object(at: indexPath)
            let chatCellDisplayModel = ChatsListCellDisplayModel(
                date: chat.lastMessage?.date,
                name: chat.withUser?.name,
                chatID: chat.chatID,
                message: chat.lastMessage?.text,
                online: chat.withUser?.isOnline ?? false,
                hasUnreadMessages: chat.hasUnreadMessages)
            return chatCellDisplayModel
        }
        return ChatsListCellDisplayModel()
    }
    
    func getTitleForSection(section: Int) -> String? {
        guard let sections = dataProvider?.fetchedResultsController?.sections else {
            preconditionFailure("no sections in fetchedResultsController")
        }
        guard sections[section].numberOfObjects > 0 else {
            return nil
        }
        if let chatInSection = dataProvider?.fetchedResultsController?.object(at: IndexPath(row: 0, section: section)) {
            return chatInSection.isOnline ? "Online" : "History"
        }
        return nil
    }
}

//MARK: - ICommunicationServiceDelegate
extension ChatsListModel: ICommunicationServiceDelegate {
    
    func foundUser(userID: String, userName: String?) {
        self.chatsListStorageManager.saveChat(withUser: userID, userName: userName)
    }
    
    func lostUser(userID: String) {
        self.chatsListStorageManager.changeChatStatusToOffline(withUser: userID)
    }
    
    func receivedMessage(text: String, fromUserID: String, toUserID: String) {
        self.chatsListStorageManager.saveMessage(messageText: text,
                                                 fromUser: fromUserID,
                                                 toUser: toUserID,
                                                 completionHandler: {})
    }
}
