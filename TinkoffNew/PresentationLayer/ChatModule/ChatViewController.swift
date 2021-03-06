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
            changeSendButtonState(flag: true)
        }
    }
    @IBOutlet private weak var messageTextView: UITextView!
    @IBOutlet private weak var bottomConstraint: NSLayoutConstraint!

    
    //MARK: - Actions
    @IBAction private func sendButtonAction(_ sender: UIButton) {
        messageTextView.text = messageTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        model.send(message: messageTextView.text) {
            DispatchQueue.main.async {
                self.messageTextView.text = ""
                self.changeSendButtonState(flag: false)
            }
        }
    }

    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    //MARK: - Properties
    var titleLabel: UILabel?
    private var model: IChatModel!
    var userIsOnline: Bool = true {
        didSet {
            changeSendButtonState(flag: userIsOnline)
            changeTitleState(flag: userIsOnline)
        }
    }

    // MARK: View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        setupMessageTextView()
        self.model.delegate = self
        messageTextView.delegate = self
        sendButton.isEnabled = false
        registerForKeyboardNotifications()
        self.userIsOnline = model.chatOnline
        configureTitle(with: model.userName)
        self.sendButton.backgroundColor = UIColor.lightGray
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        model.markChatAsRead()
        changeTitleState(flag: model.chatOnline)
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
                let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
                let normalScale = 1.0
                let enlargedScale = 1.15
                scaleAnimation.values = [normalScale, enlargedScale, normalScale]
                
                let colorAnimation = CABasicAnimation(keyPath: "backgroundColor")
                self.sendButton.backgroundColor = conditionToEnableButton ? UIColor.init(red: 36/255,
                                                                                         green: 113/255,
                                                                                         blue: 250/255,
                                                                                         alpha: 1) : UIColor.lightGray
                
                let animationGroup = CAAnimationGroup()
                animationGroup.duration = 0.5
                animationGroup.animations = [scaleAnimation, colorAnimation]
                self.sendButton.layer.add(animationGroup, forKey: "animationGroup")

                self.sendButton.isEnabled = flag
            }
        }
    }
    
    private func changeTitleState(flag: Bool) {
        let color = flag ? UIColor.init(red: 85/255, green: 177/255, blue: 114/255, alpha: 1) : UIColor.black
        let scale: CGFloat = flag ? 1.1 : 1.0
        
        DispatchQueue.main.async {
            if let title = self.titleLabel {
                UIView.transition(with: title,
                                  duration: 1,
                                  options: .transitionCrossDissolve,
                                  animations: {
                                    title.transform = CGAffineTransform(scaleX: scale, y: scale)
                                    title.textColor = color
                },
                                  completion: nil)
            }
        }
    }

    private func configureTitle(with userName: String) {
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
        titleLabel.text = userName
        titleLabel.textAlignment = .center
        navigationItem.titleView = titleLabel
        self.titleLabel = titleLabel
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
        self.userIsOnline = online
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
