//
//  Parser.swift
//  TinkoffNew
//
//  Created by Dmitry Gachkovsky on 19/11/2017.
//  Copyright © 2017 Dmitry Gachkovsky. All rights reserved.
//

import Foundation

protocol IModel {
    associatedtype Model
}

class Parser<T> {
    func parse(data: Data) -> T? { return nil }
}
