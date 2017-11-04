//
//  RootAssembly.swift
//  TinkoffNew
//
//  Created by Dmitry Gachkovsky on 02/11/2017.
//  Copyright © 2017 Dmitry Gachkovsky. All rights reserved.
//

class RootAssembly {
    // This service is used by each module of the app to keep only one communicator on the Core layer, therefore made static.
    private static let communicationService: ICommunicationService = {
        let communicator = MultipeerCommunicator(MessageConverter(encoder: MessageEncoder(), decoder: MessageDecoder()))
        let communicationService = CommunicationService(communicator: communicator)
        communicator.delegate = communicationService
        return communicationService
    }()
    
    static let conversationsListAssembly: ConversationsListAssembly = {
        let conversationsListAssembly = ConversationsListAssembly(communicationService)
        return conversationsListAssembly
    }()
//
//    static let conversationAssembly: ConversationAssembly = {
//        let communicationAssembly = ConversationAssembly(communicationService)
//        return communicationAssembly
//    }()
//
//    static let profileAssembly = ProfileAssembly()
}
