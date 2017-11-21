//
//  RequestSender.swift
//  TinkoffNew
//
//  Created by Dmitry Gachkovsky on 19/11/2017.
//  Copyright © 2017 Dmitry Gachkovsky. All rights reserved.
//

import Foundation

struct RequestConfig<T> {
    let request: IRequest
    let parser: Parser<T>
}

enum Result<T> {
    case Success(T)
    case Fail(String)
}

protocol IRequestSender {
    func send<T>(config: RequestConfig<T>, completionHandler: @escaping (Result<T>) -> Void)
}

class RequestSender: IRequestSender {
    
    let session = URLSession.shared
    
    func send<T>(config: RequestConfig<T>, completionHandler: @escaping (Result<T>) -> Void) {
        
        guard let urlRequest = config.request.urlRequest else {
            completionHandler(Result.Fail("url string can't be parser to URL"))
            return
        }
        
        let task = session.dataTask(with: urlRequest) { (data: Data?, response: URLResponse?, error: Error?) in
            if let error = error {
                completionHandler(Result.Fail(error.localizedDescription))
                return
            }
            guard let data = data,
                let parsedModel: T = config.parser.parse(data: data) else {
                    completionHandler(Result.Fail("recieved data can't be parsed"))
                    return
            }
            
            completionHandler(Result.Success(parsedModel))
        }
        
        task.resume()
    }
}
