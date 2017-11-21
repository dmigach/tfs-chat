//
//  RequestFactory.swift
//  TinkoffNew
//
//  Created by Dmitry Gachkovsky on 19/11/2017.
//  Copyright © 2017 Dmitry Gachkovsky. All rights reserved.
//

import Foundation

struct RequestsFactory {
    
    struct PixabayRequests {
        static func randomImages() -> RequestConfig<[ImageModel]> {
            return RequestConfig<[ImageModel]>(request: PixabayRandomImagesRequest(),
                                               parser: PixabayImageParser())
        }
    }
}
