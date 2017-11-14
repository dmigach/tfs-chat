//
//  AppUser.swift
//  TinkoffNew
//
//  Created by Dmitry Gachkovsky on 07/11/2017.
//  Copyright © 2017 Dmitry Gachkovsky. All rights reserved.
//

import CoreData
import Foundation

extension AppUser {
    
    static func findOrInsertAppUser(into context: NSManagedObjectContext) -> AppUser? {
        guard let model = context.persistentStoreCoordinator?.managedObjectModel else {
            assertionFailure("Model not found in context")
            return nil
        }
        
        var appUser: AppUser?
        guard let fetchRequest = AppUser.fetchRequestAppUser(withModel: model) else {
            return nil
        }
        
        do {
            let results = try context.fetch(fetchRequest)
            assert(results.count < 2, "Multiple AppUsers found")
            if let foundUser = results.first {
                appUser = foundUser
            }
        } catch {
            print("Error fetching AppUser: \(error)")
        }
        
        if appUser == nil {
            appUser = AppUser.insertAppUser(into: context)
        }
        return appUser
    }
    
    static func insertAppUser(into context: NSManagedObjectContext) -> AppUser? {
        if let appUser = NSEntityDescription.insertNewObject(forEntityName: "AppUser",
                                                             into: context) as? AppUser {
            if appUser.currentUser == nil {
                let currentUser = User.findOrInsertUser(with: User.generateUserID,
                                                        into: context)
                currentUser?.name = "dmigach"
                appUser.currentUser = currentUser
            }
            return appUser
        }
        return nil
    }
    
    static func fetchRequestAppUser(withModel model: NSManagedObjectModel) -> NSFetchRequest<AppUser>? {
        let templateName = "AppUser"
        guard let fetchRequest = model.fetchRequestTemplate(forName: templateName) as? NSFetchRequest<AppUser> else {
            assertionFailure("No template with name \(templateName)")
            return nil
        }
        return fetchRequest
    }
}
