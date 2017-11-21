//
//  ChatsListViewController.swift
//  TinkoffNew
//
//  Created by Dmitry Gachkovsky on 01/11/2017.
//  Copyright © 2017 Dmitry Gachkovsky. All rights reserved.
//

import UIKit

class ChatsListViewController: UIViewController, IChatsListModelDelegate {
    
    //MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!

    //MARK: - Properties
    private var model: IChatListModel!
    private var profileAssembler: ProfileAssembly?
    private var chatAssembler: ChatAssembly?
    
    private struct SegueIdentifiers {
        static let chat = "ShowChat"
        static let profile = "ShowProfile"
    }

    func inject(model: IChatListModel,
                chatAssembler: ChatAssembly,
                profileAssembler: ProfileAssembly) {
        self.model = model
        self.chatAssembler = chatAssembler
        self.profileAssembler = profileAssembler
    }
    
    //MARK: VC Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.model.delegate = self
        self.tableView.dataSource = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        model.relaunchCommunication()
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case SegueIdentifiers.profile?:
            prepareForProfileSegue(to: segue.destination)
        case SegueIdentifiers.chat?:
            prepareForChatSegue(to: segue.destination)
        default:
            assertionFailure("Unknown segue identifier")
        }
    }
    
    private func prepareForProfileSegue(to target: UIViewController) {
        guard let navigationVC = target as? UINavigationController,
                let profileVC = navigationVC.topViewController as? ProfileViewController else { return }
        
        if let profileAssembly = self.profileAssembler {
            profileAssembly.injectDependencies(to: profileVC)
        }
    }
    
    private func prepareForChatSegue(to target: UIViewController) {
        guard let chatViewController = target as? ChatViewController else {
            return
        }
        guard let selectedIndexPath = tableView.indexPathForSelectedRow else {
            assertionFailure("Unknown segue destination view controller")
            return
        }
        let choosedChat = model.getChat(at: selectedIndexPath)
        if let id = choosedChat.chatID {
            if let chatAssembly = self.chatAssembler {
                chatAssembly.assembly(chatViewController: chatViewController,
                                      chatID: id)
            }
        }
        tableView.deselectRow(at: selectedIndexPath, animated: true)
    }
}

//MARK: - UITableViewDataSource
extension ChatsListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ChatCell.identifier, for: indexPath)
        
        guard let chatCell = cell as? ChatCell else {
            return cell
        }
        
        if let chat = model?.getChat(at: indexPath) {
            chat.configureChatCell(cell: chatCell)
            chatCell.configureCellAppearance()
        }
        return chatCell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if let number = model?.getNumberOfSections() {
            return number
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let number = model?.getNumberOfRowsIn(section: section) {
            return number
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return model.getTitleForSection(section: section)
    }
}
