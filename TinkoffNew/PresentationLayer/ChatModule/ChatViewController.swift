//
//  ChatViewController.swift
//  TinkoffNew
//
//  Created by Dmitry Gachkovsky on 06/11/2017.
//  Copyright © 2017 Dmitry Gachkovsky. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController {

    //MARK: - Outlets
    @IBOutlet internal weak var tableView: UITableView!
    @IBOutlet private weak var sendButton: UIButton! {
        didSet {
            sendButton.isEnabled = true
        }
    }
    @IBOutlet private weak var messageTextView: UITextView!
    @IBOutlet private weak var bottomConstraint: NSLayoutConstraint!

    
    //MARK: - Action
    @IBAction private func sendButtonAction(_ sender: UIButton) {
        messageTextView.text = messageTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        model.send(message: messageTextView.text) {
            DispatchQueue.main.async {
                self.messageTextView.text = ""
                self.sendButton.isEnabled = false
            }
        }
    }

    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    //MARK: - Properties
    private var model: IChatModel!
    var userIsOnline: Bool = true {
        didSet {
            changeSendButtonState(flag: userIsOnline)
        }
    }

    // MARK: View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        setupMessageTextView()
        self.model.delegate = self
        sendButton.isEnabled = false
        messageTextView.delegate = self
        registerForKeyboardNotifications()
        configureTitle(with: model.userName)
        self.userIsOnline = model.chatOnline
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        model.markChatAsRead()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        scrollToBottom()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        tableView.reloadData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Dependency injection
    func injectDependencies(model: IChatModel) {
        self.model = model
    }
    
    // MARK: UI
    private func setupMessageTextView() {
        self.messageTextView.layer.borderWidth = 1
        self.messageTextView.layer.cornerRadius = 10
        self.messageTextView.layer.borderColor = UIColor.black.cgColor
    }
    
    private func changeSendButtonState(flag: Bool) {
        DispatchQueue.main.async {
            let conditionToEnableButton = self.userIsOnline && self.messageTextView != nil && self.messageTextView.text != ""
            let currentButtonStateDiffers = self.sendButton.isEnabled != conditionToEnableButton
            if currentButtonStateDiffers {
                self.sendButton.isEnabled = flag
            }
        }
    }

    private func configureTitle(with userName: String) {
        navigationItem.title = userName
    }
    
    private func configureTableView() {
        tableView.dataSource = self
    }
    
    private func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(moveScreen(_:)),
                                               name: .UIKeyboardWillChangeFrame, object: nil)
    }
    
    private func scrollToBottom() {
        DispatchQueue.main.async {
            let numberOfSections = self.tableView.numberOfSections
            let numberOfRows = self.tableView.numberOfRows(inSection: numberOfSections - 1)
            if numberOfRows > 0 {
                let indexPath = IndexPath(row: numberOfRows - 1, section: (numberOfSections - 1))
                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
    }
    
    @objc private func moveScreen(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            let duration: TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
            let animationCurveRawNSNumber = userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber
            let animationCurveRaw = animationCurveRawNSNumber.uintValue
            let animationCurve = UIViewAnimationOptions(rawValue: animationCurveRaw)
            if endFrame.origin.y >= UIScreen.main.bounds.height {
                bottomConstraint.constant = 0.0
            } else {
                bottomConstraint.constant = endFrame.size.height
            }
            view.layoutIfNeeded()
            UIView.animate(withDuration: duration,
                           delay: 0,
                           options: animationCurve,
                           animations: { self.view.layoutIfNeeded() },
                           completion: { _ in self.scrollToBottom() }
            )}
    }
}

// MARK: - IChatModelDelegate
extension ChatViewController: IChatModelDelegate {
    func userChangedStatusTo(online: Bool) {
        self.userIsOnline = false
    }
}

// MARK: - UITableViewDataSource
extension ChatViewController: UITableViewDataSource {
    private struct CellIdentifier {
        static let incomingCellIdentifier = "IncomingCell"
        static let outgoingCellIdentifier = "OutgoingCell"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.getNumberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = model.getMessage(at: indexPath)
        
        let identifier = message.type == .incoming ? CellIdentifier.incomingCellIdentifier : CellIdentifier.outgoingCellIdentifier
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        
        guard let messageCell = cell as? MessageCellConfiguration & UITableViewCell else {
            assertionFailure("Wrong cell type")
            return cell
        }
        
        messageCell.textOfMessage = message.text
        return cell
    }
}

extension ChatViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if let text = textView.text {
            let allowSend = text != "" && userIsOnline
            changeSendButtonState(flag: allowSend)
        }
    }
}
