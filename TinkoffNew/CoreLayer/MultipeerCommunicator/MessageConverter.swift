//
//  MessageCenter.swift
//  TinkoffNew
//
//  Created by Dmitry Gachkovsky on 03/11/2017.
//  Copyright © 2017 Dmitry Gachkovsky. All rights reserved.
//

import Foundation

//MARK: - Protocols
protocol IMessageConverter: class {
    func getDataForSending(message: String) -> Data?
    func getMessageText(from data: Data) -> String?
}

protocol IMessageEncoder: class {
    func getDataForSending(message: String) -> Data?
}

protocol IMessageDecoder: class {
    func getMessageText(from data: Data) -> String?
}

//MARK: - MessageConverter
class MessageConverter: IMessageConverter {
    private let encoder: IMessageEncoder
    private let decoder: IMessageDecoder
    
    init(encoder: IMessageEncoder, decoder: IMessageDecoder) {
        self.encoder = encoder
        self.decoder = decoder
    }
    
    func getDataForSending(message: String) -> Data? {
        return self.encoder.getDataForSending(message: message)
    }
    
    func getMessageText(from data: Data) -> String? {
        return self.decoder.getMessageText(from: data)
    }
}

//MARK: - MessageEncoder
class MessageEncoder: IMessageEncoder {
    private struct MessageWrapConstants {
        static let messageTextKey = "text"
        static let eventTypeKey = "eventType"
        static let messageIdKey = "messageId"
        static let messageEventTypeDescription = "TextMessage"
    }

    func getDataForSending(message: String) -> Data? {
        let message = [MessageWrapConstants.eventTypeKey: MessageWrapConstants.messageEventTypeDescription,
                       MessageWrapConstants.messageIdKey: self.generateMessageId(),
                       MessageWrapConstants.messageTextKey: message]
        do {
            return try JSONSerialization.data(withJSONObject: message)
        } catch {
            //TODO Assert
            assertionFailure("Failed creating data from message: \(error)")
            return nil
        }
    }
    
    private func generateMessageId() -> String {
        guard let id = """
                    \(arc4random_uniform(UINT32_MAX))
                    + \(Date.timeIntervalSinceReferenceDate)
                    + \(arc4random_uniform(UINT32_MAX))
                    """.data(using: .utf8)?.base64EncodedString()
            else {
                assertionFailure("Message id generation is broken")
                return "brokenId"
            }
        return id
    }
}

//MARK: - MessageDecoder
class MessageDecoder: IMessageDecoder {
    private static let messageTextKey = "text"
    
    func getMessageText(from data: Data) -> String? {
        if let json = try? JSONSerialization.jsonObject(with: data),
            let castedMessage = json as? [String: String] {
            return castedMessage[MessageDecoder.messageTextKey]
        } else {
            return nil
        }
    }
}
