//
//  ChatsListAssembly.swift
//  TinkoffNew
//
//  Created by Dmitry Gachkovsky on 03/11/2017.
//  Copyright © 2017 Dmitry Gachkovsky. All rights reserved.
//

import UIKit

class ChatsListModuleAssembly {
    
    private let chatAssembler: ChatAssembly
    private let coreDataStack: ICoreDataStack
    private let profileAssembler: ProfileAssembly
    private let communicationService: ICommunicationService
    
    init(chatAssembler: ChatAssembly,
         coreDataStack: ICoreDataStack,
         profileAssembler: ProfileAssembly,
         communicationService: ICommunicationService) {
        self.chatAssembler = chatAssembler
        self.coreDataStack = coreDataStack
        self.profileAssembler = profileAssembler
        self.communicationService = communicationService
    }
    
    func injectDependencies(to chatsListVC: ChatsListViewController) {
        let model = createChatsListModel()
        chatsListVC.inject(model: model,
                           chatAssembler: self.chatAssembler,
                           profileAssembler: self.profileAssembler)
    }
    
    private func createChatsListModel() -> IChatListModel {
        let storageManager = self.createChatsListStorageManager()
        let chatsListModel = ChatsListModel(communicationService: communicationService,
                                            chatsListStorageManager: storageManager)
        self.communicationService.delegate = chatsListModel
        return chatsListModel
    }
    
    private func createChatsListStorageManager() -> ChatsListStorageManager {
        return ChatsListStorageManager(coreDataStack: self.coreDataStack)
    }
}
