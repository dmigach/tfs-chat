//
//  MessageDisplayModel.swift
//  TinkoffNew
//
//  Created by Dmitry Gachkovsky on 03/11/2017.
//  Copyright © 2017 Dmitry Gachkovsky. All rights reserved.
//

import Foundation

class MessageDisplayModel {
    @objc enum MessageType: Int {
        case incoming = 0
        case outgoing = 1
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
