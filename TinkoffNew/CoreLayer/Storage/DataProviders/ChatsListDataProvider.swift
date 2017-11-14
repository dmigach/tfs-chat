//
//  ChatsListDataProvider
//  TinkoffNew
//
//  Created by Dmitry Gachkovsky on 13/11/2017.
//  Copyright © 2017 Dmitry Gachkovsky. All rights reserved.
//

import UIKit
import CoreData
import Foundation

protocol IChatsListDataProvider {
    var fetchedResultsController: NSFetchedResultsController<Chat>? {get set}
}

class ChatsListDataProvider: DataProvider, IChatsListDataProvider {
    
    var fetchedResultsController: NSFetchedResultsController<Chat>?
    
    init(tableView: UITableView?, stack: ICoreDataStack) {
        super.init()

        self.tableView = tableView
        guard let context = stack.saveContext else {
            assertionFailure("Error loading core data context")
            return
        }
        
        let fetchRequest = NSFetchRequest<Chat>(entityName: "Chat")
        let onlineDescriptor = NSSortDescriptor(key: #keyPath(Chat.isOnline), ascending: false)
        let dateDescriptor = NSSortDescriptor(key: #keyPath(Chat.lastMessage.date), ascending: false)
        fetchRequest.sortDescriptors = [onlineDescriptor, dateDescriptor]
        fetchedResultsController = NSFetchedResultsController<Chat>(fetchRequest: fetchRequest,
                                                                    managedObjectContext: context,
                                                                    sectionNameKeyPath: #keyPath(Chat.isOnline),
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
