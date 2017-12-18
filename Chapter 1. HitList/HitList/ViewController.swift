//
//  ViewController.swift
//  HitList
//
//  Created by venj on 2017/12/17.
//  Copyright © 2017年 venj. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var people: [Person] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")

        let ad = UIApplication.shared.delegate as! AppDelegate
        let context = ad.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Person>(entityName: "Person")
        do {
            people = try context.fetch(fetchRequest)
        } catch let error {
            print(error.localizedDescription)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func addPerson(_ sender: Any) {
        let alert = UIAlertController(title: "Add Person", message: "Please input a name.", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Add a name"
        }
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] (action) in
            guard let `self` = self else { return }
            let name = alert.textFields?.first?.text ?? "Anonymous"
            self.save(name: name)
            let indexPath = IndexPath(row: self.people.count - 1, section: 0)
            self.tableView.insertRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }

    func save(name:String) {
        let ad = UIApplication.shared.delegate as! AppDelegate
        let context = ad.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Person", in: context)!
        let person = Person(entity: entity, insertInto: context)
        person.name = name
        people.append(person)
        ad.saveContext()
    }
}

extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return people.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        cell.textLabel?.text = people[indexPath.row].name
        return cell
    }

}

