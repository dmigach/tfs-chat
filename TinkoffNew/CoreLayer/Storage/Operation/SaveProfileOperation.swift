//
//  SaveProfileOperation.swift
//  TinkoffNew
//
//  Created by Dmitry Gachkovsky on 06/11/2017.
//  Copyright © 2017 Dmitry Gachkovsky. All rights reserved.
//

import Foundation

//DEPRECATED
class SaveProfileOperation: Operation {
    private let profile: ProfileStorageModel
    private let completionHandler: (Bool) -> Void
    private let profileConverter: IProfileConverter
    
    init(userProfile: ProfileStorageModel,
         profileConverter: IProfileConverter,
         completionHandler: @escaping (Bool) -> Void) {
        self.profile = userProfile
        self.profileConverter = profileConverter
        self.completionHandler = completionHandler
    }
    
    override func main() {
        if isCancelled {
            return
        }
        profileConverter.save(profile: profile)
        completionHandler(true)
    }
}
