//
//  ChatsListViewController.swift
//  TinkoffNew
//
//  Created by Dmitry Gachkovsky on 01/11/2017.
//  Copyright © 2017 Dmitry Gachkovsky. All rights reserved.
//

import UIKit

class ChatsListViewController: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet private weak var tableView: UITableView!

    //MARK: - Properties
    private var model: IChatListModel!
    private let sectionTitles = ["Online", "History"]
    private var chats = [[ChatDisplayModel](), [ChatDisplayModel]()]
    
    private struct SegueIdentifiers {
        static let chat = "ShowChat"
        static let profile = "ShowProfile"
    }

    func inject(model: IChatListModel) {
        self.model = model
    }
    
    //MARK: VC Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        model.resumeListeningToCommunicationService()
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
        RootAssembly.profileAssembly.injectDependencies(to: profileVC)
    }
    
    private func prepareForChatSegue(to target: UIViewController) {
        guard let chatViewController = target as? ChatViewController else {
            return
        }
        guard let selectedIndexPath = tableView.indexPathForSelectedRow else {
            assertionFailure("Unknown segue destination view controller")
            return
        }
        let choosedChat = self.getChat(at: selectedIndexPath)
        RootAssembly.chatAssembly.assembly(chatViewController: chatViewController,
                                                   chat: choosedChat)
        tableView.deselectRow(at: selectedIndexPath, animated: true)
    }
    
    //MARK: - Helpers
    func getChat(at indexPath: IndexPath) -> ChatDisplayModel {
        return chats[indexPath.section][indexPath.row]
    }
}

//MARK: - UITableViewDataSource
extension ChatsListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ChatCell.identifier, for: indexPath)
        
        guard let chatCell = cell as? ChatCell else {
            return cell
        }
        
        let chat = self.getChat(at: indexPath)
        chatCell.name = chat.userName
        chatCell.online = chat.isOnline
        chatCell.configureCellAppearance()
        chatCell.date = chat.lastMessageDate
        chatCell.message = chat.messages.last?.text
        chatCell.hasUnreadMessages = chat.hasUnreadMessages
        
        return chatCell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return chats.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats[section].count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
}

//MARK: - IChatListModelDelegate
extension ChatsListViewController: IChatListModelDelegate {
    func setup(dataSource: [ChatDisplayModel]) {
        let onlineChats = dataSource.filter { $0.isOnline }.sort()
        let offlineChats = dataSource.filter { !$0.isOnline }.sort()
        chats = [onlineChats, offlineChats]
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}


