//
//  ViewController.swift
//  CoreDataDemo
//
//  Created by Liis on 11.05.2020.
//  Copyright © 2020 Liis. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    var container: NSPersistentContainer!
    
    var personRepo: PersonRepository!
    var contactRepo: ContactRepository!
    var contactTypeRepo: ContactTypeRepository!
    
    @IBOutlet weak var tableView: UITableView!
    
    var fetchController: NSFetchedResultsController<Person>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        container = AppDelegate.persistentContainer
        
        personRepo = PersonRepository(container: container)
        contactRepo = ContactRepository(container: container)
        contactTypeRepo = ContactTypeRepository(container: container)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
        
        let request = NSFetchRequest<Person>(entityName: String(describing: Person.self))
        request.sortDescriptors = [NSSortDescriptor(key: "firstName", ascending: true)]
        fetchController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: container.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchController!.delegate = self
        
        try? fetchController!.performFetch()
        
        initContactTypes()
        /*
        do {
            /*let newPerson = Person(context: self.personRepo.context)
            newPerson.firstName = "Andres"
            newPerson.lastName = "Käver"
            try personRepo.insert(person: newPerson)*/
            
            let result = try personRepo.all()
            for person in result {
                print(person.firstName!)
                print(person.lastName!)
            }
        } catch {
            print("Failed!")
        }*/
    }
    
    func initContactTypes() {
        do {
            let result = try contactTypeRepo.all()
            if (result.count == 0) {
                print("initContactTypes")
                let types = ["Phone", "Email", "Address", "Website"]
                for type in types {
                    print(type)
                    let newContactType = ContactType(context: self.contactTypeRepo.context)
                    newContactType.name = type
                    try contactTypeRepo.insert(contactType: newContactType)
                }
            } else {
                print(result)
            }
        } catch {
            print("Failed to initContactTypes()!")
        }
    }
    
    @IBAction func addPersonTouchUpInside(_ sender: Any) {
        let alertController = UIAlertController(title: "New user", message: "", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Add", style: .default, handler: {_ in
            let person = Person(context: self.personRepo.context)
            person.firstName = alertController.textFields?[0].text
            person.lastName = alertController.textFields?[1].text
            do {
                try person.validateForInsert()
                print("passed validation")
                try? self.personRepo.insert(person: person)
            } catch {
                let error = error as NSError
                print(error)
            }
        }))
        alertController.addTextField { textField in
            textField.placeholder = "First name"
        }
        alertController.addTextField { textField in
            textField.placeholder = "Last name"
        }
        
        self.present(alertController, animated: true, completion: nil)
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.fetchController?.fetchedObjects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "PersonTableViewCell", for: indexPath) as! PersonTableViewCell
        guard let person = self.fetchController?.object(at: indexPath) else {
            return cell
        }
        
        cell.selectionStyle = .none
        //cell.textLabel?.text = "\(person.firstName!) \(person.lastName!)"
        cell.name?.text = "\(person.firstName!) \(person.lastName!)"
        cell.contactsCount?.text = "0"
        
        return cell
    }
    
    
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            guard let person = self.fetchController?.object(at: indexPath) else {return}
            try? personRepo.delete(person: person)
        }
    }
}

extension ViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            self.tableView.deleteRows(at: [indexPath!], with: .automatic)
        case .insert:
            self.tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .update:
            self.tableView.reloadRows(at: [indexPath!], with: .automatic)
        case .move:
            self.tableView.reloadData()
        @unknown default:
            fatalError("unknown")
        }
    }
}
