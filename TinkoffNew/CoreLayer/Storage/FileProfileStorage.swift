//
//  FileProfileStorage.swift
//  TinkoffNew
//
//  Created by Dmitry Gachkovsky on 04/11/2017.
//  Copyright © 2017 Dmitry Gachkovsky. All rights reserved.
//

import UIKit

//MARK: - Protocol
protocol IProfileConverter: class {
    func save(profile: ProfileStorageModel)
    func loadProfile() -> ProfileStorageModel?
}

//MARK: - Class
class FileProfileStorage: IProfileConverter {

    //MARK: - Static properties
    private static let nameKey = "name"
    private static let infoKey = "info"
    private static let fileName = "Profile"
    private static let userPhotoKey = "userPhoto"
    
    //MARK: - Properties
    private var filePath: URL {
        return fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(FileProfileStorage.fileName)
    }
    private let fileManager = FileManager.default

    //MARK: - Save/load
    func save(profile: ProfileStorageModel) {
        let dataDictionary = serialize(profile)
        let data = NSKeyedArchiver.archivedData(withRootObject: dataDictionary)
        do {
            try data.write(to: filePath)
        } catch {
            print("Error writing data \(error)")
        }
    }
    
    func loadProfile() -> ProfileStorageModel? {
        guard fileManager.fileExists(atPath: filePath.path) else {
            return nil
        }
        do {
            let data = try Data(contentsOf: filePath)
            let profile = try deserialize(from: data)
            return profile
        } catch {
            print("Error loading data from file \(error)")
        }
        return nil
    }
    
    //MARK: - Serialization
    private func serialize(_ profile: ProfileStorageModel) -> [String: Any] {
        let userPhotoData = NSKeyedArchiver.archivedData(withRootObject: profile.userPhoto ?? #imageLiteral(resourceName: "PhotoPlaceholder"))
        return [FileProfileStorage.userPhotoKey: userPhotoData,
                FileProfileStorage.nameKey: profile.name ?? "",
                FileProfileStorage.infoKey: profile.info ?? ""]
    }
    
    private func deserialize(from data: Data) throws -> ProfileStorageModel? {
        guard let dictionary = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String: Any],
            let name = dictionary[FileProfileStorage.nameKey] as? String,
            let userInfo = dictionary[FileProfileStorage.infoKey] as? String,
            let userPhotoData = dictionary[FileProfileStorage.userPhotoKey] as? Data,
            let userPhoto = NSKeyedUnarchiver.unarchiveObject(with: userPhotoData) as? UIImage
            else { return nil }
        return ProfileStorageModel(name: name, info: userInfo, userPhoto: userPhoto)
    }
}
