//
//  ContactViewController.swift
//  CoreDataDemo
//
//  Created by Liis on 12.05.2020.
//  Copyright © 2020 Liis. All rights reserved.
//

import UIKit
import CoreData

class ContactViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var container: NSPersistentContainer!
    
    var personRepo: PersonRepository!
    var contactRepo: ContactRepository!
    var contactTypeRepo: ContactTypeRepository!
    
    var fetchControllerPerson: NSFetchedResultsController<Person>?
    var fetchControllerContact: NSFetchedResultsController<Contact>?
    var fetchControllerContactType: NSFetchedResultsController<ContactType>?
    
    var person = Person()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        container = AppDelegate.persistentContainer
        
        self.title = "\(person.firstName!) \(person.lastName!)"
        
        personRepo = PersonRepository(container: container)
        contactRepo = ContactRepository(container: container)
        contactTypeRepo = ContactTypeRepository(container: container)
        
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ContactTableViewCell")
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
        
        /*let request = NSFetchRequest<Person>(entityName: String(describing: Person.self))
        request.sortDescriptors = [NSSortDescriptor(key: "firstName", ascending: true)]
        fetchController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: container.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchController!.delegate = self
        
        try? fetchController!.performFetch()*/
        
        let requestContact = NSFetchRequest<Contact>(entityName: String(describing: Contact.self))
        requestContact.sortDescriptors = [NSSortDescriptor(key: "value", ascending: true)]
        fetchControllerContact = NSFetchedResultsController(fetchRequest: requestContact, managedObjectContext: container.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchControllerContact!.delegate = self
        try? fetchControllerContact!.performFetch()
        
        let requestPerson = NSFetchRequest<Person>(entityName: String(describing: Person.self))
        requestPerson.sortDescriptors = [NSSortDescriptor(key: "firstName", ascending: true)]
        fetchControllerPerson = NSFetchedResultsController(fetchRequest: requestPerson, managedObjectContext: container.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchControllerPerson!.delegate = self
        try? fetchControllerPerson!.performFetch()
        
        let requestContactType = NSFetchRequest<ContactType>(entityName: String(describing: ContactType.self))
        requestContactType.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        fetchControllerContactType = NSFetchedResultsController(fetchRequest: requestContactType, managedObjectContext: container.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchControllerContactType!.delegate = self
        try? fetchControllerContactType!.performFetch()
        

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
    
    /*
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
    }*/
    
    
    @IBAction func addContactTouchUpInside(_ sender: Any) {
        let alertController = UIAlertController(title: "Add contact for \(self.person.firstName!) \(self.person.lastName!)", message: "", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Add", style: .default, handler: {_ in
            /*
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
            }*/
        }))
        alertController.addTextField { textField in
            textField.placeholder = "Value"
        }
        alertController.addTextField { textField in
            textField.placeholder = "Last name"
        }
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func editContactTouchUpInside(_ sender: Any) {
        let alertController = UIAlertController(title: "Edit contact", message: "", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Save changes", style: .default, handler: {_ in
            let firstName = alertController.textFields?[0].text
            let lastName = alertController.textFields?[1].text
            
            self.person.firstName = firstName
            self.person.lastName = lastName
            try? self.personRepo.update(person: self.person)
            
        }))
        alertController.addTextField { textField in
            textField.text = "\(self.person.firstName!)"
        }
        alertController.addTextField { textField in
            textField.text = "\(self.person.lastName!)"
        }
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func deleteContactTouchUpInside(_ sender: Any) {
    }
    
}

extension ContactViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.fetchControllerContact?.fetchedObjects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "ContactTableViewCell", for: indexPath) as! ContactTableViewCell
        guard let contact = self.fetchControllerContact?.object(at: indexPath) else {
            return cell
        }
        
        
        cell.selectionStyle = .none
        cell.value?.text = "\(contact.value!)"
        // todo setting image too
        
        return cell
    }
    
    
}

extension ContactViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            guard let contact = self.fetchControllerContact?.object(at: indexPath) else {return}
            try? contactRepo.delete(contacts: contact)
        }
    }
}

extension ContactViewController: NSFetchedResultsControllerDelegate {
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
