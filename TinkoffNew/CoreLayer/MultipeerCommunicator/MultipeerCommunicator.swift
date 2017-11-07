//
//  MultipeerCommunicator.swift
//  TinkoffNew
//
//  Created by Dmitry Gachkovsky on 02/11/2017.
//  Copyright © 2017 Dmitry Gachkovsky. All rights reserved.
//

import MultipeerConnectivity

//MARK: - Protocols
protocol ICommunicator: class {
    weak var delegate: ICommunicatorDelegate? { get set }
    func sendMessage(text: String, to userID: String, completionHandler: ((_ success: Bool, _ error: Error?) -> Void)?)
}

protocol ICommunicatorDelegate: class {
    //Discovering
    func lostUser(userID: String)
    func foundUser(userID: String, userName: String?)
    
    //Errors
    func failedToStartAdvertising(error: Error)
    func failedToStartBrowsingForUsers(error: Error)
    
    //Messages
    func receivedMessage(text: String, fromUser sender: String, toUser receiver: String)
}

//MARK: - MultipeerCommunicator
class MultipeerCommunicator: NSObject {
    
    //MARK: - Constants
    private struct ConnectivityConstants {
        static let timeout: TimeInterval = 30
        static let serviceType = "tinkoff-chat"
        static let discoveryInfoUserNameKey = "userName"
        static let discoveryInfo = [discoveryInfoUserNameKey: UIDevice.current.name]
        static let myPeerID = MCPeerID(displayName: String(describing: UIDevice.current.identifierForVendor))
    }
    
    //MARK: - Properties
    weak var delegate: ICommunicatorDelegate?
    
    private let messageConverter: IMessageConverter
    private let serviceBrowser: MCNearbyServiceBrowser
    private let serviceAdvertiser: MCNearbyServiceAdvertiser
    
    private var sessionList = [MCPeerID: MCSession]()
    private var peersInfo = [MCPeerID: [String: String]?]()
    
    
    //MARK: - Init
    init(_ messageConverter: IMessageConverter) {
        self.messageConverter = messageConverter
        self.serviceBrowser = MCNearbyServiceBrowser(peer: ConnectivityConstants.myPeerID,
                                                     serviceType: ConnectivityConstants.serviceType)
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: ConnectivityConstants.myPeerID,
                                                           discoveryInfo: ConnectivityConstants.discoveryInfo,
                                                           serviceType: ConnectivityConstants.serviceType)
        super.init()
        
        self.serviceBrowser.delegate = self
        self.serviceAdvertiser.delegate = self
        
        
        self.startServices()
    }
    
    deinit {
        self.stopServices()
    }
    
    private func startServices() {
        serviceBrowser.startBrowsingForPeers()
        serviceAdvertiser.startAdvertisingPeer()
    }
    
    private func stopServices() {
        serviceBrowser.stopBrowsingForPeers()
        serviceAdvertiser.stopAdvertisingPeer()
    }
    
    //MARK: - Multipeer Helpers
    private func getSessionForUser(with peerID: MCPeerID) -> MCSession? {
        return sessionList[peerID]
    }
    
    private func createNewSession(with peerID: MCPeerID) -> MCSession {
        let session = MCSession(peer: ConnectivityConstants.myPeerID,
                                securityIdentity: nil,
                                encryptionPreference: .none)
        session.delegate = self
        sessionList[peerID] = session
        return session
    }
    
    private func getPeerIDFor(_ userID: String) -> MCPeerID? {
        return sessionList.keys.filter { $0.displayName == userID }.first
    }
}

// MARK: - ICommunicator
extension MultipeerCommunicator: ICommunicator {
    
    enum MultipeerCommunicatorError: Error {
        case peerSessionError
        case serializationError
    }
    
    func sendMessage(text: String, to userID: String, completionHandler: ((_ success: Bool, _ error: Error?) -> Void)?) {
        guard let peerID = getPeerIDFor(userID), let session = sessionList[peerID] else {
            completionHandler?(false, MultipeerCommunicatorError.peerSessionError)
            return
        }
        
        guard let encodedMessage = messageConverter.getDataForSending(message: text) else {
            completionHandler?(false, MultipeerCommunicatorError.serializationError)
            return
        }
        
        do {
            try session.send(encodedMessage, toPeers: [peerID], with: .reliable)
            completionHandler?(true, nil)
        } catch {
            completionHandler?(false, error)
        }
    }
}

// MARK: MCNearbyServiceAdvertiserDelegate
extension MultipeerCommunicator: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        let session = getSessionForUser(with: peerID) ?? createNewSession(with: peerID)
        invitationHandler(true, session)
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        delegate?.failedToStartAdvertising(error: error)
    }
}

// MARK: - MCNearbyServiceBrowserDelegate
extension MultipeerCommunicator: MCNearbyServiceBrowserDelegate {
    
    func browser(_ browser: MCNearbyServiceBrowser,
                 foundPeer peerID: MCPeerID,
                 withDiscoveryInfo info: [String: String]?) {
        
        peersInfo[peerID] = info
        let session = getSessionForUser(with: peerID) ?? createNewSession(with: peerID)
        
        browser.invitePeer(peerID,
                           to: session,
                           withContext: nil,
                           timeout: ConnectivityConstants.timeout)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        if sessionList.removeValue(forKey: peerID) != nil {
            delegate?.lostUser(userID: peerID.displayName)
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        delegate?.failedToStartBrowsingForUsers(error: error)
    }
}

// MARK: MCSessionDelegate
extension MultipeerCommunicator: MCSessionDelegate {
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        guard let message = messageConverter.getMessageText(from: data) else {
            //TODO There is a print instead assertion cause it's pretty probable that someone may try to send bad message
            print("Bad message came from \(peerID.displayName)")
            return
        }
        delegate?.receivedMessage(text: message,
                                    fromUser: peerID.displayName,
                                    toUser: ConnectivityConstants.myPeerID.displayName)
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            if let peerDiscoveryInfo = peersInfo[peerID] {
                delegate?.foundUser(userID: peerID.displayName,
                                    userName: peerDiscoveryInfo?[ConnectivityConstants.discoveryInfoUserNameKey])
            }
        case .notConnected:
            if sessionList.removeValue(forKey: peerID) != nil {
                delegate?.lostUser(userID: peerID.displayName)
            }
            peersInfo.removeValue(forKey: peerID)
            session.disconnect()
        case .connecting:
            print("connecting to \(peerID.displayName)")
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
}
