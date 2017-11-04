//
//  CommunicatonService.swift
//  TinkoffNew
//
//  Created by Dmitry Gachkovsky on 03/11/2017.
//  Copyright © 2017 Dmitry Gachkovsky. All rights reserved.
//

import Foundation

//MARK: - Protocols
protocol ICommunicationService: class {
    var communicator: ICommunicator { get }
    weak var delegate: ICommunicationServiceDelegate? { get set }
    func sendMessage(text: String, to userID: String, completionHandler: ((_ success: Bool, _ error: Error?) -> Void)?)
}

protocol ICommunicationServiceDelegate: class {
    func lostUser(userID: String)
    func foundUser(userID: String, userName: String?)
    func receivedMessage(text: String, fromUserID: String, toUserID: String)
}

//Optional methods.
extension ICommunicationServiceDelegate {
    func foundUser(userID: String, userName: String?) {
        //This is default implementation for method, so it became optional.
        //Only ChatsList should respond to didFindUser, but not Chat screen.
    }
}

class CommunicationService: ICommunicationService {
    let communicator: ICommunicator
    weak var delegate: ICommunicationServiceDelegate?
    
    init(communicator: ICommunicator) {
        self.communicator = communicator
    }
    
    func sendMessage(text: String, to userID: String, completionHandler: ((_ success: Bool, _ error: Error?) -> Void)?) {
        communicator.sendMessage(text: text, to: userID, completionHandler: completionHandler)
    }
}

// MARK: - ICommunicationServiceDelegate
extension CommunicationService: ICommunicatorDelegate {
    func foundUser(userID: String, userName: String?) {
        delegate?.foundUser(userID: userID, userName: userName)
    }
    
    func lostUser(userID: String) {
        delegate?.lostUser(userID: userID)
    }
    
    func receivedMessage(text: String, fromUser sender: String, toUser receiver: String) {
        delegate?.receivedMessage(text: text, fromUserID: sender, toUserID: receiver)
    }
    
    func failedToStartAdvertising(error: Error) {
        assertionFailure("\(error)")
    }
    
    func failedToStartBrowsingForUsers(error: Error) {
        assertionFailure("\(error)")
    }
}
