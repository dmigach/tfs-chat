//
//  ChatsListAssembly.swift
//  TinkoffNew
//
//  Created by Dmitry Gachkovsky on 03/11/2017.
//  Copyright © 2017 Dmitry Gachkovsky. All rights reserved.
//

import UIKit

class ChatsListAssembly {
    private let communicationService: ICommunicationService
    
    init(communicationService: ICommunicationService) {
        self.communicationService = communicationService
    }
    
    func injectDependencies(to chatsListVC: ChatsListViewController) {
        let model = createChatsListModel()
        model.delegate = chatsListVC
        chatsListVC.inject(model: model)
    }
    
    private func createChatsListModel() -> IChatListModel {
        let chatsListModel = ChatsListModel(communicationService: communicationService)
        communicationService.delegate = chatsListModel
        return chatsListModel
    }
}
