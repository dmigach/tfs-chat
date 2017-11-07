//
//  ChatCell.swift
//  TinkoffNew
//
//  Created by Dmitry Gachkovsky on 03/11/2017.
//  Copyright © 2017 Dmitry Gachkovsky. All rights reserved.
//

import UIKit
import Foundation

//MARK: Protocols
protocol ChatCellConfiguration: class {
    var online: Bool { get set }
    var name: String? { get set }
    var date: String? { get set }
    var message: String? { get set }
    var hasUnreadMessages: Bool { get set }
    
    func configureCellAppearance()
}

//MARK: - ChatCell
class ChatCell: UITableViewCell {
    
    //MARK: - Outlets
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var messageLabel: UILabel!
    
    //MARK: - Constants
    private struct Constants {
        static let noMessagesText = "No messages yet"
        static let offileBackgroundColor: UIColor = .white
        static let onlineBackgroundColor: UIColor = .yellow
    }
    
    private struct Fonts {
        static let normalFont: UIFont = .systemFont(ofSize: 17)
        static let hasUnreadFont: UIFont = .boldSystemFont(ofSize: 17)
        static let noMessagesFont: UIFont = .italicSystemFont(ofSize: 17)
    }
    
    //MARK: - Properties
    var hasUnreadMessages: Bool = false
    
    var name: String? {
        didSet {
            nameLabel.text = name
        }
    }
    
    var date: String? {
        didSet {
            dateLabel.text = date
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
    
    var online: Bool = false {
        didSet {
            backgroundColor = online ? Constants.onlineBackgroundColor : Constants.offileBackgroundColor
        }
    }

    public static var identifier: String {
        return String(describing: self)
    }
}

//MARK: - ChatCellConfiguration
extension ChatCell: ChatCellConfiguration {
    func configureCellAppearance() {
        if self.message != nil {
            if self.hasUnreadMessages {
                self.messageLabel.font = Fonts.hasUnreadFont
            } else {
                self.messageLabel.font = Fonts.normalFont
            }
        } else {
            self.messageLabel.font = Fonts.noMessagesFont
        }
    }
}
