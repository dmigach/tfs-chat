//
//  RequestSender.swift
//  TinkoffNew
//
//  Created by Dmitry Gachkovsky on 19/11/2017.
//  Copyright © 2017 Dmitry Gachkovsky. All rights reserved.
//

import Foundation


protocol IRequestSender {
    func send<T>(config: RequestConfig<T>,
                 completionHandler: @escaping (Result<T>) -> Void)
}

struct RequestConfig<Model> {
    let request: IRequest
    let parser: Parser<Model>
}

enum Result<T> {
    case success(T)
    case fail(String)
}

class RequestSender: IRequestSender {
    
    let session = URLSession.shared
    
    func send<T>(config: RequestConfig<T>,
                 completionHandler: @escaping (Result<T>) -> Void) {
        
        guard let urlRequest = config.request.urlRequest else {
            completionHandler(Result.fail("url string can't be converted to URL"))
            return
        }
        
        let task = session.dataTask(with: urlRequest) { (data: Data?, response: URLResponse?, error: Error?) in
            if let error = error {
                completionHandler(Result.fail(error.localizedDescription))
                return
            }
            guard let data = data,
                let parsedModel: T = config.parser.parse(data: data) else {
                    completionHandler(Result.fail("recieved data can't be parsed"))
                    return
            }
            completionHandler(Result.success(parsedModel))
        }
        task.resume()
    }
}
