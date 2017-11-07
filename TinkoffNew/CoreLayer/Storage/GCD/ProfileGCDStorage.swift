//
//  ProfileGCDStorage.swift
//  TinkoffNew
//
//  Created by Dmitry Gachkovsky on 04/11/2017.
//  Copyright © 2017 Dmitry Gachkovsky. All rights reserved.
//

import Foundation

//DEPRECATED
class ProfileGCDStorage: IProfileStorage {
    
    private let profileConverter: IProfileConverter
    private let serialQueue = DispatchQueue(label: "com.dmigach.TinkoffMes.profileGCD")
    
    init(profileConverter: IProfileConverter) {
        self.profileConverter = profileConverter
    }
    
    func save(profile: ProfileStorageModel,
              completionHandler: @escaping (Bool) -> Void) {
        serialQueue.async {
            self.profileConverter.save(profile: profile)
            completionHandler(true)
        }
    }
    
    func load(completionHandler: @escaping (ProfileStorageModel?) -> Void) {
        serialQueue.async {
                let profile = self.profileConverter.loadProfile()
                completionHandler(profile)
        }
    }
}
