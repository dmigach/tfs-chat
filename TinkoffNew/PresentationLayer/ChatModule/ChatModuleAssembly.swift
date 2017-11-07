//
//  ChatModuleAssembly.swift
//  TinkoffNew
//
//  Created by Dmitry Gachkovsky on 06/11/2017.
//  Copyright © 2017 Dmitry Gachkovsky. All rights reserved.
//

import Foundation

class ChatAssembly {
    
    private let communicationService: ICommunicationService
    
    init(communicationService: ICommunicationService) {
        self.communicationService = communicationService
    }
    
    func assembly(chatViewController: ChatViewController,
                  chat: ChatDisplayModel) {
        let model = getChatModel(communicationService: communicationService,
                                 chat: chat)
        communicationService.delegate = model
        chatViewController.setup(dataSource: chat.messages)
        model.delegate = chatViewController
        chatViewController.injectDependencies(model: model)
    }
    
    private func getChatModel(communicationService: ICommunicationService,
                              chat: ChatDisplayModel) -> ChatModel {
        return ChatModel(communicationService: communicationService,
                         chat: chat)
    }
}
