//
//  MessageCell.swift
//  TinkoffNew
//
//  Created by Dmitry Gachkovsky on 06/11/2017.
//  Copyright © 2017 Dmitry Gachkovsky. All rights reserved.
//

import UIKit

protocol MessageCellConfiguration: class {
    var textOfMessage: String? {get set}
}

class MessageCell: UITableViewCell, MessageCellConfiguration {
    
    enum MessageCellType {
        case incoming
        case outgoing
    }
    
    @IBOutlet private weak var messageLabel: UILabel!
    
    @IBOutlet private weak var messageContainerView: UIView! {
        didSet {
            messageContainerView.clipsToBounds = true
        }
    }
    
    var textOfMessage: String? {
        didSet {
            messageLabel.text = textOfMessage
        }
    }
    
    private static let defaultCornerRadius = 16.0
}
