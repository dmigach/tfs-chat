//
//  ChatCell.swift
//  TinkoffNew
//
//  Created by Dmitry Gachkovsky on 03/11/2017.
//  Copyright © 2017 Dmitry Gachkovsky. All rights reserved.
//

import Foundation
import UIKit


//MARK: Protocols
protocol ChatCellConfiguration: class {
    var name: String? { get set }
    var message: String? { get set }
    var date: String? { get set }
    var online: Bool { get set }
    var hasUnreadMessages: Bool { get set }
    
    func applyFontStyle()
}

//MARK: ChatCell
class ChatCell: UITableViewCell, ChatCellConfiguration {
    
    //MARK: - Outlets
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    
    //MARK: - Properties
    private struct Constants {
        static let noMessagesText = "No messages yet"
        static let onlineBackgroundColor: UIColor = .yellow
        static let offileBackgroundColor: UIColor = .white
    }
    
    var name: String? {
        didSet {
            nameLabel.text = name
        }
    }
    
    var message: String? {
        didSet {
            if message != nil {
                messageLabel.text = message
            } else {
                messageLabel.text = Constants.noMessagesText
            }
        }
    }
    
    var date: String? {
        didSet {
            dateLabel.text = date
        }
    }
    
    var online: Bool = false {
        didSet {
            backgroundColor = online ? Constants.onlineBackgroundColor : Constants.offileBackgroundColor
        }
    }
    
    var hasUnreadMessages: Bool = false
    
    public static var identifier: String {
        return String(describing: self)
    }
    
    func applyFontStyle() {
        if message != nil {
            if hasUnreadMessages {
                messageLabel.font = .boldSystemFont(ofSize: messageLabel.font.pointSize)
            } else {
                messageLabel.font = .systemFont(ofSize: messageLabel.font.pointSize)
            }
        } else {
            messageLabel.font = .italicSystemFont(ofSize: messageLabel.font.pointSize)
        }
    }
}
