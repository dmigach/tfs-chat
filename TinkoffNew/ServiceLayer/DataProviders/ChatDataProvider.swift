//
//  ChatDataProvider.swift
//  TinkoffNew
//
//  Created by Dmitry Gachkovsky on 13/11/2017.
//  Copyright © 2017 Dmitry Gachkovsky. All rights reserved.
//

import UIKit
import CoreData
import Foundation

protocol IChatDataProvider {
    var fetchedResultsController: NSFetchedResultsController<Message>? {get set}
}

class ChatDataProvider: DataProvider, IChatDataProvider {
    var fetchedResultsController: NSFetchedResultsController<Message>?
    
    init(tableView: UITableView?, stack: ICoreDataStack, chatID: String) {
        super.init()
        self.tableView = tableView
        guard let context = stack.saveContext else {
            assertionFailure("Error loading core data context")
            return
        }
        
        
        let fetchRequest = NSFetchRequest<Message>(entityName: "Message")
        fetchRequest.predicate = NSPredicate(format: "inChat.chatID == %@", NSString(string: chatID) )
        let dateDescriptor = NSSortDescriptor(key: #keyPath(Message.date), ascending: true)
        fetchRequest.sortDescriptors = [dateDescriptor]
        fetchedResultsController = NSFetchedResultsController<Message>(fetchRequest: fetchRequest,
                                                                    managedObjectContext: context,
                                                                    sectionNameKeyPath: nil,
                                                                    cacheName: nil)
        fetchedResultsController?.delegate = self
        
        do {
            try self.fetchedResultsController?.performFetch()
            self.tableView?.reloadData()
        } catch {
            print("Error fetching: \(error)")
        }
    }
}
