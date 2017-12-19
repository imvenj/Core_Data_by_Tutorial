//
//  File.swift
//  CampgroundManagerTests
//
//  Created by venj on 12/19/17.
//  Copyright © 2017 Razeware. All rights reserved.
//

import Foundation
import CoreData
import CampgroundManager

class TestCoreDataStack : CampgroundManager.CoreDataStack {
  convenience init() {
    self.init(modelName: "CampgroundManager")
  }

  override init(modelName: String) {
    super.init(modelName: modelName)
    let description = NSPersistentStoreDescription()
    description.type = NSInMemoryStoreType

    let container = NSPersistentContainer(name: modelName)
    container.persistentStoreDescriptions = [description]
    container.loadPersistentStores { (description, error) in
      if let error = error as NSError? {
        fatalError("Unresolved error: \(error), \(error.userInfo)")
      }
      self.storeContainer = container
    }

  }

}
