//
//  PixabayImageParser.swift
//  TinkoffNew
//
//  Created by Dmitry Gachkovsky on 19/11/2017.
//  Copyright © 2017 Dmitry Gachkovsky. All rights reserved.
//

import Foundation

struct ImageModel {
    let imageURL: String
}

class PixabayImageParser: Parser<[ImageModel]> {
    typealias Model = [ImageModel]
    override func parse(data: Data) -> Model? {
        
        var imageModels = Model()
        
        do {
            if let imagesListJson = try JSONSerialization.jsonObject(with: data,
                                                                     options: []) as? [String: Any] {
                guard let hits = imagesListJson["hits"] as? [Any] else { return nil }
                
                for element in hits {
                    if let dictionary = element as? [String: Any] {
                        if let webformatURL = dictionary["webformatURL"] as? String {
                            imageModels.append(ImageModel(imageURL: webformatURL))
                        }
                    }
                }
                return imageModels
            }
        } catch {
            print("error in converting the data to JSON")
        }
        return imageModels
    }
}
