//
//  Array+Extension.swift
//  TinkoffNew
//
//  Created by Dmitry Gachkovsky on 03/11/2017.
//  Copyright © 2017 Dmitry Gachkovsky. All rights reserved.
//

import Foundation

extension Array where Element:ChatDisplayModel {
    func sort() -> [ChatDisplayModel] {
        let chatsWithMessage =
            self.filter { $0.lastMessageDate != nil }.sorted { $0.lastMessageDate! > $1.lastMessageDate! }
        let emptyChats =
            self.filter { $0.lastMessageDate == nil }.sorted { $0.userName > $1.userName }
        return chatsWithMessage + emptyChats
    }
}
