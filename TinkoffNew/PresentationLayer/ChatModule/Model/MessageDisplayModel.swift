//
//  MessageDisplayModel.swift
//  TinkoffNew
//
//  Created by Dmitry Gachkovsky on 03/11/2017.
//  Copyright © 2017 Dmitry Gachkovsky. All rights reserved.
//

import Foundation

class MessageDisplayModel {
    enum MessageType {
        case incoming
        case outgoing
    }
    
    let text: String
    let date: String
    let type: MessageType
    
    init(withText text: String,
         date: String,
         type: MessageType) {
        self.text = text
        self.date = date
        self.type = type
    }
}
