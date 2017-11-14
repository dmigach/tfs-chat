//
//  ProfileAssembly.swift
//  TinkoffNew
//
//  Created by Dmitry Gachkovsky on 04/11/2017.
//  Copyright © 2017 Dmitry Gachkovsky. All rights reserved.
//

import Foundation

protocol IProfileStorage {
    func save(profile: ProfileStorageModel,
              completionHandler: @escaping (_ success: Bool) -> Void)
    func load(completionHandler: @escaping (ProfileStorageModel?) -> Void)
}

class ProfileAssembly {
    private var coreDataStack: ICoreDataStack
    
    init(coreDataStack: ICoreDataStack) {
        self.coreDataStack = CoreDataStack()
    }
    
    private func getCoreDataStorage() -> ProfileStorageManager {
        let dataStack = CoreDataStack()
        return ProfileStorageManager.init(with: dataStack)
    }
    
    private func getProfileConverter() -> IProfileConverter {
        return FileProfileStorage()
    }
    
    private func getProfileModel() -> IProfileModel {
        let profileStorageService = getProfileStorageService()
        return ProfileModel(profileStorageService: profileStorageService)
    }
    
    private func getStorages() -> (profileGCDStorage: IProfileStorage,
        profileOperationQueueStorage: IProfileStorage,
        profileCoreDataStorage: ProfileStorageManager) {
        let profileHandler = getProfileConverter()
        let coreDataStorage = self.getCoreDataStorage()
            return (ProfileGCDStorage(profileConverter: profileHandler),
                    ProfileOperationStorage(profileHandler: profileHandler),
                    coreDataStorage)
    }
    
    func injectDependencies(to profileViewController: ProfileViewController) {
        let model = getProfileModel()
        profileViewController.injectDependencies(model: model)
    }
    
    private func getProfileStorageService() -> IProfileStorageService {
        let storages = getStorages()
        return ProfileStorageService(profileGCDStorage: storages.profileGCDStorage,
                                     OperationStorage: storages.profileOperationQueueStorage,
                                     CoreDataStorage: storages.profileCoreDataStorage)
    }
}
