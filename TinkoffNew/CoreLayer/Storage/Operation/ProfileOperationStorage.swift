//
//  ProfileOperationQueueStorage.swift
//  TinkoffNew
//
//  Created by Dmitry Gachkovsky on 04/11/2017.
//  Copyright © 2017 Dmitry Gachkovsky. All rights reserved.
//

import Foundation

class ProfileOperationStorage: IProfileStorage {
    private let queue = OperationQueue()
    private let profileConverter: IProfileConverter
    
    init(profileHandler: IProfileConverter) {
        self.profileConverter = profileHandler
    }
    
    func save(profile: ProfileStorageModel,
              completionHandler: @escaping (Bool) -> Void) {
        let operation = SaveProfileOperation(userProfile: profile,
                                                 profileConverter: profileConverter,
                                                 completionHandler: completionHandler)
        queue.addOperation(operation)
    }
    
    func load(completionHandler: @escaping (ProfileStorageModel?) -> Void) {
        let operation = LoadProfileOperation(profileConverter: profileConverter,
                                             completionHandler: completionHandler)
        queue.addOperation(operation)
    }
}
