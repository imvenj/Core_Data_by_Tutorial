//
//  Attachment.swift
//  UnCloudNotes
//
//  Created by venj on 12/19/17.
//  Copyright © 2017 Ray Wenderlich. All rights reserved.
//

import UIKit
import CoreData

class Attachment : NSManagedObject {
  @NSManaged var dateCreated: Date
  @NSManaged var note: Note?
}
