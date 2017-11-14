//
//  Chat+Extension.swift
//  TinkoffNew
//
//  Created by Dmitry Gachkovsky on 13/11/2017.
//  Copyright © 2017 Dmitry Gachkovsky. All rights reserved.
//

import CoreData
import Foundation

extension Chat {
    
    static func findOrInsertChat(withID ID: String,
                                         into context: NSManagedObjectContext) -> Chat? {
        
        let predicate = NSPredicate(format: "chatID == %@", ID)
        let fetchRequest = NSFetchRequest<Chat>(entityName: "Chat")
        let sortDescriptor = NSSortDescriptor(key: "chatID", ascending: true)
        
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        var chat: Chat?
        do {
            let results = try context.fetch(fetchRequest)
            assert(results.count < 2, "Multiple chats with same id found!")
            if let foundChat = results.first {
                chat = foundChat
            }
        } catch {
            print("Failed to fetch chat: \(error)")
        }
        if chat == nil {
            chat = Chat.insertChat(with: ID, into: context)
        }
        return chat
    }
    
    static func insertChat(with ID: String,
                                   into context: NSManagedObjectContext) -> Chat? {
        if let chat = NSEntityDescription.insertNewObject(forEntityName: "Chat",
                                                          into: context) as? Chat {
            chat.chatID = ID
            chat.hasUnreadMessages = false
            return chat
        }
        return nil
    }
}

extension Chat {
    
    static func fetchRequestChatWithID(ID: String,
                                       withModel model: NSManagedObjectModel) -> NSFetchRequest<Chat>? {
        let templateName = "ChatWithID"
        let variables = [
            "chatID" : ID
        ]
        
        guard let fetchRequest = model.fetchRequestFromTemplate(withName: templateName,
                                                                substitutionVariables: variables) as? NSFetchRequest<Chat> else {
            assertionFailure("No template with name: \(templateName)")
            return nil
        }
        return fetchRequest
    }
}
