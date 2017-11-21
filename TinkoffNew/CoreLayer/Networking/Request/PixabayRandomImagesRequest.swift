//
//  PixabayRandomImagesRequest.swift
//  TinkoffNew
//
//  Created by Dmitry Gachkovsky on 19/11/2017.
//  Copyright © 2017 Dmitry Gachkovsky. All rights reserved.
//

import Foundation

class PixabayRandomImagesRequest: IRequest {
    private struct PixaBayRequestParts {
        static let baseUrl: String = "https://pixabay.com/api/"
        static let apiKey: String = "7100407-b360b970d4a42d896913adfeb"
        static let perPage: String = "200"
    }
    
    var urlRequest: URLRequest? {
        let urlString: String = "\(PixaBayRequestParts.baseUrl)?key=\(PixaBayRequestParts.apiKey)&per_page=\(PixaBayRequestParts.perPage)"
        if let url = URL(string: urlString) {
            return URLRequest(url: url)
        }
        return nil
    }
}
