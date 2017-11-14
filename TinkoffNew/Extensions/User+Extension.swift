//
//  User.swift
//  TinkoffNew
//
//  Created by Dmitry Gachkovsky on 07/11/2017.
//  Copyright © 2017 Dmitry Gachkovsky. All rights reserved.
//

import UIKit
import CoreData
import Foundation

extension User {
    
    static func findOrInsertUser(with ID: String,
                                 into context: NSManagedObjectContext) -> User? {
        let manager = FetchRequestBuilder(objectModel: context.persistentStoreCoordinator?.managedObjectModel)
        guard let fetchRequest = manager.fetchRequestUserWith(ID: ID) else {
            return nil
        }

        var user: User?
        do {
            let results = try context.fetch(fetchRequest)
            assert(results.count < 2, "Multiple users with same id found!")
            if let foundUser = results.first {
                user = foundUser
            }
        } catch {
            print("Failed to fetch User: \(error)")
        }
        if user == nil {
            user = insertUser(with: ID, into: context)
        }
        return user
    }
    
    static func insertUser(with ID: String,
                           into context: NSManagedObjectContext) -> User? {
        if let user = NSEntityDescription.insertNewObject(forEntityName: "User",
                                                          into: context) as? User {
            user.userID = ID
            return user
        }
        return nil
    }
    
    static var generateUserID: String {
        return UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
    }
}

extension User {
    static func fetchRequestUserWith(ID: String,
                                     in model: NSManagedObjectModel) -> NSFetchRequest<User>? {
        
        let templateName = "UserWithID"
        let variables = [
            "userID" : ID
        ]
        guard let fetchRequest = model.fetchRequestFromTemplate(withName: templateName,
                                                                substitutionVariables: variables) as? NSFetchRequest<User> else {
            print("No template with name: \(templateName)")
            return nil
        }
        return fetchRequest
    }
}
