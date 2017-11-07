//
//  LoadProfileOperations.swift
//  TinkoffNew
//
//  Created by Dmitry Gachkovsky on 06/11/2017.
//  Copyright © 2017 Dmitry Gachkovsky. All rights reserved.
//

import Foundation

//DEPRECATED
class LoadProfileOperation: Operation {
    private let profileConverter: IProfileConverter
    private let completionHandler: (ProfileStorageModel?) -> Void
    
    init(profileConverter: IProfileConverter,
         completionHandler: @escaping (ProfileStorageModel?) -> Void) {
        self.profileConverter = profileConverter
        self.completionHandler = completionHandler
    }
    
    override func main() {
        if isCancelled {
            return
        }
        let profile = profileConverter.loadProfile()
        completionHandler(profile)
    }
}
