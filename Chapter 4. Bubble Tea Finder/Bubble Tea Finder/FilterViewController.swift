/**
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

protocol FilterViewControllerDelegate: class {
  func filterViewController(filter: FilterViewController, didSelectPredicate predicate: NSPredicate?, sortDiscriptor: NSSortDescriptor?)
}

class FilterViewController: UITableViewController {

  @IBOutlet weak var firstPriceCategoryLabel: UILabel!
  @IBOutlet weak var secondPriceCategoryLabel: UILabel!
  @IBOutlet weak var thirdPriceCategoryLabel: UILabel!
  @IBOutlet weak var numDealsLabel: UILabel!

  // MARK: - Price section
  @IBOutlet weak var cheapVenueCell: UITableViewCell!
  @IBOutlet weak var moderateVenueCell: UITableViewCell!
  @IBOutlet weak var expensiveVenueCell: UITableViewCell!

  // MARK: - Most popular section
  @IBOutlet weak var offeringDealCell: UITableViewCell!
  @IBOutlet weak var walkingDistanceCell: UITableViewCell!
  @IBOutlet weak var userTipsCell: UITableViewCell!
  
  // MARK: - Sort section
  @IBOutlet weak var nameAZSortCell: UITableViewCell!
  @IBOutlet weak var nameZASortCell: UITableViewCell!
  @IBOutlet weak var distanceSortCell: UITableViewCell!
  @IBOutlet weak var priceSortCell: UITableViewCell!

  var coreDataStack: CoreDataStack = AppDelegate.shared.coreDataStack
  lazy var cheapVenuePredicate: NSPredicate = {
    let predicate = NSPredicate(format: "%K == %@", #keyPath(Venue.priceInfo.priceCategory), "$")
    return predicate
  }()

  lazy var moderateVenuePredicate: NSPredicate = {
    let predicate = NSPredicate(format: "%K == %@", #keyPath(Venue.priceInfo.priceCategory), "$$")
    return predicate
  }()

  lazy var expensiveVenuePredicate: NSPredicate = {
    let predicate = NSPredicate(format: "%K == %@", #keyPath(Venue.priceInfo.priceCategory), "$$$")
    return predicate
  }()

  lazy var offeringDealPredicate: NSPredicate = {
    let predicate = NSPredicate(format: "%K > 0", #keyPath(Venue.specialCount))
    return predicate
  }()
  lazy var walkingDistancePredicate: NSPredicate = {
    let predicate = NSPredicate(format: "%K < 500", #keyPath(Venue.location.distance))
    return predicate
  }()
  lazy var hasUserTipsPredicate: NSPredicate = {
    let predicate = NSPredicate(format: "%K > 0", #keyPath(Venue.stats.tipCount))
    return predicate
  }()

  lazy var nameSortDescriptor: NSSortDescriptor = {
    let compareSelector = #selector(NSString.localizedStandardCompare(_:))
    return NSSortDescriptor(key: #keyPath(Venue.name), ascending: true, selector: compareSelector)
  }()

  lazy var distanceSortDescriptor: NSSortDescriptor = {
    return NSSortDescriptor(keyPath: \Venue.location?.distance, ascending: true)
    //return NSSortDescriptor(key: #keyPath(Venue.location.distance), ascending: true)
  }()

  lazy var priceSortDescriptor: NSSortDescriptor = {
    return NSSortDescriptor(keyPath: \Venue.priceInfo?.priceCategory, ascending: true)
    //return NSSortDescriptor(key: #keyPath(Venue.priceInfo.priceCategory), ascending: true)
  }()

  weak var delegate: FilterViewControllerDelegate?
  var selectedSortDescriptor: NSSortDescriptor?
  var selectedPredicate: NSPredicate?


  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    populateCheapVenueCountLabel()
    populateModerateVenueCountLabel()
    populateExpensiveVenueCountLabel()
    populateDealsCountLabel()
  }
}

// MARK: - IBActions
extension FilterViewController {

  @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
    delegate?.filterViewController(filter: self, didSelectPredicate: selectedPredicate, sortDiscriptor: selectedSortDescriptor)
    dismiss(animated: true, completion: nil)
  }
}

// MARK - UITableViewDelegate
extension FilterViewController {

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let cell = tableView.cellForRow(at: indexPath) else { return }
    switch cell {
    case cheapVenueCell:
      selectedPredicate = cheapVenuePredicate
    case moderateVenueCell:
      selectedPredicate = moderateVenuePredicate
    case expensiveVenueCell:
      selectedPredicate = expensiveVenuePredicate
    case offeringDealCell:
      selectedPredicate = offeringDealPredicate
    case distanceSortCell:
      selectedPredicate = walkingDistancePredicate
    case userTipsCell:
      selectedPredicate = hasUserTipsPredicate
    case nameAZSortCell:
      selectedSortDescriptor = nameSortDescriptor
    case nameZASortCell:
      selectedSortDescriptor = nameSortDescriptor.reversedSortDescriptor as? NSSortDescriptor
    case distanceSortCell:
      selectedSortDescriptor = distanceSortDescriptor
    case priceSortCell:
      selectedSortDescriptor = priceSortDescriptor
    default:
      break
    }
    cell.accessoryType = .checkmark
  }
}

extension FilterViewController {
  func populateCheapVenueCountLabel() {
    let fetchRequest = NSFetchRequest<NSNumber>(entityName: "Venue")
    fetchRequest.resultType = .countResultType
    fetchRequest.predicate = cheapVenuePredicate

    do {
      let countResult = try coreDataStack.managedContext.fetch(fetchRequest)
      let count = countResult.first?.intValue ?? 0
      firstPriceCategoryLabel.text = "\(count) bubble tea places"
    } catch let error as NSError {
      print("Error fetch cheap venues count: \(error), \(error.userInfo)")
    }
  }

  func populateModerateVenueCountLabel() {
    let fetchRequest = NSFetchRequest<NSNumber>(entityName: "Venue")
    fetchRequest.resultType = .countResultType
    fetchRequest.predicate = moderateVenuePredicate

    do {
      let countResult = try coreDataStack.managedContext.fetch(fetchRequest)
      let count = countResult.first?.intValue ?? 0
      secondPriceCategoryLabel.text = "\(count) bubble tea places"
    } catch let error as NSError {
      print("Error fetch moderate venues count: \(error), \(error.userInfo)")
    }
  }

  func populateExpensiveVenueCountLabel() {
    let fetchRequest: NSFetchRequest<Venue> = Venue.fetchRequest()
    fetchRequest.predicate = expensiveVenuePredicate

    do {
      let count = try coreDataStack.managedContext.count(for: fetchRequest)
      thirdPriceCategoryLabel.text = "\(count) bubble tea places"
    } catch let error as NSError {
      print("Error fetch expensive venues count: \(error), \(error.userInfo)")
    }
  }

  func populateDealsCountLabel() {
    let fetchRequest = NSFetchRequest<NSDictionary>(entityName: "Venue")
    fetchRequest.resultType = .dictionaryResultType

    let sumExpressionDesc = NSExpressionDescription()
    sumExpressionDesc.name = "sumDeals"

    let specialCountExpression = NSExpression(forKeyPath: \Venue.specialCount)
    sumExpressionDesc.expression = NSExpression(forFunction: "sum:", arguments: [specialCountExpression])
    //sumExpressionDesc.expression = specialCountExpression // Wrong
    sumExpressionDesc.expressionResultType = .integer32AttributeType

    fetchRequest.propertiesToFetch = [sumExpressionDesc]

    do {
      let results = try coreDataStack.managedContext.fetch(fetchRequest)
      let resultDict = results.first!
      let numberOfDeals = resultDict["sumDeals"] ?? 0
      numDealsLabel.text = "\(numberOfDeals) total deals"
      print("\(resultDict)")
    } catch let error as NSError {
      print("Error fetch deals count: \(error), \(error.userInfo)")
    }
  }
}
