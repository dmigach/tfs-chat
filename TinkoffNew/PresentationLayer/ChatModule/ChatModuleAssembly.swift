//
//  ChatModuleAssembly.swift
//  TinkoffNew
//
//  Created by Dmitry Gachkovsky on 06/11/2017.
//  Copyright © 2017 Dmitry Gachkovsky. All rights reserved.
//

import Foundation

class ChatAssembly {
    
    private let coreDataStack: ICoreDataStack
    private let communicationService: ICommunicationService
    
    init(communicationService: ICommunicationService,
         coreDataStack: ICoreDataStack) {
        self.coreDataStack = coreDataStack
        self.communicationService = communicationService
    }
    
    func assembly(chatViewController: ChatViewController,
                  chatID: String) {
        let model = getChatModel(communicationService: communicationService,
                                 chatID: chatID)
        model.delegate = chatViewController
        communicationService.delegate = model
        chatViewController.injectDependencies(model: model)
    }
    
    private func getChatModel(communicationService: ICommunicationService,
                              chatID: String) -> ChatModel {
        return ChatModel(communicationService: communicationService,
                         chatStoragemanager: self.getChatStorageManager(),
                         chatID: chatID)
    }
    
    private func getChatStorageManager() -> ChatStorageManager {
        return ChatStorageManager(coreDataStack: self.coreDataStack)
    }
}
