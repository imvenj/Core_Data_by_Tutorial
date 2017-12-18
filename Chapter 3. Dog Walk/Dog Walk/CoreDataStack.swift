//
//  CoreDataStack.swift
//  Dog Walk
//
//  Created by venj on 12/18/17.
//  Copyright © 2017 Razeware. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
  private let modelName: String
  init(modelName: String) {
    self.modelName = modelName
  }

  private lazy var storeContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: modelName)
    container.loadPersistentStores(completionHandler: { (storeDescriotion, error) in
      if let error = error as NSError? {
        print("Error loading persistent store: \(error), \(error.userInfo)")
      }
    })
    return container
  }()

  lazy var managedContext: NSManagedObjectContext = {
    return storeContainer.viewContext
  }()

  func saveContext() {
    guard managedContext.hasChanges else { return }
    do {
      try managedContext.save()
    } catch let error as NSError {
      print("Error saving data: \(error), \(error.userInfo)")
    }
  }
}
