//
//  AppDelegate.swift
//  TinkoffNew
//
//  Created by Dmitry Gachkovsky on 01/11/2017.
//  Copyright © 2017 Dmitry Gachkovsky. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let rootVC = window?.rootViewController as? UINavigationController
        
        if let chatsListViewController = rootVC?.topViewController as? ChatsListViewController {
            RootAssembly.chatsListAssembly.injectDependencies(to: chatsListViewController)
            return true
        } else {
            return false
        }
    }
}

