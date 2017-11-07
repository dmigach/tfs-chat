//
//  ProfileDisplayModel.swift
//  TinkoffNew
//
//  Created by Dmitry Gachkovsky on 04/11/2017.
//  Copyright © 2017 Dmitry Gachkovsky. All rights reserved.
//

import UIKit

struct ProfileViewModel {
    var name: String?
    var info: String?
    var profilePhoto: UIImage?
    
    static func createDefaultProfile() -> ProfileViewModel {
        let name = "Ivan Ivanov"
        let info = "Blah blah blah"
        return ProfileViewModel(name: name,
                                info: info,
                                profilePhoto: #imageLiteral(resourceName: "PhotoPlaceholder"))
    }
}

extension ProfileViewModel: Equatable {
    static func == (lhs: ProfileViewModel, rhs: ProfileViewModel) -> Bool {
        return lhs.name == rhs.name &&
            lhs.info == rhs.info &&
            lhs.profilePhoto == rhs.profilePhoto
    }
}
