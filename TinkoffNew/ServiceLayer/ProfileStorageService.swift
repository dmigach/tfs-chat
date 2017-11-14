//
//  ProfileStorageService.swift
//  TinkoffNew
//
//  Created by Dmitry Gachkovsky on 04/11/2017.
//  Copyright © 2017 Dmitry Gachkovsky. All rights reserved.
//

import Foundation

//MARK: - Protocol
protocol IProfileStorageService: class {
    func save(profile: ProfileStorageModel,
              saveKind: ProfileSaveKind,
              completionHandler: @escaping(_ result: Bool) -> ())
    func load(saveKind: ProfileSaveKind,
              completionHandler: @escaping (ProfileStorageModel?) -> ())
}

//MARK: - Class
class ProfileStorageService: IProfileStorageService {
    
    //MARK: - Properties
    private let GCDStorage: IProfileStorage
    private let OperationStorage: IProfileStorage
    private let coreDataStorage: ProfileStorageManager

    //MARK: - Init
    init(profileGCDStorage: IProfileStorage,
         OperationStorage: IProfileStorage,
         CoreDataStorage: ProfileStorageManager) {
        self.GCDStorage = profileGCDStorage
        self.coreDataStorage = CoreDataStorage
        self.OperationStorage = OperationStorage
    }
    
    //MARK: - Save/load
    func save(profile: ProfileStorageModel,
              saveKind: ProfileSaveKind,
              completionHandler: @escaping (Bool) -> ()) {
        let manager = dataManager(with: saveKind)
        manager.save(profile: profile,
                     completionHandler: completionHandler)
        
    }
    
    func load(saveKind: ProfileSaveKind,
              completionHandler: @escaping (ProfileStorageModel?) -> ()) {
        let manager = dataManager(with: saveKind)
        manager.load(completionHandler: completionHandler)
    }
    
    private func dataManager(with kind: ProfileSaveKind) -> IProfileStorage {
        if kind == .GCD {
            return GCDStorage
        } else if kind == .Operation {
            return OperationStorage
        } else if kind == .CoreData{
            return coreDataStorage
        }
        return coreDataStorage
    }
    
    func saveWithGCD(profileStorageModel: ProfileStorageModel,
                     completionHandler: @escaping (Bool) -> Void) {
        GCDStorage.save(profile: profileStorageModel,
                        completionHandler: completionHandler)
    }
    
    func saveWithOperation(profileStorageModel: ProfileStorageModel,
                                completionHandler: @escaping (Bool) -> Void) {
        OperationStorage.save(profile: profileStorageModel,
                              completionHandler: completionHandler)
    }
    
    func loadWithGCD(completionHandler: @escaping (ProfileStorageModel?) -> Void) {
        GCDStorage.load(completionHandler: completionHandler)
    }
    
    func loadWithOperation(completionHandler: @escaping (ProfileStorageModel?) -> Void) {
        OperationStorage.load(completionHandler: completionHandler)
    }
}
