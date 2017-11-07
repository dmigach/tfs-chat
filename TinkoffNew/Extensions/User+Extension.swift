//
//  User.swift
//  TinkoffNew
//
//  Created by Dmitry Gachkovsky on 07/11/2017.
//  Copyright © 2017 Dmitry Gachkovsky. All rights reserved.
//

import Foundation
import UIKit
import CoreData

extension User {
    
    static func findOrInsertAppUser(with id: String, in context: NSManagedObjectContext) -> User? {
        if let user = NSEntityDescription.insertNewObject(forEntityName: "User", into: context) as? User {
            user.userID = id
            return user
        }
        return nil
    }
    
    static var generatedUserIdString: String {
        return UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
    }
}
