//
//  ImageAttachment.swift
//  UnCloudNotes
//
//  Created by venj on 12/19/17.
//  Copyright © 2017 Ray Wenderlich. All rights reserved.
//

import UIKit
import CoreData

class ImageAttachment: Attachment {
  @NSManaged var caption: String
  @NSManaged var width: Float
  @NSManaged var height: Float
  @NSManaged var image: UIImage?
}
