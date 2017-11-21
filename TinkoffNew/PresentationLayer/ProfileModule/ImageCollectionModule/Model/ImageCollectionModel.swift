//
//  ImageCollectionModel.swift
//  TinkoffNew
//
//  Created by Dmitry Gachkovsky on 19/11/2017.
//  Copyright © 2017 Dmitry Gachkovsky. All rights reserved.
//

import Foundation

struct CellDisplayModel {
    let imageURL: String
}

protocol IImageCollectionModel: class {
    func fetchImages()
    weak var delegate: IImageCollectionModelDelegate? { get set }
}

protocol IImageCollectionModelDelegate: class {
    func show(error: String)
    func setup(dataSource: [CellDisplayModel])
}

class ImageCollectionModel: IImageCollectionModel {
    
    let imagesService:  IImageLoadingService
    var delegate: IImageCollectionModelDelegate?
    
    init(imageService: IImageLoadingService) {
        self.imagesService = imageService
    }
    
    func fetchImages() {
        self.imagesService.loadImages {
            (apps: [ImageModel]?, error) in
            
            if let apps = apps {
                let cells = apps.map({ CellDisplayModel(imageURL: $0.imageURL) })
                self.delegate?.setup(dataSource: cells)
            } else {
                self.delegate?.show(error: error ?? "Error")
            }
        }
    }
}
