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

class ViewController: UIViewController {

  // MARK: - Properties
  lazy var dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
  }()
  var managedContext: NSManagedObjectContext = AppDelegate.shared.coreDataStack.managedContext
  var currentDog: Dog?


  // MARK: - IBOutlets
  @IBOutlet var tableView: UITableView!

  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()

    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")

    let dogName = "Fido"
    let fetch: NSFetchRequest<Dog> = Dog.fetchRequest()
    //fetch.predicate = NSPredicate(format: "name == %@", dogName)
    fetch.predicate = NSPredicate(format: "%K == %@", #keyPath(Dog.name), dogName)
    do {
      let results = try managedContext.fetch(fetch)
      if results.count > 0 {
        currentDog = results.first
      }
      else {
        let entity = NSEntityDescription.entity(forEntityName: "Dog", in: managedContext)!
        currentDog = Dog(entity: entity, insertInto: managedContext)
        currentDog?.name = dogName
        try managedContext.save()
      }
    } catch let error as NSError {
      print("Error load or create dog: \(error), \(error.userInfo)")
    }
  }
}

// MARK: - IBActions
extension ViewController {

  @IBAction func add(_ sender: UIBarButtonItem) {
    let entity = NSEntityDescription.entity(forEntityName: "Walk", in: managedContext)!
    let walk = Walk(entity: entity, insertInto: managedContext)
    walk.date = Date()

    guard let currentDog = currentDog else { return }
    let indexPath = IndexPath(row: currentDog.walks?.count ?? 0, section: 0)

    currentDog.addToWalks(walk)

    do {
      try managedContext.save()
      tableView.insertRows(at: [indexPath], with: .automatic)
    } catch let error as NSError {
      currentDog.removeFromWalks(walk)
      print("Error save dog walks: \(error), \(error.userInfo)")
    }
  }
}

// MARK: UITableViewDataSource
extension ViewController: UITableViewDataSource {

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let walks = currentDog?.walks else { return 1 }
    return walks.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    guard let walk = currentDog?.walks?[indexPath.row] as? Walk, let walkDate = walk.date else { return cell }
    cell.textLabel?.text = dateFormatter.string(from: walkDate)
    return cell
  }

  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return "List of Walks"
  }

  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }

  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      guard let currentDog = currentDog, let walkToRemove = currentDog.walks?[indexPath.row] as? Walk else { return }

      //managedContext.delete(walkToRemove)
      currentDog.removeFromWalks(walkToRemove) // Also do the trick.

      do {
        try managedContext.save()
        tableView.deleteRows(at: [indexPath], with: .automatic)
      }
      catch let error as NSError {
        print("Error delete dog walk: \(error), \(error.userInfo)")
      }
    }
  }

}
