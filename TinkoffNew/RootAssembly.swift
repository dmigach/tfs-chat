//
//  RootAssembly.swift
//  TinkoffNew
//
//  Created by Dmitry Gachkovsky on 02/11/2017.
//  Copyright © 2017 Dmitry Gachkovsky. All rights reserved.
//

class RootAssembly {
    static let profileAssembly = ProfileAssembly()

    static let chatsListAssembly: ChatsListAssembly = {
        let chatsListAssembler = ChatsListAssembly(communicationService: communicationServiceAssembly)
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
        let communicationAssembly = ChatAssembly(communicationService: communicationServiceAssembly)
        return communicationAssembly
    }()

}
