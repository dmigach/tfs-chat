//
//  Message+Extension.swift
//  TinkoffNew
//
//  Created by Dmitry Gachkovsky on 14/11/2017.
//  Copyright © 2017 Dmitry Gachkovsky. All rights reserved.
//

import Foundation
import CoreData

extension Message {
    
    static func insertMessage(withID ID: String,
                              into context: NSManagedObjectContext) -> Message? {
        if let message = NSEntityDescription.insertNewObject(forEntityName: "Message",
                                                             into: context) as? Message {
            message.date = Date()
            message.messageID = ID
            return message
        }
        return nil
    }
}
