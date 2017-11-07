//
//  StorageManager.swift
//  TinkoffNew
//
//  Created by Dmitry Gachkovsky on 07/11/2017.
//  Copyright © 2017 Dmitry Gachkovsky. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class StorageManager: IProfileStorage {
    let stack: ICoreDataStack
    
    init(with stack: ICoreDataStack) {
        self.stack = stack
    }
    
    func save(profile: ProfileStorageModel,
              completionHandler: @escaping (_ success: Bool) -> Void) {
        guard let context = stack.saveContext else {
            completionHandler(false)
            return
        }
        guard let appUser = AppUser.findOrInsertAppUser(in: context) else {
            completionHandler(false)
            return
        }
        guard let user = appUser.currentUser else {
            completionHandler(false)
            return
        }
        
        user.name = profile.name
        user.info = profile.info
        
        if let userPhoto = profile.userPhoto {
            let userPhotoData = UIImagePNGRepresentation(userPhoto)
            user.photo = userPhotoData
        }
        
        context.perform {
            self.stack.performSave(context: context) { (success) in
                DispatchQueue.main.async {
                    completionHandler(success)
                }
            }
        }
    }
    
    
    func load(completionHandler: @escaping (ProfileStorageModel?) -> Void) {
        
        guard let context = stack.saveContext else {
            completionHandler(nil)
            return
        }
        
        context.perform {
    
            guard let appUser = AppUser.findOrInsertAppUser(in: context) else {
                completionHandler(nil)
                return
            }
            guard let user = appUser.currentUser else {
                completionHandler(nil)
                return
            }
            
            var image = #imageLiteral(resourceName: "PhotoPlaceholder")
            if let userPhotoData = user.photo {
                image = UIImage(data: userPhotoData as Data)!
            }
            
            let profile = ProfileStorageModel.init(name: user.name, info: user.info, userPhoto: image)
            
            DispatchQueue.main.async {
                completionHandler(profile)
            }
        }
    }
}
