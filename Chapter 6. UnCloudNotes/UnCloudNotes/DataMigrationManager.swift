//
//  File.swift
//  UnCloudNotes
//
//  Created by venj on 12/19/17.
//  Copyright © 2017 Ray Wenderlich. All rights reserved.
//

import Foundation
import CoreData

class DataMigrationManager {
  let enableMigrations: Bool
  let modelName: String
  let storeName: String = "UnCloudNotesDataModel"
  var stack: CoreDataStack {
    guard enableMigrations, !store(at: storeURL, isCompatibleWithModel: currentModel)
      else { return CoreDataStack(modelName: modelName) }
    performMigration()
    return CoreDataStack(modelName: modelName)
  }

  init(modelName: String, enableMigrations: Bool = false) {
    self.modelName = modelName
    self.enableMigrations = enableMigrations
  }

  private func store(at storeURL: URL, isCompatibleWithModel model: NSManagedObjectModel) -> Bool {
    let storeMetadata = metadataForStoreAtURL(storeURL: storeURL)
    return model.isConfiguration(withName: nil, compatibleWithStoreMetadata: storeMetadata)
  }

  private func metadataForStoreAtURL(storeURL: URL) -> [String : Any] {
    let metadata: [String: Any]

    do {
      metadata = try NSPersistentStoreCoordinator.metadataForPersistentStore(ofType: NSSQLiteStoreType, at: storeURL, options: nil)
    } catch let error {
      metadata = [:]
      print("Error fetching metadata: \(error.localizedDescription)")
    }

    return metadata
  }

  private var applicationSupportURL: URL {
    let path = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true) .first
    return URL(fileURLWithPath: path!)
  }

  private lazy var storeURL: URL = {
    let storeFileName = "\(self.storeName).sqlite"
    return URL(fileURLWithPath: storeFileName, relativeTo: self.applicationSupportURL)
  }()


  private var storeModel: NSManagedObjectModel? {
    return NSManagedObjectModel.modelVersionsFor(modelNamed: modelName).filter { self.store(at: storeURL, isCompatibleWithModel: $0) }.first
  }

  private lazy var currentModel: NSManagedObjectModel = NSManagedObjectModel.model(named: self.modelName)

  func performMigration() {
    if !currentModel.isVersion4 {
      //fatalError("Can only handle migrations to version 4!")
      return
    }
    if let storeModel = self.storeModel {
      if storeModel.isVersion1 {
        let destinationModel = NSManagedObjectModel.version2
        migrateStoreAt(URL: storeURL, fromModel: storeModel, toModel: destinationModel)
        performMigration()
      }
      else if storeModel.isVersion2 {
        let destinationModel = NSManagedObjectModel.version3
        let mappingModel = NSMappingModel(from: nil, forSourceModel: storeModel, destinationModel: destinationModel)
        migrateStoreAt(URL: storeURL, fromModel: storeModel,toModel: destinationModel,
                       mappingModel: mappingModel)
        performMigration()
      }
      else if storeModel.isVersion3 {
        let destinationModel = NSManagedObjectModel.version4
        let mappingModel = NSMappingModel(from: nil, forSourceModel: storeModel, destinationModel: destinationModel)
        migrateStoreAt(URL: storeURL, fromModel: storeModel, toModel: destinationModel, mappingModel: mappingModel)
      }
    }
  }


  private func migrateStoreAt(URL storeURL: URL, fromModel from: NSManagedObjectModel, toModel to: NSManagedObjectModel, mappingModel: NSMappingModel? = nil) {
    // 1
    let migrationManager = NSMigrationManager(sourceModel: from, destinationModel: to)
    // 2
    var migrationMappingModel: NSMappingModel
    if let mappingModel = mappingModel {
      migrationMappingModel = mappingModel
    }
    else {
      migrationMappingModel = try! NSMappingModel.inferredMappingModel(forSourceModel: from, destinationModel: to)
    }
    let targetURL = storeURL.deletingLastPathComponent()
    let destinationName = storeURL.lastPathComponent + "~1"
    let destinationURL = targetURL.appendingPathComponent(destinationName)
    print("From Model: \(from.entityVersionHashesByName)")
    print("To Model: \(to.entityVersionHashesByName)")
    print("Migrating store \(storeURL) to \(destinationURL)")
    print("Mapping model: \(mappingModel!)")

    let success: Bool
    do {
      try migrationManager.migrateStore(from: storeURL, sourceType: NSSQLiteStoreType, options: nil, with: migrationMappingModel, toDestinationURL: destinationURL, destinationType: NSSQLiteStoreType, destinationOptions: nil)
      success = true
    }
    catch {
      success = false
      print("Migration failed: \(error)")
    }

    if success {
      print("Migration Completed Successfully")
      let fileManager = FileManager.default
      do {
        try fileManager.removeItem(at: storeURL)
        try fileManager.moveItem(at: destinationURL, to: storeURL)
      }
      catch {
        print("Error migrating \(error)")
      }
    }
  }
}

extension NSManagedObjectModel {
  private class func modelURLs(in modelFolder: String) -> [URL] {
    return Bundle.main.urls(forResourcesWithExtension: "mom", subdirectory: "\(modelFolder).momd") ?? []
  }

  class func modelVersionsFor(modelNamed modelName: String) -> [NSManagedObjectModel] {
    return modelURLs(in: modelName).flatMap(NSManagedObjectModel.init)
  }

  class func uncloudNotesModel(named modelName: String) -> NSManagedObjectModel {
    let model = modelURLs(in: modelName)
      .filter { $0.lastPathComponent == "\(modelName).mom"}
      .first
      .flatMap(NSManagedObjectModel.init)
    return model ?? NSManagedObjectModel()
  }

  class var version1: NSManagedObjectModel {
    return uncloudNotesModel(named: "UnCloudNotesDataModel")
  }



  var isVersion1: Bool {
    return self == type(of: self).version1
  }

  class var version2: NSManagedObjectModel {
    return uncloudNotesModel(named: "UnCloudNotesDataModel 2")
  }

  var isVersion2: Bool {
    return self == type(of: self).version2
  }

  class var version3: NSManagedObjectModel {
    return uncloudNotesModel(named: "UnCloudNotesDataModel 3")
  }

  var isVersion3: Bool {
    return self == type(of: self).version3
  }

  class var version4: NSManagedObjectModel {
    return uncloudNotesModel(named: "UnCloudNotesDataModel 4")
  }

  var isVersion4: Bool {
    return self == type(of: self).version4
  }

  class func model(named modelName: String, in bundle: Bundle = .main) -> NSManagedObjectModel {
    return bundle.url(forResource: modelName, withExtension: "momd").flatMap(NSManagedObjectModel.init) ?? NSManagedObjectModel()
  }
}

func ==(lhs: NSManagedObjectModel, rhs: NSManagedObjectModel) -> Bool {
  return lhs.entitiesByName == rhs.entitiesByName
}
