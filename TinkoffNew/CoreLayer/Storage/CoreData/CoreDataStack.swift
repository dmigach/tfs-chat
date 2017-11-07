//
//  CoreDataStack.swift
//  TinkoffNew
//
//  Created by Dmitry Gachkovsky on 07/11/2017.
//  Copyright © 2017 Dmitry Gachkovsky. All rights reserved.
//

import Foundation
import CoreData

//MARK: - Protocol
protocol ICoreDataStack: class {
    var saveContext: NSManagedObjectContext? { get }
    func performSave(context: NSManagedObjectContext,
                     completionHandler: @escaping (Bool)->() )
}

//MARK: - Class
class CoreDataStack: ICoreDataStack {
    
    private var storeURL: URL {
        get {
            let documentsDirURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let url = documentsDirURL.appendingPathComponent("TinkoffMes.sqlite")
            return url
        }
    }
    
    //MARK: - managedObjectModel
    private let managedObjectModelName = "TinkoffMes"
    private var _managedObjectModel: NSManagedObjectModel?
    private var managedObjectModel: NSManagedObjectModel? {
        get {
            if self._managedObjectModel == nil {
                guard let modelURL = Bundle.main.url(forResource: "TinkoffMes", withExtension: "momd") else {
                    return nil
                }
                
                self._managedObjectModel = NSManagedObjectModel(contentsOf: modelURL)
            }
            return self._managedObjectModel
        }
    }
    
    //MARK: - persistentStoreCoordinator
    private var _persistentStoreCoordinator: NSPersistentStoreCoordinator?
    private var persistentStoreCoordinator: NSPersistentStoreCoordinator? {
        get {
            if self._persistentStoreCoordinator == nil {
                guard let model = self.managedObjectModel else {
                    return nil
                }
                
                self._persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
                
                do {
                    try self._persistentStoreCoordinator?.addPersistentStore(ofType: NSSQLiteStoreType,
                                                                        configurationName: nil,
                                                                        at: self.storeURL,
                                                                        options: nil)
                } catch {
                    assertionFailure("Error adding persistent coordinator \(error)")
                }
            }
            return self._persistentStoreCoordinator
        }
    }

    //MARK: - masterContext
    private var _masterContext: NSManagedObjectContext?
    private var masterContext: NSManagedObjectContext? {
        get {
            if self._masterContext == nil {
                let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
                guard let persistentStoreCoordinator = self.persistentStoreCoordinator else {
                    print("Empty persistent store coordinator")
                    return nil
                }
                context.persistentStoreCoordinator = persistentStoreCoordinator
                context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
                context.undoManager = nil
                self._masterContext = context
            }
            return self._masterContext
        }
    }
    
    //MARK: - mainContext
    private var _mainContext: NSManagedObjectContext?
    private var mainContext: NSManagedObjectContext? {
        get {
            if self._mainContext == nil {
                let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
                guard let parentContext = self.masterContext else {
                    print("No master context")
                    return nil
                }
                context.parent = parentContext
                context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
                context.undoManager = nil
                self._mainContext = context
            }
            return self._mainContext
        }
    }
    
    //MARK: - saveContext
    public var _saveContext: NSManagedObjectContext?
    public var saveContext: NSManagedObjectContext? {
        get {
            if self._saveContext == nil {
                let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
                guard let parentContext = self.mainContext else {
                    print("No master context")
                    return nil
                }
                context.parent = parentContext
                context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
                context.undoManager = nil
                self._saveContext = context
            }
            return self._saveContext
        }
    }
    
    //MARK: - Save
    public func performSave(context: NSManagedObjectContext, completionHandler: @escaping (Bool)->() ) {
        if context.hasChanges {
            context.perform { [weak self] in
                do {
                    try context.save()
                } catch {
                    print("Context save error: \(error)")
                }
                if let parent = context.parent {
                    self?.performSave(context: parent, completionHandler: completionHandler)
                } else {
                    completionHandler(true)
                }
            }
        } else {
            completionHandler(true)
        }
    }
}
