//
//  FetchRequestBuilder.swift
//  TinkoffNew
//
//  Created by Dmitry Gachkovsky on 13/11/2017.
//  Copyright © 2017 Dmitry Gachkovsky. All rights reserved.
//

import Foundation
import CoreData

class FetchRequestBuilder {
    
    let objectModel: NSManagedObjectModel?
    
    init(objectModel: NSManagedObjectModel?) {
        self.objectModel = objectModel
    }
    
    func getAllChats() -> NSFetchRequest<Chat>? {
        let fetchRequest = NSFetchRequest<Chat>(entityName: "Chat")
        return fetchRequest
    }
    
    func fetchRequestUserWith(ID: String) -> NSFetchRequest<User>? {
        if let model = objectModel {
            return User.fetchRequestUserWith(ID: ID,
                                             in: model)
        } else {
            return nil
        }
    }
}
