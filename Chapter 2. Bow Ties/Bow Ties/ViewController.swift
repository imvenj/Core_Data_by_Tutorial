/*
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import CoreData

class ViewController: UIViewController {

  // MARK: - IBOutlets
  @IBOutlet weak var segmentedControl: UISegmentedControl!
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var ratingLabel: UILabel!
  @IBOutlet weak var timesWornLabel: UILabel!
  @IBOutlet weak var lastWornLabel: UILabel!
  @IBOutlet weak var favoriteLabel: UILabel!

  let managedContext = AppDelegate.shared.persistentContainer.viewContext

  var currentBowtie: Bowtie?

  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    insertSampleData()
    populateUI(forSelectedIndex: 0)
  }

  // MARK: - IBActions
  @IBAction func segmentedControl(_ sender: Any?) {
    populateUI(forSelectedIndex: segmentedControl.selectedSegmentIndex)
  }

  @IBAction func wear(_ sender: Any?) {
    guard let currentBowtie = currentBowtie else { return }
    let times = currentBowtie.timesWorn
    currentBowtie.timesWorn = times + 1
    currentBowtie.lastWorn = Date()
    do {
      try managedContext.save()
      populate(bowtie: currentBowtie)
    } catch let error {
      print("Error saving data: \(error.localizedDescription)")
    }
  }
  
  @IBAction func rate(_ sender: Any?) {
    let message = sender == nil ? "Rate value should between 0 and 5.\nRate this bowtie." : "Rate this bowtie."
    let alert = UIAlertController(title: "New rating", message: message, preferredStyle: .alert)
    alert.addTextField { (tf) in
      tf.keyboardType = .numberPad
    }
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] (action) in
      guard let `self` = self else { return }
      guard let textField = alert.textFields?.first else { return }
      self.update(rating: textField.text)
    }
    alert.addAction(saveAction)
    alert.addAction(cancelAction)
    present(alert, animated: true, completion: nil)
  }

  // MARK: - Helpers
  func populate(bowtie: Bowtie) {
    guard let imageData = bowtie.photoData,
      let lastWorn = bowtie.lastWorn,
      let tintColor = bowtie.tintColor as? UIColor else {
        return
    }

    imageView.image = UIImage(data: imageData)
    nameLabel.text = bowtie.name
    ratingLabel.text = "Rating: \(bowtie.rating)/5"
    timesWornLabel.text = "# of times worn: \(bowtie.timesWorn)"

    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .short
    dateFormatter.timeStyle = .none

    lastWornLabel.text = dateFormatter.string(from: lastWorn)
    favoriteLabel.isEnabled = !bowtie.isFavorite
    view.tintColor = tintColor
  }

  func insertSampleData() {
    let fetch = NSFetchRequest<Bowtie>(entityName: "Bowtie")
    fetch.predicate = NSPredicate(format: "searchKey != nil")
    let count = try! managedContext.count(for: fetch)
    if count > 0 {
      return
    }

    let path = Bundle.main.path(forResource: "SampleData", ofType: "plist")
    let dataArray = NSArray(contentsOfFile: path!)!
    dataArray.forEach { dict in
      let entity = NSEntityDescription.entity(forEntityName: "Bowtie", in: managedContext)!
      let bowtie = Bowtie(entity: entity, insertInto: managedContext)
      let bowtieDict = dict as! [String: AnyObject]
      bowtie.name = bowtieDict["name"] as? String
      bowtie.searchKey = bowtieDict["searchKey"] as? String
      bowtie.rating = bowtieDict["rating"] as! Double
      let colorDict = bowtieDict["tintColor"] as! [String: NSNumber]
      bowtie.tintColor = UIColor.color(dict: colorDict)

      let imageName = bowtieDict["imageName"] as! String
      let image = UIImage(named: imageName)!
      let photoData = UIImagePNGRepresentation(image)
      bowtie.photoData = photoData!
      bowtie.lastWorn = bowtieDict["lastWorn"] as? Date
      let timesWorn = bowtieDict["timesWorn"] as! NSNumber
      bowtie.timesWorn = timesWorn.int32Value
      bowtie.isFavorite = bowtieDict["isFavorite"] as! Bool
    }
    AppDelegate.shared.saveContext()
  }

  func update(rating: String?) {
    guard let rating = rating, let rateValue = Double(rating), let currentBowtie = currentBowtie else {
      return
    }
    currentBowtie.rating = rateValue
    do {
      try managedContext.save()
      populate(bowtie: currentBowtie)
    } catch let error as NSError {
      //print("Error saving rating: \(error.localizedDescription)")
      if error.domain == NSCocoaErrorDomain && (error.code == NSValidationNumberTooLargeError || error.code == NSValidationNumberTooSmallError) {
        rate(nil)
      }
      else {
        print("Error saving rating: \(error), user info: \(error.userInfo)")
      }
    }
  }

  func populateUI(forSelectedIndex index: Int) {
    if index >= segmentedControl.numberOfSegments { return }
    let request = NSFetchRequest<Bowtie>(entityName: "Bowtie")
    let firstTitle = segmentedControl.titleForSegment(at: index)!
    request.predicate = NSPredicate(format: "searchKey == %@", firstTitle)

    do {
      let results = try managedContext.fetch(request)
      currentBowtie = results.first!
      populate(bowtie: results.first!)
    } catch let error {
      print("Error fetch data: \(error.localizedDescription)")
    }
  }
}

extension UIColor {
  class func color(dict: [String: NSNumber]) -> UIColor {
    let r = CGFloat(dict["red"]!.doubleValue)
    let g = CGFloat(dict["green"]!.doubleValue)
    let b = CGFloat(dict["blue"]!.doubleValue)
    return UIColor(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: 1.0)
  }
}
