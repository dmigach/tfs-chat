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
    private struct SegueIdentifiers {
        static let profileSegue = "ShowProfile"
        static let conversationSegue = "ShowChat"
    }
    
    private var model: IChatListModel!
    private let sectionTitles = ["Online", "History"]
    private var chats = [[ChatDisplayModel](), [ChatDisplayModel]()]
    
    func getConversation(at indexPath: IndexPath) -> ChatDisplayModel {
        return chats[indexPath.section][indexPath.row]
    }

    // MARK: Dependency injection
    
    func setDependencies(_ model: IChatListModel) {
        self.model = model
    }
    
    // MARK: View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        assertDependencies()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        model.resumeListeningToCommunicationService()
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case SegueIdentifiers.profileSegue?:
            handleProfileSegue(with: segue.destination)
        case SegueIdentifiers.conversationSegue?:
            handleConversationSegue(with: segue.destination)
        default:
            assertionFailure("Unknown segue identifier")
        }
    }
    
    private func handleProfileSegue(with destination: UIViewController) {
//        guard
//            let containerViewController = destination as? UINavigationController,
//            let profileViewController = containerViewController.topViewController as? ProfileViewController else {
//                assertionFailure("Unknown segue destination view controller")
//                return
//        }
//        RootAssembly.profileAssembly.assembly(profileViewController)
    }
    
    private func handleConversationSegue(with destination: UIViewController) {
//        guard let conversationViewController = destination as? ConversationViewController else {
//            return
//        }
//        guard let selectedIndexPath = tableView.indexPathForSelectedRow else {
//            assertionFailure("Unknown segue destination view controller")
//            return
//        }
//        let selectedConversation = tableDataSource.conversation(for: selectedIndexPath)
//        RootAssembly.conversationAssembly.assembly(conversationViewController,
//                                                   conversation: selectedConversation)
//        tableView.deselectRow(at: selectedIndexPath, animated: true)
    }
    
//    @IBAction func unwindToConversationsList(sender: UIStoryboardSegue) { }
    
    // MARK: Private methods
    
//    private func assertDependencies() {
//        assert(tableDataSource != nil && tableDelegate != nil && model != nil)
//    }
}

//MARK: - UITableViewDelegate
extension ChatsListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let conversationCell = cell as? ChatCellConfiguration else {
            assertionFailure("Wrong cell type in ConversationListViewController")
            return
        }
        conversationCell.applyFontStyle()
    }
}

//MARK: - UITableViewDataSource
extension ChatsListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChatCell.identifier, for: indexPath)
        guard let conversationCell = cell as? ChatCellConfiguration & UITableViewCell else {
            assertionFailure("Wrong cell type in ConversationsListViewController")
            return cell
        }
        let conversation = self.getConversation(at: indexPath)
        conversationCell.name = conversation.userName
        conversationCell.message = conversation.messages.last?.text
        conversationCell.date = conversation.lastMessageDate
        conversationCell.online = conversation.isOnline
        conversationCell.hasUnreadMessages = conversation.hasUnreadMessages
        
        return conversationCell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats[section].count
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return chats.count
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


