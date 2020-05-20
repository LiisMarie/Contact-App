//
//  ViewController.swift
//  CoreDataDemo
//
//  Created by Liis on 11.05.2020.
//  Copyright © 2020 Liis. All rights reserved.
//

import UIKit
import CoreData

class PersonViewController: UIViewController {
    
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
        
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
        
        let request = NSFetchRequest<Person>(entityName: String(describing: Person.self))
        request.sortDescriptors = [NSSortDescriptor(key: "firstName", ascending: true)]
        fetchController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: container.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchController!.delegate = self
        
        try? fetchController!.performFetch()
        
        initContactTypes()
        
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

extension PersonViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.fetchController?.fetchedObjects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "PersonTableViewCell", for: indexPath) as! PersonTableViewCell
        guard let person = self.fetchController?.object(at: indexPath) else {
            return cell
        }
        
        cell.selectionStyle = .none
        cell.name?.text = "\(person.firstName!) \(person.lastName!)"
        
        do {
            let contacts = try contactRepo.all()
            var personContacts =  [Contact]()
            for contact in contacts {
                if contact.person == person {
                    personContacts.append(contact)
                }
            }
            if (personContacts.count == 0) {
                cell.contactsCount?.text = "0 contacts"
            } else if (personContacts.count == 1) {
                cell.contactsCount?.text = "\(personContacts[0].value!)"
            } else {
                cell.contactsCount?.text = "\(personContacts.count) contacts"
            }
        } catch {
            cell.contactsCount?.text = "0 contacts"
        }
        
        return cell
    }
    
}

extension PersonViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            
            guard let person = self.fetchController?.object(at: indexPath) else {return}
            
            let alertController = UIAlertController(title: "Delete person", message: "Are you sure about deleting \(person.firstName!) \(person.lastName!)?", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            alertController.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: {
                (_: UIAlertAction!) in
                try? self.personRepo.delete(person: person)
            }))
            
            self.present(alertController, animated: true, completion: nil)
            
        }
    }
    
    internal func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let edit = UIContextualAction(style: .normal, title: "Edit") {
            (contextualAction, view, actionPerformed: (Bool) -> ()) in
            print("Edit clicked")
            
            guard let person = self.fetchController?.object(at: indexPath) else {return}
            let alertController = UIAlertController(title: "Edit person", message: "", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alertController.addAction(UIAlertAction(title: "Save changes", style: .default, handler: {_ in
                let firstName = alertController.textFields?[0].text
                let lastName = alertController.textFields?[1].text
                
                person.firstName = firstName
                person.lastName = lastName
                try? self.personRepo.update(person: person)
                
            }))
            alertController.addTextField { textField in
                textField.text = "\(person.firstName!)"
            }
            alertController.addTextField { textField in
                textField.text = "\(person.lastName!)"
            }
            
            self.present(alertController, animated: true, completion: nil)
        }
        return UISwipeActionsConfiguration(actions: [edit])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /*
        let vc = storyboard?.instantiateViewController(withIdentifier: "ContactViewController") as? ContactViewController
        let person = (self.fetchController?.object(at: indexPath))
        if (person != nil) {
            vc?.person = person!
            vc?.contactType = nil
        }
        self.navigationController?.pushViewController(vc!, animated: true)*/
        //performSegue(withIdentifier: "FromPersonsToContacts", sender: tableView)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ContactViewController") as! ContactViewController
        let person = (self.fetchController?.object(at: indexPath))
        if (person != nil) {
            viewController.person = person!
            viewController.contactType = nil
        }
        present(viewController, animated: true, completion: nil)
    }
}

extension PersonViewController: NSFetchedResultsControllerDelegate {
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
