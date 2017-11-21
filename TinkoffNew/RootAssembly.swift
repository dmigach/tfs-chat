//
//  RootAssembly.swift
//  TinkoffNew
//
//  Created by Dmitry Gachkovsky on 02/11/2017.
//  Copyright © 2017 Dmitry Gachkovsky. All rights reserved.
//

class RootAssembly {
    lazy var profileAssembly = ProfileAssembly(coreDataStack: coreDataStack)

    lazy var chatsListAssembly: ChatsListModuleAssembly = {
        let chatsListAssembler = ChatsListModuleAssembly(chatAssembler: self.chatAssembly,
                                                         coreDataStack: self.coreDataStack,
                                                         profileAssembler: self.profileAssembly,
                                                         communicationService: self.communicationServiceAssembly)
        return chatsListAssembler
    }()
    
    lazy var chatAssembly: ChatAssembly = {
        let communicationAssembly = ChatAssembly(communicationService: self.communicationServiceAssembly,
                                                 coreDataStack: self.coreDataStack)
        return communicationAssembly
    }()
    
    lazy var coreDataStack: ICoreDataStack = {
       return CoreDataStack()
    }()
    
    lazy var communicationServiceAssembly: ICommunicationService = {
        let communicator = MultipeerCommunicator(MessageConverter(encoder: MessageEncoder(),
                                                                  decoder: MessageDecoder()))
        let communicationService = CommunicationService(communicator: communicator)
        communicator.delegate = communicationService
        return communicationService
    }()
}
