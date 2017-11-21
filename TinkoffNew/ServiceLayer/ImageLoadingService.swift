//
//  ImageLoadingService.swift
//  TinkoffNew
//
//  Created by Dmitry Gachkovsky on 19/11/2017.
//  Copyright © 2017 Dmitry Gachkovsky. All rights reserved.
//

import Foundation

protocol IImageLoadingService {
    func loadImages(completionHandler: @escaping ([ImageModel]?, String?) -> Void)
}

class ImageLoadingService: IImageLoadingService {
    
    let requestSender: IRequestSender
    
    init(requestSender: IRequestSender) {
        self.requestSender = requestSender
    }
    
    func loadImages(completionHandler: @escaping ([ImageModel]?, String?) -> Void) {
        let requestConfig: RequestConfig<[ImageModel]> = RequestsFactory.PixabayRequests.randomImages()
        
        requestSender.send(config: requestConfig) { (result: Result<[ImageModel]>) in
            switch result {
            case .success(let tracks):
                completionHandler(tracks, nil)
            case .fail(let error):
                completionHandler(nil, error)
            }
        }
    }
}
