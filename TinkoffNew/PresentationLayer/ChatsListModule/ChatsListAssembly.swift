//
//  ChatsListAssembly.swift
//  TinkoffNew
//
//  Created by Dmitry Gachkovsky on 03/11/2017.
//  Copyright © 2017 Dmitry Gachkovsky. All rights reserved.
//

import UIKit

class ConversationsListAssembly {
    private let communicationService: ICommunicationService
    
    init(_ communicationService: ICommunicationService) {
        self.communicationService = communicationService
    }
    
    func assembly(_ conversationsListViewController: ChatsListViewController) {
        let model = getConversationsListModel()
        model.delegate = conversationsListViewController
        conversationsListViewController.setDependencies(model)
    }
    
    // MARK: - Private methods
    
    private func getConversationsListModel() -> IChatListModel {
        let conversationsListModel = ChatsListModel(communicationService: communicationService)
        communicationService.delegate = conversationsListModel
        return conversationsListModel
    }
    
//    private func getMessageHandler() -> IMessageCenter {
//        return MessageHandler(encoder: getMessageEncoder(), decoder: getMessageDecoder())
//    }
//    
//    private func getMessageEncoder() -> IMessageEncoder {
//        return MessageEncoder()
//    }
//    
//    private func getMessageDecoder() -> IMessageDecoder {
//        return MessageDecoder()
//    }
}
