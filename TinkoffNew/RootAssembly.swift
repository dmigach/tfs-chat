//
//  RootAssembly.swift
//  TinkoffNew
//
//  Created by Dmitry Gachkovsky on 02/11/2017.
//  Copyright © 2017 Dmitry Gachkovsky. All rights reserved.
//

class RootAssembly {
    static let profileAssembly = ProfileAssembly(coreDataStack: coreDataStack)

    static let chatsListAssembly: ChatsListModuleAssembly = {
        let chatsListAssembler = ChatsListModuleAssembly(communicationService: RootAssembly.communicationServiceAssembly,
                                                         coreDataStack: coreDataStack)
        return chatsListAssembler
    }()
    
    private static let communicationServiceAssembly: ICommunicationService = {
        let communicator = MultipeerCommunicator(MessageConverter(encoder: MessageEncoder(),
                                                                  decoder: MessageDecoder()))
        let communicationService = CommunicationService(communicator: communicator)
        communicator.delegate = communicationService
        return communicationService
    }()
    
    static let chatAssembly: ChatAssembly = {
        let communicationAssembly = ChatAssembly(communicationService: RootAssembly.communicationServiceAssembly,
                                                 coreDataStack: RootAssembly.coreDataStack)
        return communicationAssembly
    }()
    
    private static let coreDataStack: ICoreDataStack = {
       return CoreDataStack()
    }()
}
