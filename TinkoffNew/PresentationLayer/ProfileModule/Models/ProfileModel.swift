//
//  ProfileModel.swift
//  TinkoffNew
//
//  Created by Dmitry Gachkovsky on 04/11/2017.
//  Copyright © 2017 Dmitry Gachkovsky. All rights reserved.
//

import UIKit

enum ProfileSaveKind {
    case GCD
    case CoreData
    case Operation
}

protocol IProfileModel: class {
    var profileChanged: Bool { get }
    func update(with profile: ProfileViewModel)
    func saveProfile(saveKind: ProfileSaveKind,
                     completionHandler: @escaping (Bool) -> Void)
    func loadProfile(saveKind: ProfileSaveKind,
                     completionHandler: @escaping (ProfileViewModel) -> Void)
}

class ProfileModel: IProfileModel {
    
    var profileChanged: Bool {
        return changedProfile != currentProfile
    }
    private let profileStorageService: IProfileStorageService
    private var currentProfile: ProfileViewModel = ProfileViewModel.createDefaultProfile()
    private var changedProfile: ProfileViewModel = ProfileViewModel.createDefaultProfile()
    
    init(profileStorageService: IProfileStorageService) {
        self.profileStorageService = profileStorageService
    }
    
    func saveProfile(saveKind: ProfileSaveKind,
                     completionHandler: @escaping (Bool) -> ()) {
        let profileData = ProfileStorageModel(name: changedProfile.name,
                                              info: changedProfile.info,
                                              userPhoto: changedProfile.profilePhoto)
        
        profileStorageService.save(profile: profileData,
                                   saveKind: saveKind,
                                   completionHandler: completionHandler)
    }
    
    func loadProfile(saveKind: ProfileSaveKind,
                     completionHandler: @escaping (ProfileViewModel) -> ()) {
        profileStorageService.load(saveKind: saveKind) { (profileData) in
            if let profile = profileData {
                self.currentProfile = ProfileViewModel(name: profile.name,
                                                       info: profile.info,
                                                       profilePhoto: profile.userPhoto)
            } else {
                self.currentProfile = ProfileViewModel.createDefaultProfile()
            }
            self.changedProfile = self.currentProfile
            completionHandler(self.currentProfile)
        }
    }
    
    func update(with profile: ProfileViewModel) {
        self.changedProfile = profile
    }
}
