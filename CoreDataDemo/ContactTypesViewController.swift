//
//  ContactTypesViewController.swift
//  CoreDataDemo
//
//  Created by Liis on 13.05.2020.
//  Copyright © 2020 Liis. All rights reserved.
//

import UIKit
import CoreData

// cell identifier ContactTypeCell

class ContactTypesViewController: UIViewController {
    
    var container: NSPersistentContainer!
    
    var personRepo: PersonRepository!
    var contactRepo: ContactRepository!
    var contactTypeRepo: ContactTypeRepository!
    
    @IBOutlet weak var tableView: UITableView!
    
    var fetchController: NSFetchedResultsController<ContactType>?
    
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
        
        let request = NSFetchRequest<ContactType>(entityName: String(describing: ContactType.self))
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        fetchController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: container.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchController!.delegate = self
        
        try? fetchController!.performFetch()
                
    }
}

extension ContactTypesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.fetchController?.fetchedObjects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "ContactTypeCell", for: indexPath) as! ContactTypeTableViewCell
        guard let contactType = self.fetchController?.object(at: indexPath) else {
            return cell
        }
        
        cell.selectionStyle = .none
        
        cell.contactType?.text = "\(contactType.name!)"
        cell.icon?.image = UIImage(named: (contactType.name!))

        /*
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
        }*/
        
        return cell
    }
    
}

extension ContactTypesViewController: UITableViewDelegate {
    /*
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
    }*/
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "ContactViewController") as? ContactViewController
        let contactType = (self.fetchController?.object(at: indexPath))
        if (contactType != nil) {
            vc?.contactType = contactType!
            vc?.person = nil
        }
        self.navigationController?.pushViewController(vc!, animated: true)
    }
}

extension ContactTypesViewController: NSFetchedResultsControllerDelegate {
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
